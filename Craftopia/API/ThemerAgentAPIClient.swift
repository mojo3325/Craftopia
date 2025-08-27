import Foundation

/// API client for gpt-oss-120b model - specialized for theming and UX design tokens
class ThemerAgentAPIClient: ObservableObject {
    private let apiKey: String
    private let baseURL = "https://api.cerebras.ai/v1"
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    /// System prompt for minimalist SwiftUI-inspired design tokens
    private let systemPrompt = """
You are an expert UX/UI designer specializing in Soft UI (Flat 2.0) design systems. Your role is to create design tokens that match Craftopia's sophisticated, modern aesthetic - a refined flat design with subtle depth through soft shadows, gentle gradients, and elegant surfaces.

CRAFTOPIA DESIGN PHILOSOPHY:
- SOFT UI (FLAT 2.0): Clean flat design enhanced with subtle shadows and gentle gradients for depth
- SOPHISTICATED MINIMALISM: Refined elegance through careful use of shadows and spacing
- PREMIUM AESTHETICS: High-quality visual design that feels polished and professional
- CONSISTENT SURFACES: White/dark surfaces with consistent shadow language
- SEMANTIC COLOR USAGE: Purposeful color application that guides user behavior

TASK: Create design tokens that perfectly match Craftopia's Soft UI aesthetic:

1. CRAFTOPIA COLOR SYSTEM: Exact color palette matching the main application
2. SOFT UI SHADOWS: Multi-layered shadow system for subtle depth
3. SURFACE TREATMENTS: Gradient backgrounds and sophisticated border treatments
4. TYPOGRAPHY HIERARCHY: Clean, readable text system with proper contrast
5. COMPONENT STYLING: Detailed shadow, gradient, and interaction specifications
6. INTERACTION DESIGN: Soft hover states and micro-interactions

SOFT UI DESIGN PRINCIPLES:
- Multiple soft shadows (light outer + deeper inner) for depth
- Thin borders (1px) with thoughtful opacity
- Subtle gradients for surface depth, not decoration
- Corner radius: 10-16px for modern, friendly feel
- High contrast ratios for accessibility (WCAG AA+)
- Touch-friendly sizing (44px minimum)
- Generous spacing for premium feel

OUTPUT FORMAT (JSON):
{
  "lightThemeTokens": {
    "--color-primary": "#186DEE",
    "--color-primary-accent": "#1B77FD",
    "--color-primary-gradient-top": "#6DA4FB",
    "--color-primary-gradient-bottom": "#206CE5",
    "--color-secondary": "#ECECEC",
    "--color-bg": "#F5F6F8",
    "--color-surface": "#FFFFFF",
    "--color-surface-secondary": "#FAFBFC",
    "--color-border": "#E3E6EB",
    "--color-border-strong": "#2D5DB7",
    "--color-text": "#4B5669",
    "--color-text-heading": "#131B22",
    "--color-text-secondary": "#6B7684",
    "--color-text-muted": "#99A1B3",
    "--color-shadow": "rgba(186, 186, 186, 0.6)",
    "--color-shadow-strong": "rgba(186, 186, 186, 0.3)",
    "--color-success": "#2ED47A",
    "--color-warning": "#EDA23A",
    "--color-error": "#F05A5A"
  },
  "darkThemeTokens": {
    "--color-primary": "#186DEE",
    "--color-primary-accent": "#1B77FD", 
    "--color-primary-gradient-top": "#6DA4FB",
    "--color-primary-gradient-bottom": "#206CE5",
    "--color-secondary": "#2C2C2E",
    "--color-bg": "#07090D",
    "--color-surface": "#15171F",
    "--color-surface-secondary": "#0C0E12",
    "--color-border": "#3A3A3C",
    "--color-border-strong": "#0A84FF",
    "--color-text": "#EBEBF5",
    "--color-text-heading": "#FFFFFF",
    "--color-text-secondary": "#ABABAB",
    "--color-text-muted": "#8E8E93",
    "--color-shadow": "rgba(0, 0, 0, 0.4)",
    "--color-shadow-strong": "rgba(0, 0, 0, 0.2)",
    "--color-success": "#30D158",
    "--color-warning": "#FF9F0A",
    "--color-error": "#FF453A"
  },
  "typography": {
    "--font-family-system": "-apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif",
    "--font-size-xs": "0.75rem",
    "--font-size-sm": "0.875rem",
    "--font-size-base": "1rem",
    "--font-size-lg": "1.125rem",
    "--font-size-xl": "1.25rem",
    "--font-size-2xl": "1.5rem",
    "--font-size-3xl": "2rem",
    "--font-weight-normal": "400",
    "--font-weight-medium": "500",
    "--font-weight-semibold": "600",
    "--font-weight-bold": "700",
    "--line-height-tight": "1.2",
    "--line-height-normal": "1.5",
    "--line-height-relaxed": "1.7"
  },
  "spacing": {
    "--space-1": "0.25rem",
    "--space-2": "0.5rem",
    "--space-3": "0.75rem",
    "--space-4": "1rem",
    "--space-5": "1.25rem",
    "--space-6": "1.5rem",
    "--space-8": "2rem",
    "--space-10": "2.5rem",
    "--space-12": "3rem",
    "--space-16": "4rem"
  },
  "componentStyling": {
    "primaryButtons": "Blue gradient background (linear-gradient from --color-primary-gradient-top to --color-primary-gradient-bottom), white text, 44px min height. Soft shadow: 0 6px 12px --color-shadow-strong, 0 2px 6px --color-shadow. Corner radius: 12px. Hover: slight shadow increase.",
    "secondaryButtons": "--color-surface background with --color-text, thin border (1px solid --color-border). Same shadow as primary but lighter. Corner radius: 10px. Hover: slightly darker background.",
    "destructiveButtons": "--color-error background with white text. Same shadow treatment as primary. Use for delete/clear actions only.",
    "inputs": "--color-surface background, 1px border --color-border, soft inset shadow. Focus: border becomes --color-primary. Padding: 16px. Corner radius: 12px. Shadow: 0 2px 6px --color-shadow.",
    "containers": "--color-surface background (or gradient from surface to surface), 1px border --color-border. Soft shadow: 0 3px 8px --color-shadow. Corner radius: 16px. Padding: 16-24px.",
    "cards": "White/dark surface with gradient background, thin border, soft shadow for elevation. No heavy shadows - keep it elegant and light.",
    "layout": "Use CSS Grid/Flexbox with --space-4 gaps for related elements, --space-6 for sections. Generous padding for premium feel."
  },
  "shadowSystem": {
    "soft": "0 2px 6px var(--color-shadow)",
    "medium": "0 6px 12px var(--color-shadow-strong), 0 2px 6px var(--color-shadow)",
    "strong": "0 12px 24px var(--color-shadow-strong), 0 6px 12px var(--color-shadow)",
    "inset": "inset 0 1px 3px var(--color-shadow)"
  },
  "brandingConcept": "Soft UI (Flat 2.0) aesthetic matching Craftopia's sophisticated design language. Clean surfaces enhanced with subtle shadows and gentle gradients. Primary blue (#186DEE) for actions, refined grays for supporting elements. Premium feel through careful shadow work and surface treatments.",
  "visualStyle": "Soft UI design with elegant depth through multi-layered shadows and subtle gradients. Clean typography hierarchy, generous spacing, sophisticated surface treatments. Consistent shadow language: soft shadows for elevation, thin borders for definition, gradient backgrounds for premium feel. Mobile-optimized with 44px+ touch targets."
}

SOFT UI DESIGN GUIDELINES:
- PRIMARY BLUES (#186DEE, #1B77FD): Main action buttons with gradient backgrounds and soft shadows
- SECONDARY GRAYS: Supporting buttons and containers with subtle shadows and borders
- SURFACE TREATMENTS: White/dark backgrounds with gradient overlays and soft shadows
- SHADOW SYSTEM: Multiple shadow layers (light outer + subtle inner) for elegant depth
- BORDER USAGE: Thin 1px borders with appropriate opacity for definition
- CORNER RADIUS: 10-16px for modern, friendly feel
- SUCCESS/WARNING/ERROR: Semantic colors with same shadow treatment as primary elements

SOFT UI COMPONENT RULES:
- ALL interactive elements must have soft shadows for tactile feel
- Use gradient backgrounds for buttons (subtle, not dramatic)
- Containers get soft elevation shadows + thin borders
- Text inputs have inset shadows + focus border treatment
- Maintain consistent corner radius throughout (10-16px)
- Generous padding and spacing for premium aesthetic

CRITICAL: Return ONLY valid JSON. No explanations, no markdown, no additional text.
"""
    
