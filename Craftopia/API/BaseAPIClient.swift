import Foundation

/// Base class for all API clients to eliminate code duplication
class BaseAPIClient: ObservableObject {
    let apiKey: String
    let baseURL = "https://api.cerebras.ai/v1"
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    /// Validate API key
    func validateAPIKey() -> Bool {
        return !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// Create base URL request
    func createBaseRequest() -> URLRequest? {
        guard let url = URL(string: "\(baseURL)/chat/completions") else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 120
        
        return request
    }
    
    /// Make API request with common error handling
    func makeAPIRequest<T: Codable>(
        requestBody: [String: Any],
        responseType: T.Type,
        agentName: String
    ) async throws -> T {
        guard validateAPIKey() else {
            throw APIError.invalidAPIKey
        }
        
        guard var request = createBaseRequest() else {
            throw APIError.invalidURL
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if httpResponse.statusCode != 200 {
            let errorData = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("[\(agentName)] HTTP Error \(httpResponse.statusCode): \(errorData)")
            throw APIError.httpError(statusCode: httpResponse.statusCode, message: errorData)
        }
        
        // Log raw JSON response for debugging
        if let rawJSON = String(data: data, encoding: .utf8) {
            print("[\(agentName)] Raw JSON response: \(rawJSON)")
        }
        
        let apiResponse = try JSONDecoder().decode(T.self, from: data)
        print("[\(agentName)] API response decoded successfully")
        
        return apiResponse
    }
    
    /// Extract content from API response with fallback to reasoning
    func extractContent(from choice: CerebrasChoice, agentName: String) -> String? {
        if let content = choice.message.content, !content.isEmpty {
            print("[\(agentName)] Using content field")
            return content
        } else if let reasoning = choice.message.reasoning, !reasoning.isEmpty {
            print("[\(agentName)] Content missing or empty, using reasoning field")
            return reasoning
        }
        return nil
    }
}

/// Common API errors
enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, message: String)
    case invalidAPIKey
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from API"
        case .httpError(let statusCode, let message):
            return "HTTP error \(statusCode): \(message)"
        case .invalidAPIKey:
            return "Invalid or missing API key"
        }
    }
}
