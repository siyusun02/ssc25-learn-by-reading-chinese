import SwiftUI

struct PinyinCharacterPair: Identifiable {
    static let defaultColor: Color = .primary
    
    let id = UUID()
    let pinyin: String
    let character: Character
    let color: Color
    
    init(pinyin: String, character: Character, color: Color = PinyinCharacterPair.defaultColor) {
        self.pinyin = pinyin
        self.character = character
        self.color = color
    }
}
