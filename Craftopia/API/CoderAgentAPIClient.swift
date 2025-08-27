import Foundation

/// API client for qwen3-coder model - specialized for code generation
class CoderAgentAPIClient: ObservableObject {
    private let apiKey: String
    private let baseURL = "https://api.cerebras.ai/v1"
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    /// System prompt for Soft UI (Flat 2.0) HTML applications matching Craftopia aesthetic
    private let systemPrompt = """
You are an expert front-end engineer implementing Soft UI (Flat 2.0) applications that match Craftopia's sophisticated design aesthetic. Create applications with elegant depth through soft shadows, subtle gradients, and refined surface treatments.

You have been provided with:
1. A focused SPECIFICATION from the planning agent
2. Complete SOFT UI DESIGN TOKENS from the theming agent matching Craftopia's style

OUTPUT CONTRACT (STRICT):
- Return ONLY raw HTML. No explanations. No markdown fences.
- Produce a complete document: <!DOCTYPE html>, <html>, <head>, <body>
- Include one <style> block in <head> and one <script> block at the end of <body>
- Do NOT reference external resources (no CDNs, no web fonts, no external libraries)
- Use inline SVG for any icons needed

SOFT UI DESIGN IMPLEMENTATION (REQUIRED):
- Use ONLY the CSS variables provided in the design tokens
- Implement SOFT SHADOWS: multi-layered shadows (light outer + subtle inner) for depth
- Apply GRADIENT BACKGROUNDS: subtle gradients for buttons and surfaces
- Use THIN BORDERS: 1px borders with proper opacity for definition
- Corner radius: 10-16px consistently throughout
- Implement both light and dark theme support using @media (prefers-color-scheme)
- Follow component styling guidance exactly (shadows, gradients, borders)

CRAFTOPIA AESTHETIC REQUIREMENTS:
- SOPHISTICATED SURFACES: Clean backgrounds with gradient overlays
- SOFT ELEVATION: Subtle shadows for tactile feel without heaviness
- ELEGANT INTERACTIONS: Smooth hover states with shadow/gradient changes
- PREMIUM SPACING: Generous padding and margins for high-end feel
- REFINED TYPOGRAPHY: Clean text hierarchy with proper contrast

IMPLEMENTATION REQUIREMENTS:
- Implement ALL features listed in the specification
- Every interactive element MUST work correctly with proper event handling
- Form inputs must accept and process data properly
- Buttons must perform their intended actions with visual feedback
- Display results clearly with appropriate styling
- Follow the macro flows and user journeys exactly

SOFT UI DESIGN GUIDELINES:
- BUTTONS: Gradient backgrounds + soft shadows + 44px min height + rounded corners
- INPUTS: Surface backgrounds + inset shadows + focus border treatment + padding
- CONTAINERS: Surface gradients + elevation shadows + thin borders + generous padding
- CARDS: Elegant surfaces with soft shadows and subtle borders
- LAYOUT: CSS Grid/Flexbox with generous spacing and proper visual hierarchy

COPY AND LANGUAGE:
- All user-facing text MUST be in English only
- Use clear, professional, human-friendly copy
- No lorem ipsum or placeholder text
- Label buttons and inputs clearly

STRUCTURE CHECKLIST:
- <meta charset="utf-8"> and <meta name="viewport" content="width=device-width, initial-scale=1">
- Meaningful <title> derived from the specification
- BEM-style class naming for maintainability
- System font stack from design tokens
- Preserve focus outlines for accessibility

JAVASCRIPT REQUIREMENTS (CRITICAL):
- Vanilla JS (ES6+), use const/let
- Initialize inside a DOMContentLoaded handler
- Attach events with addEventListener; avoid inline on* attributes
- Avoid innerHTML; prefer textContent or createElement
- Use try/catch and console.error for error handling
- Every button click MUST be handled correctly
- Every form input MUST be processed properly
- Display calculations/results immediately and correctly
- Implement smooth visual feedback for interactions

SOFT UI CSS IMPLEMENTATION:
- Define CSS custom properties for theme switching
- Use box-shadow for soft elevation effects
- Implement gradient backgrounds with linear-gradient()
- Apply consistent border-radius values
- Use padding and margin for generous spacing
- Implement hover states with shadow/gradient transitions

VALIDATION:
- Output valid HTML5 with proper indentation
- Close all tags and quote all attributes
- Ensure document is self-contained
- Test all interactions work correctly
- Verify responsive design on mobile

CRITICAL:
- Use ONLY the design tokens provided for theming
- Implement Soft UI aesthetic with shadows, gradients, and refined surfaces
- Ensure ALL interactive elements actually work
- Return only the raw HTML; do not wrap in code fences
- Match Craftopia's sophisticated, premium design language
"""
    
    /// Generate HTML application code
    func generateCode(context: AgentContext) async throws -> AgentExecutionResult {
        let startTime = Date()
        
        // Validate API key
        if apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let error = CoderAgentError.invalidAPIKey.localizedDescription
            return AgentExecutionResult(
                agentType: .coder,
                status: .failed,
                error: error,
                executionTimeSeconds: Date().timeIntervalSince(startTime)
            )
        }
        
