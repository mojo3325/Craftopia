import Foundation
import Combine
import SwiftUI

/// Unified service for four-stage HTML generation pipeline
@MainActor
class GenerationService: ObservableObject {
    private let plannerApiClient: PlannerAgentAPIClient
    private let themerApiClient: ThemerAgentAPIClient
    private let coderApiClient: CoderAgentAPIClient
    private let reviewerApiClient: ThinkingAgentAPIClient
    private let store: GenerationStore
    private let loggingService: AgentLoggingService
    
    @AppStorage("useAgentSwarm") var useAgentSwarm: Bool = true
    
    /// Current logging session ID
    private var currentSessionId: String?
    
    init(apiKey: String, store: GenerationStore) {
        self.plannerApiClient = PlannerAgentAPIClient(apiKey: apiKey)
        self.themerApiClient = ThemerAgentAPIClient(apiKey: apiKey)
        self.coderApiClient = CoderAgentAPIClient(apiKey: apiKey)
        self.reviewerApiClient = ThinkingAgentAPIClient(apiKey: apiKey)
        self.store = store
        self.loggingService = AgentLoggingService()
        self.currentSessionId = nil
    }
    
    /// Generate HTML from prompt using either regular coder-only mode or four-stage swarm mode
    func generateHtml(prompt: String) async {
        let mode: GenerationMode = useAgentSwarm ? .swarm : .single
        
        // Start logging session
        currentSessionId = loggingService.startGenerationSession(prompt: prompt, mode: mode)
        
        store.setGenerating(prompt: prompt, mode: mode)
        
        if mode == .swarm {
            await executeFourStageGeneration(prompt: prompt)
        } else {
            await executeSingleGeneration(prompt: prompt)
        }
        
        // Complete logging session
        if let sessionId = currentSessionId {
            loggingService.logSessionCompletion(sessionId: sessionId, state: store.state)
        }
    }
    
    /// Execute single agent generation using CoderAgentAPIClient
    private func executeSingleGeneration(prompt: String) async {
        do {
            let context = AgentContext(originalPrompt: prompt, agentType: .coder)
            
            // Log agent start
            if let sessionId = currentSessionId {
                loggingService.logAgentStart(sessionId: sessionId, agent: .coder, context: context)
            }
            
            let startTime = Date()
            let result = try await coderApiClient.generateCode(context: context)
            let executionTime = Date().timeIntervalSince(startTime)
            
            if result.status == .completed, let html = result.content {
                // Log successful completion
                if let sessionId = currentSessionId {
                    let execution = AgentExecution(
                        agentType: .coder,
                        status: .completed,
                        content: html,
                        executionTime: executionTime
                    )
                    loggingService.logAgentCompletion(sessionId: sessionId, execution: execution)
                }
                store.setSuccess(html: html)
            } else {
                let errorMessage = result.error ?? "Failed to generate content"
                // Log failure
                if let sessionId = currentSessionId {
                    loggingService.logAgentFailure(sessionId: sessionId, agent: .coder, error: errorMessage, executionTime: executionTime)
                }
                store.setError(error: errorMessage)
            }
        } catch {
            // Log exception
            if let sessionId = currentSessionId {
                loggingService.logAgentFailure(sessionId: sessionId, agent: .coder, error: error.localizedDescription, executionTime: 0)
            }
            store.setError(error: error.localizedDescription)
        }
    }
    
