//
//  ToggleSetting.swift
//  MacOSBackroundImage
//
//  Created by Ravi Shankar on 18/03/25.
//

import SwiftUI

struct ToggleSetting: View {
    let title: String
    let isOn: Bool
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Toggle("", isOn: .constant(isOn))
                .labelsHidden()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ToggleSetting(title: "Enable Notifications", isOn: true)
        .padding()
} 