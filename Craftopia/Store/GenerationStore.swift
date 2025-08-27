import Foundation
import Combine

/// Unified store for managing all generation state (both regular and swarm)
@MainActor
class GenerationStore: ObservableObject, GenerationActions {
    @Published var state = GenerationState()
    
    // Coalesce multiple field updates into a single @Published emission
    private func updateState(_ transform: (inout GenerationState) -> Void) {
        var newState = state
        transform(&newState)
        state = newState
    }
    
    // MARK: - Basic State Management
    
    /// Set generating state for any mode
    func setGenerating(prompt: String, mode: GenerationMode = .single) {
        updateState { s in
            s.status = .generating
            s.mode = mode
            s.prompt = prompt
            s.html = nil
            s.error = nil
            s.startTime = Date()
            s.endTime = nil
            if mode == .swarm {
                s.swarmPhase = .plannerPhase
                s.currentAgent = .planner
                s.agentExecutions = []
            }
        }
    }
    
    /// Set success state
    func setSuccess(html: String) {
        updateState { s in
            s.status = .success
            s.html = html
            s.error = nil
            s.endTime = Date()
            if s.mode == .swarm {
                s.swarmPhase = .completed
                s.currentAgent = nil
            }
        }
    }
    
    /// Set error state
    func setError(error: String) {
        updateState { s in
            s.status = .error
            s.error = error
            s.endTime = Date()
            if s.mode == .swarm {
                s.swarmPhase = .failed
                s.currentAgent = nil
            }
        }
    }
    
    /// Reset state
    func reset() {
        state = GenerationState()
    }
    
    // MARK: - Swarm-Specific State Management
    
    /// Set current swarm phase
    func setSwarmPhase(_ phase: SwarmExecutionStatus, currentAgent: AgentType? = nil) {
        updateState { s in
            s.swarmPhase = phase
            s.currentAgent = currentAgent
            switch phase {
            case .idle: s.status = .idle
            case .plannerPhase, .themerPhase, .coderPhase, .reviewerPhase: s.status = .generating
            case .completed: s.status = .success
            case .failed: s.status = .error
            }
        }
    }
    
    /// Add agent execution result
    func addAgentExecution(_ execution: AgentExecution) {
        updateState { s in
            s.agentExecutions.append(execution)
        }
    }
    

    /// Set swarm success with final result
    func setSwarmSuccess(finalResult: String, thinkingResult: AgentExecution?) {
        updateState { s in
            if let thinkingResult = thinkingResult {
                s.agentExecutions.append(thinkingResult)
            }
            s.status = .success
            s.html = finalResult
            s.error = nil
            s.endTime = Date()
            s.swarmPhase = .completed
            s.currentAgent = nil
        }
    }
    
    // MARK: - Computed Properties
    
    /// Check if generation is in progress
    var isGenerating: Bool {
        state.isGenerating
    }
    
    /// Check if there is an error
    var hasError: Bool {
        state.hasError
    }
    
    /// Check if there is a successful result
    var hasSuccess: Bool {
        state.isSuccess
    }
    
    /// Get current generated content
    var generatedContent: String? {
        state.html
    }
    
    /// Get current error message
    var errorMessage: String? {
        state.error
    }
    
    /// Get execution progress
    var executionProgress: Double {
        state.executionProgress
    }
    
    /// Get current phase description
    var currentPhaseDescription: String {
        state.currentPhaseDescription
    }
    
    /// Check if swarm mode is active
    var isSwarmMode: Bool {
        state.mode == .swarm
    }
    
    /// Get detailed execution summary for swarm mode
    var executionSummary: String {
        guard state.mode == .swarm else { return "" }
        
        var summary: [String] = []
        
        if let prompt = state.prompt {
            summary.append("Request: \(prompt)")
        }
        
        if let swarmPhase = state.swarmPhase {
            summary.append("Status: \(swarmPhase.displayName)")
        }
        
        if !state.agentExecutions.isEmpty {
            summary.append("\nExecution Details:")
            
            for execution in state.agentExecutions {
                let status = execution.status == .completed ? "✅" : "❌"
                let time = String(format: "%.1fs", execution.executionTime)
                summary.append("\(status) \(execution.agentType.displayName) (\(time))")
                
                if let error = execution.error {
                    summary.append("   Error: \(error)")
                }
            }
        }
        
        if state.totalExecutionTime > 0 {
            summary.append("\nTotal Time: \(String(format: "%.1f", state.totalExecutionTime))s")
        }
        
        return summary.joined(separator: "\n")
    }
}
 