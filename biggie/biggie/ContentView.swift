import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var profile: Profile? = Profile.load()
    @State private var goals: [Goal] = Goal.load()
    @State private var showingParentControls = false
    @State private var isSoundMuted = false
    
    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
            } else if let profile = profile {
                TabView {
                    GoalsView(goals: $goals)
                        .tabItem {
                            Label("Goals", systemImage: "star.fill")
                        }
                    
                    ProfileView(profile: profile)
                        .tabItem {
                            Label("Profile", systemImage: "person.fill")
                        }
                    
                    RewardsView()
                        .tabItem {
                            Label("Rewards", systemImage: "trophy.fill")
                        }
                }
                .onChange(of: goals) { newGoals in
                    Goal.save(newGoals)
                }
                .tint(Theme.primary)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
                            Button(action: {
                                isSoundMuted.toggle()
                                SoundManager.shared.toggleMute()
                            }) {
                                Image(systemName: isSoundMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                            }
                            
                            Button(action: {
                                showingParentControls = true
                            }) {
                                Image(systemName: "lock.fill")
                            }
                        }
                    }
                }
                .sheet(isPresented: $showingParentControls) {
                    ParentControlView()
                }
            } else {
                CreateProfileView(profile: $profile)
            }
        }
        .preferredColorScheme(.light) // Force light mode for kids
        .onAppear {
            isSoundMuted = SoundManager.shared.isSoundMuted()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
} 