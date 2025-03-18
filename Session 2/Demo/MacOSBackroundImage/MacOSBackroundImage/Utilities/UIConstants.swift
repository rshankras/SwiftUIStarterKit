//
//  UIConstants.swift
//  MacOSBackroundImage
//
//  Created by Ravi Shankar on 18/03/25.
//

import SwiftUI

struct UIConstants {
    static func icon(for option: String) -> String {
        switch option {
        case "Home": return "house"
        case "Settings": return "gear"
        case "Profile": return "person.circle"
        case "Help": return "questionmark.circle"
        case "About": return "info.circle"
        default: return "circle"
        }
    }
} 