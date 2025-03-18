import Foundation
import PDFKit

class PDFTextExtractor {
    // This function extracts text from a PDF document and reports progress
    func extractText(from document: PDFDocument, progressHandler: @escaping (Double) -> Void) async -> String {
        var extractedText = ""
        
        for pageIndex in 0..<document.pageCount {
            guard let page = document.page(at: pageIndex) else { 
                continue 
            }
            
            if let pageText = page.string {
                extractedText += pageText + "\n\n"
            }
            
            // Report progress
            let progress = Double(pageIndex + 1) / Double(document.pageCount)
            await MainActor.run {
                progressHandler(progress)
            }
        }
        
        return extractedText
    }
} 