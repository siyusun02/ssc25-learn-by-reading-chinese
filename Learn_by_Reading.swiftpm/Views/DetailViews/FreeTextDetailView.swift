import SwiftUI
import NaturalLanguage
import Translation

struct FreeTextDetailView: View {
    @StateObject private var viewModel: FreeTextDetailViewModel
    
    init(text: String, dictionary: CedictDB) {
        _viewModel = StateObject(wrappedValue: FreeTextDetailViewModel(text: text, dictionary: dictionary))
    }
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            TabView {
                ForEach(Array(viewModel.sentences.enumerated()), id: \.element.0) { index, element in
                    VStack(alignment: .leading) {
                        if let sentence = viewModel.getSentenceById(element.0) {
                            
                            HStack {
                                Text("Sentence \(index + 1) of \(viewModel.sentences.count)")
                                    .font(.headline).bold()
                                SpeechButton(speechHelper: viewModel.speechHelper, text: sentence.original)
                            }
                            
                            Divider()
                            
                            ScrollView {
                                Text(sentence.original).font(.title2)
                            }.frame(maxHeight: 115)
                            Divider()
                            
                            SentenceGroupsView(sentence: sentence)
                        } else {
                            Text("Failed to load sentence. Please try again.")
                        }
                    }.padding(.bottom, 48) // for the tab view index
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
        .padding()
        .environmentObject(viewModel)
    }
}

struct SentenceGroupsView: View {
    @EnvironmentObject var viewModel: FreeTextDetailViewModel
    
    @State var sentence: Sentence
    @State var parsedWords: [ParsedWord] = []
    
    @State private var configuration: TranslationSession.Configuration?
    
    @State var translation: String? = nil
    @State var translated: Bool = false
    
    @State private var expandedSection: Int? = nil
    
    init(sentence: Sentence) {
        self.sentence = sentence
    }
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack {
                Button {
                    expandedSection = 0
                } label: {
                    Label(
                        "Translate",
                        systemImage: "translate"
                    )
                }
                .buttonStyle(.secondary)
                
                CopyButton(textToCopy: sentence.original, maxHeight: 16)
            }.font(.footnote).lineLimit(1)
            
            List {
                DisclosureGroup(isExpanded: Binding(
                    get: { expandedSection == 0 },
                    set: { expandedSection = $0 ? 0 : nil }
                )) {
                    ScrollView {
                        Text(self.translation ?? "Loading...").padding(.top)
                            .translationTask(source: Locale.Language(identifier: "zh-cn"),
                                             target: Locale.Language(identifier: "en-us")
                            ) { session in
                                guard !translated else {
                                    print("DEBUG: already translate")
                                    return
                                }
                                
                                Task { @MainActor in
                                    do {
                                        let response = try await session.translate(sentence.original)
                                        self.translation = response.targetText
                                        self.translated = true
                                    } catch {
                                        print("ERROR: Failed to translate", error)
                                        self.translation = "Failed to translate, please make sure you downloaded the required language packs."
                                    }
                                }
                            }
                    }
                } label: {
                    Text("Translation")
                        .font(.headline)
                        .bold()
                        .foregroundStyle(.primary)
                }
                
                DisclosureGroup(isExpanded: Binding(
                    get: { expandedSection == 1 },
                    set: { expandedSection = $0 ? 1 : nil }
                ))  {
                    ScrollView {
                        VStack(alignment: .trailing) {
                            PinyinViewSentence(parsedWords: parsedWords)
                                .padding(.top)
                            
                            Button {
                                viewModel.chineseForm = viewModel.chineseForm.toggle()
                            } label: {
                                Label(viewModel.chineseForm.toggle().name(), systemImage: "arrow.2.squarepath")
                            }.buttonStyle(.secondary).padding(.vertical)
                                .font(.footnote).lineLimit(1)
                        }
                    }
                } label: {
                    Text("Sentence with Pinyin")
                        .font(.headline)
                        .bold()
                        .foregroundStyle(.primary)
                }
                
                DisclosureGroup(isExpanded: Binding(
                    get: { expandedSection == 2 },
                    set: { expandedSection = $0 ? 2 : nil }
                ))  {
                    ScrollView {
                        LazyVStack(alignment: .leading) {
                            ForEach(self.parsedWords) { word in
                                ParsedWordView(word: word, chineseForm: $viewModel.chineseForm)
                            }
                        }.padding(.top)
                    }
                } label: {
                    Text("Word Breakdown with Definitions")
                        .font(.headline)
                        .bold()
                        .foregroundStyle(.primary)
                }
            }
            .listStyle(.plain)
            
        }.onAppear {
            Task {
                self.parsedWords = await viewModel.getParsedWords(for: sentence.id)
            }
        }.animation(.easeInOut(duration: 0.1), value: expandedSection)
        
    }
}

struct ParsedWordView: View {
    let word: ParsedWord
    @EnvironmentObject var viewModel: FreeTextDetailViewModel
    @Binding var chineseForm: ChineseForm
    
    var body: some View {
        if let entry = word.entry {
            PinyinView(
                pinyin: entry.pinyin,
                characters: chineseForm.getFrom(entry: entry)
            )
            
            HStack {
                Button {
                    chineseForm = chineseForm.toggle()
                } label: {
                    Label(chineseForm.toggle().name(), systemImage: "arrow.2.squarepath")
                }.buttonStyle(.secondary)
                
                CopyButton(textToCopy: chineseForm.getFrom(entry: entry), maxHeight: 16)
                SpeechButton(speechHelper: viewModel.speechHelper, text: chineseForm.getFrom(entry: entry))
                    .buttonStyle(.secondary)
            }.font(.footnote)
            
            TextDefinitionView(definition: entry.definition)
        } else {
            PinyinView(
                pinyin: " ",
                characters: word.original
            )
            
            TextDefinitionView(definition: "No entry found")
        }
    }
}

struct PinyinViewSentence: View {
    private static let columns = Utils.createGridItems(count: 8)
    @EnvironmentObject var viewModel: FreeTextDetailViewModel
    let parsedWords: [ParsedWord]
    
    var body: some View {
        VStack(alignment: .leading) {
            if parsedWords.isEmpty {
                ProgressView("Loading words...")
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                LazyVGrid(columns: PinyinViewSentence.columns, alignment: .leading) {
                    ForEach(parsedWords) { parsedWord in
                        ForEach(viewModel.getPinyinCharacterPairs(for: parsedWord)) { pair in
                            PinyinView(pinyin: pair.pinyin, characters: String(pair.character))
                        }
                        
                        if viewModel.getPinyinCharacterPairs(for: parsedWord).isEmpty {
                            Text(parsedWord.original)
                        }
                    }
                }
            }
        }
    }
}


#Preview {
    let text = """
    相傳東晉時，浙江上虞祝家有⼀⼥祝英台（⼜名：祝九妹），⼥扮男裝到杭州遊學，途中遇到
    會稽來的同學梁⼭伯，兩⼈便相偕同同窗三年，感情深厚，但梁⼭伯（⼜名：梁三伯）並
    不知道祝英台是⼥兒後來祝英台中斷學業返回家鄉。梁⼭伯到上虞拜訪祝英台時，才知道
    三年同窗的好友竟是⼥紅妝，欲向祝家提親，此時祝英台已許配給⾺⽂之後梁⼭伯在鄞當
    縣令時，因過度鬱悶⽽去世了
    """
    
    Text(text).sheet(isPresented: .constant(true)) {
        FreeTextDetailView(text: text, dictionary: CedictDB())
            .presentationDetents([.large])
    }
}

