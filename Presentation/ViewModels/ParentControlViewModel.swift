import Foundation
import SwiftUI
import Combine

@MainActor
class ParentControlViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var parentControl: ParentControl?
    @Published private(set) var errorMessage: String?
    @Published private(set) var isLoading = false
    @Published private(set) var isAuthenticated = false
    @Published private(set) var validationAttempts = 0
    
    // MARK: - Private Properties
    private let parentControlUseCases: ParentControlUseCases
    private let soundManager: SoundManager
    private var cancellables = Set<AnyCancellable>()
    private let maxValidationAttempts = 3
    private let validationResetInterval: TimeInterval = 300 // 5 minutes
    
    // MARK: - Initialization
    init(parentControlUseCases: ParentControlUseCases, soundManager: SoundManager) {
        self.parentControlUseCases = parentControlUseCases
        self.soundManager = soundManager
        setupValidationReset()
    }
    
    // MARK: - Public Methods
    func loadParentControl() async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            parentControl = try await parentControlUseCases.getParentControl()
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    func validatePinCode(_ pinCode: String) async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            isAuthenticated = try await parentControlUseCases.validatePinCode(pinCode)
            if isAuthenticated {
                soundManager.playSound(.buttonTap)
                validationAttempts = 0
            } else {
                handleFailedValidation()
            }
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    func updatePinCode(_ pinCode: String) async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await parentControlUseCases.updatePinCode(pinCode)
            soundManager.playSound(.buttonTap)
            await loadParentControl()
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    func updateDailyLimit(_ limit: Int) async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await parentControlUseCases.updateDailyLimit(limit)
            soundManager.playSound(.buttonTap)
            await loadParentControl()
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    func toggleParentControl() async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await parentControlUseCases.toggleParentControl()
            soundManager.playSound(.buttonTap)
            await loadParentControl()
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    func updateAllowedRewards(_ rewardIds: [UUID]) async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await parentControlUseCases.updateAllowedRewards(rewardIds)
            soundManager.playSound(.buttonTap)
            await loadParentControl()
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    // MARK: - Private Methods
    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        soundManager.playSound(.error)
    }
    
    private func handleFailedValidation() {
        validationAttempts += 1
        soundManager.playSound(.error)
        
        if validationAttempts >= maxValidationAttempts {
            errorMessage = "Too many failed attempts. Please try again later."
            isAuthenticated = false
        } else {
            errorMessage = "Invalid PIN code. \(maxValidationAttempts - validationAttempts) attempts remaining."
        }
    }
    
    private func setupValidationReset() {
        Timer.publish(every: validationResetInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.validationAttempts = 0
            }
            .store(in: &cancellables)
    }
} 