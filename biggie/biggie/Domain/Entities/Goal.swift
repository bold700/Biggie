import Foundation

struct Goal: Identifiable, Codable {
    let id: UUID
    var title: String
    var reward: String
    var requiredCompletions: Int
    var currentCompletions: Int
    var createdAt: Date
    var lastCompletedAt: Date?
    
    var isCompleted: Bool {
        currentCompletions >= requiredCompletions
    }
    
    var progress: Double {
        Double(currentCompletions) / Double(requiredCompletions)
    }
    
    var isOverdue: Bool {
        guard let lastCompleted = lastCompletedAt else { return false }
        return Calendar.current.dateComponents([.day], from: lastCompleted, to: Date()).day ?? 0 > 1
    }
    
    init(
        id: UUID = UUID(),
        title: String,
        reward: String,
        requiredCompletions: Int,
        currentCompletions: Int = 0,
        createdAt: Date = Date(),
        lastCompletedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.reward = reward
        self.requiredCompletions = requiredCompletions
        self.currentCompletions = currentCompletions
        self.createdAt = createdAt
        self.lastCompletedAt = lastCompletedAt
    }
    
    static let examples = [
        Goal(title: "Make my bed", reward: "Sticker", requiredCompletions: 1),
        Goal(title: "Brush my teeth", reward: "Playtime", requiredCompletions: 2),
        Goal(title: "Help mom", reward: "1 coin", requiredCompletions: 3)
    ]
} 