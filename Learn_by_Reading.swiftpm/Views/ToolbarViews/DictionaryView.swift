import SwiftUI

struct DictionaryView: View {
    @State private var searchText: String = ""
    @State private var searchResults: [CedictEntry] = []
    @State private var chineseForm: ChineseForm = .simplified
    @State private var speechHelper = SpeechHelper()
    private var database = CedictDB()
    
    var onClose: (() -> Void)?
    
    init(_ onClose: (() -> Void)? = nil) {
        self.onClose = onClose
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Dictionary")
                .font(.largeTitle)
                .bold()
                .padding(.top, 20)
            
            TextField("Search for a word...", text: $searchText, onCommit: performSearch)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .onChange(of: searchText) { _ in performSearch() }
            
            ScrollView {
                LazyVStack {
                    ForEach(searchResults) { match in
                        VStack(alignment: .leading) {
                            PinyinView(
                                pinyin: match.pinyin,
                                characters: chineseForm.getFrom(entry: match),
                                toColor: searchText,
                                onTap: { searchText = String($0.character) }
                            )
                            
                            HStack {
                                Button {
                                    chineseForm = chineseForm.toggle()
                                } label: {
                                    Label(chineseForm.toggle().name(), systemImage: "arrow.2.squarepath")
                                }.buttonStyle(.secondary)
                                
                                CopyButton(textToCopy: chineseForm.getFrom(entry: match))
                                SpeechButton(speechHelper: speechHelper, text: chineseForm.getFrom(entry: match))
                                    .buttonStyle(.secondary)
                            }.font(.footnote)
                            
                            TextDefinitionView(definition: match.definition)
                        }
                        
                        Divider().padding()
                    }
                }.padding()
            }
            .scrollDismissesKeyboard(.immediately)
            .overlay {
                if searchResults.isEmpty {
                    if searchText.isEmpty {
                        ContentUnavailableView {
                            Label("Search", systemImage: "magnifyingglass")
                        } description: {
                            Text("Type in chinese characters, pinyin or english words.")
                        }
                    } else {
                        ContentUnavailableView.search
                    }
                }
            }
            
            Spacer()
            Divider()
            Button("Close") {
                onClose?()
            }
            .buttonStyle(.primary)
            .font(.title3)
            .padding(.bottom, 16)
        }
        .frame(maxWidth: 600)
        .padding(.vertical, 16)
    }
    
    private func performSearch() {
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }
        
        searchResults = database.searchByAnyField(searchTerm: searchText)
    }
}

#Preview {
    @Previewable @State var show = true
    Button("Click") {
        show = true
    }
    .fullScreenCover(isPresented: $show) {
        DictionaryView( { show = false })
    }
}
