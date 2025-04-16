import SwiftUI

class ParsedWord: Identifiable {
    let id = UUID()
    let original: String
    let pinyinCharacterPairsSimpl: [PinyinCharacterPair]
    let pinyinCharacterPairsTradi: [PinyinCharacterPair]
    let entry: CedictEntry?
    
    init(original: String, pinyinCharacterPairsSimpl: [PinyinCharacterPair], pinyinCharacterPairsTradi: [PinyinCharacterPair], entry: CedictEntry? = nil) {
        self.original = original
        self.entry = entry
        self.pinyinCharacterPairsSimpl = pinyinCharacterPairsSimpl
        self.pinyinCharacterPairsTradi = pinyinCharacterPairsTradi
    }
}
