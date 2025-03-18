//
//  FAQItem.swift
//  MacOSBackroundImage
//
//  Created by Ravi Shankar on 18/03/25.
//

import SwiftUI

struct FAQItem: View {
    let question: String
    let answer: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(question)
                .font(.headline)
            Text(answer)
                .font(.body)
                .foregroundColor(.gray)
                .padding(.leading)
        }
        .padding(.vertical, 5)
    }
}

#Preview {
    FAQItem(
        question: "How do I create a new project?",
        answer: "Navigate to the Projects tab and click on the '+' button in the top right corner."
    )
    .padding()
} 