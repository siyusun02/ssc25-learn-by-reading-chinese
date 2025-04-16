import SwiftUI
import PDFKit
import NaturalLanguage


struct Utils {
    
    /**
        Creates an array of `GridItem` objects with the specified size.

        - Parameters:
          - `count`: The number of grid items to create.
          - `gridItemSize`: The size of each grid item (default is `.flexible()`).
        - Returns: An array of `GridItem` objects.
    */
    static func createGridItems(count: Int, gridItemSize: GridItem.Size = .flexible()) -> [GridItem] {
        return Array(repeating: GridItem(gridItemSize), count: count)
    }
    
    /**
        Converts a `CGPoint` to a `UnitPoint` relative to a given rectangle.

        - Parameters:
          - `point`: The `CGPoint` to convert.
          - `rect`: The reference `CGRect` used for conversion.
        - Returns: The corresponding `UnitPoint`.
    */
    static func convertPointToUnitPoint(for point: CGPoint, in rect: CGRect) -> UnitPoint {
        return UnitPoint(x: point.x / rect.width, y: point.y / rect.height)
    }
    
    /**
        Cleans a string by removing newline characters and normalizing Unicode.

        - Parameters:
          - `input`: The string to clean.
        - Returns: A cleaned string without newline characters, or `nil` if input is `nil`.
    */
    static func cleanString(_ input: String?) -> String? {
        guard let input = input else { return nil }
        return input
            .precomposedStringWithCompatibilityMapping
            .replacingOccurrences(of: "\n", with: "")
    }
    
    /**
        Splits the input text into sentences.

        - Parameters:
          - `text`: The text to split.
        - Returns: An array of sentences.
    */
    static func splitInSentences(_ text: String) -> [String] {
        return split(text, unit: .sentence)
    }
    
    /**
        Splits the input text into words.

        - Parameters:
          - `text`: The text to split.
        - Returns: An array of words.
    */
    static func splitInWords(_ text: String) -> [String] {
        return split(text, unit: .word)
    }
    
    /**
        Splits the input text into tokens based on the specified unit.

        - Parameters:
          - `text`: The text to split.
          - `unit`: The `NLTokenUnit` specifying how to tokenize the text.
        - Returns: An array of tokens (either words or sentences).
    */
    static func split(_ text: String, unit: NLTokenUnit) -> [String] {
        let tokenizer = NLTokenizer(unit: unit)
        let text = text.replacingOccurrences(of: "\n", with: "")
        tokenizer.string = text
        
        var tokens: [String] = []
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { tokenRange, _ in
            tokens.append(String(text[tokenRange]))
            return true
        }
        
        return tokens
    }
    
    /**
        Finds all character indexes where `matchString` appears as a whole in `sourceString`.

        - Parameters:
          - `matchString`: The substring to search for.
          - `sourceString`: The string to search within.

        - Returns: A set of starting indexes where `matchString` occurs.
    */
    static func findOccurrences(of matchString: String, in sourceString: String) -> Set<Int> {
        var indexes: Set<Int> = Set()
        
        sourceString.ranges(of: matchString).forEach { range in
            let allIndexes = sourceString.indices
                .filter { range.contains($0) }
                .map { $0.utf16Offset(in: sourceString) }
            
            indexes.formUnion(allIndexes)
        }
        
        return indexes
    }
    
    /**
        Finds all indexes where individual characters of `matchString` appear in `sourceString`.

        - Parameters:
          - `matchString`: The string whose characters will be searched individually.
          - `sourceString`: The string to search within.

        - Returns: A set of indexes where any character from `matchString` appears.
    */
    static func findSplitOccurrences(of matchString: String, in sourceString: String) -> Set<Int> {
        var indexes: Set<Int> = Set()
        
        for matchChar in matchString {
            let all = sourceString.indices(of: matchChar).ranges.flatMap { range in
                sourceString[range].indices.map {
                    sourceString.distance(from: sourceString.startIndex, to: $0)
                }
            }
            
            indexes.formUnion(all)
        }
        
        sourceString.ranges(of: matchString).forEach { range in
            let allIndexes = sourceString.indices
                .filter { range.contains($0) }
                .map { $0.utf16Offset(in: sourceString) }
            
            indexes.formUnion(allIndexes)
        }
        
        return indexes
    }
}

