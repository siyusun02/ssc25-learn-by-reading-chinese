import SwiftUI
import UniformTypeIdentifiers

struct PDFFileDocument: FileDocument {
    var data: Data
    
    init(data: Data) {
        self.data = data
    }
    
    init() {
        self.data = Data()
    }
    
    static var readableContentTypes: [UTType] { [.pdf] }
    
    // nothing because read-only
    static var writableContentTypes: [UTType] { [] }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.data = data
    }
    
    // not needed because read-only
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: data)
    }
}
