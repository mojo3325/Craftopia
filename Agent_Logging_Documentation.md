# Agent Logging System for Validation

## Overview

This implementation adds comprehensive logging capabilities to the Craftopia multi-agent generation system. The logging system captures detailed information about agent execution for validation and debugging purposes.

## Features

### 1. AgentLoggingService
- **Location**: `/Craftopia/Services/AgentLoggingService.swift`
- **Purpose**: Manages creation and writing of markdown log files
- **Key Methods**:
  - `startGenerationSession()` - Initializes a new log file
  - `logAgentStart()` - Records when an agent begins execution
  - `logAgentCompletion()` - Records successful agent completion
  - `logAgentFailure()` - Records agent failures
  - `logSessionCompletion()` - Records final generation results
  - `logFallbackExecution()` - Records when swarm mode falls back to single agent

### 2. Integration with GenerationService
- **Location**: `/Craftopia/Services/GenerationService.swift`
- **Changes**: Added logging calls throughout the generation pipeline
- **Features**:
  - Automatic session tracking with unique session IDs
  - Detailed timing measurements for each agent
  - Context logging (what information each agent receives)
  - Error tracking and fallback logging

### 3. LogsView UI Component
- **Location**: `/Craftopia/Views/LogsView.swift`
- **Purpose**: Provides user interface for viewing and managing logs
- **Features**:
  - Display logs directory path
  - List recent log files with creation date and size
  - View log content in-app
  - Open logs directory in Finder (macOS only)

## Log File Structure

Each generation session creates a markdown file with the following structure:

```markdown
# Agent Generation Log

**Session ID:** `20240827_143022`
**Timestamp:** `2024-08-27T14:30:22Z`
**Mode:** `Swarm`
**Status:** `In Progress`

## User Prompt
```
Create a simple calculator app with dark theme
```

## Agent Execution Timeline

### 🤖 Planner/Spec Agent Started
**Time:** `14:30:22.123`
**Model:** `gpt-oss-120b`
**Description:** Creates feature list, macro flows, acceptance criteria and test checklist

### ✅ Planner/Spec Agent Completed
**Time:** `14:30:28.456`
**Execution Time:** `6.33s`
**Status:** `Completed`
**Output:**
```
[Planning output truncated for display...]
```

### 🤖 Themer/UX Tokens Agent Started
**Time:** `14:30:28.500`
...

---

## 🎉 Generation Session SUCCESS
**Completion Time:** `14:31:45.789`
**Total Execution Time:** `83.67s`
**Mode:** `Swarm`
**Agent Executions:** `4`
**Final Phase:** `Completed`
**Generated HTML Length:** `15423 characters`

## Execution Summary
| Agent | Status | Time | Output Size |
|-------|--------|------|-------------|
| Planner/Spec | ✅ Completed | 6.33s | 2156 chars |
| Themer/UX Tokens | ✅ Completed | 12.45s | 3421 chars |
| Coder | ✅ Completed | 45.22s | 15423 chars |
| Reviewer/Polisher | ✅ Completed | 19.67s | 15998 chars |
```

## Log Storage

- **Directory**: `~/Documents/AgentLogs/`
- **File Format**: `generation_log_YYYYMMDD_HHMMSS.md`
- **Encoding**: UTF-8
- **Automatic Creation**: Logs directory is created automatically on first use

## Usage

### Integration into Existing UI

To add logs access to your settings or debug menu:

```swift
import SwiftUI

struct SettingsView: View {
    @StateObject private var generationService: GenerationService
    @State private var showingLogs = false
    
    var body: some View {
        List {
            // ... other settings ...
            
            Section("Debug") {
                Button("View Agent Logs") {
                    showingLogs = true
                }
            }
        }
        .sheet(isPresented: $showingLogs) {
            LogsView(generationService: generationService)
        }
    }
}
```

### Accessing Logs Programmatically

```swift
// Get logs directory path
let logsPath = generationService.logsDirectoryPath

// Get list of log files
let logFiles = generationService.getLogFiles()

// Read a specific log file
if let firstLog = logFiles.first {
    let content = try String(contentsOf: firstLog, encoding: .utf8)
    print(content)
}
```

## Benefits for Validation

1. **Agent Performance Tracking**: Monitor execution times and identify bottlenecks
2. **Context Flow Validation**: Verify that information flows correctly between agents
3. **Error Analysis**: Detailed error logging helps identify failure patterns
4. **Fallback Monitoring**: Track when and why swarm mode falls back to single agent
5. **Output Quality Assessment**: Compare outputs between different agents and sessions
6. **Reproducibility**: Session IDs and timestamps allow reproduction of specific scenarios

## Example Validation Scenarios

### Performance Analysis
- Compare execution times between single and swarm modes
- Identify which agents take the longest to execute
- Monitor if certain prompts consistently cause timeouts

### Quality Validation
- Review agent outputs to ensure they meet expectations
- Compare final results between swarm and single agent modes
- Identify patterns in successful vs failed generations

### Error Pattern Detection
- Track common failure points in the pipeline
- Monitor fallback frequency and causes
- Identify prompts that consistently cause issues

## Future Enhancements

1. **Log Analytics Dashboard**: Create aggregated views of performance metrics
2. **Export Functionality**: Add options to export logs in different formats
3. **Search and Filtering**: Add search capabilities within log content
4. **Automated Analysis**: Implement automated detection of performance issues
5. **Cloud Backup**: Option to backup logs to cloud storage for team analysis