//
//  BottomBarView.swift
//  MacOSBackroundImage
//
//  Created by Ravi Shankar on 18/03/25.
//

import SwiftUI

struct BottomBarView: View {
    let options: [String]
    @Binding var selectedOption: String
    let availableWidth: CGFloat
    
    // Constants for layout calculations
    private let minItemWidth: CGFloat = 60
    private let horizontalPadding: CGFloat = 40
    private let spacing: CGFloat = 10
    
    var body: some View {
        // Calculate how many full items we can fit
        let availableWidthForItems = availableWidth - horizontalPadding
        let maxFullItemsWithSpacing = Int((availableWidthForItems + spacing) / (minItemWidth + spacing))
        
        return HStack(spacing: spacing) {
            if maxFullItemsWithSpacing >= options.count {
                // We can show all items normally
                ForEach(options, id: \.self) { option in
                    bottomBarButton(option: option)
                }
            } else if maxFullItemsWithSpacing >= 3 {
                // Show first options and use a more menu
                ForEach(Array(options.prefix(maxFullItemsWithSpacing - 1)), id: \.self) { option in
                    bottomBarButton(option: option)
                }
                
                // More menu for remaining options
                Menu {
                    ForEach(Array(options.dropFirst(maxFullItemsWithSpacing - 1)), id: \.self) { option in
                        Button(action: {
                            selectedOption = option
                        }) {
                            Label(option, systemImage: UIConstants.icon(for: option))
                        }
                    }
                } label: {
                    VStack {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 18))
                        Text("More")
                            .font(.caption)
                    }
                    .frame(width: minItemWidth)
                    .foregroundColor(.white)
                }
            } else {
                // Very narrow - just show the most important options and a compact more menu
                bottomBarButton(option: "Home")
                
                // Compact overflow menu
                Menu {
                    ForEach(Array(options.dropFirst(1)), id: \.self) { option in
                        Button(action: {
                            selectedOption = option
                        }) {
                            Label(option, systemImage: UIConstants.icon(for: option))
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 18))
                }
                .frame(width: minItemWidth)
                .foregroundColor(.white)
            }
        }
        .padding(.horizontal, horizontalPadding / 2)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // Individual bottom bar button
    private func bottomBarButton(option: String) -> some View {
        Button(action: {
            selectedOption = option
        }) {
            VStack {
                Image(systemName: UIConstants.icon(for: option))
                    .font(.system(size: 18))
                Text(option)
                    .font(.caption)
            }
            .frame(width: 60)
            .padding(.vertical, 8)
            .foregroundColor(selectedOption == option ? .blue : .white)
            .background(selectedOption == option ? Color.blue.opacity(0.3) : Color.clear)
            .cornerRadius(6)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    BottomBarView(
        options: ["Home", "Settings", "Profile", "Help", "About"],
        selectedOption: .constant("Home"),
        availableWidth: 500
    )
    .frame(height: 60)
    .background(Color.black.opacity(0.3))
} 