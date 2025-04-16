import SwiftUI

struct CopyButton: View {
    @State private var clicked = false
    var label: String = "Copy"
    var labelClicked: String = "Copied!"
    var duration: Double = 2

    var textToCopy: String
    var maxHeight: CGFloat = 20
    
    var body: some View {
        HStack {
            Button(action: {
                guard !self.clicked else { return }
                
                UIPasteboard.general.string = textToCopy
                withAnimation {
                    self.clicked = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    self.clicked = false
                }
            }) {
                Label(self.clicked ? labelClicked : label, systemImage: "doc.on.doc.fill")
                    .frame(maxHeight: self.maxHeight)
            }
            .buttonStyle(.primary)
        }
    }
}

#Preview {
    HStack {
        CopyButton(textToCopy: "Copy me")
        Button("test") {}.buttonStyle(.primary)
    }
}
