import Foundation

/// API client for gpt-oss-120b model with reasoning - specialized for planning and specification
class PlannerAgentAPIClient: BaseAPIClient {
    
    /// System prompt for balanced planning with reasoning - focused but complete
    private let systemPrompt = """
You are an expert product designer with enhanced reasoning capabilities, focused on creating WELL-DESIGNED, FUNCTIONAL applications. Your role is to take user requests and plan complete but focused implementations.

USE REASONING TO:
- Analyze user needs and identify core vs. nice-to-have features
- Consider edge cases and potential user flows
- Evaluate the balance between functionality and simplicity
- Plan a coherent user experience from start to finish
- Anticipate implementation challenges and design around them

CORE PRINCIPLES:
- COMPLETE CORE EXPERIENCE: Include all essential features for basic functionality
- FOCUSED SCOPE: Maximum 4 core features, no advanced features
- QUALITY IMPLEMENTATION: Each feature must work perfectly
- VISUAL COMPLETENESS: Include all necessary UI elements for functionality
- USER-FRIENDLY: Include only expected basic interactions

TASK: Transform the user's request into a complete plan that covers:

1. CORE FEATURES: All essential features needed for a complete, working application
2. USER FLOWS: Clear, intuitive interactions that feel natural
3. INTERFACE ELEMENTS: Proper buttons, inputs, displays, and visual feedback
4. BASIC CRITERIA: Comprehensive requirements covering functionality and usability
5. VALIDATION TESTS: Tests that ensure the application works as expected
6. CLEAN ARCHITECTURE: Well-structured implementation approach
7. POLISHED UX: Professional, attractive user experience

OUTPUT FORMAT (JSON):
{
  "features": [
    "Core Feature 1: Primary functionality with proper interface",
    "Core Feature 2: Essential secondary functionality",
    "Core Feature 3: Important user interaction",
    "Core Feature 4: Required feedback display (only if needed for core functionality)"
  ],
  "macroFlows": [
    "Primary Flow: User opens app → performs main actions → sees clear results",
    "Secondary Flow: User handles edge cases or alternative interactions",
    "Error Flow: User encounters errors → receives helpful feedback → can recover"
  ],
  "acceptanceCriteria": [
    "Functionality: All core features work correctly and responsively",
    "Interface: Buttons, inputs, and displays are properly styled and functional",
    "Readability: All text is clearly visible with proper contrast in both light and dark themes",
    "Usability: Interface is intuitive and provides appropriate feedback",
    "Visual: Design follows brand color scheme exactly with no decorative elements",
    "Theme Compatibility: Colors work perfectly in both light and dark modes",
    "Responsive: Works well on mobile and desktop devices"
  ],
  "testChecklist": [
    "Test 1: Verify all interactive elements respond correctly",
    "Test 2: Confirm calculations/logic produce expected results",
    "Test 3: Check visual feedback and state changes work properly",
    "Test 4: Validate text readability and contrast in both light and dark themes",
    "Test 5: Verify button text visibility",
    "Test 6: Validate responsive design on different screen sizes",
    "Test 7: Test error handling and edge cases"
  ],
  "architecture": "Modern React application with functional components and hooks. Uses JSX syntax, ES6+ features, and component-based architecture. State managed through React hooks (useState, useEffect). Clean separation of concerns with reusable components and responsive design patterns.",
  "userExperience": "Clean, modern React interface with intuitive controls and clear visual hierarchy. Component-based architecture ensures maintainable and scalable code. Consistent with brand aesthetics using CSS-in-JS or className approaches. Responsive design optimized for mobile-first experience. Smooth interactions with React state management and proper hook usage. Accessible design with proper contrast and touch targets."
}

EXAMPLES OF GOOD BALANCED SCOPE:
- Calculator: Basic arithmetic operations (+, -, ×, ÷), clear button, number display, proper button styling with primary/secondary colors
- Todo List: Add task, mark complete, delete task, task counter, clean list interface
- Timer: Set minutes/seconds, start/stop/reset, countdown display, completion alert
- Color Picker: Color selection, hex/rgb display, copy to clipboard, color preview

AVOID BOTH EXTREMES:
- DON'T add complex features like: advanced settings, user accounts, data export, complex calculations
- DON'T omit basic features like: proper styling, essential buttons, clear displays, basic interactions

CRITICAL: Return ONLY valid JSON. No explanations, no markdown, no additional text.
"""
    
