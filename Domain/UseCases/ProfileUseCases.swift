import Foundation

// MARK: - Protocols
protocol ProfileRepositoryProtocol {
    func fetchProfile() async throws -> Profile?
    func saveProfile(_ profile: Profile) async throws
    func updateProfile(_ profile: Profile) async throws
    func deleteProfile() async throws
}

protocol ProfileValidationProtocol {
    func validateProfile(_ profile: Profile) throws
    func validateName(_ name: String) throws
    func validateAge(_ age: Int) throws
}

// MARK: - Use Cases
class ProfileUseCases {
    private let repository: ProfileRepositoryProtocol
    private let validator: ProfileValidationProtocol
    
    init(repository: ProfileRepositoryProtocol, validator: ProfileValidationProtocol) {
        self.repository = repository
        self.validator = validator
    }
    
    func getProfile() async throws -> Profile? {
        return try await repository.fetchProfile()
    }
    
    func createProfile(_ profile: Profile) async throws {
        try validator.validateProfile(profile)
        try await repository.saveProfile(profile)
    }
    
    func updateProfile(_ profile: Profile) async throws {
        try validator.validateProfile(profile)
        try await repository.updateProfile(profile)
    }
    
    func deleteProfile() async throws {
        try await repository.deleteProfile()
    }
    
    func addCoins(_ amount: Int, to profile: Profile) async throws {
        var updatedProfile = profile
        updatedProfile.coins += amount
        try await repository.updateProfile(updatedProfile)
    }
}

// MARK: - Default Implementation
class DefaultProfileValidator: ProfileValidationProtocol {
    func validateProfile(_ profile: Profile) throws {
        try validateName(profile.name)
        try validateAge(profile.age)
    }
    
    func validateName(_ name: String) throws {
        if name.isEmpty {
            throw AppError.invalidInput("Name cannot be empty")
        }
        
        if name.count < 2 {
            throw AppError.invalidInput("Name must be at least 2 characters")
        }
        
        if name.count > 20 {
            throw AppError.invalidInput("Name must be less than 20 characters")
        }
    }
    
    func validateAge(_ age: Int) throws {
        if age < 5 {
            throw AppError.invalidInput("Age must be at least 5")
        }
        
        if age > 8 {
            throw AppError.invalidInput("Age must be at most 8")
        }
    }
} 