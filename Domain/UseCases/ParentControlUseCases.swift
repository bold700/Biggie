import Foundation
import os.log

// MARK: - Protocols
protocol ParentControlRepositoryProtocol {
    func fetchParentControl() async throws -> ParentControl
    func saveParentControl(_ parentControl: ParentControl) async throws
}

protocol ParentControlValidationProtocol {
    func validatePinCode(_ pinCode: String) throws
    func validateDailyLimit(_ limit: Int) throws
    func validateParentControl(_ parentControl: ParentControl) throws
}

protocol ParentControlLoggingProtocol {
    func logAction(_ action: String, details: [String: Any])
    func logError(_ error: Error, context: String)
}

// MARK: - Use Cases
class ParentControlUseCases {
    private let repository: ParentControlRepositoryProtocol
    private let validator: ParentControlValidationProtocol
    private let logger: ParentControlLoggingProtocol
    private var lastPinValidationAttempt: Date?
    private let pinValidationCooldown: TimeInterval = 1.0
    
    init(
        repository: ParentControlRepositoryProtocol,
        validator: ParentControlValidationProtocol,
        logger: ParentControlLoggingProtocol = DefaultParentControlLogger()
    ) {
        self.repository = repository
        self.validator = validator
        self.logger = logger
    }
    
    func getParentControl() async throws -> ParentControl {
        logger.logAction("fetch_parent_control", details: [:])
        return try await repository.fetchParentControl()
    }
    
    func updateParentControl(_ parentControl: ParentControl) async throws {
        logger.logAction("update_parent_control", details: [
            "isEnabled": parentControl.isEnabled,
            "dailyGoalLimit": parentControl.dailyGoalLimit
        ])
        
        try validator.validateParentControl(parentControl)
        var updatedControl = parentControl
        updatedControl.lastModifiedAt = Date()
        try await repository.saveParentControl(updatedControl)
    }
    
    func validatePinCode(_ pinCode: String) async throws -> Bool {
        // Rate limiting
        if let lastAttempt = lastPinValidationAttempt,
           Date().timeIntervalSince(lastAttempt) < pinValidationCooldown {
            throw AppError.tooManyAttempts("Please wait before trying again")
        }
        lastPinValidationAttempt = Date()
        
        logger.logAction("validate_pin", details: ["length": pinCode.count])
        
        try validator.validatePinCode(pinCode)
        let parentControl = try await repository.fetchParentControl()
        let isValid = parentControl.pinCode == pinCode
        
        if !isValid {
            logger.logError(AppError.invalidPin, context: "PIN validation failed")
        }
        
        return isValid
    }
    
    func updatePinCode(_ pinCode: String) async throws {
        logger.logAction("update_pin", details: ["length": pinCode.count])
        
        try validator.validatePinCode(pinCode)
        var parentControl = try await repository.fetchParentControl()
        parentControl.pinCode = pinCode
        parentControl.lastModifiedAt = Date()
        parentControl.lastModifiedBy = "user"
        try await repository.saveParentControl(parentControl)
    }
    
    func updateDailyLimit(_ limit: Int) async throws {
        logger.logAction("update_daily_limit", details: ["newLimit": limit])
        
        try validator.validateDailyLimit(limit)
        var parentControl = try await repository.fetchParentControl()
        parentControl.dailyGoalLimit = limit
        parentControl.lastModifiedAt = Date()
        parentControl.lastModifiedBy = "user"
        try await repository.saveParentControl(parentControl)
    }
    
    func toggleParentControl() async throws {
        var parentControl = try await repository.fetchParentControl()
        let newState = !parentControl.isEnabled
        
        logger.logAction("toggle_parent_control", details: ["newState": newState])
        
        parentControl.isEnabled = newState
        parentControl.lastModifiedAt = Date()
        parentControl.lastModifiedBy = "user"
        try await repository.saveParentControl(parentControl)
    }
    
    func updateAllowedRewards(_ rewardIds: [UUID]) async throws {
        logger.logAction("update_allowed_rewards", details: ["count": rewardIds.count])
        
        var parentControl = try await repository.fetchParentControl()
        parentControl.allowedRewards = rewardIds
        parentControl.lastModifiedAt = Date()
        parentControl.lastModifiedBy = "user"
        try await repository.saveParentControl(parentControl)
    }
}

// MARK: - Default Implementation
class DefaultParentControlValidator: ParentControlValidationProtocol {
    func validatePinCode(_ pinCode: String) throws {
        if pinCode.isEmpty {
            throw AppError.invalidInput("PIN code cannot be empty")
        }
        
        if pinCode.count != 4 {
            throw AppError.invalidInput("PIN code must be 4 digits")
        }
        
        if !pinCode.allSatisfy({ $0.isNumber }) {
            throw AppError.invalidInput("PIN code must contain only numbers")
        }
    }
    
    func validateDailyLimit(_ limit: Int) throws {
        if limit < 1 {
            throw AppError.invalidInput("Daily limit must be at least 1")
        }
        
        if limit > 20 {
            throw AppError.invalidInput("Daily limit cannot exceed 20")
        }
    }
    
    func validateParentControl(_ parentControl: ParentControl) throws {
        try validatePinCode(parentControl.pinCode)
        try validateDailyLimit(parentControl.dailyGoalLimit)
    }
}

// MARK: - Logger Implementation
class DefaultParentControlLogger: ParentControlLoggingProtocol {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.app", category: "ParentControl")
    
    func logAction(_ action: String, details: [String: Any]) {
        logger.info("\(action): \(details)")
    }
    
    func logError(_ error: Error, context: String) {
        logger.error("\(context): \(error.localizedDescription)")
    }
} 