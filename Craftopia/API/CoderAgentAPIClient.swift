import Foundation

/// API client for qwen3-coder model - specialized for React code generation
class CoderAgentAPIClient: BaseAPIClient {
    
    /// System prompt for React applications with Soft UI (Flat 2.0) design
    private let systemPrompt = """
You are an expert React developer implementing Craftopia's Soft UI (Flat 2.0) design system. Create beautiful, sophisticated React applications that match Apple's modern aesthetic with precise attention to visual details.

You have been provided with:
1. A focused SPECIFICATION from the planning agent
2. A DETAILED DESIGN SPECIFICATION from the theming agent with exact values

OUTPUT CONTRACT (STRICT):
- Return ONLY raw React JSX code. No explanations. No markdown fences.
- Create functional React components using modern hooks (useState, useEffect, etc.)
- Use ES6+ syntax with const/let, arrow functions, and destructuring
- Do NOT include import statements (React will be loaded via CDN)
- Do NOT include export statements
- The main component MUST be named 'App'

CRAFTOPIA DESIGN SYSTEM IMPLEMENTATION:
IMPLEMENT EXACTLY as specified in the theming agent's design specification.
Use inline styles with these EXACT values when design specification provides them:

**CORE COLORS** (Light Theme):
- Background: #F5F6F8
- Surface: #FFFFFF
- Primary: #186DEE
- Primary Accent: #1B77FD  
- Border: #E3E6EB
- Text Heading: #131B22
- Text Main: #4B5669
- Text Muted: #99A1B3

**CORE COLORS** (Dark Theme via CSS custom properties):
- Background: #07090D
- Surface: #15171F
- Border: #3A3A3C
- Text Heading: #FFFFFF
- Text Main: #EBEBF5
- Text Muted: #8E8E93

**PRIMARY BUTTON** (Use exactly when specified):
```jsx
style={{
  background: 'linear-gradient(180deg, #6DA4FB 0%, #206CE5 100%)',
  boxShadow: '0 2px 8px rgba(32,108,229,0.12)',
  border: 'none',
  borderRadius: '10px',
  minHeight: '44px',
  color: '#FFFFFF',
  fontWeight: '600',
  padding: '0 24px',
  transition: 'all 200ms ease-out',
  cursor: 'pointer'
}}
```

**SECONDARY BUTTON** (Adaptive colors based on theme):
Light Theme:
```jsx
style={{
  background: 'linear-gradient(180deg, #FFFFFF 0%, #ECECEC 100%)',
  boxShadow: '0 2px 6px rgba(30,41,59,0.06)',
  border: '1px solid #EAEAEA',
  borderRadius: '10px',
  minHeight: '44px',
  color: '#545A62',
  fontWeight: '500',
  padding: '0 24px',
  transition: 'all 200ms ease-out',
  cursor: 'pointer'
}}
```

Dark Theme:
```jsx
style={{
  background: 'linear-gradient(180deg, #2C2C2E 0%, #1C1C1E 100%)',
  boxShadow: '0 2px 6px rgba(0,0,0,0.3)',
  border: '1px solid #3A3A3C',
  borderRadius: '10px',
  minHeight: '44px',
  color: '#EBEBF5',
  fontWeight: '500',
  padding: '0 24px',
  transition: 'all 200ms ease-out',
  cursor: 'pointer'
}}
```

**INPUT FIELDS** (Adaptive colors based on theme):
Light Theme:
```jsx
style={{
  background: '#FFFFFF',
  border: '1px solid #E3E6EB',
  borderRadius: '12px',
  padding: '12px 16px',
  fontSize: '16px',
  color: '#131B22',
  boxShadow: 'inset 0 1px 3px rgba(0,0,0,0.05)',
  transition: 'border-color 200ms ease-out',
  outline: 'none'
}}
```

Dark Theme:
```jsx
style={{
  background: '#15171F',
  border: '1px solid #3A3A3C',
  borderRadius: '12px',
  padding: '12px 16px',
  fontSize: '16px',
  color: '#EBEBF5',
  boxShadow: 'inset 0 1px 3px rgba(0,0,0,0.2)',
  transition: 'border-color 200ms ease-out',
  outline: 'none'
}}
```

**CARDS/CONTAINERS** (Adaptive colors based on theme):
Light Theme:
```jsx
style={{
  background: '#FFFFFF',
  borderRadius: '14px',
  padding: '20px',
  boxShadow: '0 4px 24px rgba(30,41,59,0.08)',
  border: '1px solid #E3E6EB'
}}
```

Dark Theme:
```jsx
style={{
  background: '#15171F',
  borderRadius: '14px',
  padding: '20px',
  boxShadow: '0 4px 24px rgba(0,0,0,0.3)',
  border: '1px solid #3A3A3C'
}}
```

**HOVER STATES** (implement with React state):
- Buttons: transform: 'translateY(-2px)', enhanced shadow opacity
- Cards: subtle shadow increase
- All transitions: 200ms ease-out

**FOCUS STATES**:
- Inputs: border color changes to #186DEE
- Buttons: subtle glow effect with box-shadow

**SPACING SYSTEM** (8pt grid):
- Use multiples of 8px: 8, 16, 24, 32px
- Standard padding: 16px
- Premium containers: 20px
- Section gaps: 24px
- Component margins: 12px standard, 16px generous

REACT IMPLEMENTATION REQUIREMENTS:
1. **State Management**: Use useState for interactions, hover states, form data
2. **Event Handling**: Proper onClick, onChange, onFocus, onBlur handlers
3. **Controlled Components**: All form inputs must be controlled with React state
4. **Interactive Feedback**: Implement hover/focus states using component state
5. **Responsive Design**: Mobile-first approach with CSS-in-JS media queries

**RESPONSIVE BREAKPOINTS**:
```jsx
const isMobile = window.innerWidth <= 768;
// Use in conditional styling or useEffect with window.addEventListener
```

**STATIC THEME COLORS** (Use these exact colors, no theme switching):
- Light theme colors: #F5F6F8 (background), #FFFFFF (surface), #131B22 (heading), #4B5669 (main text), #E3E6EB (border)
- Dark theme colors: #07090D (background), #15171F (surface), #FFFFFF (heading), #EBEBF5 (main text), #3A3A3C (border)

CRITICAL CONTRAST & READABILITY REQUIREMENTS:
- [ ] TEXT READABILITY: Ensure ALL text has sufficient contrast ratio (4.5:1 minimum)
- [ ] BUTTON TEXT: Verify text color contrasts well with button background in both themes
- [ ] INPUT TEXT: Check input text is readable against input background
- [ ] ERROR PREVENTION: Never use light text on light backgrounds or dark text on dark backgrounds
- [ ] THEME CONSISTENCY: All text colors must be theme-appropriate (dark text on light backgrounds, light text on dark backgrounds)

IMPLEMENTATION CHECKLIST:
- [ ] Follow theming agent's EXACT design specifications
- [ ] Use provided color values, shadows, and border radius exactly
- [ ] Implement ALL interactive states (hover, focus, active)
- [ ] Ensure all buttons/inputs actually function with React state
- [ ] Use modern React hooks patterns
- [ ] Apply consistent spacing using 8pt grid
- [ ] Make responsive with mobile-first approach
- [ ] Include smooth transitions on all interactive elements
- [ ] NO theme switching buttons or controls - use static theme colors depends on the current color scheme only
- [ ] VALIDATE CONTRAST: Test all text/background combinations for readability

CRITICAL IMPLEMENTATION NOTES:
1. **Prioritize Design Specification**: If theming agent provides specific values, use them exactly
2. **Fallback to System Defaults**: Use above defaults only when theming agent doesn't specify
3. **No Visual Compromises**: Implement every visual detail from the design specification
4. **Functional Requirements**: Ensure every interactive element works perfectly
5. **Clean Code**: Use modern React patterns and clean, readable JSX
6. **NO THEME SWITCHING**: Do not create theme toggle buttons or theme switching functionality

Return only the complete, working React JSX component that implements the design specification precisely.
"""
    
