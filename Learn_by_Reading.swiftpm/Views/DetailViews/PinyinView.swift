import SwiftUI

struct PinyinView: View {
    private static var columns = Utils.createGridItems(count: 6)
    private let pairs: [PinyinCharacterPair]
    private let onTap: ((_ pair: PinyinCharacterPair) -> Void)?

    init(pinyin: String, characters: String, toColor: String? = nil, onTap: ((_ pair: PinyinCharacterPair) -> Void)? = nil) {
        self.pairs = ChineseUtils.createPinyinCharacterPairs(characterString: characters, pinyinString: pinyin, toColor: toColor)
        self.onTap = onTap
    }

    var body: some View {
        ViewThatFits {
            HStack {
                pairView()
            }

            LazyVGrid(columns: PinyinView.columns) {
                pairView()
            }
        }
    }

    private func pairView() -> some View {
        ForEach(pairs) { pair in
            VStack {
                Text(pair.pinyin).font(.subheadline).lineLimit(1)
                Text(String(pair.character))
                    .textSelection(.enabled)
                    .font(.title)
                    .foregroundStyle(pair.color)
            }
            .onTapGesture {
                onTap?(pair)
            }
        }
    }
}

