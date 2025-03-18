//
//  ContentView.swift
//  AIPDFChatDemo
//
//  Created by Ravi Shankar on 12/03/25.
//

import SwiftUI
import PDFKit

struct ContentView: View {
    @StateObject private var pdfManager = PDFDocumentManager()
    @StateObject private var openAIService = OpenAIService()
    @StateObject private var chatViewModel: ChatViewModel
    
    @State private var showingSettings = false
    @State private var showDebugInfo: Bool = false
    @State private var showingChatHistory = false
    
    init() {
        // Create the services with simpler initialization
        let embeddingService = EmbeddingService()
        
        // Try to create a message repository
        var messageRepository: MessageRepositoryProtocol? = nil
        do {
            messageRepository = try SwiftDataMessageRepository()
        } catch {
            print("Failed to initialize message repository: \(error.localizedDescription)")
        }
        
        // Initialize the chatViewModel with all dependencies
        _chatViewModel = StateObject(wrappedValue: ChatViewModel(
            openAIService: OpenAIService(),
            pdfManager: PDFDocumentManager(),
            embeddingService: embeddingService,
            messageRepository: messageRepository
        ))
    }
    
    var body: some View {
        // Break down the body into smaller, more manageable functions
        buildNavigationStack()
    }
    
    // Break down the body into smaller, more manageable functions
    private func buildNavigationStack() -> some View {
        NavigationStack {
            VStack {
                if pdfManager.selectedPDF == nil {
                    buildWelcomeView()
                } else {
                    buildChatView()
                }
            }
            .navigationTitle("AI PDF Chat")
            .toolbar {
                buildToolbarItems()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingChatHistory) {
                buildChatHistoryView()
            }
            .overlay(
                Group {
                    if showDebugInfo {
                        buildDebugOverlay()
                    }
                }
            )
            .onAppear {
                setupOnAppear()
            }
            .onDisappear {
                NotificationCenter.default.removeObserver(self)
            }
        }
    }
    
    // Welcome screen when no PDF is selected
    private func buildWelcomeView() -> some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("AI PDF Chat Demo")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Upload a PDF to start chatting with it")
                .foregroundColor(.secondary)
            
            PDFPickerView(pdfManager: pdfManager)
                .padding()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // Chat view when a PDF is selected
    private func buildChatView() -> some View {
        VStack {
            // PDF info header
            buildPdfHeader()
            
            // Processing indicator
            if pdfManager.isProcessing {
                buildProcessingIndicator()
            }
            
            // Manual embedding generation button
            if shouldShowEmbeddingButton() {
                buildEmbeddingButton()
            }
            
            // Embedding status (if in progress)
            if isGeneratingEmbeddings() {
                buildEmbeddingStatus()
            }
            
            // Chat messages
            buildChatMessagesView()
            
            // Message input
            buildMessageInputView()
        }
    }
    
