//
//  WindowUtil.swift
//  MacOSBackroundImage
//
//  Created by Ravi Shankar on 18/03/25.
//

import SwiftUI
import AppKit

struct WindowUtil {
    static func configureWindowForTransparency() {
        NSWindow.allowsAutomaticWindowTabbing = false
        if let window = NSApplication.shared.windows.first {
            window.backgroundColor = .clear
        }
    }
}
