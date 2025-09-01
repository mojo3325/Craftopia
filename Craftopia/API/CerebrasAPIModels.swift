import Foundation

/// Shared API response models for Cerebras API across all agent clients
/// Used by PlannerAgentAPIClient, ThemerAgentAPIClient, CoderAgentAPIClient, and ThinkingAgentAPIClient

/// Main API response structure from Cerebras
struct CerebrasAPIResponse: Codable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [CerebrasChoice]
    let usage: CerebrasUsage?
    let systemFingerprint: String?
    let timeInfo: CerebrasTimeInfo?
    
    enum CodingKeys: String, CodingKey {
        case id, object, created, model, choices, usage
        case systemFingerprint = "system_fingerprint"
        case timeInfo = "time_info"
    }
}

/// Choice structure in the API response
struct CerebrasChoice: Codable {
    let index: Int
    let message: CerebrasMessage
    let finishReason: String?
    
    enum CodingKeys: String, CodingKey {
        case index, message
        case finishReason = "finish_reason"
    }
}

/// Message structure containing the generated content
struct CerebrasMessage: Codable {
    let role: String
    let content: String? // Optional - may be missing with reasoning models
    let reasoning: String? // Optional reasoning field for gpt-oss-120b with reasoning_effort
    
    enum CodingKeys: String, CodingKey {
        case role, content, reasoning
    }
}

/// Usage information (tokens consumed)
struct CerebrasUsage: Codable {
    let promptTokens: Int
    let completionTokens: Int
    let totalTokens: Int
    let promptTokensDetails: CerebrasPromptTokensDetails?
    
    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
        case promptTokensDetails = "prompt_tokens_details"
    }
}

/// Prompt tokens details
struct CerebrasPromptTokensDetails: Codable {
    let cachedTokens: Int?
    
    enum CodingKeys: String, CodingKey {
        case cachedTokens = "cached_tokens"
    }
}

/// Time information for the request
struct CerebrasTimeInfo: Codable {
    let queueTime: Double?
    let promptTime: Double?
    let completionTime: Double?
    let totalTime: Double?
    let created: Int?
    
    enum CodingKeys: String, CodingKey {
        case queueTime = "queue_time"
        case promptTime = "prompt_time"
        case completionTime = "completion_time"
        case totalTime = "total_time"
        case created
    }
}

/// Error response structure from Cerebras API
struct CerebrasAPIError: Codable, Error {
    let error: CerebrasErrorDetail
}

/// Detailed error information
struct CerebrasErrorDetail: Codable {
    let message: String
    let type: String
    let code: String?
    
    enum CodingKeys: String, CodingKey {
        case message, type, code
    }
}