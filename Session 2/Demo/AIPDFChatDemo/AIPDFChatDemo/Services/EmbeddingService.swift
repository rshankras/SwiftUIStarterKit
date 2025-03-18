import Foundation
import SwiftUI

class EmbeddingService: EmbeddingServiceProtocol, ObservableObject {
    @AppStorage("openai_api_key") private var apiKey: String = ""
    @AppStorage("embedding_model") internal var embeddingModel: String = "text-embedding-3-small"
    
    private let baseURL = "https://api.openai.com/v1/embeddings"
    
    init() {
        // No need to set the apiKey here as it comes from @AppStorage
    }
    
    // Alternative parsing approach using Codable
    struct EmbeddingResponse: Codable {
        let data: [EmbeddingItem]
        let model: String
        let usage: Usage
    }

    struct EmbeddingItem: Codable {
        let embedding: [Float]
        let index: Int
        let object: String
    }

    struct Usage: Codable {
        let promptTokens: Int
        let totalTokens: Int
        
        enum CodingKeys: String, CodingKey {
            case promptTokens = "prompt_tokens"
            case totalTokens = "total_tokens"
        }
    }
    
    func generateEmbedding(for text: String) async throws -> [Float] {
        guard !text.isEmpty else {
            print("ERROR: Cannot generate embedding for empty text")
            throw NSError(domain: "EmbeddingService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Cannot generate embedding for empty text"])
        }
        
        guard !apiKey.isEmpty else {
            print("ERROR: API Key is missing")
            throw NSError(domain: "EmbeddingService", code: 401, userInfo: [NSLocalizedDescriptionKey: "API Key is missing"])
        }
        
        print("Generating embedding for text of length \(text.count) using model: \(embeddingModel)")
        
        // Prepare the request body
        let requestBody: [String: Any] = [
            "model": embeddingModel,
            "input": text
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            throw NSError(domain: "EmbeddingService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to serialize request"])
        }
        
        // Create the request
        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        // Make the API call
        let (data, response) = try await URLSession.shared.data(for: request)
        
        print("API Response Status: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
        
        // Print the raw response for debugging
        if let responseString = String(data: data, encoding: .utf8) {
            print("API Response Body: \(responseString)")
        }
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            if let responseString = String(data: data, encoding: .utf8) {
                print("API Error Response: \(responseString)")
            }
            throw NSError(domain: "EmbeddingService", code: (response as? HTTPURLResponse)?.statusCode ?? 500, 
                          userInfo: [NSLocalizedDescriptionKey: "API request failed with status: \((response as? HTTPURLResponse)?.statusCode ?? 0)"])
        }
        
        // Parse using Codable
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(EmbeddingResponse.self, from: data)
            if let firstEmbedding = response.data.first?.embedding {
                print("Successfully parsed embedding with \(firstEmbedding.count) dimensions using Codable")
                return firstEmbedding
            } else {
                throw NSError(domain: "EmbeddingService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No embedding found in response"])
            }
        } catch {
            print("Codable parsing error: \(error.localizedDescription)")
            
            // Fallback to manual JSON parsing
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let dataArray = json["data"] as? [[String: Any]],
               let firstItem = dataArray.first,
               let embeddingArray = firstItem["embedding"] as? [NSNumber] {
                
                let floatEmbedding = embeddingArray.map { $0.floatValue }
                print("Successfully parsed embedding with \(floatEmbedding.count) dimensions using fallback method")
                return floatEmbedding
            }
            
            throw error
        }
    }
    
    // Calculate cosine similarity between two embedding vectors
    func cosineSimilarity(a: [Float], b: [Float]) -> Float {
        guard a.count == b.count && !a.isEmpty else { return 0 }
        
        var dotProduct: Float = 0
        var magnitudeA: Float = 0
        var magnitudeB: Float = 0
        
        for i in 0..<a.count {
            dotProduct += a[i] * b[i]
            magnitudeA += a[i] * a[i]
            magnitudeB += b[i] * b[i]
        }
        
        magnitudeA = sqrt(magnitudeA)
        magnitudeB = sqrt(magnitudeB)
        
        guard magnitudeA > 0 && magnitudeB > 0 else { return 0 }
        
        return dotProduct / (magnitudeA * magnitudeB)
    }
} 
