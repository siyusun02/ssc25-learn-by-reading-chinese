import SwiftUI
import NaturalLanguage

struct ChineseUtils {
    
    /**
        Detects whether the provided text is in Chinese (Simplified or Traditional).

        - Uses `NLLanguageRecognizer` to identify the dominant language.
        - Adds constraints to avoid misidentifying Chinese words as Japanese (e.g., 坟墓).
        
        - Parameter `text`: The text to analyze.
        - Returns: `true` if the text is identified as Simplified or Traditional Chinese, otherwise `false`.
    */
    static func detectChinese(text: String) -> Bool {
        if text.precomposedStringWithCompatibilityMapping.trimmingCharacters(in: .whitespacesAndNewlines) == "。" {
            return false
        }
        
        
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        
        // adding constraint because of some words that would be identfied in other languages
        // eg. 坟墓 japanese
        recognizer.languageConstraints = [.simplifiedChinese, .traditionalChinese]
        
        guard let l = recognizer.dominantLanguage else {
            return false
        }
        
        return l == .simplifiedChinese || l == .traditionalChinese
    }
    
    
    /**
        Converts numeric tone markers in Pinyin (e.g., "ni3 hao3") into proper diacritic marks (e.g., "nǐ hǎo").

        - Numbers 1-4 are replaced with the corresponding vowel tone mark.
        - Prioritizes 'a', 'e', or the last vowel if multiple exist.
        - Removes tone number from the final output.
        - Ignores tone 5 (neutral).

        - Parameter `original`: Pinyin string with numeric tones.
        - Returns: A prettified Pinyin string with diacritic tone marks.
    */
    static func prettifyPinyin(_ original: String) -> String {
        // convert so the tones are above the vowels
        let toneMap: [Character: [Character]] = [
            "a": ["ā", "á", "ǎ", "à"], "e": ["ē", "é", "ě", "è"], "i": ["ī", "í", "ǐ", "ì"],
            "o": ["ō", "ó", "ǒ", "ò"], "u": ["ū", "ú", "ǔ", "ù"], "ü": ["ǖ", "ǘ", "ǚ", "ǜ"]
        ]
        
        let words = original.split(separator: " ")
        var result: [String] = []
        
        for word in words {
            var letters = Array(word)
            if let digitIndex = letters.firstIndex(where: { $0.isNumber }),
               let toneValue = Int(String(letters[digitIndex])), toneValue > 0, toneValue <= 4 {
                
                let toneNumber = toneValue - 1
                let vowelIndex = letters.firstIndex(where: { toneMap.keys.contains($0) }) ??
                                 letters.lastIndex(where: { "aeiouü".contains($0) })
                
                if let vowelIdx = vowelIndex, let replacements = toneMap[letters[vowelIdx]] {
                    letters[vowelIdx] = replacements[toneNumber]
                    letters.remove(at: digitIndex)  // Remove tone number
                }
            }
            result.append(String(letters))
        }
        
        return result.joined(separator: " ").replacingOccurrences(of: "5", with: "")
    }
    
    /**
     Creates `PinyinCharacterPair` instances by pairing each Chinese character in `characterString`
     with its corresponding Pinyin syllable from `pinyinString`.
     
     - `characterString.count` must match the number of whitespace-separated words in `pinyinString`.
     - If `toColor` is provided, matching characters are highlighted (`tintColor` for exact matches, `orange` for partial matches).
     
     - Parameters:
     - `characterString`: Chinese characters.
     - `pinyinString`: Space-separated Pinyin syllables.
     - `toColor`: (Optional) String to highlight matching characters.
     
     - Returns: An array of `PinyinCharacterPair`.
     */
    static func createPinyinCharacterPairs(characterString: String, pinyinString: String, toColor: String? = nil) -> [PinyinCharacterPair] {
        let pinyin: [String] = pinyinString.components(separatedBy: " ")
        let characters: [Character] = Array(characterString)
        var pairs: [PinyinCharacterPair] = []
        
        guard pinyin.count == characters.count else {
            print("ERROR: pinyin count \(pinyin.count) != characters count \(characters.count)")
            return []
        }
        
        // indexes of the characters that match "toColor"
        var indexes: Set<Int> = Set()
        // indexes of the characters that match the split "toColor"
        var indexesSplit: Set<Int> = Set()
        
        if let toColor = toColor {
            indexes = Utils.findSplitOccurrences(of: toColor, in: characterString)
            indexesSplit = Utils.findSplitOccurrences(of: toColor, in: characterString)
        }
        
        // create the actual pairs
        for i in 0 ..< pinyin.count {
            var color = PinyinCharacterPair.defaultColor
            
            if indexes.contains(i) {
                color = Color(UIColor.tintColor)    // color for exact matches
            } else if indexesSplit.contains(i) {
                color = Color(UIColor.orange)       // color for split matches
            }
            
            let pair = PinyinCharacterPair(
                pinyin: pinyin[i],
                character: characters[i],
                color: color)
            
            pairs.append(pair)
        }
        
        return pairs
    }
}
