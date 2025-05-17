import SwiftUI

struct Reward: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var iconName: String
    var isUnlocked: Bool
}

struct RewardView: View {
    let reward: Reward
    @State private var isAnimating = false
    
    var body: some View {
        VStack {
            Image(systemName: reward.iconName)
                .font(.system(size: 60))
                .foregroundColor(reward.isUnlocked ? Theme.accent : .gray)
                .scaleEffect(isAnimating ? 1.2 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isAnimating)
            
            Text(reward.title)
                .font(Theme.headlineFont)
                .foregroundColor(reward.isUnlocked ? Theme.text : .gray)
            
            Text(reward.description)
                .font(Theme.bodyFont)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .fill(Color.white)
                .shadow(radius: 5)
        )
        .onAppear {
            if reward.isUnlocked {
                isAnimating = true
            }
        }
    }
}

struct RewardsView: View {
    @State private var rewards: [Reward] = [
        Reward(title: "First Goal", description: "Completed your first goal!", iconName: "star.fill", isUnlocked: false),
        Reward(title: "Goal Master", description: "Completed 5 goals!", iconName: "trophy.fill", isUnlocked: false),
        Reward(title: "Perfect Week", description: "Completed all goals for a week!", iconName: "crown.fill", isUnlocked: false)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 20) {
                ForEach(rewards) { reward in
                    RewardView(reward: reward)
                }
            }
            .padding()
        }
        .navigationTitle("Rewards")
    }
} 