    /// Execute four-stage generation: Planner -> Themer -> Coder -> Reviewer
    private func executeFourStageGeneration(prompt: String) async {
        do {
            // Stage 1: Planner Agent
            store.setSwarmPhase(.plannerPhase, currentAgent: .planner)
            let plannerStartTime = Date()
            
            let plannerContext = AgentContext(originalPrompt: prompt, agentType: .planner)
            
            // Log planner start
            if let sessionId = currentSessionId {
                loggingService.logAgentStart(sessionId: sessionId, agent: .planner, context: plannerContext)
            }
            
            let plannerResult = try await plannerApiClient.generatePlan(context: plannerContext)
            let plannerExecutionTime = Date().timeIntervalSince(plannerStartTime)
            
            guard plannerResult.status == .completed, let plannerOutput = plannerResult.content else {
                throw GenerationError.plannerFailed(plannerResult.error ?? "Planner agent failed")
            }
            
            let plannerExecution = AgentExecution(
                agentType: .planner,
                status: .completed,
                content: plannerOutput,
                executionTime: plannerExecutionTime
            )
            store.addAgentExecution(plannerExecution)
            
            // Log planner completion
            if let sessionId = currentSessionId {
                loggingService.logAgentCompletion(sessionId: sessionId, execution: plannerExecution)
            }
            
            // Stage 2: Themer Agent
            store.setSwarmPhase(.themerPhase, currentAgent: .themer)
            let themerStartTime = Date()
            
            let themerContext = AgentContext(
                originalPrompt: prompt,
                plannerOutput: plannerOutput,
                agentType: .themer
            )
            
            // Log themer start
            if let sessionId = currentSessionId {
                loggingService.logAgentStart(sessionId: sessionId, agent: .themer, context: themerContext)
            }
            
            let themerResult = try await themerApiClient.generateTheme(context: themerContext)
            let themerExecutionTime = Date().timeIntervalSince(themerStartTime)
            
            guard themerResult.status == .completed, let themerOutput = themerResult.content else {
                throw GenerationError.themerFailed(themerResult.error ?? "Themer agent failed")
            }
            
            let themerExecution = AgentExecution(
                agentType: .themer,
                status: .completed,
                content: themerOutput,
                executionTime: themerExecutionTime
            )
            store.addAgentExecution(themerExecution)
            
            // Log themer completion
            if let sessionId = currentSessionId {
                loggingService.logAgentCompletion(sessionId: sessionId, execution: themerExecution)
            }
            
            // Stage 3: Coder Agent
            store.setSwarmPhase(.coderPhase, currentAgent: .coder)
            let coderStartTime = Date()
            
            let coderContext = AgentContext(
                originalPrompt: prompt,
                plannerOutput: plannerOutput,
                themerOutput: themerOutput,
                agentType: .coder
            )
            
            // Log coder start
            if let sessionId = currentSessionId {
                loggingService.logAgentStart(sessionId: sessionId, agent: .coder, context: coderContext)
            }
            
            let coderResult = try await coderApiClient.generateCode(context: coderContext)
            let coderExecutionTime = Date().timeIntervalSince(coderStartTime)
            
            guard coderResult.status == .completed, let coderOutput = coderResult.content else {
                throw GenerationError.coderFailed(coderResult.error ?? "Coder agent failed")
            }
            
            let coderExecution = AgentExecution(
                agentType: .coder,
                status: .completed,
                content: coderOutput,
                executionTime: coderExecutionTime
            )
            store.addAgentExecution(coderExecution)
            
            // Log coder completion
            if let sessionId = currentSessionId {
                loggingService.logAgentCompletion(sessionId: sessionId, execution: coderExecution)
            }
            
            // Stage 4: Reviewer Agent
            store.setSwarmPhase(.reviewerPhase, currentAgent: .reviewer)
            let reviewerStartTime = Date()
            
            let reviewerContext = AgentContext(
                originalPrompt: prompt,
                plannerOutput: plannerOutput,
                themerOutput: themerOutput,
                coderOutput: coderOutput,
                agentType: .reviewer
            )
            
            // Log reviewer start
            if let sessionId = currentSessionId {
                loggingService.logAgentStart(sessionId: sessionId, agent: .reviewer, context: reviewerContext)
            }
            
            let reviewerResult = try await reviewerApiClient.reviewAndImprove(context: reviewerContext)
            let reviewerExecutionTime = Date().timeIntervalSince(reviewerStartTime)
            
            let finalResult: String
            if reviewerResult.status == .completed, let reviewerOutput = reviewerResult.content, reviewerOutput.trimmingCharacters(in: .whitespacesAndNewlines).count >= 200 {
                finalResult = reviewerOutput
                let reviewerExecution = AgentExecution(
                    agentType: .reviewer,
                    status: .completed,
                    content: reviewerOutput,
                    executionTime: reviewerExecutionTime
                )
                store.addAgentExecution(reviewerExecution)
                
                // Log reviewer completion
                if let sessionId = currentSessionId {
                    loggingService.logAgentCompletion(sessionId: sessionId, execution: reviewerExecution)
                }
            } else {
                // If reviewer fails, use coder result as fallback
                let errorMessage = reviewerResult.error ?? "Reviewer output too short or invalid"
                print("Reviewer failed: \(errorMessage), using coder output")
                finalResult = coderOutput
                let failedReviewerExecution = AgentExecution(
                    agentType: .reviewer,
                    status: .failed,
                    error: errorMessage,
                    executionTime: reviewerExecutionTime
                )
                store.addAgentExecution(failedReviewerExecution)
                
                // Log reviewer failure
                if let sessionId = currentSessionId {
                    loggingService.logAgentFailure(sessionId: sessionId, agent: .reviewer, error: errorMessage, executionTime: reviewerExecutionTime)
                }
            }
            
            // Complete four-stage execution
            store.setSwarmSuccess(finalResult: finalResult, thinkingResult: nil)
            
        } catch {
            // If four-stage fails, try fallback to single agent
            await executeFallbackGeneration(prompt: prompt, error: error)
        }
    }
    
