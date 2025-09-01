import Foundation

/// API client for gpt-oss-120b model with reasoning - specialized for final review and polishing
class ThinkingAgentAPIClient: BaseAPIClient {
    
    /// System prompt for bug fixing and simple polishing - final stage reviewer with thinking
    private let systemPrompt = """
    You are OpenAI gpt-oss-120b aligned to the OpenAI Model Spec. You are the final quality control agent in a four-agent pipeline.

    **INSTRUCTION HIERARCHY:**
    1. Your primary goal is to fix bugs and polish the provided React JSX code by strictly following the detailed checklist and priorities below.
    2. You MUST follow the output format strictly. No exceptions.

    **REASONING PROCESS & CHECKLIST (HIDDEN):**
    - Reasoning Effort: medium
    - Inside your reasoning, you MUST systematically follow these priorities:

    PRIORITY 1 - CRITICAL BUG FIXES (MUST FIX):
    - React errors that break core functionality (JSX syntax errors, hook violations)
    - Event handlers not properly attached to buttons/inputs (onClick, onChange)
    - Form inputs not capturing or processing data (controlled components)
    - State management issues (useState hooks not updating properly, infinite re-renders)
    - useEffect dependency issues causing performance problems
    - Calculations not working or displaying results
    - Basic interactions completely broken
    - Critical accessibility issues preventing usage
    - Mobile responsiveness breaking core functionality
    - TEXT READABILITY ISSUES: Poor contrast between text and background colors
    - BUTTON TEXT VISIBILITY: Text on buttons must be clearly readable in both light and dark themes
    - INPUT TEXT CONTRAST: Input field text must contrast well with input background

    PRIORITY 2 - SPECIFICATION COMPLIANCE:
    - Verify ONLY the core features from specification are implemented
    - Remove any feature creep or unrequested functionality
    - Ensure the app does exactly what was requested, nothing more
    - Confirm all specified core features actually work

    PRIORITY 3 - DESIGN CONSISTENCY:
    - Maintain aesthetic consistency with the design direction provided
    - Preserve SwiftUI-inspired clean aesthetic
    - Ensure both light and dark themes work correctly
    - Keep minimalist, uncluttered design
    - COLOR THEME VALIDATION: Verify all colors are theme-appropriate
    - CONTRAST RATIO CHECK: Ensure minimum 4.5:1 contrast ratio for text readability
    - THEME-SPECIFIC FIXES: Apply correct colors for light/dark themes (dark text on light backgrounds, light text on dark backgrounds)
    - BUTTON COLOR FIXES: ensure text is visible against button background
    - INPUT FIELD COLORS: Verify input text color contrasts with input background color

    PRIORITY 4 - EXPLICIT FIXES ONLY (execute only if priorities 1-3 are complete):
    - Add hover states: opacity 0.9 for buttons, no other effects
    - Fix spacing: use 16px/24px padding standards exactly
    - Add focus outlines: 2px solid var(--color-primary) on focusable elements
    - Do NOT add any improvements beyond these specific fixes

    WHAT NOT TO DO:
    - Do NOT add features that weren't requested
    - Do NOT make the design more complex or "impressive"
    - Do NOT add animations, effects, or visual flourishes
    - Do NOT add history, settings, or configuration panels
    - Do NOT add "nice-to-have" functionality
    - Do NOT change the core simplicity of the design
    - Do NOT add theme switching buttons or theme toggle functionality

    **FINAL OUTPUT (VISIBLE):**
    - After your thinking process is complete, provide the final, complete, and corrected React JSX code.
    """

