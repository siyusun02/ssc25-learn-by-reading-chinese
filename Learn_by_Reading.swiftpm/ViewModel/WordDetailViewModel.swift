import SwiftUI

class WordDetailViewModel: ObservableObject {
    @Published var chineseForm: ChineseForm = .simplified
    @Published var word: String
    @Published var exact: CedictEntry?
    @Published var moreWords: [CedictEntry] = []
    @Published var speechHelper = SpeechHelper()
    
    private let dictionary: CedictDB

    init(word: String, dictionary: CedictDB) {
        self.word = word
        self.dictionary = dictionary
        searchWord()
    }
    
    func setWord(word: String) {
        guard word != self.word else { return } // make sure word changed
        
        withAnimation(.smooth(duration: 0.3)) {
            self.word = word
            searchWord()
        }
    }

    func searchWord() {
        print("DEBUG: search '\(word)' in dictionary")
        exact = dictionary.searchExact(word: word)
        moreWords = dictionary.search(word: word).filter { $0.id != exact?.id }
        
        if exact == nil && moreWords.count < 10 && word.count > 1 {
            // search for more words by splitting
            for char in word {
                moreWords.append(contentsOf: dictionary.search(word: String(char)))
            }
        }
    }
}
