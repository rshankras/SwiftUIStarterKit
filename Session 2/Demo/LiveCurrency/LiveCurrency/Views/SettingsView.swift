//
//  SettingsView.swift
//  LiveCurrency
//
//  Created by Ravi Shankar on 18/09/24.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        Form {
            Section(header: Text("Appearance")) {
                Toggle("Dark Mode", isOn: $isDarkMode)
            }
            
            Section(header: Text("Attribution")) {
                Link("Rates By Exchange Rate API", destination: URL(string: "https://www.exchangerate-api.com")!)
                    .foregroundColor(.blue)
            }
        }
        .navigationTitle("Settings")
    }
}
