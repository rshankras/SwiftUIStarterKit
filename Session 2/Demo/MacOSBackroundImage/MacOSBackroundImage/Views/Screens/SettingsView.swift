//
//  SettingsView.swift
//  MacOSBackroundImage
//
//  Created by Ravi Shankar on 18/03/25.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Settings")
                .font(.title)
            
            Group {
                ToggleSetting(title: "Enable Notifications", isOn: true)
                ToggleSetting(title: "Dark Mode", isOn: false)
                ToggleSetting(title: "Sync with Cloud", isOn: true)
                ToggleSetting(title: "Auto-update", isOn: true)
            }
            
            Divider()
            
            Text("Account Settings")
                .font(.headline)
            
            HStack {
                Text("Email:")
                    .bold()
                Text("user@example.com")
                Spacer()
                Text("Change")
                    .foregroundColor(.blue)
            }
            .padding(.vertical, 4)
            
            HStack {
                Text("Password:")
                    .bold()
                Text("••••••••")
                Spacer()
                Text("Reset")
                    .foregroundColor(.blue)
            }
            .padding(.vertical, 4)
            
            Spacer()
        }
    }
}

#Preview {
    SettingsView()
        .frame(width: 500, height: 400)
        .background(Color.black.opacity(0.1))
        .padding()
} 