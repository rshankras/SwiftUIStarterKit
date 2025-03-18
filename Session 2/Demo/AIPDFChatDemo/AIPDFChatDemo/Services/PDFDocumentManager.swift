import SwiftUI
import PDFKit
import UniformTypeIdentifiers

class PDFDocumentManager: ObservableObject {
    @Published var selectedPDF: PDFDocument?
    @Published var pdfURL: URL?
    @Published var pdfText: String = ""
    @Published var textChunks: [TextChunk] = []
    @Published var isProcessing: Bool = false
    @Published var processingProgress: Double = 0
    @Published var errorMessage: String?
    
    @Published var embeddingStatus: String = "Not started"
    @Published var embeddingsGenerated: Int = 0
    @Published var totalChunksToEmbed: Int = 0
    
    private let chunkSize = 1000 // Characters per chunk
    private let chunkOverlap = 200 // Characters of overlap between chunks
    
    var embeddingService: EmbeddingService?
    @AppStorage("openai_api_key") private var apiKey: String = ""
    
    func extractTextFromPDF() {
        guard let document = selectedPDF else {
            print("ERROR: No PDF document selected")
            errorMessage = "No PDF document selected"
            return
        }
        
        isProcessing = true
        processingProgress = 0
        errorMessage = nil
        
        print("Starting text extraction from PDF with \(document.pageCount) pages")
        
        Task {
            var extractedText = ""
            var pageTexts: [String] = []
            
            for pageIndex in 0..<document.pageCount {
                guard let page = document.page(at: pageIndex) else { 
                    print("WARNING: Could not access page \(pageIndex)")
                    continue 
                }
                
                if let pageText = page.string {
                    if pageText.isEmpty {
                        print("WARNING: Empty text on page \(pageIndex+1)")
                    } else {
                        print("Extracted \(pageText.count) characters from page \(pageIndex+1)")
                        pageTexts.append(pageText)
                    }
                    extractedText += pageText + "\n\n"
                } else {
                    print("ERROR: Failed to extract text from page \(pageIndex+1)")
                }
                
                // Update progress on main thread
                await MainActor.run {
                    self.processingProgress = Double(pageIndex + 1) / Double(document.pageCount) * 0.5
                }
            }
            
            print("Text extraction complete. Total characters: \(extractedText.count)")
            
            if extractedText.isEmpty {
                print("ERROR: No text extracted from PDF")
                await MainActor.run {
                    self.errorMessage = "Could not extract text from this PDF. It may be scanned or image-based."
                    self.isProcessing = false
                }
                return
            }
            
            await MainActor.run {
                self.pdfText = extractedText
                print("Creating text chunks...")
                self.createTextChunks(from: extractedText)
            }
        }
    }
    
    func createTextChunks(from text: String) {
        textChunks.removeAll()
        
        // Move chunking to a background task
        Task {
            // Split text into chunks with overlap
            var chunks: [TextChunk] = []
            var startIndex = text.startIndex
            
            while startIndex < text.endIndex {
                let endDistance = min(chunkSize, text.distance(from: startIndex, to: text.endIndex))
                let endIndex = text.index(startIndex, offsetBy: endDistance)
                
                let chunk = String(text[startIndex..<endIndex])
                chunks.append(TextChunk(content: chunk))
                
                // Move start index forward by chunkSize - chunkOverlap
                let nextStartDistance = max(0, chunkSize - chunkOverlap)
                if nextStartDistance == 0 { break } // Prevent infinite loop
                
                startIndex = text.index(startIndex, offsetBy: min(nextStartDistance, text.distance(from: startIndex, to: text.endIndex)))
            }
            
            print("Created \(chunks.count) text chunks")
            
            // Update on main thread
            await MainActor.run {
                self.textChunks = chunks
                
                // Important: Mark processing as complete even if we don't have embeddings yet
                // This allows the user to start chatting while embeddings are generated in background
                self.isProcessing = false
                self.processingProgress = 1.0
                
                // Trigger embedding generation in background if API key is available
                if let embeddingService = self.embeddingService, !self.apiKey.isEmpty {
                    Task {
                        await self.generateEmbeddings(with: embeddingService)
                    }
                } else {
                    print("WARNING: No embedding service or API key available. Embeddings will not be generated.")
                }
            }
        }
    }
    
    func generateEmbeddings(with embeddingService: EmbeddingServiceProtocol) async {
        guard !textChunks.isEmpty else { 
            print("ERROR: No text chunks to embed")
            await MainActor.run {
                self.embeddingStatus = "No chunks to embed"
            }
            return 
        }
        
        await MainActor.run {
            self.embeddingStatus = "Starting embedding generation"
            self.embeddingsGenerated = 0
            self.totalChunksToEmbed = self.textChunks.count
        }
        
        print("Starting embedding generation for \(textChunks.count) chunks")
        
        for (index, chunk) in textChunks.enumerated() {
            do {
                await MainActor.run {
                    self.embeddingStatus = "Generating embedding \(index+1)/\(self.textChunks.count)"
                }
                
                print("Generating embedding for chunk \(index+1)/\(textChunks.count)")
                let embedding = try await embeddingService.generateEmbedding(for: chunk.content)
                
                // Verify embedding was created successfully
                if embedding.isEmpty {
                    print("WARNING: Empty embedding returned for chunk \(index+1)")
                } else {
                    print("SUCCESS: Generated embedding with \(embedding.count) dimensions")
                }
                
                // Update the chunk with its embedding
                await MainActor.run {
                    var updatedChunks = self.textChunks
                    updatedChunks[index] = TextChunk(content: chunk.content, embedding: embedding)
                    self.textChunks = updatedChunks
                    self.embeddingsGenerated = index + 1
                }
            } catch {
                print("ERROR generating embedding for chunk \(index+1): \(error.localizedDescription)")
                await MainActor.run {
                    self.embeddingStatus = "Error embedding chunk \(index+1): \(error.localizedDescription)"
                }
            }
        }
        
        // Verify embeddings were created
        let embeddedCount = textChunks.filter { $0.embedding != nil }.count
        print("Embedding generation complete. \(embeddedCount)/\(textChunks.count) chunks have embeddings")
        
        await MainActor.run {
            self.embeddingStatus = "Completed: \(self.embeddingsGenerated)/\(self.totalChunksToEmbed) chunks embedded"
        }
    }
    
