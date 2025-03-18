import Foundation
import SwiftData

class ChatHistoryManager {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    init() throws {
        let schema = Schema([Message.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            modelContext = ModelContext(modelContainer)
        } catch {
            print("Error setting up SwiftData: \(error.localizedDescription)")
            throw error
        }
    }
    
    // Save a new message
    func saveMessage(_ message: Message) {
        modelContext.insert(message)
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving message: \(error.localizedDescription)")
        }
    }
    
    // Load messages for a specific PDF
    func loadMessages(forPDF pdfFileName: String?) -> [Message] {
        let descriptor = FetchDescriptor<Message>(
            predicate: pdfFileName != nil ? #Predicate<Message> { $0.pdfFileName == pdfFileName } : nil,
            sortBy: [SortDescriptor(\.timestamp)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching messages: \(error.localizedDescription)")
            return []
        }
    }
    
    // Delete all messages for a specific PDF
    func deleteMessages(forPDF pdfFileName: String?) {
        let descriptor = FetchDescriptor<Message>(
            predicate: pdfFileName != nil ? #Predicate<Message> { $0.pdfFileName == pdfFileName } : nil
        )
        
        do {
            let messages = try modelContext.fetch(descriptor)
            for message in messages {
                modelContext.delete(message)
            }
            try modelContext.save()
        } catch {
            print("Error deleting messages: \(error.localizedDescription)")
        }
    }
    
    // Delete all messages
    func deleteAllMessages() {
        let descriptor = FetchDescriptor<Message>()
        
        do {
            let messages = try modelContext.fetch(descriptor)
            for message in messages {
                modelContext.delete(message)
            }
            try modelContext.save()
        } catch {
            print("Error deleting all messages: \(error.localizedDescription)")
        }
    }
} 