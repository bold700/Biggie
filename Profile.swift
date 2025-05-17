import Foundation

struct Profile: Identifiable, Codable {
    var id = UUID()
    var name: String
    var age: Int
    var favoriteColor: String?
    var favoriteCharacter: String?
    
    static let example = Profile(
        name: "Tom",
        age: 7,
        favoriteColor: "Blue",
        favoriteCharacter: "Superhero"
    )
    
    static func save(_ profile: Profile) {
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: "savedProfile")
        }
    }
    
    static func load() -> Profile? {
        if let data = UserDefaults.standard.data(forKey: "savedProfile"),
           let profile = try? JSONDecoder().decode(Profile.self, from: data) {
            return profile
        }
        return nil
    }
} 