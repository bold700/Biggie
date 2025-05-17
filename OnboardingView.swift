import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    
    let pages = [
        OnboardingPage(
            title: "Welcome to Biggie!",
            description: "Your fun adventure to achieve goals and earn rewards!",
            imageName: "star.fill"
        ),
        OnboardingPage(
            title: "Set Your Goals",
            description: "Create fun tasks and choose your rewards",
            imageName: "list.bullet"
        ),
        OnboardingPage(
            title: "Track Progress",
            description: "Watch your progress grow and earn rewards",
            imageName: "chart.bar.fill"
        ),
        OnboardingPage(
            title: "Have Fun!",
            description: "Let's start your adventure!",
            imageName: "hand.thumbsup.fill"
        )
    ]
    
    var body: some View {
        TabView(selection: $currentPage) {
            ForEach(0..<pages.count, id: \.self) { index in
                VStack(spacing: 20) {
                    Image(systemName: pages[index].imageName)
                        .font(.system(size: 80))
                        .foregroundColor(Theme.primary)
                        .padding()
                    
                    Text(pages[index].title)
                        .font(Theme.titleFont)
                        .multilineTextAlignment(.center)
                    
                    Text(pages[index].description)
                        .font(Theme.bodyFont)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    if index == pages.count - 1 {
                        Button(action: {
                            withAnimation {
                                hasCompletedOnboarding = true
                            }
                        }) {
                            Text("Get Started!")
                                .font(Theme.headlineFont)
                                .modifier(Theme.buttonStyle())
                        }
                        .padding(.top, 20)
                    }
                }
                .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let imageName: String
} 