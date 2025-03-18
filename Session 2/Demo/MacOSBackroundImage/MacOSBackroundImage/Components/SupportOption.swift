//
//  SupportOption.swift
//  MacOSBackroundImage
//
//  Created by Ravi Shankar on 18/03/25.
//

import SwiftUI

struct SupportOption: View {
    let title: String
    let icon: String
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.system(size: 24))
            Text(title)
                .font(.caption)
        }
        .frame(width: 100, height: 70)
        .background(Color.black.opacity(0.15))
        .cornerRadius(8)
    }
}

#Preview {
    SupportOption(title: "Contact Support", icon: "envelope")
} 