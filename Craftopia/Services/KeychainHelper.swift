import Foundation
import Security

/// KeychainHelper provides secure storage for sensitive data like API keys using iOS Keychain Services
/// This is much more secure than storing keys in plain text files or UserDefaults
final class KeychainHelper {
    
    // MARK: - Private Properties
    
    /// Service identifier for keychain items
    private static let service = Bundle.main.bundleIdentifier ?? "com.craftopia.app"
    
    // MARK: - API Key Management
    
    /// Store an API key securely in the keychain
    /// - Parameters:
    ///   - key: The API key value to store
    ///   - account: The account identifier (e.g., "cerebras_api_key")
    /// - Returns: True if successfully stored, false otherwise
    static func storeAPIKey(_ key: String, for account: String) -> Bool {
        guard let keyData = key.data(using: .utf8) else {
            print("KeychainHelper: Failed to convert key to data")
            return false
        }
        
        // First, delete any existing item with the same account
        deleteAPIKey(for: account)
        
        // Create the keychain query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecSuccess {
            print("KeychainHelper: Successfully stored key for account: \(account)")
            return true
        } else {
            print("KeychainHelper: Failed to store key for account: \(account). Status: \(status)")
            return false
        }
    }
    
    /// Retrieve an API key from the keychain
    /// - Parameter account: The account identifier (e.g., "cerebras_api_key")
    /// - Returns: The API key if found, nil otherwise
    static func retrieveAPIKey(for account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            if status != errSecItemNotFound {
                print("KeychainHelper: Failed to retrieve key for account: \(account). Status: \(status)")
            }
            return nil
        }
        
        guard let keyData = result as? Data,
              let key = String(data: keyData, encoding: .utf8) else {
            print("KeychainHelper: Failed to convert retrieved data to string")
            return nil
        }
        
        return key
    }
    
    /// Delete an API key from the keychain
    /// - Parameter account: The account identifier (e.g., "cerebras_api_key")
    /// - Returns: True if successfully deleted or didn't exist, false on error
    @discardableResult
    static func deleteAPIKey(for account: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        // Success if deleted or item didn't exist
        if status == errSecSuccess || status == errSecItemNotFound {
            return true
        } else {
            print("KeychainHelper: Failed to delete key for account: \(account). Status: \(status)")
            return false
        }
    }
    
    /// Update an existing API key in the keychain
    /// - Parameters:
    ///   - key: The new API key value
    ///   - account: The account identifier (e.g., "cerebras_api_key")
    /// - Returns: True if successfully updated, false otherwise
    static func updateAPIKey(_ key: String, for account: String) -> Bool {
        guard let keyData = key.data(using: .utf8) else {
            print("KeychainHelper: Failed to convert key to data")
            return false
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        let attributes: [String: Any] = [
            kSecValueData as String: keyData
        ]
        
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        
        if status == errSecSuccess {
            print("KeychainHelper: Successfully updated key for account: \(account)")
            return true
        } else if status == errSecItemNotFound {
            // If item doesn't exist, create it
            return storeAPIKey(key, for: account)
        } else {
            print("KeychainHelper: Failed to update key for account: \(account). Status: \(status)")
            return false
        }
    }
    
    /// Check if an API key exists in the keychain
    /// - Parameter account: The account identifier (e.g., "cerebras_api_key")
    /// - Returns: True if key exists, false otherwise
    static func apiKeyExists(for account: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: false
        ]
        
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    // MARK: - Convenience Methods
    
    /// Clear all API keys stored by this app (useful for logout/reset)
    static func clearAllAPIKeys() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status == errSecSuccess || status == errSecItemNotFound {
            print("KeychainHelper: Successfully cleared all API keys")
        } else {
            print("KeychainHelper: Failed to clear API keys. Status: \(status)")
        }
    }
}

// MARK: - Account Identifiers

/// Predefined account identifiers for different API keys
extension KeychainHelper {
    
    /// Account identifier for Cerebras API key
    static let cerebrasAccount = "cerebras_api_key"
    
    // Add more account identifiers for other services as needed
    // static let openaiAccount = "openai_api_key"
    // static let anthropicAccount = "anthropic_api_key"
}