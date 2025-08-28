import Foundation

/// API client for gpt-oss-120b model with reasoning - specialized for planning and specification
class PlannerAgentAPIClient: ObservableObject {
    private let apiKey: String
    private let baseURL = "https://api.cerebras.ai/v1"
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
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
    "Usability: Interface is intuitive and provides appropriate feedback",
    "Visual: Design follows brand color scheme exactly with no decorative elements",
    "Responsive: Works well on mobile and desktop devices"
  ],
  "testChecklist": [
    "Test 1: Verify all interactive elements respond correctly",
    "Test 2: Confirm calculations/logic produce expected results",
    "Test 3: Check visual feedback and state changes work properly",
    "Test 4: Validate responsive design on different screen sizes",
    "Test 5: Test error handling and edge cases"
  ],
  "architecture": "Single-page application with semantic HTML structure, CSS custom properties for theming, and vanilla JavaScript for interactivity. Organized with clear separation of concerns: structure (HTML), presentation (CSS), and behavior (JS).",
  "userExperience": "Clean, modern interface with intuitive controls and clear visual hierarchy. Consistent with brand aesthetics using defined color variables. Responsive design that works well on mobile. Smooth interactions with appropriate feedback. Accessible design with proper contrast and touch targets."
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
        
        // Validate API key
        if apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let error = PlannerAgentError.invalidAPIKey.localizedDescription
            return AgentExecutionResult(
                agentType: .planner,
                status: .failed,
                error: error,
                executionTimeSeconds: Date().timeIntervalSince(startTime)
            )
        }
        
        guard let url = URL(string: "\(baseURL)/chat/completions") else {
            let error = PlannerAgentError.invalidURL.localizedDescription
            return AgentExecutionResult(
                agentType: .planner,
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
        // Build planning prompt
        let userPrompt = buildPlanningPrompt(from: context)
        
        let requestBody: [String: Any] = [
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userPrompt]
            ],
            "model": "gpt-oss-120b",
            "temperature": 0.3,
            "max_tokens": 12000,
            "top_p": 0.85,
            "reasoning_effort": "medium"
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                let error = PlannerAgentError.invalidResponse.localizedDescription
                return AgentExecutionResult(
                    agentType: .planner,
                    status: .failed,
                    error: error,
                    executionTimeSeconds: Date().timeIntervalSince(startTime)
                )
            }
            
            if httpResponse.statusCode != 200 {
                let errorData = String(data: data, encoding: .utf8) ?? "Unknown error"
                print("[PlannerAgent] HTTP Error \(httpResponse.statusCode): \(errorData)")
                
                let error = PlannerAgentError.httpError(statusCode: httpResponse.statusCode, message: errorData).localizedDescription
                return AgentExecutionResult(
                    agentType: .planner,
                    status: .failed,
                    error: error,
                    executionTimeSeconds: Date().timeIntervalSince(startTime)
                )
            }
            
            let apiResponse = try JSONDecoder().decode(CerebrasAPIResponse.self, from: data)
            
            guard let firstChoice = apiResponse.choices.first else {
                let error = PlannerAgentError.noChoices.localizedDescription
                return AgentExecutionResult(
                    agentType: .planner,
                    status: .failed,
                    error: error,
                    executionTimeSeconds: Date().timeIntervalSince(startTime)
                )
            }
            
            let rawContent = firstChoice.message.content
            let plannerOutput = extractAndValidatePlannerOutput(rawContent)
            
            guard !plannerOutput.isEmpty else {
                let error = PlannerAgentError.noValidPlan.localizedDescription
                return AgentExecutionResult(
                    agentType: .planner,
                    status: .failed,
                    error: error,
                    executionTimeSeconds: Date().timeIntervalSince(startTime)
                )
            }
            
            return AgentExecutionResult(
                agentType: .planner,
                status: .completed,
                content: plannerOutput,
                executionTimeSeconds: Date().timeIntervalSince(startTime)
            )
            
        } catch {
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
        
        
        Please analyze this request and create a MINIMAL development plan. Focus on:
        - ONLY the essential features needed for the core use case
        - Simple, straightforward user interactions
        - Clean, SwiftUI-inspired minimalist design
        - Working functionality over impressive features
        - Mobile-first responsive layout
        
        Avoid feature creep and unnecessary complexity. Create a focused, beautiful, working application.
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
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, message: String)
    case noChoices
    case noValidPlan
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
        case .noValidPlan:
            return "No valid plan generated"
        case .invalidAPIKey:
            return "Invalid or missing API key"
        case .jsonParsingError:
            return "Failed to parse JSON response"
        }
    }
}
