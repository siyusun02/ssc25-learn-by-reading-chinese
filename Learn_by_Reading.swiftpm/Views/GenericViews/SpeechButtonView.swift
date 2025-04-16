import SwiftUI

struct SpeechButton: View {
    private var speechHelper: SpeechHelper
    
    @State var isPlaying = false
    let text: String
    
    init(speechHelper: SpeechHelper, isPlaying: Bool = false, text: String) {
        self.speechHelper = speechHelper
        self.isPlaying = isPlaying
        self.text = text
    }
    
    var body: some View {
        Button {
            if isPlaying {
                isPlaying = false
                speechHelper.stop()
            } else {
                isPlaying = true
                speechHelper.speak(text: text, isPlaying: $isPlaying)
            }
        } label: {
            Image(systemName: "speaker.wave.2.fill")
                .resizable()
                .frame(width: 16, height: 16)
                .padding(2)
        }.buttonStyle(.secondary)
    }
}
