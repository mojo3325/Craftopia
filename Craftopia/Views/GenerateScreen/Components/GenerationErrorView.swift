import SwiftUI

/// View component that displays error states with simple restart functionality
struct GenerationErrorView: View {
    let error: String?
    let onBackToStart: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(Color(hex: "dc3545"))
            
            Text("Generation Failed")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(SoftUI.Colors.textHeading)
            
            if let error = error {
                Text(error)
                    .font(.body)
                    .foregroundColor(SoftUI.Colors.textMain)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button("Back to Start") {
                onBackToStart()
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 32)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [SoftUI.Colors.bluePrimary, SoftUI.Colors.bluePrimary.opacity(0.8)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(12)
            .shadow(color: SoftUI.Colors.shadowRGBA.opacity(0.3), radius: 4, x: 0, y: 2)
        }
        .softContainerStyle()
        .padding(.horizontal, 20)
    }
}

#Preview {
    GenerationErrorView(
        error: "Something went wrong during generation",
        onBackToStart: { }
    )
}