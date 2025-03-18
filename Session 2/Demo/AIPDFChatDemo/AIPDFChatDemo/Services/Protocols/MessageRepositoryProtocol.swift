import Foundation

protocol MessageRepositoryProtocol {
    func saveMessage(_ message: Message)
    func loadMessages(forPDF pdfFileName: String?) -> [Message]
    func deleteMessages(forPDF pdfFileName: String?)
    func deleteAllMessages()
} 