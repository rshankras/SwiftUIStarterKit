//
//  MainContentView.swift
//  MacOSBackroundImage
//
//  Created by Ravi Shankar on 18/03/25.
//

import SwiftUI

struct MainContentView: View {
    let selectedItem: String?
    let selectedBottomOption: String
    
    var body: some View {
        VStack {
            // Title showing current context
            Text("\(selectedItem ?? "") - \(selectedBottomOption)")
                .font(.headline)
                .padding(.top)
            
            // Content area based on bottom option selected
            switch selectedBottomOption {
            case "Home":
                HomeView()
            case "Settings":
                SettingsView()
            case "Profile":
                ProfileView()
            case "Help":
                HelpView()
            case "About":
                AboutView()
            default:
                Text("Select an option")
            }
        }
        .padding()
        .background(Color.black.opacity(0.1))
        .cornerRadius(8)
        .padding()
    }
}

#Preview {
    MainContentView(selectedItem: "Sidebar Item 1", selectedBottomOption: "Home")
        .frame(width: 600, height: 400)
        .background(Color.gray.opacity(0.3))
} 