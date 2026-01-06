import Foundation

/// Secure API Configuration using Keychain and build-time configuration
/// This replaces the previous insecure implementation that stored keys in plain text
struct SecureAPIConfig {
    
    // MARK: - Build Configuration Keys
    
    /// Cerebras API key from build configuration (Info.plist)
    /// This will be set from Config.xcconfig file during build time
    private static var buildTimeCerebrasKey: String? {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "CEREBRAS_API_KEY") as? String,
              !key.isEmpty,
              key != "$(CEREBRAS_API_KEY)" else {
            return nil
        }
        return key.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - Keychain Keys
    
    private static var keychainCerebrasKey: String? {
        KeychainHelper.retrieveAPIKey(for: KeychainHelper.cerebrasAccount)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - API Key Access
    
    /// Get Cerebras API key from Keychain, falling back to build configuration.
    static var cerebrasAPIKey: String? {
        if let keychainKey = keychainCerebrasKey, !keychainKey.isEmpty {
            return keychainKey
        }
        return buildTimeCerebrasKey
    }
    
    /// Check if API key is configured and valid
    static var isAPIKeyConfigured: Bool {
        guard let key = cerebrasAPIKey else { return false }
        
        // Validate key format - Cerebras keys typically start with "csk-"
        return key.hasPrefix("csk-") && key.count > 10
    }
    
    /// Get configuration error message with helpful instructions
    static var configurationErrorMessage: String {
        if !isAPIKeyConfigured {
            return """
            Cerebras API key is not configured. 
            Please:
            1. Open Settings and paste your API key (stored securely in Keychain)
            2. Or create a local Config.xcconfig file (use Config-Template.xcconfig as reference)
               and set: CEREBRAS_API_KEY = csk-your-key-here
            """
        }
        return ""
    }
    
    // MARK: - Runtime Configuration
    
    /// Imports the build-time key into Keychain (one-time migration).
    /// Useful if you previously used Config.xcconfig and want to stop keeping secrets in files.
    static func forceUpdateFromBuildConfig() -> Bool {
        if hasKeychainAPIKey {
            return true
        }
        guard let buildKey = buildTimeCerebrasKey, !buildKey.isEmpty else {
            return false
        }
        return KeychainHelper.storeAPIKey(buildKey, for: KeychainHelper.cerebrasAccount)
    }
    
    /// Store API key securely in Keychain.
    /// - Parameter key: The API key value
    /// - Returns: True if successfully stored (or cleared when empty), false otherwise
    @discardableResult
    static func setCerebrasAPIKey(_ key: String) -> Bool {
        let trimmedKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedKey.isEmpty {
            return KeychainHelper.deleteAPIKey(for: KeychainHelper.cerebrasAccount)
        }
        return KeychainHelper.storeAPIKey(trimmedKey, for: KeychainHelper.cerebrasAccount)
    }
    
    /// True if an API key exists in Keychain.
    static var hasKeychainAPIKey: Bool {
        KeychainHelper.apiKeyExists(for: KeychainHelper.cerebrasAccount)
    }
}

// MARK: - Legacy Compatibility

/// Legacy compatibility wrapper to avoid breaking existing code
/// @deprecated Use SecureAPIConfig instead
typealias APIConfig = SecureAPIConfig 
