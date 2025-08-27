import Foundation

/// API client for qwen3-235b-thinking model - specialized for final review and polishing
class ThinkingAgentAPIClient: ObservableObject {
    private let apiKey: String
    private let baseURL = "https://api.cerebras.ai/v1"
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    /// System prompt for bug fixing and simple polishing - final stage reviewer
    private let systemPrompt = """
You are the final quality control agent in a four-agent pipeline. You receive:
1. Original user request
2. Minimal specification focusing on core features
3. SwiftUI-inspired design tokens
4. Generated HTML application code

Your role as the BUG FIXER and SIMPLE POLISHER:

PRIORITY 1 - CRITICAL BUG FIXES (MUST FIX):
- JavaScript errors that break core functionality
- Event handlers not properly attached to buttons/inputs
- Form inputs not capturing or processing data
- Calculations not working or displaying results
- Basic interactions completely broken
- Critical accessibility issues preventing usage
- Mobile responsiveness breaking core functionality

PRIORITY 2 - SPECIFICATION COMPLIANCE:
- Verify ONLY the core features from specification are implemented
- Remove any feature creep or unrequested functionality
- Ensure the app does exactly what was requested, nothing more
- Confirm all specified core features actually work

PRIORITY 3 - DESIGN TOKEN CONSISTENCY:
- Maintain exact design token usage throughout
- Preserve SwiftUI-inspired clean aesthetic
- Ensure both light and dark themes work correctly
- Keep minimalist, uncluttered design

PRIORITY 4 - SIMPLE POLISHING (only if no critical bugs):
- Improve basic user feedback (simple hover states)
- Fix minor spacing or alignment issues
- Enhance basic accessibility (focus outlines, labels)
- Minor UX improvements that don't add complexity

WHAT NOT TO DO:
- Do NOT add features that weren't requested
- Do NOT make the design more complex or "impressive"
- Do NOT add animations, effects, or visual flourishes
- Do NOT add history, settings, or configuration panels
- Do NOT add "nice-to-have" functionality
- Do NOT change the core simplicity of the design

OUTPUT REQUIREMENTS:
- Return ONLY the improved HTML code
- No explanations or markdown fences
- Complete, self-contained HTML document
- All core functionality must work perfectly
- Maintain simple, clean design
- Production-ready quality

THINKING PROCESS:
1. Test each interactive element mentally - does it work?
2. Check if any unrequested features were added - remove them
3. Verify design tokens are used correctly
4. Fix any broken functionality first
5. Only polish if everything works correctly
6. Keep it simple and focused
7. Return clean, working code

Remember: Your job is to make it work correctly and keep it simple!
"""
    
    /// Review and polish the final application
    func reviewAndImprove(context: AgentContext) async throws -> AgentExecutionResult {
        let startTime = Date()
        
        // Validate API key
        if apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let error = ThinkingAgentError.invalidAPIKey.localizedDescription
            return AgentExecutionResult(
                agentType: .reviewer,
                status: .failed,
                error: error,
                executionTimeSeconds: Date().timeIntervalSince(startTime)
            )
        }
        
        guard let url = URL(string: "\(baseURL)/chat/completions") else {
            let error = ThinkingAgentError.invalidURL.localizedDescription
            return AgentExecutionResult(
                agentType: .reviewer,
                status: .failed,
                error: error,
                executionTimeSeconds: Date().timeIntervalSince(startTime)
            )
        }
        
        // Prepare request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 120
        
        // Build comprehensive review prompt with all context
        let userPrompt = buildReviewPrompt(from: context)
        
