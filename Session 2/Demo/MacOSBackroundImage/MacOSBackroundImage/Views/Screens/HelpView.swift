//
//  HelpView.swift
//  MacOSBackroundImage
//
//  Created by Ravi Shankar on 18/03/25.
//

import SwiftUI

struct HelpView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Help & Support")
                .font(.title)
            
            Text("Frequently Asked Questions")
                .font(.headline)
            
            FAQItem(question: "How do I create a new project?", 
                   answer: "Navigate to the Projects tab and click on the '+' button in the top right corner.")
            
            FAQItem(question: "How can I change my password?", 
                   answer: "Go to Settings > Account Settings and click on 'Reset' next to Password.")
            
            FAQItem(question: "Is my data secure?", 
                   answer: "Yes, all your data is encrypted and stored securely on our servers.")
            
            Divider()
            
            Text("Need more help?")
                .font(.headline)
            
            HStack(spacing: 20) {
                SupportOption(title: "Contact Support", icon: "envelope")
                SupportOption(title: "Documentation", icon: "book")
                SupportOption(title: "Live Chat", icon: "message")
            }
            
            Spacer()
        }
    }
}

#Preview {
    HelpView()
        .frame(width: 500, height: 400)
        .background(Color.black.opacity(0.1))
        .padding()
} 