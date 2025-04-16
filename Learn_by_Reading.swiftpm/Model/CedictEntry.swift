struct CedictEntry: Identifiable {
    let id: Int
    let traditional: String
    let simplified: String
    let definition: String
    let pinyin: String
    
    init(id: Int, traditional: String, simplified: String, definition: String, pinyinRaw: String) {
        self.id = id
        self.traditional = traditional
        self.simplified = simplified
        self.definition = ChineseUtils.prettifyPinyin(definition)
        self.pinyin = ChineseUtils.prettifyPinyin(pinyinRaw)
    }
    
}