        guard let url = URL(string: "\(baseURL)/chat/completions") else {
            let error = CoderAgentError.invalidURL.localizedDescription
            return AgentExecutionResult(
                agentType: .coder,
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
        request.timeoutInterval = 120 // Longer timeout for code generation
        
        // Construct prompt with context
        let userPrompt = buildUserPrompt(from: context)
        
        let requestBody: [String: Any] = [
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userPrompt]
            ],
            "model": "qwen-3-coder-480b",
            "temperature": 0.7,
            "max_tokens": 16000,
            "top_p": 0.8
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                let error = CoderAgentError.invalidResponse.localizedDescription
                return AgentExecutionResult(
                    agentType: .coder,
                    status: .failed,
                    error: error,
                    executionTimeSeconds: Date().timeIntervalSince(startTime)
                )
            }
            
            if httpResponse.statusCode != 200 {
                let error = CoderAgentError.httpError(statusCode: httpResponse.statusCode).localizedDescription
                return AgentExecutionResult(
                    agentType: .coder,
                    status: .failed,
                    error: error,
                    executionTimeSeconds: Date().timeIntervalSince(startTime)
                )
            }
            
            let apiResponse = try JSONDecoder().decode(CerebrasAPIResponse.self, from: data)
            
            guard let firstChoice = apiResponse.choices.first else {
                let error = CoderAgentError.noChoices.localizedDescription
                return AgentExecutionResult(
                    agentType: .coder,
                    status: .failed,
                    error: error,
                    executionTimeSeconds: Date().timeIntervalSince(startTime)
                )
            }
            
            let rawContent = firstChoice.message.content
            let cleanedContent = extractHTMLFromResponse(rawContent)
            
            guard !cleanedContent.isEmpty else {
                let error = CoderAgentError.noValidCode.localizedDescription
                return AgentExecutionResult(
                    agentType: .coder,
                    status: .failed,
                    error: error,
                    executionTimeSeconds: Date().timeIntervalSince(startTime)
                )
            }
            
            return AgentExecutionResult(
                agentType: .coder,
                status: .completed,
                content: cleanedContent,
                executionTimeSeconds: Date().timeIntervalSince(startTime)
            )
            
        } catch {
            return AgentExecutionResult(
                agentType: .coder,
                status: .failed,
                error: error.localizedDescription,
                executionTimeSeconds: Date().timeIntervalSince(startTime)
            )
        }
    }
    
    /// Build user prompt from context with plan and design tokens
    private func buildUserPrompt(from context: AgentContext) -> String {
        var prompt = "ORIGINAL REQUEST: \(context.originalPrompt)"
        
        // Add planning specification if available
        if let plannerOutput = context.plannerOutput {
            prompt += "\n\n=== SPECIFICATION FROM PLANNER ==="
            prompt += "\n\(plannerOutput)"
        }
        
        // Add design tokens and visual design if available
        if let themerOutput = context.themerOutput {
            prompt += "\n\n=== DESIGN TOKENS & VISUAL DESIGN ==="
            prompt += "\n\(themerOutput)"
        }
        
        if let additionalInstructions = context.additionalInstructions {
            prompt += "\n\nADDITIONAL REQUIREMENTS:\n\(additionalInstructions)"
        }
        
        prompt += """
        
        
        IMPLEMENTATION TASK:
        Create a simple, working HTML application that:
        1. Implements ONLY the core features from the specification (avoid feature creep)
        2. Uses ONLY the provided design tokens for clean SwiftUI-style design
        3. Ensures ALL interactive elements actually work correctly
        4. Focuses on functionality over flashy features
        5. Maintains clean, minimalist aesthetic
        6. Works perfectly on mobile devices
        
        Remember: Simple, functional, beautiful. Every button must work, every input must respond.
        Generate the complete, working HTML document now.
        """
        
        return prompt
    }
    
    /// Clean HTML content from API response
    private func extractHTMLFromResponse(_ content: String) -> String {
        var cleanContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove markdown code blocks
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
        
        // Strip thinking/reasoning blocks if any sneak in
        cleanContent = cleanContent.replacingOccurrences(
            of: #"<(think|thinking)[^>]*>[\s\S]*?<\/(think|thinking)>"#,
            with: "",
            options: [.regularExpression, .caseInsensitive]
        )
        
        // Extract from <!DOCTYPE html> or <html>
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

/// Errors specific to coder agent
enum CoderAgentError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case noChoices
    case noValidCode
    case invalidAPIKey
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL for coder agent"
        case .invalidResponse:
            return "Invalid response from coder agent"
        case .httpError(let statusCode):
            switch statusCode {
            case 401:
                return "Invalid API key for coder agent"
            case 429:
                return "Rate limit exceeded for coder agent"
            case 404:
                return "Coder model not found"
            default:
                return "Coder agent HTTP error: \(statusCode)"
            }
        case .noChoices:
            return "No response from coder agent"
        case .noValidCode:
            return "Coder agent failed to generate valid code"
        case .invalidAPIKey:
            return "Coder agent API key not configured"
        }
    }
}