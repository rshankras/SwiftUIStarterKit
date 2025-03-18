import SwiftUI
import SwiftData

struct ChatDetailView: View {
    let pdfFileName: String
    @Environment(\.modelContext) private var modelContext
    @Query private var messages: [Message]
    @Environment(\.dismiss) private var dismiss
    
    init(pdfFileName: String) {
        self.pdfFileName = pdfFileName
        // Create a predicate to filter messages for this PDF
        let predicate = #Predicate<Message> { $0.pdfFileName == pdfFileName }
        // Sort by timestamp to show messages in chronological order
        let sortDescriptor = SortDescriptor(\Message.timestamp)
        
        // Apply the query configuration
        _messages = Query(filter: predicate, sort: [sortDescriptor])
    }
    
    var body: some View {
        VStack {
            // PDF file name header
            Text(pdfFileName)
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
            
            // Messages
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(messages) { message in
                        MessageView(message: message)
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Chat History")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // Delete all messages for this PDF
                    for message in messages {
                        modelContext.delete(message)
                    }
                    try? modelContext.save()
                    dismiss()
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
    }
} 