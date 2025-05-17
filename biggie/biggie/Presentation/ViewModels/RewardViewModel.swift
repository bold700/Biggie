import Foundation
import SwiftUI

@MainActor
class RewardViewModel: ObservableObject {
    @Published var rewards: [Reward] = []
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private let rewardUseCases: RewardUseCases
    private let profileUseCases: ProfileUseCases
    private let soundManager: SoundManager
    
    init(rewardUseCases: RewardUseCases, profileUseCases: ProfileUseCases, soundManager: SoundManager) {
        self.rewardUseCases = rewardUseCases
        self.profileUseCases = profileUseCases
        self.soundManager = soundManager
    }
    
    func loadRewards() async {
        isLoading = true
        do {
            rewards = try await rewardUseCases.getRewards()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func createReward(_ reward: Reward) async {
        do {
            try await rewardUseCases.createReward(reward)
            soundManager.playSound(.buttonTap)
            await loadRewards()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func updateReward(_ reward: Reward) async {
        do {
            try await rewardUseCases.updateReward(reward)
            soundManager.playSound(.buttonTap)
            await loadRewards()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteReward(_ reward: Reward) async {
        do {
            try await rewardUseCases.deleteReward(reward)
            soundManager.playSound(.buttonTap)
            await loadRewards()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func unlockReward(_ reward: Reward) async {
        guard let profile = try? await profileUseCases.getProfile() else {
            errorMessage = "Profile not found"
            return
        }
        
        do {
            let updatedReward = try await rewardUseCases.unlockReward(reward, profileCoins: profile.coins)
            try await profileUseCases.addCoins(-reward.cost, to: profile)
            soundManager.playSound(.rewardUnlocked)
            await loadRewards()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
} 