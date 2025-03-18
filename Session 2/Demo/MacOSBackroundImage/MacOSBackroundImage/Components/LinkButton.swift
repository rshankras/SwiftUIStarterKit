//
//  LinkButton.swift
//  MacOSBackroundImage
//
//  Created by Ravi Shankar on 18/03/25.
//

import SwiftUI

struct LinkButton: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(title)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.15))
        .cornerRadius(8)
    }
}

#Preview {
    LinkButton(title: "Website", icon: "globe")
} 