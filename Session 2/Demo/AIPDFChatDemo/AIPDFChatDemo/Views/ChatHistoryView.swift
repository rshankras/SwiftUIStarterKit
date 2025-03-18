import SwiftUI
import SwiftData

struct ChatHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var chatSessions: [Message]
    @Environment(\.dismiss) private var dismiss
    
    var onSelectPDF: (String) -> Void
    
    // Group messages by PDF file
    private var groupedSessions: [String?: [Message]] {
        Dictionary(grouping: chatSessions) { $0.pdfFileName }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(groupedSessions.keys.compactMap { $0 }).sorted(), id: \.self) { pdfName in
                    if let messages = groupedSessions[pdfName], !messages.isEmpty {
                        NavigationLink(destination: ChatDetailView(pdfFileName: pdfName)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(pdfName)
                                    .font(.headline)
                                
                                HStack {
                                    Text("\(messages.count) messages")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    // Show the date of the most recent message
                                    if let latestMessage = messages.max(by: { $0.timestamp < $1.timestamp }) {
                                        Text(formatDate(latestMessage.timestamp))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                // Preview of the last message
                                if let lastUserMessage = messages.filter({ $0.sender == .user })
                                    .sorted(by: { $0.timestamp > $1.timestamp })
                                    .first {
                                    Text("Q: \(lastUserMessage.content)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                                
                                if let lastAIMessage = messages.filter({ $0.sender == .ai })
                                    .sorted(by: { $0.timestamp > $1.timestamp })
                                    .first {
                                    Text("A: \(lastAIMessage.content)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                deletePDFSession(pdfName)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            
                            Button {
                                onSelectPDF(pdfName)
                                dismiss()
                            } label: {
                                Label("Open", systemImage: "doc.text")
                            }
                            .tint(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Chat History")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear All") {
                        deleteAllSessions()
                    }
                    .foregroundColor(.red)
                }
            }
            .overlay {
                if groupedSessions.isEmpty {
                    ContentUnavailableView(
                        "No Chat History",
                        systemImage: "bubble.left.and.bubble.right",
                        description: Text("Your conversations with PDFs will appear here")
                    )
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    private func deletePDFSession(_ pdfName: String) {
        if let messages = groupedSessions[pdfName] {
            for message in messages {
                modelContext.delete(message)
            }
            try? modelContext.save()
        }
    }
    
    private func deleteAllSessions() {
        for (_, messages) in groupedSessions {
            for message in messages {
                modelContext.delete(message)
            }
        }
        try? modelContext.save()
    }
} 
