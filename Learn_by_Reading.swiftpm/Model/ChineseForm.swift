enum ChineseForm {
    case traditional, simplified
    
    func toggle() -> ChineseForm {
        switch(self) {
        case .traditional:
            return .simplified
        case .simplified:
            return .traditional
        }
    }
    
    func name() -> String {
        switch(self) {
        case .traditional:
            return "Traditional"
        case .simplified:
            return "Simplified"
        }
    }
    
    func getFrom(entry: CedictEntry) -> String {
        switch(self) {
        case .traditional:
            return entry.traditional
        case .simplified:
            return entry.simplified
        }
    }
}
