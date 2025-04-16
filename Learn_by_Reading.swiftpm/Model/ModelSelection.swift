import SwiftUI

struct ModelSelection: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let type: ModelSelectionType
}

enum ModelSelectionType {
    case word, freeText
}
