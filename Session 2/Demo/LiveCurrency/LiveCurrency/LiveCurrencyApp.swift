//
//  LiveCurrencyApp.swift
//  LiveCurrency
//
//  Created by Ravi Shankar on 18/09/24.
//

import SwiftUI

@main
struct LiveCurrencyApp: App {
    @AppStorage("isDarkMode") private var isDarkMode = false
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}