    /// Generate comprehensive plan and specification
    func generatePlan(context: AgentContext) async throws -> AgentExecutionResult {
        let startTime = Date()
        
        // Build planning prompt
        let userPrompt = buildPlanningPrompt(from: context)
        
        let requestBody: [String: Any] = [
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userPrompt]
            ],
            "model": "gpt-oss-120b",
            "temperature": 0.3,
            "max_completion_tokens": 12000,
            "top_p": 0.85,
            "reasoning_effort": "medium"
        ]
        
        do {
            let apiResponse = try await makeAPIRequest(
                requestBody: requestBody,
                responseType: CerebrasAPIResponse.self,
                agentName: "PlannerAgent"
            )
            
            guard let firstChoice = apiResponse.choices.first else {
                return AgentExecutionResult(
                    agentType: .planner,
                    status: .failed,
                    error: PlannerAgentError.noChoices.localizedDescription,
                    executionTimeSeconds: Date().timeIntervalSince(startTime)
                )
            }
            
            guard let rawContent = extractContent(from: firstChoice, agentName: "PlannerAgent") else {
                return AgentExecutionResult(
                    agentType: .planner,
                    status: .failed,
                    error: PlannerAgentError.noValidPlan.localizedDescription,
                    executionTimeSeconds: Date().timeIntervalSince(startTime)
                )
            }
            
            let plannerOutput = extractAndValidatePlannerOutput(rawContent)
            
            guard !plannerOutput.isEmpty else {
                return AgentExecutionResult(
                    agentType: .planner,
                    status: .failed,
                    error: PlannerAgentError.noValidPlan.localizedDescription,
                    executionTimeSeconds: Date().timeIntervalSince(startTime)
                )
            }
            
            return AgentExecutionResult(
                agentType: .planner,
                status: .completed,
                content: plannerOutput,
                executionTimeSeconds: Date().timeIntervalSince(startTime)
            )
            
        } catch let error as APIError {
            return AgentExecutionResult(
                agentType: .planner,
                status: .failed,
                error: error.localizedDescription,
                executionTimeSeconds: Date().timeIntervalSince(startTime)
            )
        } catch {
            print("[PlannerAgent] CATCH ERROR: \(error)")
            if let decodingError = error as? DecodingError {
                print("[PlannerAgent] Decoding error details: \(decodingError)")
            }
            return AgentExecutionResult(
                agentType: .planner,
                status: .failed,
                error: error.localizedDescription,
                executionTimeSeconds: Date().timeIntervalSince(startTime)
            )
        }
    }
    
    /// Build planning prompt from context
    private func buildPlanningPrompt(from context: AgentContext) -> String {
        var prompt = "USER REQUEST: \(context.originalPrompt)"
        
        if let instructions = context.additionalInstructions {
            prompt += "\n\nADDITIONAL REQUIREMENTS: \(instructions)"
        }
        
        prompt += """
        
        
        Please analyze this request and create a MINIMAL React development plan. Focus on:
        - ONLY the essential features needed for the core use case
        - Simple, straightforward user interactions using React hooks
        - Clean, SwiftUI-inspired minimalist design with React components
        - Working functionality over impressive features
        - Mobile-first responsive layout
        - Modern React patterns (functional components, hooks, controlled inputs)
        
        Avoid feature creep and unnecessary complexity. Create a focused, beautiful, working React application.
        Return the plan as valid JSON following the specified format.
        """
        
        return prompt
    }
    
    /// Extract and validate planner output with robust JSON parsing
    private func extractAndValidatePlannerOutput(_ rawContent: String) -> String {
        // Log raw content for debugging
        print("[PlannerAgent] Raw response length: \(rawContent.count)")
        print("[PlannerAgent] Raw response preview: \(String(rawContent.prefix(200)))...")
        
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
        
        // Try to find JSON object boundaries if there's extra text
        if let jsonStart = cleanContent.firstIndex(of: "{"),
           let jsonEnd = cleanContent.lastIndex(of: "}") {
            let jsonRange = jsonStart...jsonEnd
            cleanContent = String(cleanContent[jsonRange])
        }
        
        // Validate it's proper JSON by trying to parse it
        guard let jsonData = cleanContent.data(using: .utf8) else {
            print("[PlannerAgent] Failed to convert to data")
            return ""
        }
        
        do {
            guard let jsonObject = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
                print("[PlannerAgent] Failed to parse JSON object")
                return ""
            }
            
            // Validate required fields with more lenient approach
            let requiredFields = ["features", "macroFlows", "acceptanceCriteria", "testChecklist", "architecture", "userExperience"]
            let criticalFields = ["features", "macroFlows"] // Most critical fields
            
            let missingCritical = criticalFields.filter { jsonObject[$0] == nil }
            let missingAll = requiredFields.filter { jsonObject[$0] == nil }
            
            if !missingCritical.isEmpty {
                print("[PlannerAgent] Missing critical fields: \(missingCritical)")
                return ""
            }
            
            if !missingAll.isEmpty {
                print("[PlannerAgent] Missing optional fields: \(missingAll), but proceeding with core planning")
            }
            
            print("[PlannerAgent] JSON validation successful")
            return cleanContent
            
        } catch {
            print("[PlannerAgent] JSON parsing error: \(error)")
            return ""
        }
    }
}

/// Errors specific to planner agent
enum PlannerAgentError: Error, LocalizedError {
    case noChoices
    case noValidPlan
    
    var errorDescription: String? {
        switch self {
        case .noChoices:
            return "No response choices received"
        case .noValidPlan:
            return "No valid plan generated"
        }
    }
}