    // PDF header with file name and change button
    private func buildPdfHeader() -> some View {
        HStack {
            if let url = pdfManager.pdfURL {
                Text(url.lastPathComponent)
                    .font(.headline)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            
            Spacer()
            
            Button(action: {
                pdfManager.selectedPDF = nil
                pdfManager.pdfURL = nil
                pdfManager.pdfText = ""
                pdfManager.textChunks = []
                chatViewModel.clearChat()
            }) {
                Text("Change PDF")
                    .font(.subheadline)
            }
        }
        .padding(.horizontal)
    }
    
    // Processing indicator for PDF
    private func buildProcessingIndicator() -> some View {
        VStack {
            ProgressView(value: pdfManager.processingProgress)
                .progressViewStyle(LinearProgressViewStyle())
                .padding()
            
            Text("Processing PDF: \(Int(pdfManager.processingProgress * 100))%")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }
    
    // Helper function to determine if embedding button should be shown
    private func shouldShowEmbeddingButton() -> Bool {
        return !pdfManager.isProcessing && 
               pdfManager.textChunks.isEmpty == false && 
               pdfManager.embeddingsGenerated == 0
    }
    
    // Button to manually generate embeddings
    private func buildEmbeddingButton() -> some View {
        Button("Generate Embeddings") {
            Task {
                // Create a new EmbeddingService instance directly - it will use @AppStorage for the API key
                let embeddingService = EmbeddingService()
                print("Manually triggering embedding generation...")
                await pdfManager.generateEmbeddings(with: embeddingService)
            }
        }
        .padding()
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(8)
        .padding(.bottom)
    }
    
    // Helper function to determine if embeddings are being generated
    private func isGeneratingEmbeddings() -> Bool {
        return pdfManager.embeddingsGenerated > 0 && 
               pdfManager.embeddingsGenerated < pdfManager.totalChunksToEmbed
    }
    
    // Status indicator for embedding generation
    private func buildEmbeddingStatus() -> some View {
        Text("Generating embeddings: \(pdfManager.embeddingsGenerated)/\(pdfManager.totalChunksToEmbed)")
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.bottom)
    }
    
    // Chat messages scrollview
    private func buildChatMessagesView() -> some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(chatViewModel.messages) { message in
                    MessageView(message: message)
                }
                
                if openAIService.isLoading || chatViewModel.isProcessing {
                    HStack {
                        Spacer()
                        ProgressView()
                            .padding()
                        Spacer()
                    }
                }
            }
            .padding(.vertical)
        }
    }
    
    // Message input field and send button
    private func buildMessageInputView() -> some View {
        HStack {
            TextField("Ask about the PDF...", text: $chatViewModel.newMessageText)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .disabled(isInputDisabled())
            
            Button(action: {
                chatViewModel.sendMessage()
            }) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.blue)
            }
            .disabled(isSendButtonDisabled())
        }
        .padding()
    }
    
    // Helper function to determine if input should be disabled
    private func isInputDisabled() -> Bool {
        return openAIService.isLoading || chatViewModel.isProcessing || pdfManager.isProcessing
    }
    
    // Helper function to determine if send button should be disabled
    private func isSendButtonDisabled() -> Bool {
        return chatViewModel.newMessageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || 
               openAIService.isLoading || 
               chatViewModel.isProcessing ||
               pdfManager.isProcessing
    }
    
    // Toolbar items
    private func buildToolbarItems() -> some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    showingChatHistory = true
                }) {
                    Image(systemName: "clock.arrow.circlepath")
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showDebugInfo.toggle()
                }) {
                    Image(systemName: "ladybug")
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingSettings = true
                }) {
                    Image(systemName: "gear")
                }
            }
        }
    }
    
    // Chat history view
    private func buildChatHistoryView() -> some View {
        ChatHistoryView(onSelectPDF: { pdfName in
            // Handle selecting a PDF from history
            let success = pdfManager.findAndLoadPDF(withName: pdfName)
            
            if !success {
                print("Could not find PDF file: \(pdfName)")
                // You could add an alert here
            }
        })
    }
    
    // Debug overlay
    private func buildDebugOverlay() -> some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Debug Information")
                        .font(.headline)
                    
                    Divider()
                    
                    Text("PDF Processing:")
                        .font(.subheadline)
                        .bold()
                    Text("Chunks: \(pdfManager.textChunks.count)")
                    Text("Embedding Status: \(pdfManager.embeddingStatus)")
                    Text("Embeddings: \(pdfManager.embeddingsGenerated)/\(pdfManager.totalChunksToEmbed)")
                    
                    Divider()
                    
                    Text("Last Query:")
                        .font(.subheadline)
                        .bold()
                    Text(chatViewModel.lastQueryDebugInfo)
                        .font(.system(.body, design: .monospaced))
                        .lineLimit(nil)
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground).opacity(0.95))
            
            Button("Close Debug") {
                showDebugInfo = false
            }
            .padding()
        }
    }
    
    // Setup on appear
    private func setupOnAppear() {
        // Ensure ChatViewModel is using the same PDFManager instance
        chatViewModel.pdfManager = pdfManager
        
        // Test the API key with a simple embedding request
        Task {
            // Create a new instance for testing
            let testService = EmbeddingService()
            do {
                let testEmbedding = try await testService.generateEmbedding(for: "Test embedding request")
                print("API key test: SUCCESS - Generated embedding with \(testEmbedding.count) dimensions")
            } catch {
                print("API key test: FAILED - \(error.localizedDescription)")
            }
        }
        
        // Set up notification observer for PDF loading
        NotificationCenter.default.addObserver(
            forName: Notification.Name("PDFDocumentLoaded"),
            object: nil,
            queue: .main
        ) { _ in
            chatViewModel.loadChatHistory()
        }
    }
}

#Preview {
    ContentView()
}
