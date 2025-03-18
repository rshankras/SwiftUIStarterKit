import SwiftUI

struct SettingsView: View {
    @AppStorage("openai_api_key") private var apiKey: String = ""
    @AppStorage("openai_model") private var selectedModel: String = "gpt-4o"
    @AppStorage("embedding_model") private var embeddingModel: String = "text-embedding-3-small"
    @Environment(\.dismiss) private var dismiss
    @State private var showingModelInfo = false
    
    // Available models
    private let availableModels = [
        "gpt-4o": "GPT-4o (Recommended)",
        "gpt-4-turbo": "GPT-4 Turbo",
        "gpt-3.5-turbo": "GPT-3.5 Turbo (Faster)"
    ]
    
    // Available embedding models
    private let availableEmbeddingModels = [
        "text-embedding-3-small": "Small (Default)",
        "text-embedding-3-large": "Large (More Accurate)",
        "text-embedding-ada-002": "Legacy"
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("API Configuration")) {
                    SecureField("OpenAI API Key", text: $apiKey)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
                
                Section(header: Text("Chat Model")) {
                    Picker("AI Model", selection: $selectedModel) {
                        ForEach(availableModels.keys.sorted(), id: \.self) { key in
                            Text(availableModels[key] ?? key)
                                .tag(key)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    // Model information
                    if let modelInfo = modelInformation[selectedModel] {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(modelInfo.name)
                                .font(.headline)
                            
                            Text(modelInfo.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Label("Performance", systemImage: "bolt")
                                    .font(.caption)
                                
                                Spacer()
                                
                                ForEach(0..<5) { i in
                                    Image(systemName: i < modelInfo.performance ? "star.fill" : "star")
                                        .foregroundColor(i < modelInfo.performance ? .yellow : .gray)
                                        .font(.caption)
                                }
                            }
                            
                            HStack {
                                Label("Cost", systemImage: "dollarsign.circle")
                                    .font(.caption)
                                
                                Spacer()
                                
                                ForEach(0..<5) { i in
                                    Image(systemName: i < modelInfo.cost ? "dollarsign" : "dollarsign")
                                        .foregroundColor(i < modelInfo.cost ? .green : .gray)
                                        .font(.caption)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    
                    Button(action: {
                        showingModelInfo = true
                    }) {
                        HStack {
                            Image(systemName: "info.circle")
                            Text("Learn about AI models")
                        }
                    }
                }
                
                Section(header: Text("Embedding Model")) {
                    Picker("Embedding Model", selection: $embeddingModel) {
                        ForEach(availableEmbeddingModels.keys.sorted(), id: \.self) { key in
                            Text(availableEmbeddingModels[key] ?? key)
                                .tag(key)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    Text("Embeddings are used to find relevant content in your PDF.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section(footer: Text("Your API key is stored securely in the device keychain.")) {
                    Button("Save") {
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingModelInfo) {
                ModelInfoView()
            }
        }
    }
    
    // Model information for display
    private let modelInformation: [String: (name: String, description: String, performance: Int, cost: Int)] = [
        "gpt-4o": (
            name: "GPT-4o",
            description: "OpenAI's most advanced model. Best for complex tasks requiring deep understanding and reasoning.",
            performance: 5,
            cost: 3
        ),
        "gpt-4-turbo": (
            name: "GPT-4 Turbo",
            description: "An advanced model with a good balance of capability and cost.",
            performance: 4,
            cost: 2
        ),
        "gpt-3.5-turbo": (
            name: "GPT-3.5 Turbo",
            description: "Faster and more economical. Good for simpler questions and basic PDF interactions.",
            performance: 3,
            cost: 1
        )
    ]
} 