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
    
    enum CodingKeys: String, CodingKey {
        case id, object, created, model, choices, usage
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
    let content: String
    
    enum CodingKeys: String, CodingKey {
        case role, content
    }
}

/// Usage information (tokens consumed)
struct CerebrasUsage: Codable {
    let promptTokens: Int
    let completionTokens: Int
    let totalTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
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