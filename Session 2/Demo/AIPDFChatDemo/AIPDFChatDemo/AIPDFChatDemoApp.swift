//
//  AIPDFChatDemoApp.swift
//  AIPDFChatDemo
//
//  Created by Ravi Shankar on 12/03/25.
//

import SwiftUI
import SwiftData

@main
struct AIPDFChatDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Message.self, isUndoEnabled: true)
    }
}
