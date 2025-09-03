import Foundation

/// API client for gpt-oss-120b model with reasoning - specialized for theming and UX design tokens
class ThemerAgentAPIClient: BaseAPIClient {
    
    /// System prompt for design mood and style description with reasoning
    private let systemPrompt = """
You are an expert UX/UI designer specializing in Craftopia's Soft UI (Flat 2.0) design system. Your role is to create precise, implementable design specifications that produce beautiful, sophisticated interfaces matching Apple's modern aesthetic.

CRAFTOPIA DESIGN PHILOSOPHY:
- **Soft UI (Flat 2.0)**: Clean minimalism + subtle depth through shadows and gradients
- **Sophisticated Surfaces**: Multi-layered shadows create tactile, elevated feel
- **Premium Spacing**: Generous padding (16-24px) for breathing room
- **Refined Typography**: Clear hierarchy without visual noise
- **Elegant Interactions**: Smooth animations with meaningful feedback

CORE VISUAL LANGUAGE:
- **Shadows**: Multi-layered for realistic depth
  - Light: 0 2px 6px rgba(30,41,59,0.06)
  - Medium: 0 4px 12px rgba(30,41,59,0.08) + 0 2px 6px rgba(30,41,59,0.04)
  - Strong: 0 6px 24px rgba(30,41,59,0.12) + 0 4px 12px rgba(30,41,59,0.06)
- **Corner Radius**: 10px buttons, 12px inputs, 14px cards, 16px containers
- **Gradients**: Subtle 2-4% brightness variations for surface sophistication
- **Borders**: 1px solid with transparency for definition without heaviness

COLOR SYSTEM (USE EXACTLY):
Light Theme:
- Background: #F5F6F8 (main canvas)
- Surface: #FFFFFF (containers, cards)
- Primary: #186DEE → #1B77FD (gradient for actions)
- Border: #E3E6EB (container separation)
- Text Heading: #131B22
- Text Main: #4B5669  
- Text Muted: #99A1B3

Dark Theme:
- Background: #07090D
- Surface: #15171F → #0C0E12 (gradient)
- Border: #3A3A3C
- Text Heading: #FFFFFF
- Text Main: #EBEBF5
- Text Muted: #8E8E93

COMPONENT SPECIFICATIONS:
**Primary Button**:
- Gradient: linear-gradient(180deg, #6DA4FB 0%, #206CE5 100%)
- Shadow: 0 2px 8px rgba(32,108,229,0.12)
- Radius: 10px, Min height: 44px
- Text: #FFFFFF, font-weight: 600
- Hover: lift 2px + shadow intensity +20%

**Secondary Button**:
- Gradient: linear-gradient(180deg, #FFFFFF 0%, #ECECEC 100%)  
- Shadow: 0 2px 6px rgba(30,41,59,0.06)
- Border: 1px solid #EAEAEA
- Text: #545A62

**Input Fields**:
- Background: Surface color
- Border: 1px solid Border color → Primary on focus
- Inner shadow: inset 0 1px 3px rgba(0,0,0,0.05)
- Padding: 12px 16px
- Radius: 12px

**Cards/Containers**:
- Background: Surface gradient
- Shadow: 0 4px 24px rgba(30,41,59,0.08)
- Border: 1px solid Border color
- Radius: 14px
- Padding: 20px

INTERACTION PATTERNS:
- Hover states: translateY(-2px) + shadow enhancement
- Press states: scale(0.96) for 100ms
- Focus states: border color change + subtle glow
- Transitions: 200ms ease-out for smooth feel

SPACING SYSTEM (8pt grid):
- Component padding: 16px standard, 20px premium containers
- Vertical gaps: 12px tight, 16px standard, 24px sections
- Touch targets: minimum 44px for accessibility

RESPONSIVE APPROACH:
- Mobile-first: stack vertically, full-width components
- Desktop: horizontal layouts, max-width containers
- Breakpoint: 768px for layout shifts
- Consistent shadows/gradients across all sizes

OUTPUT REQUIREMENTS:
Create a comprehensive design specification that includes:
1. **Visual Mood**: Overall aesthetic direction (clean, premium, sophisticated)
2. **Color Application**: Specific color usage for backgrounds, text, accents
3. **Component Styling**: Detailed specifications for buttons, inputs, cards
4. **BUTTON TYPES**: Specific styling for primary, secondary
5. **READABILITY FOCUS**: Explicit contrast specifications for text visibility
6. **THEME CONSISTENCY**: Ensure colors work perfectly in both light and dark themes
7. **Interaction Design**: Hover, focus, and animation specifications
8. **Layout Guidelines**: Spacing, typography, and responsive behavior

**IMPORTANT**: Do NOT include theme switching functionality, toggle buttons, or dark/light theme controls, theme must be applied based on the current color scheme only

Be specific with exact colors, shadow values, border radius, and spacing measurements.
Focus on creating designs that feel like premium Apple software with subtle depth and sophisticated simplicity.

CRITICAL: Return ONLY the design specification text. No JSON, no markdown, no additional formatting.
"""
    
