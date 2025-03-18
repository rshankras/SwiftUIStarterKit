//
//  ContentView.swift
//  MacOSBackroundImage
//
//  Created by Ravi Shankar on 18/03/25.
//

import SwiftUI
import AppKit

struct ContentView: View {
    @State private var selectedItem: String? = "Sidebar Item 1"
    @State private var selectedBottomOption: String = "Home"
    
    // Bottom bar options
    let bottomOptions = ["Home", "Settings", "Profile", "Help", "About"]
    
    var body: some View {
        ZStack {
            // Background image spanning the entire window
            Image("background_image")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Custom navigation view
                HStack(spacing: 0) {
                    // Custom sidebar
                    SidebarView(selectedItem: $selectedItem)
                    
                    // Divider
                    Rectangle()
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: 1)
                    
                    // Main content based on sidebar and bottom bar selection
                    MainContentView(
                        selectedItem: selectedItem,
                        selectedBottomOption: selectedBottomOption
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.clear)
                }
                .frame(maxHeight: .infinity)
                
                // Top divider for bottom bar
                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(height: 1)
                
                // Responsive bottom bar
                GeometryReader { geometry in
                    BottomBarView(
                        options: bottomOptions,
                        selectedOption: $selectedBottomOption,
                        availableWidth: geometry.size.width
                    )
                }
                .frame(height: 60)
                .background(Color.black.opacity(0.3))
            }
        }
        .onAppear {
            // Make the window background clear to allow our image to show through
            WindowUtil.configureWindowForTransparency()
        }
    }
}

#Preview {
    ContentView()
}
