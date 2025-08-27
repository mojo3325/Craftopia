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
        return key
    }
    
    // MARK: - API Key Access
    
    /// Get Cerebras API key directly from build configuration
    /// Always reads from Config.xcconfig - no caching
    static var cerebrasAPIKey: String? {
        guard let buildKey = buildTimeCerebrasKey else {
            return nil
        }
        
        let trimmedKey = buildKey.trimmingCharacters(in: .whitespacesAndNewlines)

        
        return trimmedKey
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
            1. Create a Config.xcconfig file (use Config-Template.xcconfig as reference)
            2. Add your API key: CEREBRAS_API_KEY = csk-your-key-here
            3. Or set it programmatically using SecureAPIConfig.setCerebrasAPIKey()
            """
        }
        return ""
    }
    
    // MARK: - Runtime Configuration
    
    /// This function is no longer needed since we always read directly from config
    /// Kept for backward compatibility but does nothing
    static func forceUpdateFromBuildConfig() -> Bool {
        return true
    }
    
    /// Runtime API key setting is not supported - use Config.xcconfig instead
    /// - Parameter key: The API key (ignored)
    /// - Returns: Always false since we only use build config
    @discardableResult
    static func setCerebrasAPIKey(_ key: String) -> Bool {
        return false
    }
    
    /// Always returns false since we don't use Keychain
    static var hasKeychainAPIKey: Bool {
        return false
    }
}

// MARK: - Legacy Compatibility

/// Legacy compatibility wrapper to avoid breaking existing code
/// @deprecated Use SecureAPIConfig instead
typealias APIConfig = SecureAPIConfig 