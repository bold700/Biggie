import Foundation
import SwiftUI

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var profile: Profile?
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private let profileUseCases: ProfileUseCases
    private let soundManager: SoundManager
    
    init(profileUseCases: ProfileUseCases, soundManager: SoundManager) {
        self.profileUseCases = profileUseCases
        self.soundManager = soundManager
    }
    
    func loadProfile() async {
        isLoading = true
        do {
            profile = try await profileUseCases.getProfile()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func createProfile(_ profile: Profile) async {
        do {
            try await profileUseCases.createProfile(profile)
            soundManager.playSound(.buttonTap)
            await loadProfile()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func updateProfile(_ profile: Profile) async {
        do {
            try await profileUseCases.updateProfile(profile)
            soundManager.playSound(.buttonTap)
            await loadProfile()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteProfile() async {
        do {
            try await profileUseCases.deleteProfile()
            soundManager.playSound(.buttonTap)
            await loadProfile()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func addCoins(_ amount: Int) async {
        guard let currentProfile = profile else { return }
        
        do {
            try await profileUseCases.addCoins(amount, to: currentProfile)
            soundManager.playSound(.coinEarned)
            await loadProfile()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
} 