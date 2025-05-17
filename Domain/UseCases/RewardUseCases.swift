import Foundation

// MARK: - Protocols
protocol RewardRepositoryProtocol {
    func fetchRewards() async throws -> [Reward]
    func saveRewards(_ rewards: [Reward]) async throws
    func addReward(_ reward: Reward) async throws
    func updateReward(_ reward: Reward) async throws
    func deleteReward(_ reward: Reward) async throws
}

protocol RewardValidationProtocol {
    func validateReward(_ reward: Reward) throws
    func validateRewardUnlock(_ reward: Reward, profileCoins: Int) throws
}

// MARK: - Use Cases
class RewardUseCases {
    private let repository: RewardRepositoryProtocol
    private let validator: RewardValidationProtocol
    
    init(repository: RewardRepositoryProtocol, validator: RewardValidationProtocol) {
        self.repository = repository
        self.validator = validator
    }
    
    func getRewards() async throws -> [Reward] {
        return try await repository.fetchRewards()
    }
    
    func createReward(_ reward: Reward) async throws {
        try validator.validateReward(reward)
        try await repository.addReward(reward)
    }
    
    func updateReward(_ reward: Reward) async throws {
        try validator.validateReward(reward)
        try await repository.updateReward(reward)
    }
    
    func deleteReward(_ reward: Reward) async throws {
        try await repository.deleteReward(reward)
    }
    
    func unlockReward(_ reward: Reward, profileCoins: Int) async throws -> Reward {
        try validator.validateRewardUnlock(reward, profileCoins: profileCoins)
        
        var updatedReward = reward
        updatedReward.isUnlocked = true
        updatedReward.unlockedAt = Date()
        
        try await repository.updateReward(updatedReward)
        return updatedReward
    }
}

// MARK: - Default Implementation
class DefaultRewardValidator: RewardValidationProtocol {
    func validateReward(_ reward: Reward) throws {
        if reward.title.isEmpty {
            throw AppError.invalidInput("Reward title cannot be empty")
        }
        
        if reward.description.isEmpty {
            throw AppError.invalidInput("Reward description cannot be empty")
        }
        
        if reward.cost < 1 {
            throw AppError.invalidInput("Reward cost must be at least 1")
        }
    }
    
    func validateRewardUnlock(_ reward: Reward, profileCoins: Int) throws {
        if reward.isUnlocked {
            throw AppError.rewardAlreadyUnlocked
        }
        
        if profileCoins < reward.cost {
            throw AppError.insufficientCoins
        }
    }
} 