import SwiftUI

struct OverviewView: View {
    var profile: Profile
    var goals: [Goal]

    var completedGoals: Int {
        goals.filter { $0.isCompleted }.count
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Welcome, \(profile.name)!")
                    .font(.largeTitle)
                    .bold()
                Text("Child's Progress")
                    .font(.title2)
                    .padding(.top)
                ProgressView(value: Double(completedGoals), total: Double(goals.count))
                    .accentColor(.green)
                Text("\(completedGoals) of \(goals.count) goals completed")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Divider()
                SectionHeader(title: "Summary")
                HStack(spacing: 16) {
                    InfoCard(label: "Coins", value: "\(profile.coins)")
                    InfoCard(label: "Age", value: "\(profile.age)")
                }
            }
            .padding()
        }
    }
}

#Preview {
    OverviewView(profile: .example, goals: Goal.examples)
} 