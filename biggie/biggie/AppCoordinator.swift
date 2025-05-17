import SwiftUI

class AppCoordinator: ObservableObject {
    @Published var currentTab: Tab = .goals
    @Published var showingParentControls = false
    @Published var showingAddGoal = false
    @Published var showingError = false
    @Published var errorMessage = ""
    
    let goalService: GoalServiceProtocol
    let parentControlService: ParentControlServiceProtocol
    
    init(
        goalService: GoalServiceProtocol = GoalService(),
        parentControlService: ParentControlServiceProtocol = ParentControlService()
    ) {
        self.goalService = goalService
        self.parentControlService = parentControlService
    }
    
    func showError(_ error: AppError) {
        errorMessage = error.localizedDescription
        showingError = true
    }
    
    func handleGoalCompletion(_ goal: Goal) {
        do {
            try parentControlService.validateGoalCompletion(goal)
            goalService.updateGoal(goal)
            SoundManager.shared.playSound(.goalComplete)
        } catch {
            showError(error as! AppError)
        }
    }
}

enum Tab {
    case goals
    case profile
    case rewards
}

// Protocol voor ParentControlService
protocol ParentControlServiceProtocol {
    func validateGoalCompletion(_ goal: Goal) throws
    func validateReward(_ reward: String) throws
}

class ParentControlService: ParentControlServiceProtocol {
    private let userDefaults: UserDefaults
    private let key = "parentControl"
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func validateGoalCompletion(_ goal: Goal) throws {
        let control = loadParentControl()
        if control.isEnabled {
            // Implementeer validatie logica
        }
    }
    
    func validateReward(_ reward: String) throws {
        let control = loadParentControl()
        if !control.allowedRewards.contains(reward) {
            throw AppError.rewardNotAllowed
        }
    }
    
    private func loadParentControl() -> ParentControl {
        if let data = userDefaults.data(forKey: key),
           let control = try? JSONDecoder().decode(ParentControl.self, from: data) {
            return control
        }
        return ParentControl.default
    }
} 