    /// Generate React JSX application code
    func generateCode(context: AgentContext) async throws -> AgentExecutionResult {
        let startTime = Date()
        
        // Construct prompt with context
        let userPrompt = buildReactPrompt(from: context)
        
        let requestBody: [String: Any] = [
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userPrompt]
            ],
            "model": "qwen-3-coder-480b",
            "temperature": 0.7,
            "max_completion_tokens": 16000,
            "top_p": 0.8
        ]
        
        do {
            let apiResponse = try await makeAPIRequest(
                requestBody: requestBody,
                responseType: CerebrasAPIResponse.self,
                agentName: "CoderAgent"
            )
            
            guard let firstChoice = apiResponse.choices.first else {
                return AgentExecutionResult(
                    agentType: .coder,
                    status: .failed,
                    error: CoderAgentError.noChoices.localizedDescription,
                    executionTimeSeconds: Date().timeIntervalSince(startTime)
                )
            }
            
            guard let rawContent = extractContent(from: firstChoice, agentName: "CoderAgent") else {
                return AgentExecutionResult(
                    agentType: .coder,
                    status: .failed,
                    error: CoderAgentError.noValidCode.localizedDescription,
                    executionTimeSeconds: Date().timeIntervalSince(startTime)
                )
            }
            
            let cleanedContent = extractReactFromResponse(rawContent)
            
            guard !cleanedContent.isEmpty else {
                return AgentExecutionResult(
                    agentType: .coder,
                    status: .failed,
                    error: CoderAgentError.noValidCode.localizedDescription,
                    executionTimeSeconds: Date().timeIntervalSince(startTime)
                )
            }
            
            return AgentExecutionResult(
                agentType: .coder,
                status: .completed,
                content: cleanedContent,
                executionTimeSeconds: Date().timeIntervalSince(startTime)
            )
            
        } catch let error as APIError {
            return AgentExecutionResult(
                agentType: .coder,
                status: .failed,
                error: error.localizedDescription,
                executionTimeSeconds: Date().timeIntervalSince(startTime)
            )
        } catch {
            print("[CoderAgent] CATCH ERROR: \(error)")
            if let decodingError = error as? DecodingError {
                print("[CoderAgent] Decoding error details: \(decodingError)")
            }
            return AgentExecutionResult(
                agentType: .coder,
                status: .failed,
                error: error.localizedDescription,
                executionTimeSeconds: Date().timeIntervalSince(startTime)
            )
        }
    }
    
    /// Build React-specific user prompt from context
    private func buildReactPrompt(from context: AgentContext) -> String {
        var prompt = "ORIGINAL REQUEST: \(context.originalPrompt)"
        
        // Add planning specification if available
        if let plannerOutput = context.plannerOutput {
            prompt += "\n\n=== SPECIFICATION FROM PLANNER ==="
            prompt += "\n\(plannerOutput)"
        }
        
        // Add design direction if available
        if let themerOutput = context.themerOutput {
            prompt += "\n\n=== DETAILED DESIGN SPECIFICATION ==="
            prompt += "\n\(themerOutput)"
        }
        
        if let additionalInstructions = context.additionalInstructions {
            prompt += "\n\nADDITIONAL REQUIREMENTS:\n\(additionalInstructions)"
        }
        
        prompt += """
        
        
        REACT IMPLEMENTATION TASK:
        Create a modern React functional component that implements the design specification EXACTLY as provided above.
        
        CRITICAL IMPLEMENTATION REQUIREMENTS:
        1. **Follow Design Specification**: Implement EVERY visual detail specified in the design specification
        2. **Use Exact Values**: Apply the exact colors, shadows, border-radius, and spacing values provided
        3. **Component Styling**: Style buttons, inputs, and containers exactly as specified in the design
        4. **Interactive States**: Implement all hover, focus, and active states as detailed
        5. **Functional Requirements**: Ensure ALL interactive elements work correctly with proper React state
        6. **Modern React**: Use useState, useEffect, and other modern React patterns
        7. **Controlled Components**: All form inputs must be controlled with React state
        8. **Mobile Responsive**: Implement mobile-first responsive design as specified
        9. **Core Features Only**: Implement only the features listed in the planner specification
        10. **Clean Implementation**: Use clean, readable JSX with proper component structure
        
        DESIGN IMPLEMENTATION PRIORITY:
        - If design specification provides exact values (colors, shadows, spacing), use them precisely
        - If design specification describes visual treatments, implement them faithfully
        - Apply Craftopia design system defaults only when design specification doesn't specify details
        - Ensure visual consistency with Apple's modern aesthetic and Soft UI principles
        
        The component MUST be named 'App' and implement both the functional requirements and visual design exactly.
        Generate the complete, working React JSX code that brings the design specification to life.
        """
        
        return prompt
    }
    
    /// Clean React JSX content from API response
    private func extractReactFromResponse(_ content: String) -> String {
        var cleanContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove markdown code blocks
        cleanContent = cleanContent.replacingOccurrences(
            of: #"```(?:jsx|javascript|js|react)?\s*\n?"#,
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
        
        // Look for React component (function App() or const App = ())
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
        
        return cleanContent.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

/// Errors specific to coder agent
enum CoderAgentError: Error, LocalizedError {
    case noChoices
    case noValidCode
    
    var errorDescription: String? {
        switch self {
        case .noChoices:
            return "No response from coder agent"
        case .noValidCode:
            return "Coder agent failed to generate valid code"
        }
    }
}