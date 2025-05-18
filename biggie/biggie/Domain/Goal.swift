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
        Goal(title: "Maak mijn bed op", reward: "Sticker", requiredCompletions: 1),
        Goal(title: "Tanden poetsen", reward: "Speeltijd", requiredCompletions: 2),
        Goal(title: "Help mama", reward: "1 munt", requiredCompletions: 3)
    ]
} 