import Foundation

// MARK: - Protocols
protocol GoalRepositoryProtocol {
    func fetchGoals() async throws -> [Goal]
    func saveGoals(_ goals: [Goal]) async throws
    func addGoal(_ goal: Goal) async throws
    func updateGoal(_ goal: Goal) async throws
    func deleteGoal(_ goal: Goal) async throws
}

protocol GoalValidationProtocol {
    func validateGoalCompletion(_ goal: Goal) throws
    func validateNewGoal(_ goal: Goal) throws
    func validateDailyLimit(_ goals: [Goal]) throws
}

// MARK: - Use Cases
class GoalUseCases {
    private let repository: GoalRepositoryProtocol
    private let validator: GoalValidationProtocol
    
    init(repository: GoalRepositoryProtocol, validator: GoalValidationProtocol) {
        self.repository = repository
        self.validator = validator
    }
    
    func getGoals() async throws -> [Goal] {
        return try await repository.fetchGoals()
    }
    
    func completeGoal(_ goal: Goal) async throws {
        try validator.validateGoalCompletion(goal)
        var updatedGoal = goal
        updatedGoal.currentCompletions += 1
        updatedGoal.lastCompletedAt = Date()
        try await repository.updateGoal(updatedGoal)
    }
    
    func createGoal(_ goal: Goal) async throws {
        try validator.validateNewGoal(goal)
        try await repository.addGoal(goal)
    }
    
    func deleteGoal(_ goal: Goal) async throws {
        try await repository.deleteGoal(goal)
    }
    
    func checkDailyProgress(_ goals: [Goal]) throws {
        try validator.validateDailyLimit(goals)
    }
}

// MARK: - Default Implementation
class DefaultGoalValidator: GoalValidationProtocol {
    private let parentControlService: ParentControlServiceProtocol
    private let maxDailyGoals: Int
    
    init(parentControlService: ParentControlServiceProtocol, maxDailyGoals: Int = 5) {
        self.parentControlService = parentControlService
        self.maxDailyGoals = maxDailyGoals
    }
    
    func validateGoalCompletion(_ goal: Goal) throws {
        if goal.isCompleted {
            throw AppError.goalLimitReached
        }
        
        try parentControlService.validateGoalCompletion(goal)
    }
    
    func validateNewGoal(_ goal: Goal) throws {
        if goal.title.isEmpty {
            throw AppError.invalidInput("Goal title cannot be empty")
        }
        
        if goal.requiredCompletions < 1 {
            throw AppError.invalidInput("Required completions must be at least 1")
        }
    }
    
    func validateDailyLimit(_ goals: [Goal]) throws {
        let today = Calendar.current.startOfDay(for: Date())
        let completedToday = goals.filter { goal in
            guard let lastCompleted = goal.lastCompletedAt else { return false }
            return Calendar.current.isDate(lastCompleted, inSameDayAs: today)
        }
        
        if completedToday.count >= maxDailyGoals {
            throw AppError.goalLimitReached
        }
    }
} 