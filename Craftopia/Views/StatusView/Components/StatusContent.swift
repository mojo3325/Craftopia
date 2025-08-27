import SwiftUI

/// Component for displaying status text and descriptions
struct StatusContent: View {
    let status: GenerationStatus
    let currentPhaseDescription: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(currentPhaseDescription)
                .font(.body)
                .foregroundColor(Color(hex: "EBEBF5"))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
        }
    }
}

#Preview("Idle") {
    StatusContent(status: .idle, currentPhaseDescription: "")
        .padding()
}

#Preview("Generating") {
    StatusContent(
        status: .generating,
        currentPhaseDescription: "💻 Generating application code..."
    )
    .padding()
}

#Preview("Success") {
    StatusContent(
        status: .success,
        currentPhaseDescription: "✅ Application ready!"
    )
    .padding()
}

#Preview("Error") {
    StatusContent(status: .error, currentPhaseDescription: "nil")
        .padding()
}
