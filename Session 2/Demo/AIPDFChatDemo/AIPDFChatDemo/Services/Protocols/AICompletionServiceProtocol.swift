import Foundation

protocol AICompletionServiceProtocol {
    var isLoading: Bool { get }
    
    func generateResponse(messages: [Message], relevantChunks: [String], completion: @escaping (Result<String, Error>) -> Void)
} 