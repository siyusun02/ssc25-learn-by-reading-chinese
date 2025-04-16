import SwiftUI

class Sentence: Identifiable {
    static let emptySentence: Sentence = Sentence(original: "")
    
    let id = UUID()
    let original: String
    
    init(original: String) {
        self.original = original
    }
    
    // lazy parsing
    var parsedWords: [ParsedWord]?
    
    // lazy loading
    var translation: String?
}
