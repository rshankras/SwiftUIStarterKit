import Foundation
import SwiftData

@Model
final class Message: Identifiable {
    @Attribute(.unique) var id: UUID
    var content: String
    var senderRaw: String
    var timestamp: Date
    var pdfFileName: String?
    
    var sender: MessageSender {
        get {
            return MessageSender(rawValue: senderRaw) ?? .user
        }
        set {
            senderRaw = newValue.rawValue
        }
    }
    
    init(id: UUID = UUID(), content: String, sender: MessageSender, timestamp: Date = Date(), pdfFileName: String? = nil) {
        self.id = id
        self.content = content
        self.senderRaw = sender.rawValue
        self.timestamp = timestamp
        self.pdfFileName = pdfFileName
    }
}

enum MessageSender: String, Codable {
    case user
    case ai
} 
