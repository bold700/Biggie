import Foundation

struct Goal: Identifiable, Codable {
    var id = UUID()
    var title: String
    var reward: String
    var requiredCompletions: Int
    var currentCompletions: Int
    var isCompleted: Bool {
        currentCompletions >= requiredCompletions
    }
    
    static let examples = [
        Goal(title: "Make my bed", reward: "Sticker", requiredCompletions: 1, currentCompletions: 0),
        Goal(title: "Brush my teeth", reward: "Playtime", requiredCompletions: 2, currentCompletions: 0),
        Goal(title: "Help mom", reward: "1 coin", requiredCompletions: 3, currentCompletions: 0)
    ]
    
    static func save(_ goals: [Goal]) {
        if let encoded = try? JSONEncoder().encode(goals) {
            UserDefaults.standard.set(encoded, forKey: "savedGoals")
        }
    }
    
    static func load() -> [Goal] {
        if let data = UserDefaults.standard.data(forKey: "savedGoals"),
           let goals = try? JSONDecoder().decode([Goal].self, from: data) {
            return goals
        }
        return examples
    }
} 