import SwiftUI

struct SampleData {
    static let shared = SampleData()
    
    let pdf: PDFFileDocument
    let data: Data
    
    init() {
        let samplePdf = Bundle.main.url(forResource: "sample", withExtension: "pdf")
        if let url = samplePdf, let data = try? Data(contentsOf: url){
            self.data = data
        } else {
            print("ERROR: sample.pdf not found in bundle")
            data = Data()
        }
        
        self.pdf = PDFFileDocument(data: data)
    }
}
