//
//  AboutView.swift
//  MacOSBackroundImage
//
//  Created by Ravi Shankar on 18/03/25.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "app.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("My Application")
                .font(.title)
            
            Text("Version 1.0.0")
                .foregroundColor(.gray)
            
            Divider()
            
            Text("This application demonstrates how to create a macOS app with a custom background image and navigation interface. Features include sidebar navigation, tabbed main content, and a bottom navigation bar.")
                .multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: 500)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Developed by: Your Name")
                Text("© 2023 Your Company")
                Text("License: MIT")
            }
            .padding()
            
            Spacer()
            
            HStack(spacing: 20) {
                LinkButton(title: "Website", icon: "globe")
                LinkButton(title: "Privacy Policy", icon: "lock.shield")
                LinkButton(title: "Terms of Service", icon: "doc.text")
            }
        }
    }
}

#Preview {
    AboutView()
        .frame(width: 500, height: 400)
        .background(Color.black.opacity(0.1))
        .padding()
} 