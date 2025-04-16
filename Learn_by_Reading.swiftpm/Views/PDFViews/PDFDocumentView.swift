import SwiftUI
import WebKit


struct PDFDocumentView: View {
    @StateObject var pageViewModel: PageViewModel
    
    init(document: PDFFileDocument) {
        _pageViewModel = StateObject(
            wrappedValue: PageViewModel(document: document)
        )
    }
    
    var body: some View {
        NavigationStack {
            PDFViewRepresentable(model: pageViewModel)
                .fullScreenCover(isPresented: $pageViewModel.showHelp,
                                 onDismiss: { UserDefaultsUtils.hideHelp = true }) {
                    HelpView { pageViewModel.showHelp = false }
                }
                .fullScreenCover(isPresented: $pageViewModel.showInfo) {
                    InfoView { pageViewModel.showInfo = false}
                }
                .fullScreenCover(isPresented: $pageViewModel.showDictionary) {
                    DictionaryView { pageViewModel.showDictionary = false }
                }
                .sheet(item: $pageViewModel.selection) {
                    pageViewModel.reset()
                } content: {
                    if $0.type == .word {
                        WordDetailView(word: $0.text,
                                       dictionary: pageViewModel.dictionary)
                        .presentationDetents([.fraction(0.75), .large])
                    } else {
                        FreeTextDetailView(
                            text: $0.text,
                            dictionary: pageViewModel.dictionary)
                        .presentationDetents([.large])
                    }
                }.toolbar {
                    ToolbarItemGroup(placement: .automatic) {
                        HStack (alignment: .center, spacing: 16) {
                            Button { pageViewModel.showHelp.toggle() } label: {
                                Image(systemName: "questionmark.circle")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                            }.buttonStyle(.toolbar)
                            
                            Button { pageViewModel.showInfo.toggle() } label: {
                                Image(systemName: "info.square.fill")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                            }.buttonStyle(.toolbar)
                            
                            
                            Button { pageViewModel.showDictionary.toggle() } label: {
                                Image(systemName: "character.book.closed")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                            }.buttonStyle(.toolbar)
                        }
                    }
                }
        }
    }
}

#Preview {
    let data = SampleData().data
    PDFDocumentView(document: PDFFileDocument(data: data))
}
