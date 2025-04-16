import SwiftUI
import PDFKit
import Foundation
import NaturalLanguage


class PageViewModel: ObservableObject {
    @Published var selection: ModelSelection?
    @Published var showHelp: Bool = !UserDefaultsUtils.hideHelp
    @Published var showInfo: Bool = false
    @Published var showDictionary: Bool = false
    
    let dictionary = CedictDB()
    var document: PDFFileDocument
    var pdfView = CustomPDFKitView()
    
    init(document: PDFFileDocument) {
        self.document = document
    }
    
    func reset() {
        pdfView.clearSelection()
        pdfView.highlightedSelections = []
    }
    
    func handleTap(point: CGPoint) {
        print("DEBUG: tapped on point", point)
        
        pdfView.clearSelection()
        
        guard let page = pdfView.page(for: point, nearest: true) else {
            print("DEBUG: Could not find page")
            reset()
            return
        }
        
        let areaOfInterest = pdfView.areaOfInterest(for: point)
        if areaOfInterest.contains(.textArea) {
            let pagePoint = pdfView.convert(point, to: page)
            let characterIndex = page.characterIndex(at: pagePoint)
            guard characterIndex > 0 else {
                print("Invalid character")
                return
            }
            
            let charBounds = page.characterBounds(at: characterIndex)
            guard let pdfSelection = page.selection(for: charBounds) else {
                print("no selection found")
                return
            }

            pdfSelection.color = UIColor.tintColor
            let word = extendToWord(pdfSelection, page: page)
            guard !word.isEmpty else {
                return
            }
            
            // make sure its a chinese word
            guard ChineseUtils.detectChinese(text: word) else {
                print("DEBUG: Clicked non-chinese '\(word)'")
                return
            }
            
            pdfView.highlightedSelections = [pdfSelection]
            self.selection = ModelSelection(text: word, type: .word)
        } else {
            reset()
        }
    }
    
    /*
     not using page.selectionForWord(.) but manually extending with help of NL framework
     because this supports chinese characters much better;
     returns the extended word
     */
    func extendToWord(_ origSelection: PDFSelection, page: PDFPage) -> String {
        let maxWordLength = dictionary.maxWordLength
        
        guard let origString = Utils.cleanString(origSelection.string), !origString.isEmpty else {
            print("WARN No text in selection")
            return ""
        }
        
        if origString.count > 1 {
            print("WARN found more then one character in text '\(origString)' only using first characters")
        }
        
        let temp = origSelection.copy() as! PDFSelection
        temp.extend(atStart: maxWordLength)
        // because it can be less then max word length since extend
        // goes UP TO if possible
        let offsetOriginalSelection = (Utils.cleanString(temp.string)!.count) - 1
        
        
        let selection = origSelection.copy() as! PDFSelection
        selection.extend(atStart: maxWordLength)
        selection.extend(atEnd: maxWordLength)
        
        guard let extendedText = Utils.cleanString(selection.string) else { return origString }

        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = extendedText
        
        let origIndex = extendedText.index(extendedText.startIndex, offsetBy: offsetOriginalSelection)
        let wordRange = tokenizer.tokenRange(at: origIndex)
        
        let origIndexInt = origIndex.utf16Offset(in: extendedText)
        let wordLeftInt = wordRange.lowerBound.utf16Offset(in: extendedText)
        let wordRightInt = wordRange.upperBound.utf16Offset(in: extendedText)
        
        // can happen if the tapped character is not considererd a word
        // eg. @
        guard wordRightInt > wordLeftInt else {
            print("DEBUG: no word found")
            return origString
        }
        
        let leftOffset = origIndexInt - wordLeftInt
        let rightOffset = wordRightInt - 1 - origIndexInt
        
        // extend the original selection by the offset for the whole word
        origSelection.extend(atStart: leftOffset)
        origSelection.extend(atEnd: rightOffset)
        
        return String(extendedText[wordRange])
    }
    
}