    /// Review and polish the final application
    func reviewAndImprove(context: AgentContext) async throws -> AgentExecutionResult {
        let startTime = Date()
        
        // Build comprehensive review prompt with all context
        let userPrompt = buildReviewPrompt(from: context)
        
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
        
        do {
            let apiResponse = try await makeAPIRequest(
                requestBody: requestBody,
                responseType: CerebrasAPIResponse.self,
                agentName: "ThinkingAgent"
            )
            
            guard let firstChoice = apiResponse.choices.first else {
                return AgentExecutionResult(
                    agentType: .reviewer,
                    status: .failed,
                    error: ThinkingAgentError.noChoices.localizedDescription,
                    executionTimeSeconds: Date().timeIntervalSince(startTime)
                )
            }
            
            guard let rawContent = extractContent(from: firstChoice, agentName: "ThinkingAgent") else {
                return AgentExecutionResult(
                    agentType: .reviewer,
                    status: .failed,
                    error: ThinkingAgentError.noValidImprovement.localizedDescription,
                    executionTimeSeconds: Date().timeIntervalSince(startTime)
                )
            }
            
            // Log reasoning if available (for debugging)
            if let reasoning = firstChoice.message.reasoning {
                print("[ThinkingAgent] Model reasoning available, length: \(reasoning.count)")
                print("[ThinkingAgent] Reasoning preview: \(String(reasoning.prefix(200)))...")
            }
            
            let improvedContent = extractHTMLFromResponse(rawContent)
            
            guard !improvedContent.isEmpty else {
                return AgentExecutionResult(
                    agentType: .reviewer,
                    status: .failed,
                    error: ThinkingAgentError.noValidImprovement.localizedDescription,
                    executionTimeSeconds: Date().timeIntervalSince(startTime)
                )
            }
            
            return AgentExecutionResult(
                agentType: .reviewer,
                status: .completed,
                content: improvedContent,
                executionTimeSeconds: Date().timeIntervalSince(startTime)
            )
            
        } catch let error as APIError {
            return AgentExecutionResult(
                agentType: .reviewer,
                status: .failed,
                error: error.localizedDescription,
                executionTimeSeconds: Date().timeIntervalSince(startTime)
            )
        } catch {
            print("[ThinkingAgent] CATCH ERROR: \(error)")
            if let decodingError = error as? DecodingError {
                print("[ThinkingAgent] Decoding error details: \(decodingError)")
            }
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
        
        // Include design direction and aesthetic mood
        if let themerOutput = context.themerOutput {
            prompt += "\n\n=== DESIGN DIRECTION & AESTHETIC MOOD ==="
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
        
        
        REACT REVIEW AND FIX TASK:
        1. First, check if ALL interactive elements work correctly (buttons, inputs, calculations)
        2. **CRITICAL COLOR CHECK**: Verify ALL text is readable in both light and dark themes
           - Check button text visibility (especially calculator/number buttons)
           - Validate input field text contrast
           - Ensure no poor color combinations (light text on light backgrounds, etc.)
        3. Remove any features that weren't specifically requested (avoid feature creep)
        4. Verify the design matches SwiftUI minimalist aesthetic
        5. Fix any broken React functionality (hooks, state management, event handlers)
        6. **THEME CONSISTENCY**: Ensure colors are appropriate for each theme (dark text on light, light text on dark)
        7. Keep it simple - don't add complexity or "impressive" features
        8. Return the final, working React JSX component

        Focus on making core React functionality work perfectly while keeping it beautifully simple and ensuring excellent readability.
        """
        
        return prompt
    }
    
    /// Clean React JSX content from API response
    private func extractHTMLFromResponse(_ content: String) -> String {
        print("[ThinkingAgent] Raw response length: \(content.count)")
        print("[ThinkingAgent] Raw response preview: \(String(content.prefix(200)))...")
        
        var cleanContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove markdown code fences
        cleanContent = cleanContent.replacingOccurrences(
            of: #"```(?:html|javascript|css|jsx|react|js)?\s*\n?"#,
            with: "",
            options: .regularExpression
        )
        cleanContent = cleanContent.replacingOccurrences(
            of: #"```\s*$"#,
            with: "",
            options: .regularExpression
        )
        cleanContent = cleanContent.replacingOccurrences(of: "```", with: "")
        
        // Extract React JSX component
        if let functionMatch = cleanContent.range(of: #"function\s+App\s*\([^)]*\)[\s\S]*"#, options: [.regularExpression]) {
            cleanContent = String(cleanContent[functionMatch.lowerBound...])
        } else if let constMatch = cleanContent.range(of: #"const\s+App\s*=[\s\S]*"#, options: [.regularExpression]) {
            cleanContent = String(cleanContent[constMatch.lowerBound...])
        }
        
        // Find the last closing brace of the component
        var braceCount = 0
        var inFunction = false
        var endIndex = cleanContent.endIndex
        
        for (index, char) in cleanContent.enumerated() {
            let stringIndex = cleanContent.index(cleanContent.startIndex, offsetBy: index)
            if char == "{" {
                if !inFunction {
                    inFunction = true
                }
                braceCount += 1
            } else if char == "}" {
                braceCount -= 1
                if inFunction && braceCount == 0 {
                    endIndex = cleanContent.index(stringIndex, offsetBy: 1)
                    break
                }
            }
        }
        
        if endIndex != cleanContent.endIndex {
            cleanContent = String(cleanContent[..<endIndex])
        }
        
        let finalContent = cleanContent.trimmingCharacters(in: .whitespacesAndNewlines)
        print("[ThinkingAgent] Final React code length: \(finalContent.count)")
        print("[ThinkingAgent] React extraction successful: \(!finalContent.isEmpty)")
        
        // Validate that the reviewer actually returned a meaningful React component.
        // Guard against degenerate outputs like "const App = () => {...}" with only an ellipsis
        // or extremely short placeholders that break the pipeline.
        let minimumLength = 200
        let hasReturnJSX = finalContent.range(of: #"return\s*\("#, options: [.regularExpression]) != nil
            || finalContent.range(of: #"return\s*<"#, options: [.regularExpression]) != nil
        let mentionsAppComponent = finalContent.contains("const App") || finalContent.contains("function App")
        let looksTruncated = finalContent.contains("...") && finalContent.count < 500
        
        if finalContent.count < minimumLength || !hasReturnJSX || !mentionsAppComponent || looksTruncated {
            print("[ThinkingAgent] Reviewer output rejected as too short or invalid. Falling back upstream.")
            return ""
        }
        
        return finalContent
    }
}

/// Errors specific to thinking agent
enum ThinkingAgentError: Error, LocalizedError {
    case noChoices
    case noValidImprovement
    
    var errorDescription: String? {
        switch self {
        case .noChoices:
            return "No response choices received"
        case .noValidImprovement:
            return "Thinking agent failed to improve the code"
        }
    }
}
