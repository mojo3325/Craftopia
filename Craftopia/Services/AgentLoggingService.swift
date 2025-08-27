import Foundation
import SwiftUI

/// Service for logging agent execution details to markdown files for validation
@MainActor
class AgentLoggingService: ObservableObject {
    private let documentsPath: URL
    private let logsDirectory: URL
    
    init() {
        // Get documents directory
        self.documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.logsDirectory = documentsPath.appendingPathComponent("AgentLogs")
        
        // Create logs directory if it doesn't exist
        createLogsDirectoryIfNeeded()
    }
    
    private func createLogsDirectoryIfNeeded() {
        do {
            try FileManager.default.createDirectory(at: logsDirectory, withIntermediateDirectories: true)
        } catch {
            print("Failed to create logs directory: \(error)")
        }
    }
    
    /// Start logging a new generation session
    func startGenerationSession(prompt: String, mode: GenerationMode) -> String {
        let sessionId = generateSessionId()
        let fileName = "generation_log_\(sessionId).md"
        let filePath = logsDirectory.appendingPathComponent(fileName)
        
        let header = generateSessionHeader(sessionId: sessionId, prompt: prompt, mode: mode)
        
        do {
            try header.write(to: filePath, atomically: true, encoding: .utf8)
            print("Started logging session: \(fileName)")
            return sessionId
        } catch {
            print("Failed to create log file: \(error)")
            return sessionId
        }
    }
    
    /// Log agent execution start
    func logAgentStart(sessionId: String, agent: AgentType, context: AgentContext) {
        let content = generateAgentStartLog(agent: agent, context: context)
        appendToLog(sessionId: sessionId, content: content)
    }
    
    /// Log agent execution completion
    func logAgentCompletion(sessionId: String, execution: AgentExecution) {
        let content = generateAgentCompletionLog(execution: execution)
        appendToLog(sessionId: sessionId, content: content)
    }
    
    /// Log agent execution failure
    func logAgentFailure(sessionId: String, agent: AgentType, error: String, executionTime: Double) {
        let content = generateAgentFailureLog(agent: agent, error: error, executionTime: executionTime)
        appendToLog(sessionId: sessionId, content: content)
    }
    
    /// Log generation session completion
    func logSessionCompletion(sessionId: String, state: GenerationState) {
        let content = generateSessionCompletionLog(state: state)
        appendToLog(sessionId: sessionId, content: content)
    }
    
    /// Log fallback execution
    func logFallbackExecution(sessionId: String, originalError: String, fallbackAgent: AgentType) {
        let content = generateFallbackLog(originalError: originalError, fallbackAgent: fallbackAgent)
        appendToLog(sessionId: sessionId, content: content)
    }
    
    /// Get logs directory path for user access
    var logsDirectoryPath: String {
        return logsDirectory.path
    }
    
