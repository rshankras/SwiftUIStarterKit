import Foundation

protocol EmbeddingServiceProtocol {
    var embeddingModel: String { get set }
    
    func generateEmbedding(for text: String) async throws -> [Float]
    func cosineSimilarity(a: [Float], b: [Float]) -> Float
} 