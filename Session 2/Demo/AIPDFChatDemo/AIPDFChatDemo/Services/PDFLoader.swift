import Foundation
import PDFKit

class PDFLoader {
    func loadPDF(from url: URL) -> PDFDocument? {
        return PDFDocument(url: url)
    }
    
    func findAndLoadPDF(withName fileName: String) -> URL? {
        // Common directories to search for PDFs
        let directories = [
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
            FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first,
            FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first
        ].compactMap { $0 }
        
        // Search for the PDF in each directory
        for directory in directories {
            let fileURL = directory.appendingPathComponent(fileName)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                return fileURL
            }
        }
        
        // PDF not found
        return nil
    }
} 