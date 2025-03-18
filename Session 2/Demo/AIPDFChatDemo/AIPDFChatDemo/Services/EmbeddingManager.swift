import Foundation

class EmbeddingManager {
    @Published var embeddingStatus: String = "Not started"
    @Published var embeddingsGenerated: Int = 0
    @Published var totalChunksToEmbed: Int = 0
    
    func generateEmbeddings(for chunks: [TextChunk], using service: EmbeddingServiceProtocol) async -> [TextChunk] {
        guard !chunks.isEmpty else { 
            await updateStatus("No chunks to embed", generated: 0, total: 0)
            return chunks
        }
        
        await updateStatus("Starting embedding generation", generated: 0, total: chunks.count)
        
        var updatedChunks = chunks
        
        for (index, chunk) in chunks.enumerated() {
            do {
                await updateStatus("Generating embedding \(index+1)/\(chunks.count)", generated: index, total: chunks.count)
                
                let embedding = try await service.generateEmbedding(for: chunk.content)
                
                // Update the chunk with its embedding
                updatedChunks[index] = TextChunk(content: chunk.content, embedding: embedding)
                await updateEmbeddingsGenerated(index + 1)
            } catch {
                await updateStatus("Error embedding chunk \(index+1): \(error.localizedDescription)", generated: index, total: chunks.count)
            }
        }
        
        await updateStatus("Completed", generated: updatedChunks.filter { $0.embedding != nil }.count, total: chunks.count)
        
        return updatedChunks
    }
    
    @MainActor
    private func updateStatus(_ status: String, generated: Int, total: Int) {
        embeddingStatus = status
        embeddingsGenerated = generated
        totalChunksToEmbed = total
    }
    
    @MainActor
    private func updateEmbeddingsGenerated(_ count: Int) {
        embeddingsGenerated = count
    }
    
    func findRelevantChunks(for query: String, in chunks: [TextChunk], using service: EmbeddingServiceProtocol, topK: Int = 3) async -> [String] {
        // Check if we have embeddings
        let hasEmbeddings = chunks.contains { $0.embedding != nil }
        
        if !hasEmbeddings {
            // Fallback to simple keyword matching if no embeddings
            return findRelevantChunksByKeywords(for: query, in: chunks, topK: topK)
        }
        
        do {
            let queryEmbedding = try await service.generateEmbedding(for: query)
            
            // Calculate similarity scores
            var chunksWithScores: [(chunk: TextChunk, score: Float)] = []
            
            for chunk in chunks {
                if let embedding = chunk.embedding {
                    let similarity = service.cosineSimilarity(a: queryEmbedding, b: embedding)
                    chunksWithScores.append((chunk: chunk, score: similarity))
                }
            }
            
            // Sort by similarity score (descending)
            chunksWithScores.sort { $0.score > $1.score }
            
            // Take top K chunks
            let topChunks = chunksWithScores.prefix(topK).map { $0.chunk.content }
            return topChunks
            
        } catch {
            // Fallback to using the first few chunks if embedding fails
            return findRelevantChunksByKeywords(for: query, in: chunks, topK: topK)
        }
    }
    
    // Keyword-based fallback method
    func findRelevantChunksByKeywords(for query: String, in chunks: [TextChunk], topK: Int = 3) -> [String] {
        // Extract keywords from the query (simple approach)
        let keywords = query.lowercased().split(separator: " ")
            .filter { $0.count > 3 } // Filter out short words
            .map { String($0) }
        
        // If no meaningful keywords, return first few chunks
        if keywords.isEmpty {
            return Array(chunks.prefix(min(topK, chunks.count))).map { $0.content }
        }
        
        // Score chunks based on keyword matches
        var chunksWithScores: [(chunk: TextChunk, score: Int)] = []
        
        for chunk in chunks {
            let content = chunk.content.lowercased()
            var score = 0
            
            for keyword in keywords {
                if content.contains(keyword) {
                    score += 1
                }
            }
            
            chunksWithScores.append((chunk: chunk, score: score))
        }
        
        // Sort by score (descending)
        chunksWithScores.sort { $0.score > $1.score }
        
        // Take top K chunks or all non-zero scoring chunks if less than K
        let nonZeroChunks = chunksWithScores.filter { $0.score > 0 }
        
        if nonZeroChunks.isEmpty {
            return Array(chunks.prefix(min(topK, chunks.count))).map { $0.content }
        }
        
        let resultChunks = Array(nonZeroChunks.prefix(topK))
        
        return resultChunks.map { $0.chunk.content }
    }
} 