        let requestBody: [String: Any] = [
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userPrompt]
            ],
            "model": "qwen-3-235b-a22b-thinking-2507",
            "temperature": 0.7,
            "max_tokens": 64000,
            "top_p": 0.9,
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                let error = ThinkingAgentError.invalidResponse.localizedDescription
                return AgentExecutionResult(
                    agentType: .reviewer,
                    status: .failed,
                    error: error,
                    executionTimeSeconds: Date().timeIntervalSince(startTime)
                )
            }
            
            if httpResponse.statusCode != 200 {
                let error = ThinkingAgentError.httpError(statusCode: httpResponse.statusCode).localizedDescription
                return AgentExecutionResult(
                    agentType: .reviewer,
                    status: .failed,
                    error: error,
                    executionTimeSeconds: Date().timeIntervalSince(startTime)
                )
            }
            
            let apiResponse = try JSONDecoder().decode(CerebrasAPIResponse.self, from: data)
            
            guard let firstChoice = apiResponse.choices.first else {
                let error = ThinkingAgentError.noChoices.localizedDescription
                return AgentExecutionResult(
                    agentType: .reviewer,
                    status: .failed,
                    error: error,
                    executionTimeSeconds: Date().timeIntervalSince(startTime)
                )
            }
            
            let rawContent = firstChoice.message.content
            let improvedContent = extractHTMLFromResponse(rawContent)
            
            guard !improvedContent.isEmpty else {
                let error = ThinkingAgentError.noValidImprovement.localizedDescription
                return AgentExecutionResult(
                    agentType: .reviewer,
                    status: .failed,
                    error: error,
                    executionTimeSeconds: Date().timeIntervalSince(startTime)
                )
            }
            
            return AgentExecutionResult(
                agentType: .reviewer,
                status: .completed,
                content: improvedContent,
                executionTimeSeconds: Date().timeIntervalSince(startTime)
            )
            
        } catch {
            return AgentExecutionResult(
                agentType: .reviewer,
                status: .failed,
                error: error.localizedDescription,
                executionTimeSeconds: Date().timeIntervalSince(startTime)
            )
        }
    }
    
    /// Build detailed review prompt with all pipeline context
    private func buildReviewPrompt(from context: AgentContext) -> String {
        var prompt = "ORIGINAL USER REQUEST: \(context.originalPrompt)"
        
        // Include planner specification
        if let plannerOutput = context.plannerOutput {
            prompt += "\n\n=== SPECIFICATION FROM PLANNER ==="
            prompt += "\n\(plannerOutput)"
        }
        
        // Include design tokens and visual design
        if let themerOutput = context.themerOutput {
            prompt += "\n\n=== DESIGN TOKENS & VISUAL DESIGN ==="
            prompt += "\n\(themerOutput)"
        }
        
        // Include the code to review
        if let coderOutput = context.coderOutput {
            prompt += "\n\n=== GENERATED CODE TO REVIEW ==="
            prompt += "\n\(coderOutput)"
        } else if let previousResult = context.previousResult {
            prompt += "\n\n=== GENERATED CODE TO REVIEW ==="
            prompt += "\n\(previousResult)"
        }
        
        if let additionalInstructions = context.additionalInstructions {
            prompt += "\n\nADDITIONAL REQUIREMENTS: \(additionalInstructions)"
        }
        
        prompt += """
        
        
        REVIEW AND FIX TASK:
        1. First, check if ALL interactive elements work correctly (buttons, inputs, calculations)
        2. Remove any features that weren't specifically requested (avoid feature creep)
        3. Verify the design matches SwiftUI minimalist aesthetic
        4. Fix any broken functionality
        5. Keep it simple - don't add complexity or "impressive" features
        6. Return the final, working HTML application
        
        Focus on making core functionality work perfectly while keeping it beautifully simple.
        """
        
        return prompt
    }
    
    /// Clean HTML content from API response
    private func extractHTMLFromResponse(_ content: String) -> String {
        var cleanContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove markdown code fences
        cleanContent = cleanContent.replacingOccurrences(
            of: #"```(?:html|javascript|css)?\s*\n?"#,
            with: "",
            options: .regularExpression
        )
        cleanContent = cleanContent.replacingOccurrences(
            of: #"```\s*$"#,
            with: "",
            options: .regularExpression
        )
        cleanContent = cleanContent.replacingOccurrences(of: "```", with: "")
        
        // Remove <think>/<thinking> reasoning tags from reasoning models
        cleanContent = cleanContent.replacingOccurrences(
            of: #"<(think|thinking)[^>]*>[\s\S]*?<\/(think|thinking)>"#,
            with: "",
            options: [.regularExpression, .caseInsensitive]
        )
        
        // Extract just the HTML document
        if let doctypeRange = cleanContent.range(of: #"<!DOCTYPE\s+html[\s\S]*"#, options: [.regularExpression, .caseInsensitive]) {
            cleanContent = String(cleanContent[doctypeRange.lowerBound...])
        } else if let htmlStart = cleanContent.range(of: #"<html[\s\S]*"#, options: [.regularExpression, .caseInsensitive]) {
            cleanContent = String(cleanContent[htmlStart.lowerBound...])
        }
        if let htmlEnd = cleanContent.range(of: #"</html>"#, options: [.regularExpression, .caseInsensitive]) {
            cleanContent = String(cleanContent[..<htmlEnd.upperBound])
        }
        
        return cleanContent.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

/// Errors specific to thinking agent
enum ThinkingAgentError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case noChoices
    case noValidImprovement
    case invalidAPIKey
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL for thinking agent"
        case .invalidResponse:
            return "Invalid response from thinking agent"
        case .httpError(let statusCode):
            switch statusCode {
            case 401:
                return "Invalid API key for thinking agent"
            case 429:
                return "Rate limit exceeded for thinking agent"
            case 404:
                return "Thinking model not found"
            default:
                return "Thinking agent HTTP error: \(statusCode)"
            }
        case .noChoices:
            return "No response from thinking agent"
        case .noValidImprovement:
            return "Thinking agent failed to improve the code"
        case .invalidAPIKey:
            return "Thinking agent API key not configured"
        }
    }
}
