import SwiftUI

struct MessageView: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.sender == .user {
                Spacer()
                Text(message.content)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .textSelection(.enabled)
            } else {
                Text(message.content)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .textSelection(.enabled)
                Spacer()
            }
        }
        .padding(.horizontal)
    }
} 