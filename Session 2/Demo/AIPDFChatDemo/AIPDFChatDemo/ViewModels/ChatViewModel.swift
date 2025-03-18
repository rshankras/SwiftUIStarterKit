import Foundation
import SwiftUI
import Combine

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var newMessageText: String = ""
    @Published var isProcessing: Bool = false
    
    // Debug properties
    @Published var lastQueryDebugInfo: String = ""
    
    private let openAIService: OpenAIService
    var pdfManager: PDFDocumentManager
    var embeddingService: EmbeddingService
    var messageRepository: MessageRepositoryProtocol?
    
    init(
        openAIService: OpenAIService,
        pdfManager: PDFDocumentManager,
        embeddingService: EmbeddingService,
        messageRepository: MessageRepositoryProtocol? = nil
    ) {
        self.openAIService = openAIService
        self.pdfManager = pdfManager
        self.embeddingService = embeddingService
        self.messageRepository = messageRepository
        
        // Load messages if a PDF is already selected
        loadChatHistory()
    }
    
    // Load chat history for the current PDF
    func loadChatHistory() {
        guard let messageRepository = messageRepository else { return }
        
        let pdfFileName = pdfManager.pdfURL?.lastPathComponent
        let savedMessages = messageRepository.loadMessages(forPDF: pdfFileName)
        
        DispatchQueue.main.async {
            self.messages = savedMessages
        }
    }
    
    @MainActor
    func sendMessage() {
        guard !newMessageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let pdfFileName = pdfManager.pdfURL?.lastPathComponent
        let userMessage = Message(content: newMessageText, sender: .user, pdfFileName: pdfFileName)
        messages.append(userMessage)
        
        // Save user message to history - add debug print
        if let messageRepository = messageRepository {
            messageRepository.saveMessage(userMessage)
            print("Saved user message to repository: \(userMessage.content)")
        } else {
            print("WARNING: Message repository is nil, can't save message")
        }
        
        let userInput = newMessageText
        newMessageText = ""
        
        isProcessing = true
        
        // Add debug info
        lastQueryDebugInfo = "Processing query: \(userInput)"
        
        Task {
            // Check embedding status
            lastQueryDebugInfo += "\nEmbedding status: \(pdfManager.embeddingStatus)"
            lastQueryDebugInfo += "\nEmbeddings generated: \(pdfManager.embeddingsGenerated)/\(pdfManager.totalChunksToEmbed)"
            
            // Find relevant chunks using embeddings
            let relevantChunks = await pdfManager.findRelevantChunks(
                for: userInput,
                embeddingService: embeddingService,
                topK: 5
            )
            
            // Add debug info about chunks
            await MainActor.run {
                lastQueryDebugInfo += "\nFound \(relevantChunks.count) relevant chunks"
                lastQueryDebugInfo += "\nChunk sizes: \(relevantChunks.map { $0.count })"
                
                // Preview of chunks (first 100 chars)
                for (i, chunk) in relevantChunks.enumerated() {
                    let preview = chunk.prefix(100) + (chunk.count > 100 ? "..." : "")
                    lastQueryDebugInfo += "\nChunk \(i+1) preview: \(preview)"
                }
            }
            
            // If no relevant chunks found, use the first few chunks as fallback
            var chunksToUse = relevantChunks
            if chunksToUse.isEmpty && !pdfManager.textChunks.isEmpty {
                print("WARNING: No relevant chunks found. Using first few chunks as fallback.")
                chunksToUse = Array(pdfManager.textChunks.prefix(3)).map { $0.content }
                
                await MainActor.run {
                    lastQueryDebugInfo += "\nNo relevant chunks found. Using first few chunks as fallback."
                }
            }
            
            // Generate response using only the relevant chunks
            openAIService.generateResponse(messages: messages, relevantChunks: chunksToUse) { [weak self] result in
                DispatchQueue.main.async {
                    self?.isProcessing = false
                    
                    switch result {
                    case .success(let response):
                        let aiMessage = Message(content: response, sender: .ai, pdfFileName: pdfFileName)
                        self?.messages.append(aiMessage)
                        
                        // Save AI message to history - add debug print
                        if let messageRepository = self?.messageRepository {
                            messageRepository.saveMessage(aiMessage)
                            print("Saved AI message to repository: \(aiMessage.content.prefix(50))...")
                        } else {
                            print("WARNING: Message repository is nil, can't save AI message")
                        }
                        
                        self?.lastQueryDebugInfo += "\nResponse generated successfully"
                        
                    case .failure(let error):
                        let errorMessage = Message(content: "Error: \(error.localizedDescription)", sender: .ai, pdfFileName: pdfFileName)
                        self?.messages.append(errorMessage)
                        
                        // Save error message to history
                        self?.messageRepository?.saveMessage(errorMessage)
                        
                        self?.lastQueryDebugInfo += "\nError generating response: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
    
    func clearChat() {
        messages.removeAll()
        
        // Clear chat history for current PDF
        if let messageRepository = messageRepository {
            let pdfFileName = pdfManager.pdfURL?.lastPathComponent
            messageRepository.deleteMessages(forPDF: pdfFileName)
        }
    }
} 
