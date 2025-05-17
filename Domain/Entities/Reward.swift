import Foundation

struct Reward: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var cost: Int
    var isUnlocked: Bool
    var createdAt: Date
    var unlockedAt: Date?
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        cost: Int,
        isUnlocked: Bool = false,
        createdAt: Date = Date(),
        unlockedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.cost = cost
        self.isUnlocked = isUnlocked
        self.createdAt = createdAt
        self.unlockedAt = unlockedAt
    }
    
    static let examples = [
        Reward(
            title: "Extra Playtime",
            description: "15 minutes extra playtime",
            cost: 5
        ),
        Reward(
            title: "Ice Cream",
            description: "Your favorite ice cream",
            cost: 10
        ),
        Reward(
            title: "Movie Night",
            description: "Watch your favorite movie",
            cost: 20
        )
    ]
} 