import SwiftUI

enum Tabs: Equatable, Hashable {
    case watchNow
    case library
    case new
    case favorites
    case search
}

@main
struct LearnByReadingApp: App {
    @StateObject private var cedictDB: CedictDB = CedictDB()
    @State private var showOnboarding = !UserDefaultsUtils.hideOnboarding
    @State var showSample = false
    
    var body: some Scene {
        #if os(iOS)
        DocumentGroupLaunchScene("Learn by Reading") {
            AppActionView(showSample: $showSample, showOnboarding: $showOnboarding)
        } background: {
            AppBackgroundView()
        } backgroundAccessoryView: {
            AppBackgroundAccessoryView(geometry: $0)
        } overlayAccessoryView: {
            AppOverlayAccessoryView(geometry: $0)
        }
        #endif
        
        DocumentGroup(viewing: PDFFileDocument.self) {
            PDFDocumentView(document: $0.document)
        }
    }
}
