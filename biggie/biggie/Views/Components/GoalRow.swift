import SwiftUI

struct GoalRow: View {
    let goal: Goal

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(goal.title)
                .font(.headline)
            Text("Reward: \(goal.reward)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            ProgressView(value: goal.progress)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    GoalRow(goal: Goal.examples[0])
} 