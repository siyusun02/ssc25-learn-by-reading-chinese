import SwiftUI
import WebKit

struct HelpView: View {
    var onClose: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Controls")
                .font(.largeTitle)
                .bold()
            
            Spacer()
            
            Divider()
            
            VStack(spacing: 12) {
                Image(systemName: "hand.rays.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 80)
                
                Text("Tap a character to see its definition, pinyin, translation, and related words.")
                    .font(.headline)
                    .multilineTextAlignment(.center)
            }
            
            Divider()
            
            VStack(spacing: 12) {
                Image(systemName: "selection.pin.in.out")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 80)
                
                Text("Long press & drag to select phrases for translation.")
                    .font(.headline)
                    .multilineTextAlignment(.center)
            }
            
            Divider()
            
            Spacer()
            
            Button("Got it") {
                onClose?()
            }
            .buttonStyle(.primary)
            .font(.title3)
            .padding(.top, 8)
        }
        .presentationBackground(.thinMaterial)
        .padding(.vertical, 32)
    }
}

#Preview {
    @Previewable @State var show = true
    Button("Click") {
        show = true
    }
    .fullScreenCover(isPresented: $show) {
        HelpView { show = false }
    }
}
