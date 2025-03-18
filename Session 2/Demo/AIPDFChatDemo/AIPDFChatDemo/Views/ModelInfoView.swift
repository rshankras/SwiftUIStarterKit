import SwiftUI

struct ModelInfoView: View {
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Chat Models")) {
                    modelCard(
                        name: "GPT-4o",
                        description: "OpenAI's most advanced model with multimodal capabilities. Provides the highest quality responses but at a higher cost.",
                        strengths: ["Most accurate responses", "Best reasoning capabilities", "Understands complex nuances"],
                        bestFor: ["Complex questions", "Detailed analysis", "When accuracy is crucial"],
                        performance: 5,
                        cost: 3
                    )
                    
                    modelCard(
                        name: "GPT-4 Turbo",
                        description: "A powerful model that balances performance and cost.",
                        strengths: ["Strong reasoning", "Good context handling", "Cost-effective for complex tasks"],
                        bestFor: ["Most PDF chat tasks", "Technical documents", "Detailed explanations"],
                        performance: 4,
                        cost: 2
                    )
                    
                    modelCard(
                        name: "GPT-3.5 Turbo",
                        description: "Faster and more economical model that's suitable for simpler tasks.",
                        strengths: ["Fast responses", "Low cost", "Handles straightforward content well"],
                        bestFor: ["Simple questions", "Quick lookups", "When speed is priority"],
                        performance: 3,
                        cost: 1
                    )
                }
                
                Section(header: Text("Embedding Models")) {
                    modelCard(
                        name: "text-embedding-3-small",
                        description: "Default embedding model with a good balance of accuracy and cost.",
                        strengths: ["Fast embedding generation", "Good semantic understanding", "Cost-effective"],
                        bestFor: ["Most PDF documents", "General-purpose retrieval", "Typical use cases"],
                        performance: 4,
                        cost: 1
                    )
                    
                    modelCard(
                        name: "text-embedding-3-large",
                        description: "Higher-dimensional embeddings for more accurate semantic search.",
                        strengths: ["More accurate retrieval", "Better semantic understanding", "Higher dimensions"],
                        bestFor: ["Technical or specialized documents", "When precision is crucial", "Complex retrieval needs"],
                        performance: 5,
                        cost: 2
                    )
                }
            }
            .navigationTitle("AI Model Information")
        }
    }
    
    private func modelCard(name: String, description: String, strengths: [String], bestFor: [String], performance: Int, cost: Int) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(name)
                .font(.headline)
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Label("Performance", systemImage: "bolt")
                    .font(.caption)
                
                Spacer()
                
                ForEach(0..<5) { i in
                    Image(systemName: i < performance ? "star.fill" : "star")
                        .foregroundColor(i < performance ? .yellow : .gray)
                        .font(.caption)
                }
            }
            
            HStack {
                Label("Relative Cost", systemImage: "dollarsign.circle")
                    .font(.caption)
                
                Spacer()
                
                ForEach(0..<5) { i in
                    Image(systemName: i < cost ? "dollarsign" : "dollarsign")
                        .foregroundColor(i < cost ? .green : .gray)
                        .font(.caption)
                }
            }
            
            Text("Strengths:")
                .font(.caption)
                .bold()
            
            ForEach(strengths, id: \.self) { strength in
                HStack(alignment: .top) {
                    Text("•")
                    Text(strength)
                        .font(.caption)
                }
            }
            
            Text("Best for:")
                .font(.caption)
                .bold()
            
            ForEach(bestFor, id: \.self) { use in
                HStack(alignment: .top) {
                    Text("•")
                    Text(use)
                        .font(.caption)
                }
            }
        }
        .padding(.vertical, 8)
    }
} 