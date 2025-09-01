import Foundation

/// Types of agents in the four-stage swarm
enum AgentType: String, CaseIterable, Codable {
    case planner = "gpt-oss-planner"
    case themer = "gpt-oss-themer"
    case coder = "qwen3-coder"
    case reviewer = "qwen3-reviewer"
    
    var displayName: String {
        switch self {
        case .planner:
            return "Planner/Spec"
        case .themer:
            return "Themer/UX Tokens"
        case .coder:
            return "Coder"
        case .reviewer:
            return "Reviewer/Polisher"
        }
    }
    
    var modelName: String {
        switch self {
        case .planner:
            return "gpt-oss-120b"
        case .themer:
            return "gpt-oss-120b"
        case .coder:
            return "qwen-3-coder-480b"
        case .reviewer:
            return "gpt-oss-120b"
        }
    }
    
    var description: String {
        switch self {
        case .planner:
            return "Creates feature list, macro flows, acceptance criteria and test checklist"
        case .themer:
            return "Generates W3C DTCG design tokens and stunning visual design"
        case .coder:
            return "Generates self-contained HTML based on plan and design tokens"
        case .reviewer:
            return "Fixes critical bugs and polishes the final application"
        }
    }
}

/// Status of agent execution
enum AgentExecutionStatus: String, CaseIterable, Codable {
    case idle = "idle"
    case preparing = "preparing"
    case executing = "executing"
    case completed = "completed"
    case failed = "failed"
    
    var displayName: String {
        switch self {
        case .idle:
            return "Ready"
        case .preparing:
            return "Preparing..."
        case .executing:
            return "Working..."
        case .completed:
            return "Completed"
        case .failed:
            return "Failed"
        }
    }
}

/// Status of the entire swarm execution
enum SwarmExecutionStatus: String, CaseIterable, Codable {
    case idle = "idle"
    case plannerPhase = "planner_phase"
    case themerPhase = "themer_phase"
    case coderPhase = "coder_phase"
    case reviewerPhase = "reviewer_phase"
    case completed = "completed"
    case failed = "failed"
    
    var displayName: String {
        switch self {
        case .idle:
            return "Ready to start"
        case .plannerPhase:
            return "Creating specification & plan..."
        case .themerPhase:
            return "Designing theme & tokens..."
        case .coderPhase:
            return "Generating application code..."
        case .reviewerPhase:
            return "Reviewing & polishing..."
        case .completed:
            return "Completed"
        case .failed:
            return "Failed"
        }
    }
    
    var progress: Double {
        switch self {
        case .idle:
            return 0.0
        case .plannerPhase:
            return 0.25
        case .themerPhase:
            return 0.5
        case .coderPhase:
            return 0.75
        case .reviewerPhase:
            return 0.9
        case .completed:
            return 1.0
        case .failed:
            return 0.0
        }
    }
}

/// Result of agent execution
struct AgentExecutionResult: Codable {
    let agentType: AgentType
    let status: AgentExecutionStatus
    let content: String?
    let error: String?
    let executionTimeSeconds: Double
    let timestamp: Date
    
    init(agentType: AgentType, status: AgentExecutionStatus, content: String? = nil, error: String? = nil, executionTimeSeconds: Double = 0) {
        self.agentType = agentType
        self.status = status
        self.content = content
        self.error = error
        self.executionTimeSeconds = executionTimeSeconds
        self.timestamp = Date()
    }
}

/// Context passed between agents in the four-stage pipeline
struct AgentContext: Codable {
    let originalPrompt: String
    let plannerOutput: String?
    let themerOutput: String?
    let coderOutput: String?
    let agentType: AgentType
    let additionalInstructions: String?
    
    init(originalPrompt: String, plannerOutput: String? = nil, themerOutput: String? = nil, coderOutput: String? = nil, agentType: AgentType, additionalInstructions: String? = nil) {
        self.originalPrompt = originalPrompt
        self.plannerOutput = plannerOutput
        self.themerOutput = themerOutput
        self.coderOutput = coderOutput
        self.agentType = agentType
        self.additionalInstructions = additionalInstructions
    }
    
    // Legacy support for previous result
    var previousResult: String? {
        switch agentType {
        case .planner:
            return nil
        case .themer:
            return plannerOutput
        case .coder:
            return [plannerOutput, themerOutput].compactMap { $0 }.joined(separator: "\n\n")
        case .reviewer:
            return coderOutput
        }
    }
}

/// Overall swarm execution state
struct SwarmExecutionState: Codable {
    let id: UUID
    let originalPrompt: String
    let status: SwarmExecutionStatus
    let currentAgent: AgentType?
    let results: [AgentExecutionResult]
    let finalResult: String?
    let error: String?
    let startTime: Date
    let endTime: Date?
    
    init(originalPrompt: String) {
        self.id = UUID()
        self.originalPrompt = originalPrompt
        self.status = .idle
        self.currentAgent = nil
        self.results = []
        self.finalResult = nil
        self.error = nil
        self.startTime = Date()
        self.endTime = nil
    }
    
    /// Get the last successful result
    var lastSuccessfulResult: String? {
        return results.last { $0.status == .completed }?.content
    }
    
    /// Check if swarm has completed successfully
    var isCompleted: Bool {
        return status == .completed && finalResult != nil
    }
    
    /// Check if swarm has failed
    var hasFailed: Bool {
        return status == .failed
    }
    
    /// Total execution time in seconds
    var totalExecutionTime: Double {
        if let endTime = endTime {
            return endTime.timeIntervalSince(startTime)
        }
        return Date().timeIntervalSince(startTime)
    }
}

/// Structured output from planner agent
struct PlannerOutput: Codable {
    let features: [String]
    let macroFlows: [String]
    let acceptanceCriteria: [String]
    let testChecklist: [String]
    let architecture: String
    let userExperience: String
    
    var formatted: String {
        return """
        FEATURES:
        \(features.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n"))
        
        MACRO FLOWS:
        \(macroFlows.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n"))
        
        ACCEPTANCE CRITERIA:
        \(acceptanceCriteria.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n"))
        
        TEST CHECKLIST:
        \(testChecklist.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n"))
        
        ARCHITECTURE:
        \(architecture)
        
        USER EXPERIENCE:
        \(userExperience)
        """
    }
}

/// Structured output from themer agent
struct ThemerOutput: Codable {
    let lightThemeTokens: [String: String]
    let darkThemeTokens: [String: String]
    let typography: [String: String]
    let spacing: [String: String]
    let brandingConcept: String
    let visualStyle: String
    
    var cssVariables: String {
        let lightVars = lightThemeTokens.map { "  \($0.key): \($0.value);" }.joined(separator: "\n")
        let darkVars = darkThemeTokens.map { "  \($0.key): \($0.value);" }.joined(separator: "\n")
        let typoVars = typography.map { "  \($0.key): \($0.value);" }.joined(separator: "\n")
        let spaceVars = spacing.map { "  \($0.key): \($0.value);" }.joined(separator: "\n")
        
        return """
        :root {
        \(lightVars)
        \(typoVars)
        \(spaceVars)
        }
        
        @media (prefers-color-scheme: dark) {
          :root {
        \(darkVars)
          }
        }
        """
    }
    
    var formatted: String {
        return """
        BRANDING CONCEPT:
        \(brandingConcept)
        
        VISUAL STYLE:
        \(visualStyle)
        
        CSS VARIABLES:
        \(cssVariables)
        """
    }
}