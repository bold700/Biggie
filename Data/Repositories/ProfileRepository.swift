import Foundation

class ProfileRepository: ProfileRepositoryProtocol {
    private let userDefaults: UserDefaults
    private let profileKey = "savedProfile"
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func fetchProfile() async throws -> Profile? {
        guard let data = userDefaults.data(forKey: profileKey) else {
            return nil
        }
        
        do {
            let profile = try JSONDecoder().decode(Profile.self, from: data)
            return profile
        } catch {
            throw AppError.dataLoadFailed(error)
        }
    }
    
    func saveProfile(_ profile: Profile) async throws {
        do {
            let data = try JSONEncoder().encode(profile)
            userDefaults.set(data, forKey: profileKey)
        } catch {
            throw AppError.dataSaveFailed(error)
        }
    }
    
    func updateProfile(_ profile: Profile) async throws {
        try await saveProfile(profile)
    }
    
    func deleteProfile() async throws {
        userDefaults.removeObject(forKey: profileKey)
    }
} 