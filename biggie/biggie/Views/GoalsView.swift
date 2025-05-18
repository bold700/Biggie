import SwiftUI

struct GoalsView: View {
    @Binding var goals: [Goal]

    var body: some View {
        NavigationStack {
            List {
                ForEach(goals) { goal in
                    GoalRow(goal: goal)
                }
                .onDelete(perform: deleteGoal)
            }
            .navigationTitle("Goals")
            .toolbar {
                EditButton()
            }
        }
    }

    private func deleteGoal(at offsets: IndexSet) {
        goals.remove(atOffsets: offsets)
    }
}

#Preview {
    GoalsView(goals: .constant(Goal.examples))
} 