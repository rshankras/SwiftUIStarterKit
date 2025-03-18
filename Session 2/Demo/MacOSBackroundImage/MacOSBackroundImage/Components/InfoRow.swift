//
//  InfoRow.swift
//  MacOSBackroundImage
//
//  Created by Ravi Shankar on 18/03/25.
//

import SwiftUI

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.callout)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.callout)
        }
    }
}

#Preview {
    InfoRow(title: "Member Since", value: "January 2023")
        .padding()
} 