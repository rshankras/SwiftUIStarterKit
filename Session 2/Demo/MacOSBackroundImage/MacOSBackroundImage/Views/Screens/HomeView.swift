//
//  HomeView.swift
//  MacOSBackroundImage
//
//  Created by Ravi Shankar on 18/03/25.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Welcome to the Dashboard")
                .font(.title)
            
            HStack(spacing: 20) {
                StatCard(title: "Projects", value: "12", icon: "folder")
                StatCard(title: "Tasks", value: "28", icon: "checklist")
                StatCard(title: "Notifications", value: "5", icon: "bell")
            }
            
            Text("Recent Activity")
                .font(.headline)
                .padding(.top)
            
            ForEach(1...5, id: \.self) { i in
                HStack {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 8))
                    Text("Activity item \(i)")
                    Spacer()
                    Text("Today")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 4)
            }
            
            Spacer()
        }
    }
}

#Preview {
    HomeView()
        .frame(width: 500, height: 400)
        .background(Color.black.opacity(0.1))
        .padding()
} 