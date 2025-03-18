import Foundation

struct TextChunk: Identifiable, Codable {
    var id = UUID()
    let content: String
    let embedding: [Float]?
    
    init(content: String, embedding: [Float]? = nil) {
        self.content = content
        self.embedding = embedding
    }
    
    // Add a convenience initializer that accepts Double array
    init(content: String, embeddingDouble: [Double]?) {
        self.content = content
        self.embedding = embeddingDouble?.map { Float($0) }
    }
} 