    func findRelevantChunks(for query: String, embeddingService: EmbeddingService, topK: Int = 3) async -> [String] {
        // Check if we have embeddings
        let hasEmbeddings = textChunks.contains { $0.embedding != nil }
        
        if !hasEmbeddings {
            print("DEBUG: No embeddings found in chunks. Using fallback method.")
            // Fallback to simple keyword matching if no embeddings
            return findRelevantChunksByKeywords(for: query, topK: topK)
        }
        
        do {
            print("DEBUG: Generating embedding for query: \(query)")
            let queryEmbedding = try await embeddingService.generateEmbedding(for: query)
            
            // Calculate similarity scores
            var chunksWithScores: [(chunk: TextChunk, score: Float)] = []
            
            for (index, chunk) in textChunks.enumerated() {
                if let embedding = chunk.embedding {
                    let similarity = embeddingService.cosineSimilarity(a: queryEmbedding, b: embedding)
                    chunksWithScores.append((chunk: chunk, score: similarity))
                    print("DEBUG: Chunk \(index) similarity: \(similarity)")
                }
            }
            
            // Sort by similarity score (descending)
            chunksWithScores.sort { $0.score > $1.score }
            
            // Take top K chunks
            let topChunks = chunksWithScores.prefix(topK).map { $0.chunk.content }
            print("DEBUG: Found \(topChunks.count) relevant chunks with scores: \(chunksWithScores.prefix(topK).map { $0.score })")
            return topChunks
            
        } catch {
            print("DEBUG: Error finding relevant chunks: \(error)")
            // Fallback to using the first few chunks if embedding fails
            return findRelevantChunksByKeywords(for: query, topK: topK)
        }
    }
    
    // Add a keyword-based fallback method
    func findRelevantChunksByKeywords(for query: String, topK: Int = 3) -> [String] {
        print("DEBUG: Using keyword matching fallback")
        
        // Extract keywords from the query (simple approach)
        let keywords = query.lowercased().split(separator: " ")
            .filter { $0.count > 3 } // Filter out short words
            .map { String($0) }
        
        print("DEBUG: Keywords extracted: \(keywords)")
        
        // If no meaningful keywords, return first few chunks
        if keywords.isEmpty {
            print("DEBUG: No meaningful keywords found, returning first \(min(topK, textChunks.count)) chunks")
            return Array(textChunks.prefix(min(topK, textChunks.count))).map { $0.content }
        }
        
        // Score chunks based on keyword matches
        var chunksWithScores: [(chunk: TextChunk, score: Int)] = []
        
        for (index, chunk) in textChunks.enumerated() {
            let content = chunk.content.lowercased()
            var score = 0
            
            for keyword in keywords {
                if content.contains(keyword) {
                    score += 1
                    print("DEBUG: Keyword '\(keyword)' found in chunk \(index)")
                }
            }
            
            chunksWithScores.append((chunk: chunk, score: score))
        }
        
        // Sort by score (descending)
        chunksWithScores.sort { $0.score > $1.score }
        
        // Take top K chunks or all non-zero scoring chunks if less than K
        let nonZeroChunks = chunksWithScores.filter { $0.score > 0 }
        
        if nonZeroChunks.isEmpty {
            print("DEBUG: No chunks matched any keywords, returning first \(min(topK, textChunks.count)) chunks")
            return Array(textChunks.prefix(min(topK, textChunks.count))).map { $0.content }
        }
        
        let resultChunks = Array(nonZeroChunks.prefix(topK))
        
        print("DEBUG: Found \(resultChunks.count) chunks by keywords with scores: \(resultChunks.map { $0.score })")
        
        return resultChunks.map { $0.chunk.content }
    }
    
    func loadPDF(from url: URL) {
        if let document = PDFDocument(url: url) {
            selectedPDF = document
            pdfURL = url
            extractTextFromPDF()
            
            // Notify that a PDF was loaded so chat history can be loaded
            NotificationCenter.default.post(name: Notification.Name("PDFDocumentLoaded"), object: nil)
            print("PDFDocumentManager: Posted PDFDocumentLoaded notification")
        } else {
            errorMessage = "Failed to load PDF document"
        }
    }
    
    // Helper method to find and load a PDF by filename
    func findAndLoadPDF(withName fileName: String) -> Bool {
        // Common directories to search for PDFs
        let directories = [
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
            FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first,
            FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first
        ].compactMap { $0 }
        
        // Search for the PDF in each directory
        for directory in directories {
            let fileURL = directory.appendingPathComponent(fileName)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                loadPDF(from: fileURL)
                return true
            }
        }
        
        // PDF not found
        return false
    }
} 
