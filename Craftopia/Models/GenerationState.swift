import Foundation

/// Unified generation status that supports both regular and swarm modes
enum GenerationStatus {
    case idle
    case generating
    case success
    case error
}

/// Generation mode type
enum GenerationMode {
    case single
    case swarm
}

/// Agent execution details for swarm mode
struct AgentExecution {
    let agentType: AgentType
    let status: AgentExecutionStatus
    let content: String?
    let error: String?
    let executionTime: Double
    let timestamp: Date
    
    init(agentType: AgentType, status: AgentExecutionStatus, content: String? = nil, error: String? = nil, executionTime: Double = 0) {
        self.agentType = agentType
        self.status = status
        self.content = content
        self.error = error
        self.executionTime = executionTime
        self.timestamp = Date()
    }
}

/// Unified generation state model that supports both regular and swarm generation
struct GenerationState {
    let id: UUID
    var status: GenerationStatus
    var mode: GenerationMode
    var prompt: String?
    var html: String?
    var error: String?
    var startTime: Date?
    var endTime: Date?
    
    // Swarm-specific properties
    var currentAgent: AgentType?
    var agentExecutions: [AgentExecution]
    var swarmPhase: SwarmExecutionStatus?
    
    init(mode: GenerationMode = .single) {
        self.id = UUID()
        self.status = .idle
        self.mode = mode
        self.prompt = nil
        self.html = nil
        self.error = nil
        self.startTime = nil
        self.endTime = nil
        self.currentAgent = nil
        self.agentExecutions = []
        self.swarmPhase = nil
    }
    
    // MARK: - Computed Properties
    
    /// Check if generation is currently running
    var isGenerating: Bool {
        return status == .generating
    }
    
    /// Check if generation completed successfully
    var isSuccess: Bool {
        return status == .success && html != nil
    }
    
    /// Check if generation failed
    var hasError: Bool {
        return status == .error
    }
    
    /// Get total execution time
    var totalExecutionTime: Double {
        guard let startTime = startTime else { return 0 }
        let endTime = self.endTime ?? Date()
        return endTime.timeIntervalSince(startTime)
    }
    
    /// Get current phase description for UI display
    var currentPhaseDescription: String {
        switch mode {
        case .single:
            switch status {
            case .idle:
                return "Ready to generate"
            case .generating:
                return "Generating application..."
            case .success:
                return "Application ready!"
            case .error:
                return "Generation failed"
            }
        case .swarm:
            switch swarmPhase {
            case .idle:
                return "Ready to generate"
            case .plannerPhase:
                return "Planning specifications and features..."
            case .themerPhase:
                return "Designing theme and visual tokens..."
            case .coderPhase:
                return "Generating application code..."
            case .reviewerPhase:
                return "Reviewing and polishing the final application..."
            case .completed:
                return "Application ready!"
            case .failed:
                return "Generation failed"
            case .none:
                return "Ready to generate"
            }
        }
    }
    
    /// Get execution progress (0.0 to 1.0)
    var executionProgress: Double {
        switch mode {
        case .single:
            switch status {
            case .idle: return 0.0
            case .generating: return 0.5
            case .success: return 1.0
            case .error: return 0.0
            }
        case .swarm:
            switch swarmPhase {
            case .idle: return 0.0
            case .plannerPhase: return 0.25
            case .themerPhase: return 0.5
            case .coderPhase: return 0.75
            case .reviewerPhase: return 0.9
            case .completed: return 1.0
            case .failed: return 0.0
            case .none: return 0.0
            }
        }
    }
}

/// Actions for managing unified generation state
@MainActor
protocol GenerationActions {
    func setGenerating(prompt: String, mode: GenerationMode)
    func setSuccess(html: String)
    func setError(error: String)
    func setSwarmPhase(_ phase: SwarmExecutionStatus, currentAgent: AgentType?)
    func addAgentExecution(_ execution: AgentExecution)
    func reset()
} 
