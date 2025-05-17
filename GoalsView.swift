import SwiftUI

struct GoalsView: View {
    @Binding var goals: [Goal]
    @State private var showingAddGoal = false
    @AppStorage("parentControl") private var parentControlData: Data = try! JSONEncoder().encode(ParentControl.default)
    @State private var parentControl: ParentControl = ParentControl.default
    
    var body: some View {
        NavigationView {
            List {
                ForEach($goals) { $goal in
                    GoalRow(goal: $goal, parentControl: parentControl)
                }
            }
            .navigationTitle("My Goals")
            .toolbar {
                Button(action: {
                    SoundManager.shared.playSound(.buttonTap)
                    showingAddGoal = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
            .sheet(isPresented: $showingAddGoal) {
                AddGoalView(goals: $goals)
            }
            .onAppear {
                loadParentControl()
            }
        }
    }
    
    private func loadParentControl() {
        if let control = try? JSONDecoder().decode(ParentControl.self, from: parentControlData) {
            parentControl = control
        }
    }
}

struct GoalRow: View {
    @Binding var goal: Goal
    let parentControl: ParentControl
    @State private var showingCompletionAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(goal.title)
                .font(.headline)
            
            HStack {
                Text("Reward: \(goal.reward)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(goal.currentCompletions)/\(goal.requiredCompletions)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: Double(goal.currentCompletions), total: Double(goal.requiredCompletions))
                .tint(.blue)
            
            Button(action: {
                SoundManager.shared.playSound(.buttonTap)
                if parentControl.isEnabled {
                    showingCompletionAlert = true
                } else {
                    incrementCompletion()
                }
            }) {
                Text("Done!")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(goal.isCompleted)
        }
        .padding(.vertical, 8)
        .alert("Parent Approval Required", isPresented: $showingCompletionAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Approve") {
                incrementCompletion()
            }
        } message: {
            Text("Please ask a parent to approve this goal completion.")
        }
    }
    
    private func incrementCompletion() {
        goal.currentCompletions += 1
        SoundManager.shared.playSound(.goalComplete)
        
        if goal.isCompleted {
            SoundManager.shared.playSound(.rewardEarned)
        }
    }
} 