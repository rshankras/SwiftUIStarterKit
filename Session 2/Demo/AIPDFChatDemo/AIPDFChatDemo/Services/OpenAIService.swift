import Foundation
import SwiftUI

class OpenAIService: ObservableObject, AICompletionServiceProtocol {
    @AppStorage("openai_api_key") private var apiKey: String = ""
    @AppStorage("openai_model") private var selectedModel: String = "gpt-4o"
    
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    init() {
        // No need to set the apiKey here as it comes from @AppStorage
    }
    
    @MainActor
    func generateResponse(messages: [Message], relevantChunks: [String], completion: @escaping (Result<String, Error>) -> Void) {
        guard !apiKey.isEmpty else {
            completion(.failure(NSError(domain: "OpenAIService", code: 401, userInfo: [NSLocalizedDescriptionKey: "API Key is missing"])))
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Combine relevant chunks
        let contextText = relevantChunks.joined(separator: "\n\n")
        
        // Prepare the system message with PDF context
        let systemMessage = """
        You are an AI assistant that helps answer questions about the provided PDF document.
        Use the following extracted text from the PDF to answer the user's question.
        If the answer cannot be found in the text, say "I couldn't find information about that in the PDF."
        
        PDF Content:
        \(contextText)
        """
        
        // Prepare the conversation history for the API request
        var apiMessages: [[String: Any]] = [
            ["role": "system", "content": systemMessage]
        ]
        
        // Add user messages and AI responses
        for message in messages {
            let role = message.sender == .user ? "user" : "assistant"
            apiMessages.append(["role": role, "content": message.content])
        }
        
        // Create the request body
        let requestBody: [String: Any] = [
            "model": selectedModel,
            "messages": apiMessages,
            "temperature": 0.7
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            completion(.failure(NSError(domain: "OpenAIService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to serialize request"])))
            isLoading = false
            return
        }
        
        // Create the request
        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        // Make the API call
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            defer {
                DispatchQueue.main.async {
                    self?.isLoading = false
                }
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    let error = NSError(domain: "OpenAIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                    self?.errorMessage = error.localizedDescription
                    completion(.failure(error))
                }
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    DispatchQueue.main.async {
                        completion(.success(content))
                    }
                } else {
                    throw NSError(domain: "OpenAIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"])
                }
            } catch {
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
} 