    /// Generate design tokens and visual theme
    func generateTheme(context: AgentContext) async throws -> AgentExecutionResult {
        let startTime = Date()
        
        // Validate API key
        if apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let error = ThemerAgentError.invalidAPIKey.localizedDescription
            return AgentExecutionResult(
                agentType: .themer,
                status: .failed,
                error: error,
                executionTimeSeconds: Date().timeIntervalSince(startTime)
            )
        }
        
        guard let url = URL(string: "\(baseURL)/chat/completions") else {
            let error = ThemerAgentError.invalidURL.localizedDescription
            return AgentExecutionResult(
                agentType: .themer,
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
        
        // Build theming prompt
        let userPrompt = buildThemingPrompt(from: context)
        
        let requestBody: [String: Any] = [
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userPrompt]
            ],
          "model": "gpt-oss-120b",
            "temperature": 0.5,
            "max_tokens": 12000,
            "top_p": 0.9,
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                let error = ThemerAgentError.invalidResponse.localizedDescription
                return AgentExecutionResult(
                    agentType: .themer,
                    status: .failed,
                    error: error,
                    executionTimeSeconds: Date().timeIntervalSince(startTime)
                )
            }
            
            if httpResponse.statusCode != 200 {
                let errorData = String(data: data, encoding: .utf8) ?? "Unknown error"
                let error = ThemerAgentError.httpError(statusCode: httpResponse.statusCode, message: errorData).localizedDescription
                return AgentExecutionResult(
                    agentType: .themer,
                    status: .failed,
                    error: error,
                    executionTimeSeconds: Date().timeIntervalSince(startTime)
                )
            }
            
