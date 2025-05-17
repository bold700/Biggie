import SwiftUI

struct AddGoalView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var goals: [Goal]
    
    @State private var title = ""
    @State private var reward = ""
    @State private var requiredCompletions = 1
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("New Goal")) {
                    TextField("What do you want to do?", text: $title)
                    TextField("What's your reward?", text: $reward)
                    
                    Stepper("Times to complete: \(requiredCompletions)", value: $requiredCompletions, in: 1...10)
                }
                
                Button(action: addGoal) {
                    Text("Add Goal")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                }
                .listRowBackground(Color.blue)
                .disabled(title.isEmpty || reward.isEmpty)
            }
            .navigationTitle("New Goal")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
    
    private func addGoal() {
        let newGoal = Goal(
            title: title,
            reward: reward,
            requiredCompletions: requiredCompletions,
            currentCompletions: 0
        )
        goals.append(newGoal)
        dismiss()
    }
} 