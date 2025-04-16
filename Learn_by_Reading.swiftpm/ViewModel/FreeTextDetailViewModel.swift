import SwiftUI
import NaturalLanguage

class FreeTextDetailViewModel: ObservableObject {
    @Published var chineseForm: ChineseForm = .simplified
    @Published var text: String
    
    @Published var sentences: [(UUID, Sentence)]
    
    @Published var speechHelper = SpeechHelper()
    
    private let dictionary: CedictDB
    
    init(text: String, dictionary: CedictDB) {
        self.text = text.replacingOccurrences(of: " ", with: "")
        self.dictionary = dictionary
        self.sentences = Utils.splitInSentences(text)
            .map { original in
                let s = Sentence(original: original)
                return (s.id, s)
            }
    }
    
    func getSentenceById(_ id: UUID) -> Sentence? {
        return sentences.first { $0.0 == id }?.1
    }
    
    func getParsedWords(for sentenceId: UUID) async -> [ParsedWord] {
        guard let sentence = getSentenceById(sentenceId) else {
            print("ERROR: failed to get sentence \(sentenceId)")
            return []
        }
        
        
        if let existing = sentence.parsedWords {
            return existing
        }
        
        let dictionary = CedictDB() // because of multi-threaded access
        
        print("DEBUG: parse words for sentence \(sentenceId)")
        
        let words = Utils.splitInWords(sentence.original)
        let wordToEntries = dictionary.searchExact(words: words)
        
        print("DEBUG: Found \(wordToEntries.count) to \(words.count)")
        
        let originalCharArray: [Character] = Array(sentence.original)

        var parsedWords: [ParsedWord] = []
        
        // create "ParsedWord" objects in the order of the original sentence
        // also make sure characters, that were not recognized as "words" py the
        // split in words function are also treated
        var i = 0
        for word in words {
            for char in word {
                guard i < originalCharArray.count else {
                    print("ERROR: unexpected out of bounds, i \(i), word \(word)")
                    break
                }
                
                // for characters that are not words, eg. special character,...
                var originalChar: Character = originalCharArray[i]
                while originalChar != char && i < text.count {
                    parsedWords.append(
                        ParsedWord(original: String(originalChar), pinyinCharacterPairsSimpl: [], pinyinCharacterPairsTradi: [])
                    )
                    
                    i += 1
                    originalChar = originalCharArray[i]
                }
                
                i += 1
            }
            
            // for the actual word
            if let entry = wordToEntries[word] {
                let pc = ParsedWord(original: word,
                                    pinyinCharacterPairsSimpl: ChineseUtils.createPinyinCharacterPairs(characterString: entry.simplified, pinyinString: entry.pinyin),
                                    pinyinCharacterPairsTradi: ChineseUtils.createPinyinCharacterPairs(characterString: entry.traditional, pinyinString: entry.pinyin),
                           entry: entry
                )
                
                parsedWords.append(pc)
            } else {
                print("WARN: no entry for word \(word)")
                // fallback split search
                if word.count > 1 {
                    let entries = dictionary.searchExact(words: Array(word).map {String($0)})
                    for char in word {
                        let charAsString = String(char)
                        if let entry = entries[charAsString] {
                            let pc = ParsedWord(original: charAsString,
                                                pinyinCharacterPairsSimpl: ChineseUtils.createPinyinCharacterPairs(characterString: entry.simplified, pinyinString: entry.pinyin),
                                                pinyinCharacterPairsTradi: ChineseUtils.createPinyinCharacterPairs(characterString: entry.traditional, pinyinString: entry.pinyin),
                                                entry: entry
                            )
                            parsedWords.append(pc)
                        } else {
                            parsedWords.append(
                                ParsedWord(original: charAsString, pinyinCharacterPairsSimpl: [], pinyinCharacterPairsTradi: [])
                            )
                        }
                    }
                } else {
                    parsedWords.append(
                        ParsedWord(original: word, pinyinCharacterPairsSimpl: [], pinyinCharacterPairsTradi: [])
                    )
                }
            }
        }

        
        sentence.parsedWords = parsedWords
        return sentence.parsedWords!
    }
    
    func getPinyinCharacterPairs(for parsedWord: ParsedWord) -> [PinyinCharacterPair] {
        return chineseForm == .simplified ? parsedWord.pinyinCharacterPairsSimpl : parsedWord.pinyinCharacterPairsTradi
    }
    
    func formConvertedSentence(for parsedWords: [ParsedWord]) -> String {
        return parsedWords.map { getPinyinCharacterPairs(for: $0).map {String($0.character)}.joined() }.joined()
    }
}


