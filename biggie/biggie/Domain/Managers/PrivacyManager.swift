import Foundation
import LocalAuthentication
import UserNotifications
import os.log

enum PrivacyPermission: String {
    case faceID = "Face ID"
    case notifications = "Notifications"
    case analytics = "Analytics"
    case location = "Location"
}

class PrivacyManager: ObservableObject {
    @Published private(set) var grantedPermissions: Set<PrivacyPermission> = []
    @Published private(set) var isPrivacyPolicyAccepted = false
    
    private let userDefaults: UserDefaults
    private let privacyPolicyKey = "privacyPolicyAccepted"
    private let permissionsKey = "grantedPermissions"
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.app", category: "PrivacyManager")
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        loadPrivacySettings()
        setupNotificationObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func restoreState() async throws {
        do {
            loadPrivacySettings()
            try await validatePermissions()
            logger.info("State restored successfully")
        } catch {
            logger.error("Failed to restore state: \(error.localizedDescription)")
            throw error
        }
    }
    
    func acceptPrivacyPolicy() async throws {
        do {
            isPrivacyPolicyAccepted = true
            userDefaults.set(true, forKey: privacyPolicyKey)
            logger.info("Privacy policy accepted")
        } catch {
            logger.error("Failed to save privacy policy acceptance: \(error.localizedDescription)")
            throw PrivacyError.dataSaveFailed(error)
        }
    }
    
    func requestPermission(_ permission: PrivacyPermission) async throws -> Bool {
        logger.info("Requesting permission: \(permission.rawValue)")
        
        switch permission {
        case .faceID:
            return try await requestFaceIDPermission()
        case .notifications:
            return try await requestNotificationPermission()
        case .analytics:
            return try await requestAnalyticsPermission()
        case .location:
            return try await requestLocationPermission()
        }
    }
    
    private func loadPrivacySettings() {
        do {
            isPrivacyPolicyAccepted = userDefaults.bool(forKey: privacyPolicyKey)
            if let savedPermissions = userDefaults.stringArray(forKey: permissionsKey) {
                grantedPermissions = Set(savedPermissions.compactMap { PrivacyPermission(rawValue: $0) })
            }
            logger.info("Loaded privacy settings: accepted=\(isPrivacyPolicyAccepted), permissions=\(grantedPermissions.count)")
        } catch {
            logger.error("Failed to load privacy settings: \(error.localizedDescription)")
        }
    }
    
    private func saveGrantedPermission(_ permission: PrivacyPermission) throws {
        do {
            grantedPermissions.insert(permission)
            let permissionsArray = Array(grantedPermissions.map { $0.rawValue })
            userDefaults.set(permissionsArray, forKey: permissionsKey)
            logger.info("Saved permission: \(permission.rawValue)")
        } catch {
            logger.error("Failed to save permission: \(error.localizedDescription)")
            throw PrivacyError.dataSaveFailed(error)
        }
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppWillTerminate),
            name: UIApplication.willTerminateNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    @objc private func handleAppWillTerminate() {
        do {
            try saveCurrentState()
        } catch {
            logger.error("Failed to save state during termination: \(error.localizedDescription)")
        }
    }
    
    @objc private func handleAppDidBecomeActive() {
        Task {
            do {
                try await validatePermissions()
            } catch {
                logger.error("Failed to validate permissions: \(error.localizedDescription)")
            }
        }
    }
    
    private func saveCurrentState() throws {
        do {
            let permissionsArray = Array(grantedPermissions.map { $0.rawValue })
            userDefaults.set(permissionsArray, forKey: permissionsKey)
            userDefaults.set(isPrivacyPolicyAccepted, forKey: privacyPolicyKey)
            logger.info("Current state saved successfully")
        } catch {
            logger.error("Failed to save current state: \(error.localizedDescription)")
            throw error
        }
    }
    
    private func validatePermissions() async throws {
        for permission in grantedPermissions {
            do {
                _ = try await requestPermission(permission)
            } catch {
                logger.error("Failed to validate permission \(permission.rawValue): \(error.localizedDescription)")
                grantedPermissions.remove(permission)
            }
        }
    }
    
    private func requestFaceIDPermission() async throws -> Bool {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            logger.error("Biometrics not available: \(error?.localizedDescription ?? "Unknown error")")
            throw PrivacyError.biometricsNotAvailable(error?.localizedDescription ?? "Biometrics not available")
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                 localizedReason: "Authenticate to access parent controls") { success, error in
                if success {
                    do {
                        try self.saveGrantedPermission(.faceID)
                        self.logger.info("Face ID authentication successful")
                        continuation.resume(returning: true)
                    } catch {
                        self.logger.error("Failed to save Face ID permission: \(error.localizedDescription)")
                        continuation.resume(throwing: error)
                    }
                } else {
                    self.logger.error("Face ID authentication failed: \(error?.localizedDescription ?? "Unknown error")")
                    continuation.resume(throwing: PrivacyError.authenticationFailed(error?.localizedDescription ?? "Authentication failed"))
                }
            }
        }
    }
    
    private func requestNotificationPermission() async throws -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        
        guard settings.authorizationStatus != .authorized else {
            try saveGrantedPermission(.notifications)
            logger.info("Notifications already authorized")
            return true
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if granted {
                    do {
                        try self.saveGrantedPermission(.notifications)
                        self.logger.info("Notification permission granted")
                        continuation.resume(returning: true)
                    } catch {
                        self.logger.error("Failed to save notification permission: \(error.localizedDescription)")
                        continuation.resume(throwing: error)
                    }
                } else {
                    self.logger.error("Notification permission denied: \(error?.localizedDescription ?? "Unknown error")")
                    continuation.resume(throwing: PrivacyError.notificationDenied(error?.localizedDescription ?? "Notification permission denied"))
                }
            }
        }
    }
    
    private func requestAnalyticsPermission() async throws -> Bool {
        logger.info("Requesting analytics permission")
        try saveGrantedPermission(.analytics)
        return true
    }
    
    private func requestLocationPermission() async throws -> Bool {
        logger.info("Requesting location permission")
        try saveGrantedPermission(.location)
        return true
    }
}

enum PrivacyError: LocalizedError {
    case biometricsNotAvailable(String)
    case authenticationFailed(String)
    case notificationDenied(String)
    case permissionDenied(String)
    case dataSaveFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .biometricsNotAvailable(let message):
            return "Biometrics not available: \(message)"
        case .authenticationFailed(let message):
            return "Authentication failed: \(message)"
        case .notificationDenied(let message):
            return "Notification permission denied: \(message)"
        case .permissionDenied(let message):
            return "Permission denied: \(message)"
        case .dataSaveFailed(let error):
            return "Failed to save data: \(error.localizedDescription)"
        }
    }
} 