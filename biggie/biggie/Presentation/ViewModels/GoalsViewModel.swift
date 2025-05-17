import Foundation
import SwiftUI

@MainActor
class GoalsViewModel: ObservableObject {
    @Published var goals: [Goal] = []
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private let goalUseCases: GoalUseCases
    private let soundManager: SoundManager
    
    init(goalUseCases: GoalUseCases, soundManager: SoundManager) {
        self.goalUseCases = goalUseCases
        self.soundManager = soundManager
    }
    
    func loadGoals() async {
        isLoading = true
        do {
            goals = try await goalUseCases.getGoals()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func completeGoal(_ goal: Goal) async {
        do {
            try await goalUseCases.completeGoal(goal)
            soundManager.playSound(.goalCompleted)
            await loadGoals()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func createGoal(_ goal: Goal) async {
        do {
            try await goalUseCases.createGoal(goal)
            soundManager.playSound(.buttonTap)
            await loadGoals()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteGoal(_ goal: Goal) async {
        do {
            try await goalUseCases.deleteGoal(goal)
            soundManager.playSound(.buttonTap)
            await loadGoals()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func checkDailyProgress() {
        do {
            try goalUseCases.checkDailyProgress(goals)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
} 