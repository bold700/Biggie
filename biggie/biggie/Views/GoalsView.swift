import SwiftUI

struct GoalsView: View {
    @StateObject private var viewModel: GoalsViewModel
    @State private var showingAddGoal = false
    
    init(goalUseCases: GoalUseCases, soundManager: SoundManager) {
        _viewModel = StateObject(wrappedValue: GoalsViewModel(goalUseCases: goalUseCases, soundManager: soundManager))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.goals.isEmpty {
                    ContentUnavailableView(
                        "No Goals Yet",
                        systemImage: "star.square",
                        description: Text("Add your first goal to get started!")
                    )
                } else {
                    List {
                        ForEach(viewModel.goals) { goal in
                            GoalRow(goal: goal) {
                                Task {
                                    await viewModel.completeGoal(goal)
                                }
                            }
                        }
                        .onDelete { indexSet in
                            Task {
                                for index in indexSet {
                                    await viewModel.deleteGoal(viewModel.goals[index])
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Goals")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddGoal = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddGoal) {
                CreateGoalView { newGoal in
                    Task {
                        await viewModel.createGoal(newGoal)
                    }
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
        }
        .task {
            await viewModel.loadGoals()
        }
    }
}

struct GoalRow: View {
    let goal: Goal
    let onComplete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(goal.title)
                    .font(.headline)
                Text("\(goal.currentCompletions)/\(goal.requiredCompletions) completed")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if !goal.isCompleted {
                Button {
                    onComplete()
                } label: {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.green)
                        .font(.title2)
                }
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
            }
        }
        .padding(.vertical, 8)
    }
}

struct CreateGoalView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var requiredCompletions = 1
    @State private var reward = ""
    
    let onSave: (Goal) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Goal Title", text: $title)
                    Stepper("Required Completions: \(requiredCompletions)", value: $requiredCompletions, in: 1...10)
                    TextField("Reward", text: $reward)
                }
            }
            .navigationTitle("New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newGoal = Goal(
                            title: title,
                            reward: reward,
                            requiredCompletions: requiredCompletions
                        )
                        onSave(newGoal)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
} 