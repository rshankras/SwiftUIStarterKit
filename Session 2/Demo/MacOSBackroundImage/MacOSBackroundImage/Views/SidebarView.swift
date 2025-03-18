//
//  SidebarView.swift
//  MacOSBackroundImage
//
//  Created by Ravi Shankar on 18/03/25.
//

import SwiftUI

struct SidebarView: View {
    @Binding var selectedItem: String?
    let sidebarItems = ["Sidebar Item 1", "Sidebar Item 2", "Sidebar Item 3"]
    
    var body: some View {
        VStack {
            ForEach(sidebarItems, id: \.self) { item in
                Text(item)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(selectedItem == item ? Color.blue.opacity(0.3) : Color.clear)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedItem = item
                    }
            }
            Spacer()
        }
        .frame(width: 200)
        .background(Color.black.opacity(0.2))
    }
}

#Preview {
    SidebarView(selectedItem: .constant("Sidebar Item 1"))
} 
