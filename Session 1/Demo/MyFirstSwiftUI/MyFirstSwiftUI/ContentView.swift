//
//  ContentView.swift
//  MyFirstSwiftUI
//
//  Created by Ravi Shankar on 11/03/25.
//

import SwiftUI

struct ContentView: View {
    @State private var message = "Hello, World!"
    @State private var inputText = ""
    var body: some View {
        ZStack {
            Image(systemName: "swift")
                .resizable()
                .scaledToFit()
                .foregroundColor(.gray)
                .opacity(0.8)
                .ignoresSafeArea(.all)
           Color.secondary.ignoresSafeArea(.all)
            VStack (spacing:40) {
                TextField("Enter your text", text: $inputText)
                    .padding(20)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(.roundedBorder)
                    .font(.headline)
                HStack {
                    Text(message)
                        .foregroundStyle(Color.primary)
                        .font(.title)
                        .fontWeight(.bold)
                    Image(systemName: "swift")
                        .resizable()
                        .foregroundStyle(.orange)
                        .frame(width: 25, height: 25)
                }
                Button("Click Me") {
                    message = inputText
                }
                .foregroundStyle(.primary)
                .font(.title)
                .fontWeight(.medium)
                .padding(20)
                .background().clipShape(Capsule())
            }
        }
    }
}

#Preview {
    ContentView()
}
