import Foundation
import Security

class ParentControlRepository: ParentControlRepositoryProtocol {
    private let userDefaults: UserDefaults
    private let parentControlKey = "savedParentControl"
    private let pinCodeKey = "parentControlPinCode"
    private var cache: ParentControl?
    private let cacheQueue = DispatchQueue(label: "com.app.parentcontrol.cache")
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func fetchParentControl() async throws -> ParentControl {
        // Check cache first
        if let cached = cache {
            return cached
        }
        
        // Try to load from UserDefaults
        guard let data = userDefaults.data(forKey: parentControlKey) else {
            let defaultControl = ParentControl.default
            cacheQueue.sync {
                cache = defaultControl
            }
            return defaultControl
        }
        
        do {
            let parentControl = try JSONDecoder().decode(ParentControl.self, from: data)
            // Update cache
            cacheQueue.sync {
                cache = parentControl
            }
            return parentControl
        } catch {
            throw AppError.dataLoadFailed(error)
        }
    }
    
    func saveParentControl(_ parentControl: ParentControl) async throws {
        do {
            let data = try JSONEncoder().encode(parentControl)
            userDefaults.set(data, forKey: parentControlKey)
            
            // Update cache
            cacheQueue.sync {
                cache = parentControl
            }
            
            // Save PIN to Keychain
            try await savePinToKeychain(parentControl.pinCode)
        } catch {
            throw AppError.dataSaveFailed(error)
        }
    }
    
    // MARK: - Private Methods
    
    private func savePinToKeychain(_ pin: String) async throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: pinCodeKey,
            kSecValueData as String: pin.data(using: .utf8)!,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        
        // First try to delete existing item
        SecItemDelete(query as CFDictionary)
        
        // Then add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw AppError.keychainError(status)
        }
    }
    
    private func loadPinFromKeychain() async throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: pinCodeKey,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let pin = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return pin
    }
}

// MARK: - Error Extension
extension AppError {
    static func keychainError(_ status: OSStatus) -> AppError {
        .dataSaveFailed(NSError(domain: "Keychain", code: Int(status), userInfo: [
            NSLocalizedDescriptionKey: "Failed to save to Keychain"
        ]))
    }
} 