    /// Generate design tokens and visual theme
    func generateTheme(context: AgentContext) async throws -> AgentExecutionResult {
        let startTime = Date()
        print("[ThemerAgent] Starting theme generation...")
        
        // Build theming prompt
        let userPrompt = buildThemingPrompt(from: context)
        print("[ThemerAgent] Built user prompt, length: \(userPrompt.count)")
        
        let requestBody: [String: Any] = [
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userPrompt]
            ],
            "model": "gpt-oss-120b",
            "temperature": 0.5,
            "max_completion_tokens": 12000,
            "top_p": 0.9,
            "reasoning_effort": "medium"
        ]
        
        print("[ThemerAgent] Request body prepared, making API call...")
        
        do {
            let apiResponse = try await makeAPIRequest(
                requestBody: requestBody,
                responseType: CerebrasAPIResponse.self,
                agentName: "ThemerAgent"
            )
            
            guard let firstChoice = apiResponse.choices.first else {
                print("[ThemerAgent] ERROR: No choices in API response")
                return AgentExecutionResult(
                    agentType: .themer,
                    status: .failed,
                    error: ThemerAgentError.noChoices.localizedDescription,
                    executionTimeSeconds: Date().timeIntervalSince(startTime)
                )
            }
            
            print("[ThemerAgent] Found choice, extracting content...")
            
            guard let rawContent = extractContent(from: firstChoice, agentName: "ThemerAgent") else {
                return AgentExecutionResult(
                    agentType: .themer,
                    status: .failed,
                    error: ThemerAgentError.noValidTheme.localizedDescription,
                    executionTimeSeconds: Date().timeIntervalSince(startTime)
                )
            }
            
            // Log reasoning if available (for debugging)
            if let reasoning = firstChoice.message.reasoning {
                print("[ThemerAgent] Model reasoning available, length: \(reasoning.count)")
                print("[ThemerAgent] Reasoning preview: \(String(reasoning.prefix(200)))...")
            }
            
            let themerOutput = extractAndValidateThemerOutput(rawContent)
            
            guard !themerOutput.isEmpty else {
                return AgentExecutionResult(
                    agentType: .themer,
                    status: .failed,
                    error: ThemerAgentError.noValidTheme.localizedDescription,
                    executionTimeSeconds: Date().timeIntervalSince(startTime)
                )
            }
            
            return AgentExecutionResult(
                agentType: .themer,
                status: .completed,
                content: themerOutput,
                executionTimeSeconds: Date().timeIntervalSince(startTime)
            )
            
        } catch let error as APIError {
            return AgentExecutionResult(
                agentType: .themer,
                status: .failed,
                error: error.localizedDescription,
                executionTimeSeconds: Date().timeIntervalSince(startTime)
            )
        } catch {
            print("[ThemerAgent] CATCH ERROR: \(error)")
            if let decodingError = error as? DecodingError {
                print("[ThemerAgent] Decoding error details: \(decodingError)")
            }
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
        
        
        Create a comprehensive design specification for this React application using Craftopia's Soft UI design system. Provide specific implementation details:

        REQUIRED SPECIFICATIONS:
        1. **Visual Mood & Aesthetic**: Describe the overall feeling (clean, premium, sophisticated, modern)
        2. **Color Usage**: Specify exact color application for backgrounds, text, buttons, borders, and accents
        3. **Component Styling**: Detail the visual treatment for buttons, inputs, cards, and containers
        4. **BUTTON TYPE SPECIFICS**: Provide separate styling for:
           - Primary action buttons (main CTAs)
           - Secondary buttons (less important actions)
           - Number/Calculator buttons (for keypad interfaces) - CRITICAL for readability
        5. **READABILITY REQUIREMENTS**: Explicitly specify text colors that contrast well with backgrounds
        6. **THEME COMPATIBILITY**: Ensure all color combinations work in both light and dark themes
        7. MAKE SURE that the application colors match the colorscheme.
        8. **CONTRAST VALIDATION**: Verify minimum 4.5:1 contrast ratio for all text elements
        9. **Shadow & Elevation**: Specify shadow values, layering, and depth treatments
        10. **Interaction Design**: Define hover states, focus treatments, and animation specifications
        11. **Spacing & Layout**: Provide padding, margins, and responsive behavior guidelines
        12. **Typography**: Specify font weights, sizes, and text hierarchy
        
        Be specific with measurements, colors, and visual effects. Reference the Craftopia design system values provided in the system prompt.
        The CoderAgent will implement exactly what you specify, so be precise and comprehensive.
        
        Focus on creating a design that feels like premium Apple software with subtle depth and sophisticated simplicity.
        """
        
        return prompt
    }
    
    /// Extract and validate themer output as plain text
    private func extractAndValidateThemerOutput(_ rawContent: String) -> String {
        // Log raw content for debugging
        print("[ThemerAgent] Raw response length: \(rawContent.count)")
        print("[ThemerAgent] Raw response preview: \(String(rawContent.prefix(200)))...")
        
        // Clean up the response
        var cleanContent = rawContent.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove any markdown code fences or formatting
        cleanContent = cleanContent.replacingOccurrences(
            of: #"```[^\n]*\n?"#,
            with: "",
            options: .regularExpression
        )
        cleanContent = cleanContent.replacingOccurrences(of: "```", with: "")
        
        // Remove any JSON artifacts if present
        cleanContent = cleanContent.replacingOccurrences(of: "{", with: "")
        cleanContent = cleanContent.replacingOccurrences(of: "}", with: "")
        cleanContent = cleanContent.replacingOccurrences(of: "\":", with: ":")
        cleanContent = cleanContent.replacingOccurrences(of: "\"", with: "")
        
        cleanContent = cleanContent.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Validate we have meaningful content
        guard cleanContent.count > 50 else {
            print("[ThemerAgent] Content too short: \(cleanContent.count) characters")
            return ""
        }
        
        print("[ThemerAgent] Text extraction successful")
        return cleanContent
    }
}

/// Errors specific to themer agent
enum ThemerAgentError: Error, LocalizedError {
    case noChoices
    case noValidTheme
    
    var errorDescription: String? {
        switch self {
        case .noChoices:
            return "No response choices received"
        case .noValidTheme:
            return "No valid theme generated"
        }
    }
}
