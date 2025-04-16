import SwiftUI

struct AppBackgroundAccessoryView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var geometry: DocumentLaunchGeometryProxy
    
    var body: some View {
        if horizontalSizeClass != .compact {
            ZStack {
                PaperView(geometry: geometry, left: true)
                PaperView(geometry: geometry, left: false)
            }
        }
    }
    
    private struct PaperView: View {
        let geometry: DocumentLaunchGeometryProxy
        let left: Bool
        
        var body: some View {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemBackground))
                .frame(width: geometry.titleViewFrame.width * 0.3,
                       height: geometry.frame.height * 0.5)
                .position(x: getXPos(),
                          y: geometry.titleViewFrame.midY + 116)
        }
        
        func getXPos() -> CGFloat {
            return left ? geometry.titleViewFrame.minX - 32 : geometry.titleViewFrame.maxX + 32
        }
    }
}

