//
//  ProfileView.swift
//  MacOSBackroundImage
//
//  Created by Ravi Shankar on 18/03/25.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.white)
            
            Text("User Name")
                .font(.title)
            
            Text("user@example.com")
                .foregroundColor(.gray)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 15) {
                InfoRow(title: "Member Since", value: "January 2023")
                InfoRow(title: "Subscription", value: "Pro Plan")
                InfoRow(title: "Storage Used", value: "45.8 GB / 100 GB")
                InfoRow(title: "Last Login", value: "Today, 9:45 AM")
            }
            .padding()
            .background(Color.black.opacity(0.1))
            .cornerRadius(8)
            
            Spacer()
            
            Button(action: {}) {
                Text("Edit Profile")
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

#Preview {
    ProfileView()
        .frame(width: 500, height: 400)
        .background(Color.black.opacity(0.1))
        .padding()
} 