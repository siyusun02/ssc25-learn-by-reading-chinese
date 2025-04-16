import SwiftUI

struct WrapView<Items: RandomAccessCollection, Content: View>: View where Items.Element: Identifiable & Hashable {
    let items: Items
    let spacing: CGFloat
    let content: (Items.Element) -> Content
    let maxItemWidth: CGFloat
    
    init(_ items: Items,
         maxItemWidth: CGFloat = 16,
         spacing: CGFloat = 8, @ViewBuilder
         content: @escaping (Items.Element) -> Content) {
        self.items = items
        self.maxItemWidth = maxItemWidth
        self.spacing = spacing
        self.content = content
    }
    
    var body: some View {
        GeometryReader { geometry in
            self.createWrappedLayout(availableWidth: geometry.size.width)
        }
    }
    
    private func createWrappedLayout(availableWidth: CGFloat) -> some View {
        var rows: [[Items.Element]] = [[]]
        
        var width: CGFloat = 0
        for item in items {
            if width + maxItemWidth > availableWidth {
                rows.append([item])
                width = maxItemWidth
            } else {
                rows[rows.count - 1].append(item)
                width += spacing + maxItemWidth
            }
        }
        
        return LazyVStack(alignment: .leading, spacing: spacing) {
            ForEach(rows, id: \.self) { row in
                LazyHStack(spacing: spacing) {
                    ForEach(row, id: \.self) { item in
                        self.content(item)
                    }
                }
            }
        }
    }
}
