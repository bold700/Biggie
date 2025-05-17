import Foundation

class GoalRepository: GoalRepositoryProtocol {
    private let userDefaults: UserDefaults
    private let goalsKey = "savedGoals"
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func fetchGoals() async throws -> [Goal] {
        guard let data = userDefaults.data(forKey: goalsKey) else {
            return []
        }
        
        do {
            let goals = try JSONDecoder().decode([Goal].self, from: data)
            return goals
        } catch {
            throw AppError.dataLoadFailed(error)
        }
    }
    
    func saveGoals(_ goals: [Goal]) async throws {
        do {
            let data = try JSONEncoder().encode(goals)
            userDefaults.set(data, forKey: goalsKey)
        } catch {
            throw AppError.dataSaveFailed(error)
        }
    }
    
    func addGoal(_ goal: Goal) async throws {
        var goals = try await fetchGoals()
        goals.append(goal)
        try await saveGoals(goals)
    }
    
    func updateGoal(_ goal: Goal) async throws {
        var goals = try await fetchGoals()
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index] = goal
            try await saveGoals(goals)
        }
    }
    
    func deleteGoal(_ goal: Goal) async throws {
        var goals = try await fetchGoals()
        goals.removeAll { $0.id == goal.id }
        try await saveGoals(goals)
    }
} 