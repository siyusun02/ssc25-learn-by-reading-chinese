import SwiftUI

struct AppOverlayAccessoryView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var geometry: DocumentLaunchGeometryProxy
    
    var body: some View {
        if horizontalSizeClass == .compact {
            compactView()
        } else {
            regularView()
        }
    }
    
    func regularView() -> some View {
        ZStack {
            Text("~ Chinese Edition ~")
                .padding()
                .background(Color.primary)
                .foregroundStyle(.background)
                .clipShape(.capsule)
                .font(.headline)
                .rotationEffect(.degrees(20))
                .position(x: geometry.titleViewFrame.maxX - 16,
                          y: geometry.titleViewFrame.minY)
            
            Image("Logo")
                .resizable()
                .frame(width: 200, height: 192.5)
                .foregroundStyle(.primary)
                .padding(.bottom)
                .rotationEffect(.degrees(-8))
                .position(x: geometry.titleViewFrame.minX + 8,
                          y: geometry.titleViewFrame.maxY - 116)
        }
    }
    
    func compactView() -> some View {
        ZStack {
            Text("~ Chinese Edition ~")
                .padding()
                .background(Color.primary)
                .foregroundStyle(.background)
                .clipShape(.capsule)
                .font(.caption)
                .rotationEffect(.degrees(10))
                .position(x: geometry.titleViewFrame.maxX - 48,
                          y: geometry.titleViewFrame.minY - 8)
            
            Image("Logo")
                .resizable()
                .frame(width: 120, height: 115.5)
                .foregroundStyle(.primary)
                .padding(.bottom)
                .rotationEffect(.degrees(-8))
                .position(x: geometry.titleViewFrame.minX + 16,
                          y: geometry.titleViewFrame.maxY - 116)
        }
    }
}

