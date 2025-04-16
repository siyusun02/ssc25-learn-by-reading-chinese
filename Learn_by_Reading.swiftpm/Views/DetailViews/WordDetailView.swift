import SwiftUI
import Translation
import AVFoundation
import SQLite3

struct WordDetailView:
    View {
    @StateObject private var viewModel: WordDetailViewModel

    init(word: String, dictionary: CedictDB) {
        _viewModel = StateObject(wrappedValue: WordDetailViewModel(word: word, dictionary: dictionary))
    }

    var body: some View {
        ScrollView {
            VStack {
                MainEntryView()

                Divider()

                MoreWordsView()
            }
        }
        .padding()
        .environmentObject(viewModel)
    }
}

struct MainEntryView: View {
    @EnvironmentObject var viewModel: WordDetailViewModel
    
    var body: some View {
        if let exact = viewModel.exact {
            VStack(spacing: 16) {
                chineseSection(entry: exact)
                englishSection(entry: exact)
            }.padding()
        } else {
            ContentUnavailableView {
                Label("No exact match for '\(viewModel.word)' found", systemImage: "character.book.closed.fill")
            } description: {
                Text("There is no exact match for the word. Look below for similar matches.")
            }
        }
    }

    private func chineseSection(entry: CedictEntry) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Chinese \(viewModel.chineseForm.name())").font(.headline).bold()
                SpeechButton(speechHelper: viewModel.speechHelper,
                             text: viewModel.chineseForm.getFrom(entry: entry))
            }

            PinyinView(
                pinyin: entry.pinyin,
                characters: viewModel.chineseForm.getFrom(entry: entry),
                onTap: { viewModel.setWord(word: String($0.character)) }
            )

            HStack {
                Button {
                    viewModel.chineseForm = viewModel.chineseForm.toggle()
                } label: {
                    Label(viewModel.chineseForm.toggle().name(), systemImage: "arrow.2.squarepath")
                }.buttonStyle(.secondary)

                CopyButton(textToCopy: viewModel.chineseForm.getFrom(entry: entry))
            }
            .font(.footnote)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func englishSection(entry: CedictEntry) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("English Definition")
                .font(.headline)
                .bold()

            TextDefinitionView(definition: entry.definition)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}



struct MoreWordsView: View {
    @EnvironmentObject var viewModel: WordDetailViewModel

    func getWordToColor() -> String {
        if let e = viewModel.exact {
            return viewModel.chineseForm.getFrom(entry:e)
        } else {
            return viewModel.word
        }
    }
    
    var body: some View {
        LazyVStack(alignment: .leading) {
            Text("Similar Words").font(.headline).bold()
                .padding(.bottom)

            if viewModel.moreWords.isEmpty {
                ContentUnavailableView {
                    Label("No more matches found", systemImage: "books.vertical.fill")
                }
            }

            ForEach(viewModel.moreWords) { match in
                PinyinView(
                    pinyin: match.pinyin,
                    characters: viewModel.chineseForm.getFrom(entry: match),
                    toColor: getWordToColor(),
                    onTap: { viewModel.setWord(word: String($0.character)) }
                )

                HStack {
                    Button {
                        viewModel.chineseForm = viewModel.chineseForm.toggle()
                    } label: {
                        Label(viewModel.chineseForm.toggle().name(), systemImage: "arrow.2.squarepath")
                    }.buttonStyle(.secondary)

                    CopyButton(textToCopy: viewModel.chineseForm.getFrom(entry: match))
                    SpeechButton(speechHelper: viewModel.speechHelper,
                                 text: viewModel.chineseForm.getFrom(entry: match))
                        .buttonStyle(.secondary)
                }.font(.footnote)

                TextDefinitionView(definition: match.definition)

                Divider().padding()
            }
        }.padding()
    }
}

struct TextDefinitionView: View {
    let definition: String
    
    var body: some View {
        Text(definition)
            .frame(maxHeight: .infinity, alignment: .topLeading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .textSelection(.enabled)
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 8).stroke(Color(UIColor.separator))
            )
    }
}

#Preview {
    let word = "科学家"
    Text(word).sheet(isPresented: .constant(true)) {
        WordDetailView(word: word, dictionary: CedictDB())
    }
}
