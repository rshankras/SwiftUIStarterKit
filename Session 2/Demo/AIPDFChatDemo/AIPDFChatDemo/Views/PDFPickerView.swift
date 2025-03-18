import SwiftUI
import UniformTypeIdentifiers

struct PDFPickerView: View {
    @ObservedObject var pdfManager: PDFDocumentManager
    @State private var showingFilePicker = false
    
    var body: some View {
        VStack {
            if let url = pdfManager.pdfURL {
                HStack {
                    Text(url.lastPathComponent)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    
                    Spacer()
                    
                    Button(action: {
                        pdfManager.selectedPDF = nil
                        pdfManager.pdfURL = nil
                        pdfManager.pdfText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
            } else {
                Button(action: {
                    showingFilePicker = true
                }) {
                    HStack {
                        Image(systemName: "doc.fill")
                        Text("Select PDF")
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
            
            if pdfManager.isProcessing {
                ProgressView("Processing PDF...")
                    .padding()
            }
            
            if let error = pdfManager.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [UTType.pdf],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    // Start accessing the security-scoped resource
                    guard url.startAccessingSecurityScopedResource() else {
                        pdfManager.errorMessage = "Failed to access the file"
                        return
                    }
                    
                    // Load the PDF
                    pdfManager.loadPDF(from: url)
                    
                    // Make sure to release the security-scoped resource when you're done
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        url.stopAccessingSecurityScopedResource()
                    }
                }
            case .failure(let error):
                pdfManager.errorMessage = error.localizedDescription
            }
        }
    }
} 