    /// Fallback to single agent if four-stage swarm fails
    private func executeFallbackGeneration(prompt: String, error: Error) async {
        print("Four-stage generation failed: \(error.localizedDescription), falling back to single agent")
        
        // Log fallback execution
        if let sessionId = currentSessionId {
            loggingService.logFallbackExecution(sessionId: sessionId, originalError: error.localizedDescription, fallbackAgent: .coder)
        }
        
        // Record the failed swarm attempt
        let failedExecution = AgentExecution(
            agentType: store.state.currentAgent ?? .coder,
            status: .failed,
            error: error.localizedDescription
        )
        store.addAgentExecution(failedExecution)
        
        // Switch to single mode and try again
        store.setGenerating(prompt: prompt, mode: .single)
        await executeSingleGeneration(prompt: prompt)
    }
    
    /// Reset state
    func reset() {
        currentSessionId = nil
        store.reset()
    }
    
    /// Check if generation is in progress
    var isGenerating: Bool {
        store.isGenerating
    }
    
    /// Get current state
    var currentState: GenerationState {
        store.state
    }
    
    /// Get generated content
    var generatedContent: String? {
        store.generatedContent
    }
    
    /// Check if generation completed successfully
    var hasSuccessfulResult: Bool {
        store.hasSuccess
    }
    
    /// Check if generation failed
    var hasError: Bool {
        store.hasError
    }
    
    /// Get current error message
    var errorMessage: String? {
        store.errorMessage
    }
    
    /// Get execution progress
    var executionProgress: Double {
        store.executionProgress
    }
    
    /// Get current phase description
    var currentPhaseDescription: String {
        store.currentPhaseDescription
    }
    
    /// Toggle between swarm and single mode
    func toggleGenerationMode() {
        useAgentSwarm.toggle()
    }
    
    /// Check if swarm mode is enabled
    var isSwarmMode: Bool {
        useAgentSwarm
    }
    
    /// Get logs directory path for user access
    var logsDirectoryPath: String {
        loggingService.logsDirectoryPath
    }
    
    /// Get list of all log files
    func getLogFiles() -> [URL] {
        loggingService.getLogFiles()
    }
}

/// Generation service errors for four-stage pipeline
enum GenerationError: Error, LocalizedError {
    case plannerFailed(String)
    case themerFailed(String)
    case coderFailed(String)
    case reviewerFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .plannerFailed(let message):
            return "Planning failed: \(message)"
        case .themerFailed(let message):
            return "Theme design failed: \(message)"
        case .coderFailed(let message):
            return "Code generation failed: \(message)"
        case .reviewerFailed(let message):
            return "Code review failed: \(message)"
        }
    }
} 
