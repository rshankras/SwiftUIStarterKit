import Foundation
import PDFKit
import Combine

class PDFManager: ObservableObject {
    // PDF state
    @Published var selectedPDF: PDFDocument?
    @Published var pdfURL: URL?
    @Published var pdfText: String = ""
    @Published var textChunks: [TextChunk] = []
    @Published var isProcessing: Bool = false
    @Published var processingProgress: Double = 0
    @Published var errorMessage: String?
    
    // Embedding state (forwarded from EmbeddingManager)
    @Published var embeddingStatus: String = "Not started"
    @Published var embeddingsGenerated: Int = 0
    @Published var totalChunksToEmbed: Int = 0
    
    // Dependencies
    private let pdfLoader: PDFLoader
    private let textExtractor: PDFTextExtractor
    private let chunkManager: TextChunkManager
    private let embeddingManager: EmbeddingManager
    var embeddingService: EmbeddingServiceProtocol?
    
    // Configuration
    var apiKey: String = ""
    
    // Cancellables
    private var cancellables = Set<AnyCancellable>()
    
    init(
        pdfLoader: PDFLoader = PDFLoader(),
        textExtractor: PDFTextExtractor = PDFTextExtractor(),
        chunkManager: TextChunkManager = TextChunkManager(),
        embeddingManager: EmbeddingManager = EmbeddingManager()
    ) {
        self.pdfLoader = pdfLoader
        self.textExtractor = textExtractor
        self.chunkManager = chunkManager
        self.embeddingManager = embeddingManager
        
        // Forward embedding manager's published properties
        embeddingManager.$embeddingStatus
            .assign(to: &$embeddingStatus)
        
        embeddingManager.$embeddingsGenerated
            .assign(to: &$embeddingsGenerated)
        
        embeddingManager.$totalChunksToEmbed
            .assign(to: &$totalChunksToEmbed)
    }
    
    func loadPDF(from url: URL) {
        if let document = pdfLoader.loadPDF(from: url) {
            selectedPDF = document
            pdfURL = url
            extractTextFromPDF()
            
            // Notify that a PDF was loaded
            NotificationCenter.default.post(name: Notification.Name("PDFDocumentLoaded"), object: nil)
        } else {
            errorMessage = "Failed to load PDF document"
        }
    }
    
    func findAndLoadPDF(withName fileName: String) -> Bool {
        if let fileURL = pdfLoader.findAndLoadPDF(withName: fileName) {
            loadPDF(from: fileURL)
            return true
        }
        return false
    }
    
    func extractTextFromPDF() {
        guard let document = selectedPDF else {
            errorMessage = "No PDF document selected"
            return
        }
        
        isProcessing = true
        processingProgress = 0
        errorMessage = nil
        
        Task {
            let extractedText = await textExtractor.extractText(from: document, progressHandler: { [weak self] progress in
                // Update the progress on the main thread
                Task { @MainActor in
                    self?.processingProgress = progress
                }
            })
            
            if extractedText.isEmpty {
                await MainActor.run {
                    self.errorMessage = "Could not extract text from this PDF. It may be scanned or image-based."
                    self.isProcessing = false
                }
                return
            }
            
            await MainActor.run {
                self.pdfText = extractedText
                self.createTextChunks(from: extractedText)
            }
        }
    }
    
    func createTextChunks(from text: String) {
        textChunks.removeAll()
        
        // Move chunking to a background task
        Task {
            let chunks = chunkManager.createChunks(from: text)
            
            // Update on main thread
            await MainActor.run {
                self.textChunks = chunks
                
                // Mark processing as complete
                self.isProcessing = false
                self.processingProgress = 1.0
                
                // Trigger embedding generation in background if API key is available
                if let embeddingService = self.embeddingService, !self.apiKey.isEmpty {
                    Task {
                        await self.generateEmbeddings(with: embeddingService)
                    }
                }
            }
        }
    }
    
    func generateEmbeddings(with service: EmbeddingServiceProtocol) async {
        let updatedChunks = await embeddingManager.generateEmbeddings(for: textChunks, using: service)
        
        await MainActor.run {
            self.textChunks = updatedChunks
        }
    }
    
    func findRelevantChunks(for query: String, embeddingService: EmbeddingServiceProtocol, topK: Int = 3) async -> [String] {
        return await embeddingManager.findRelevantChunks(for: query, in: textChunks, using: embeddingService, topK: topK)
    }
} 