            let apiResponse = try JSONDecoder().decode(CerebrasAPIResponse.self, from: data)
            
            guard let firstChoice = apiResponse.choices.first else {
                let error = ThemerAgentError.noChoices.localizedDescription
                return AgentExecutionResult(
                    agentType: .themer,
                    status: .failed,
                    error: error,
                    executionTimeSeconds: Date().timeIntervalSince(startTime)
                )
            }
            
            let rawContent = firstChoice.message.content
            let themerOutput = extractAndValidateThemerOutput(rawContent)
            
            guard !themerOutput.isEmpty else {
                let error = ThemerAgentError.noValidTheme.localizedDescription
                return AgentExecutionResult(
                    agentType: .themer,
                    status: .failed,
                    error: error,
                    executionTimeSeconds: Date().timeIntervalSince(startTime)
                )
            }
            
            return AgentExecutionResult(
                agentType: .themer,
                status: .completed,
                content: themerOutput,
                executionTimeSeconds: Date().timeIntervalSince(startTime)
            )
            
        } catch {
            return AgentExecutionResult(
                agentType: .themer,
                status: .failed,
                error: error.localizedDescription,
                executionTimeSeconds: Date().timeIntervalSince(startTime)
            )
        }
    }
    
    /// Build theming prompt from context
    private func buildThemingPrompt(from context: AgentContext) -> String {
        var prompt = "USER REQUEST: \(context.originalPrompt)"
        
        if let plannerOutput = context.plannerOutput {
            prompt += "\n\nPLANNING SPECIFICATION:\n\(plannerOutput)"
        }
        
        if let instructions = context.additionalInstructions {
            prompt += "\n\nADDITIONAL DESIGN REQUIREMENTS: \(instructions)"
        }
        
        prompt += """
        
        
        Please create a MINIMAL, SwiftUI-inspired design token system for this simple application. Focus on:
        - Clean, uncluttered aesthetic matching SwiftUI principles
        - Generous white space and breathing room
        - Subtle, purposeful color choices
        - Excellent readability and accessibility
        - Mobile-first responsive design
        - Functional beauty without decorative excess
        
        Create design tokens that will result in a beautiful, simple, and highly usable application.
        Return the design system as valid JSON following the specified format.
        """
        
        return prompt
    }
    
    /// Extract and validate themer output
    private func extractAndValidateThemerOutput(_ rawContent: String) -> String {       
        // Clean up the response to extract JSON
        var cleanContent = rawContent.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove any markdown code fences
        if cleanContent.hasPrefix("```json") {
            cleanContent = String(cleanContent.dropFirst(7))
        }
        if cleanContent.hasPrefix("```") {
            cleanContent = String(cleanContent.dropFirst(3))
        }
        if cleanContent.hasSuffix("```") {
            cleanContent = String(cleanContent.dropLast(3))
        }
        
        cleanContent = cleanContent.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Validate it's proper JSON by trying to parse it
        guard let jsonData = cleanContent.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData),
              let dict = jsonObject as? [String: Any] else {
            return ""
        }
        
        // Validate required fields (more flexible)
        let requiredFields = ["lightThemeTokens", "darkThemeTokens", "typography", "spacing"]
        let missingFields = requiredFields.filter { dict[$0] == nil }
        
        if !missingFields.isEmpty {
            // If we have the core color and typography, try to proceed
            if dict["lightThemeTokens"] != nil && dict["darkThemeTokens"] != nil {
            } else {
                return ""
            }
        }
        
        return cleanContent
    }
}

/// Errors specific to themer agent
enum ThemerAgentError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, message: String)
    case noChoices
    case noValidTheme
    case invalidAPIKey
    case jsonParsingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from API"
        case .httpError(let statusCode, let message):
            return "HTTP error \(statusCode): \(message)"
        case .noChoices:
            return "No response choices received"
        case .noValidTheme:
            return "No valid theme generated"
        case .invalidAPIKey:
            return "Invalid or missing API key"
        case .jsonParsingError:
            return "Failed to parse JSON response"
        }
    }
}
