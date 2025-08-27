import SwiftUI

// MARK: - Status View

/// Clean, modular component for displaying generation status
struct StatusView: View {
    let status: GenerationStatus
    let error: String?
    let currentPhaseDescription: String
    
    var body: some View {
        if status == .generating {
            // Full-screen theme-adaptive matrix effect for generating state
            ZStack {
                // Theme-adaptive matrix background with dynamic overlay
                MatrixRainCode()
                
                // Floating container with theme-aware glassmorphism
                GeneratingStateContainer(status: status, error: error, currentPhaseDescription: currentPhaseDescription)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(.all)
        } else {
            // Regular container layout for other states
            VStack(spacing: StatusViewHelpers.standardSpacing) {
                // Status icon
                StatusIcon(status: status)
                
                // Status content (text and description)
                StatusContent(status: status, currentPhaseDescription: currentPhaseDescription)
                
                // Error display
                if let error = error {
                    StatusErrorView(error: error)
                }
            }
            .statusContainerStyle()
        }
    }
}

#Preview("Idle") {
    StatusView(status: .idle, error: nil, currentPhaseDescription: "Ready to generate")
}

#Preview("Generating") {
    StatusView(status: .generating, error: nil, currentPhaseDescription: "💻 Generating application code...")
}

#Preview("Success") {
    StatusView(status: .success, error: nil, currentPhaseDescription: "✅ Application ready!")
}

#Preview("Error") {
    StatusView(status: .error, error: "Failed to connect to API", currentPhaseDescription: "nil")
}

