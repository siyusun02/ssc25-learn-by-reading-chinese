import SwiftUI

struct WelcomeView: View {
    @Binding var isPresented: Bool
    @State private var tabSelection = 0
    
    var body: some View {
        TabView(selection: $tabSelection) {
            Tab(value: 0) {
                OnboardingTabView (
                    image: "Onboarding-1",
                    title: "Welcome to Learn by Reading",
                    text: "Designed for students learning Chinese, who want to expand their vocabulary through content they enjoy.",
                    extraText: "~ Chinese Edition ~") {
                        withAnimation {
                            tabSelection = 1
                        }
                }
            }
            
            Tab(value: 1) {
                OnboardingTabView (
                    image: "Onboarding-2",
                    title: "This is for you",
                    text: "If you're learning Chinese and love reading books, novels, comics or online content in Chinese, this app is made for you.",
                    extraText: "~ I want to read in Chinese ~") {
                        withAnimation {
                            tabSelection = 2
                        }
                }
            }
            
            Tab(value: 2) {
                OnboardingTabView (
                    image: "Onboarding-3",
                    title: "Enhance Your Reading Experience",
                    text: "An advanced PDF reader for your favorite Chinese content. Simply open any PDF on your device and start reading!",
                    extraText: "~ A PDF Reader, but better ~") {
                        withAnimation {
                            tabSelection = 3
                        }
                }
            }
            
            Tab(value: 3) {
                OnboardingTabView (
                    image: "Onboarding-4",
                    title: "Instant Look-up & Translation",
                    text: "Tap any Chinese word you don’t know to get instant translations, look-up results, and more.",
                    buttonText: "Try it now!",
                    extraText: "~ Helping you when you're stuck ~") {
                        withAnimation {
                            self.isPresented = false
                        }
                }
            }
        }.tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .interactive))
    }
}

struct OnboardingTabView: View {
    let image: String
    let title: String
    let text: String
    let buttonText: String
    let extraText: String?
    let onClick: (() -> Void)?
    
    init(image: String,
         title: String,
         text: String,
         buttonText: String = "Next Page",
         extraText: String? = nil,
         onClick: (() -> Void)?) {
        self.image = image
        self.title = title
        self.text = text
        self.buttonText = buttonText
        self.extraText = extraText
        self.onClick = onClick
    }
    
    var body: some View {
        VStack (spacing: 16) {
            Image(image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 300)
                .padding(.top, 48)
            
            if let t = extraText {
                Text(t).italic()
            }
            
            Text(title).font(.title2).bold()
            Text(text)
            
            Spacer()
            
            Button (buttonText) { onClick?()}
                .buttonStyle(.primary)
                
        }
        .multilineTextAlignment(.center)
        .padding()
        .padding(.bottom, 36)
        .font(.title3)
        
    }
}

#Preview {
    @Previewable @State var showingSheet: Bool = true
    
    Button("Show") {
        showingSheet = true
    }.buttonStyle(.primary)
        .sheet(isPresented: $showingSheet) {
            WelcomeView(isPresented: $showingSheet)
        }
}
