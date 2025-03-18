import Foundation

class TextChunkManager {
    private let chunkSize: Int
    private let chunkOverlap: Int
    
    init(chunkSize: Int = 1000, chunkOverlap: Int = 200) {
        self.chunkSize = chunkSize
        self.chunkOverlap = chunkOverlap
    }
    
    func createChunks(from text: String) -> [TextChunk] {
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
        
        return chunks
    }
} 