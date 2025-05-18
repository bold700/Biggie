import Foundation

struct Profile: Identifiable, Codable {
    let id: UUID
    var name: String
    var age: Int
    var avatarColor: String
    var coins: Int
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        name: String,
        age: Int,
        avatarColor: String = "#007AFF",
        coins: Int = 0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.age = age
        self.avatarColor = avatarColor
        self.coins = coins
        self.createdAt = createdAt
    }
    
    static let example = Profile(
        name: "Tom",
        age: 7,
        avatarColor: "#FF9500"
    )
} 