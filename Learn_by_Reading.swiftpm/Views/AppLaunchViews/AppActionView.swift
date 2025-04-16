import SwiftUI

struct AppActionView: View {
    @Binding var showSample: Bool
    @Binding var showOnboarding: Bool
    
    var body: some View {
        Button("Try a sample PDF") {
            showSample = true
        }.fullScreenCover(isPresented: $showSample) {
            VStack{
                HStack {
                    Button {
                        showSample = false
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                    Text("Sample PDF")
                    Spacer()
                }.padding().fontWeight(.bold)
                
                PDFDocumentView(document: SampleData.shared.pdf)
            }
        }
        
        Button("About this app...") {
            showOnboarding = true
        }.sheet(isPresented: $showOnboarding,
                onDismiss: {UserDefaultsUtils.hideOnboarding = true}) {
            WelcomeView(isPresented: $showOnboarding)
        }
    }
}