    /// Get list of all log files
    func getLogFiles() -> [URL] {
        do {
            let files = try FileManager.default.contentsOfDirectory(at: logsDirectory, includingPropertiesForKeys: [.creationDateKey], options: [.skipsHiddenFiles])
            return files.filter { $0.pathExtension == "md" }.sorted { url1, url2 in
                let date1 = (try? url1.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
                let date2 = (try? url2.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
                return date1 > date2
            }
        } catch {
            print("Failed to list log files: \(error)")
            return []
        }
    }
    
    // MARK: - Private Methods
    
    private func generateSessionId() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        return formatter.string(from: Date())
    }
    
    private func generateSessionHeader(sessionId: String, prompt: String, mode: GenerationMode) -> String {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        
        return """
        # Agent Generation Log
        
        **Session ID:** `\(sessionId)`  
        **Timestamp:** `\(timestamp)`  
        **Mode:** `\(mode.rawValue.capitalized)`  
        **Status:** `In Progress`
        
        ## User Prompt
        ```
        \(prompt)
        ```
        
        ## Agent Execution Timeline
        
        """
    }
    
    private func generateAgentStartLog(agent: AgentType, context: AgentContext) -> String {
        let timestamp = formatTimestamp(Date())
        
        var contextInfo = """
        ### 🤖 \(agent.displayName) Agent Started
        
        **Time:** `\(timestamp)`  
        **Model:** `\(agent.modelName)`  
        **Description:** \(agent.description)
        
        **Context:**
        - Original Prompt: `\(context.originalPrompt.prefix(100))\(context.originalPrompt.count > 100 ? "..." : "")`
        """
        
        if let plannerOutput = context.plannerOutput {
            contextInfo += "\n- Planner Output: `\(plannerOutput.prefix(100))\(plannerOutput.count > 100 ? "..." : "")`"
        }
        
        if let themerOutput = context.themerOutput {
            contextInfo += "\n- Themer Output: `\(themerOutput.prefix(100))\(themerOutput.count > 100 ? "..." : "")`"
        }
        
        if let coderOutput = context.coderOutput {
            contextInfo += "\n- Coder Output: `\(coderOutput.prefix(100))\(coderOutput.count > 100 ? "..." : "")`"
        }
        
        return contextInfo + "\n\n"
    }
    
    private func generateAgentCompletionLog(execution: AgentExecution) -> String {
        let timestamp = formatTimestamp(execution.timestamp)
        let statusEmoji = execution.status == .completed ? "✅" : "❌"
        
        var log = """
        ### \(statusEmoji) \(execution.agentType.displayName) Agent Completed
        
        **Time:** `\(timestamp)`  
        **Execution Time:** `\(String(format: "%.2f", execution.executionTime))s`  
        **Status:** `\(execution.status.displayName)`
        
        """
        
        if let content = execution.content, !content.isEmpty {
            let truncatedContent = content.count > 500 ? String(content.prefix(500)) + "..." : content
            log += """
            **Output:**
            ```
            \(truncatedContent)
            ```
            
            **Full Output Length:** `\(content.count) characters`
            
            """
        }
        
        if let error = execution.error {
            log += """
            **Error:**
            ```
            \(error)
            ```
            
            """
        }
        
        return log + "\n"
    }
    
    private func generateAgentFailureLog(agent: AgentType, error: String, executionTime: Double) -> String {
        let timestamp = formatTimestamp(Date())
        
        return """
        ### ❌ \(agent.displayName) Agent Failed
        
        **Time:** `\(timestamp)`  
        **Execution Time:** `\(String(format: "%.2f", executionTime))s`  
        **Model:** `\(agent.modelName)`
        
        **Error:**
        ```
        \(error)
        ```
        
        """
    }
    
    private func generateSessionCompletionLog(state: GenerationState) -> String {
        let timestamp = formatTimestamp(Date())
        let statusEmoji = state.isSuccess ? "🎉" : "💥"
        let statusText = state.isSuccess ? "SUCCESS" : "FAILED"
        
        var log = """
        ---
        
        ## \(statusEmoji) Generation Session \(statusText)
        
        **Completion Time:** `\(timestamp)`  
        **Total Execution Time:** `\(String(format: "%.2f", state.totalExecutionTime))s`  
        **Mode:** `\(state.mode.rawValue.capitalized)`
        
        """
        
        if state.mode == .swarm {
            log += """
            **Agent Executions:** `\(state.agentExecutions.count)`  
            **Final Phase:** `\(state.swarmPhase?.displayName ?? "Unknown")`
            
            """
        }
        
        if let html = state.html, state.isSuccess {
            log += """
            **Generated HTML Length:** `\(html.count) characters`
            
            """
        }
        
        if let error = state.error {
            log += """
            **Final Error:**
            ```
            \(error)
            ```
            
            """
        }
        
        // Add summary of all agent executions
        if !state.agentExecutions.isEmpty {
            log += """
            ## Execution Summary
            
            | Agent | Status | Time | Output Size |
            |-------|--------|------|-------------|
            """
            
            for execution in state.agentExecutions {
                let outputSize = execution.content?.count ?? 0
                let statusIcon = execution.status == .completed ? "✅" : "❌"
                log += "\n| \(execution.agentType.displayName) | \(statusIcon) \(execution.status.displayName) | \(String(format: "%.2f", execution.executionTime))s | \(outputSize) chars |"
            }
            
            log += "\n\n"
        }
        
        return log
    }
    
    private func generateFallbackLog(originalError: String, fallbackAgent: AgentType) -> String {
        let timestamp = formatTimestamp(Date())
        
        return """
        ### 🔄 Fallback to Single Agent Mode
        
        **Time:** `\(timestamp)`  
        **Fallback Agent:** `\(fallbackAgent.displayName)`  
        **Original Error:** 
        ```
        \(originalError)
        ```
        
        """
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter.string(from: date)
    }
    
    private func appendToLog(sessionId: String, content: String) {
        let fileName = "generation_log_\(sessionId).md"
        let filePath = logsDirectory.appendingPathComponent(fileName)
        
        do {
            let fileHandle = try FileHandle(forWritingTo: filePath)
            defer { fileHandle.closeFile() }
            
            fileHandle.seekToEndOfFile()
            if let data = content.data(using: .utf8) {
                fileHandle.write(data)
            }
        } catch {
            // If file doesn't exist or can't be opened for writing, try creating it
            do {
                if let data = content.data(using: .utf8) {
                    try data.write(to: filePath)
                }
            } catch {
                print("Failed to write to log file: \(error)")
            }
        }
    }
}

// MARK: - Extensions

extension GenerationMode {
    var rawValue: String {
        switch self {
        case .single:
            return "single"
        case .swarm:
            return "swarm"
        }
    }
}