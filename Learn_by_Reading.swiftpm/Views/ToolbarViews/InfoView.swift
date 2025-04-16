import SwiftUI
import WebKit

struct InfoView: View {
    var onClose: (() -> Void)? = nil
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Info").font(.largeTitle).bold()
                    
                    Text("About This App").font(.headline)
                    
                    Text("Hi, I'm Si Yu, the creator of this app. I built it because, when I started formally learning Chinese, I struggled to find enjoyable yet affordable graded readers. Meanwhile, plenty of free web novels caught my interest, but they lacked the interactive learning tools I needed. Reading the originals was great for improving my Chinese, but constantly copy/pasting characters, especially when inbuilt os translation tools failed or when I was offline, got really annoying (and it was just not fun anymore).")
                    
                    
                    Text("This app makes this process smoother and more enjoyable. Now, I can read content I actually enjoy instead of settling for the graded reader stories that I choose because they were the only choice. I hope fellow Chinese learners, in particular those who speak better than they read, but want to improve on that, find this useful. The pinyin view is especially great for that as well in my opinion!")
                    
                    Text("Dictionary Source").font(.headline)
                    
                    Text("This app uses CC-CEDICT, an open-source Chinese-English dictionary. Because it is bundled into the app, it is availbe offline aswell, making it pretty fast. The CC-CEDICT data is available for download and modification under a Creative Commons Attribution-ShareAlike 4.0 International License. You can find it here:\n https://www.mdbg.net/chinese/dictionary?page=cedict")
                }
                .frame(maxWidth: 600)
                .padding()
            }
            
            Spacer()
            
            Button("Got it") {
                onClose?()
            }
            .buttonStyle(.primary)
            .font(.title3)
            .padding()
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
        InfoView { show = false }
    }
}
