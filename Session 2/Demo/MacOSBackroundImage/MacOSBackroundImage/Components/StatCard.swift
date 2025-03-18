//
//  StatCard.swift
//  MacOSBackroundImage
//
//  Created by Ravi Shankar on 18/03/25.
//

import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.system(size: 30))
                .padding(.bottom, 5)
            
            Text(value)
                .font(.title2)
                .bold()
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(width: 100, height: 100)
        .background(Color.black.opacity(0.15))
        .cornerRadius(10)
    }
}

#Preview {
    StatCard(title: "Projects", value: "12", icon: "folder")
} 