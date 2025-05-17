import Foundation

protocol GoalServiceProtocol {
    func loadGoals() -> [Goal]
    func saveGoals(_ goals: [Goal])
    func addGoal(_ goal: Goal)
    func updateGoal(_ goal: Goal)
    func deleteGoal(_ goal: Goal)
}

class GoalService: GoalServiceProtocol {
    private let userDefaults: UserDefaults
    private let key = "savedGoals"
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func loadGoals() -> [Goal] {
        if let data = userDefaults.data(forKey: key),
           let goals = try? JSONDecoder().decode([Goal].self, from: data) {
            return goals
        }
        return Goal.examples
    }
    
    func saveGoals(_ goals: [Goal]) {
        if let encoded = try? JSONEncoder().encode(goals) {
            userDefaults.set(encoded, forKey: key)
        }
    }
    
    func addGoal(_ goal: Goal) {
        var goals = loadGoals()
        goals.append(goal)
        saveGoals(goals)
    }
    
    func updateGoal(_ goal: Goal) {
        var goals = loadGoals()
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index] = goal
            saveGoals(goals)
        }
    }
    
    func deleteGoal(_ goal: Goal) {
        var goals = loadGoals()
        goals.removeAll { $0.id == goal.id }
        saveGoals(goals)
    }
} 