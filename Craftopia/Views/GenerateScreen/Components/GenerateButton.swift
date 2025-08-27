import SwiftUI

/// Generate button with active and inactive states
struct GenerateButton: View {
    @Environment(\.colorScheme) var colorScheme
    
    let isActive: Bool
    let isGenerating: Bool
    let onGenerate: () -> Void
    
    var body: some View {
        if isActive {
            activeButton
        } else {
            inactiveButton
        }
    }
    
    private var activeButton: some View {
        Button(action: onGenerate) {
            HStack(spacing: 8) {
                if isGenerating {
                    ProgressView()
                        .progressViewStyle(
                            CircularProgressViewStyle(tint: .white)
                        )
                        .scaleEffect(0.9)
                }
                Text("Create Application")
                    .font(.system(size: 17, weight: .semibold))
            }
            .frame(maxWidth: .infinity, minHeight: 52)
            .foregroundColor(.white)
            .background(SoftUI.Gradients.blueButton)
            .clipShape(
                RoundedRectangle(cornerRadius: 17, style: .circular)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 17, style: .circular)
                    .stroke(
                        colorScheme == .light 
                            ? SoftUI.Colors.bluePrimary.opacity(0.8)
                            : Color(hex: "#385FCA"),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: Color(hex: "#B3B3B3").opacity(colorScheme == .light ? 1 : 0),
                radius: 1,
                x: 0,
                y: 1
            )
            .shadow(
                color: Color(hex: "#1E293B").opacity(colorScheme == .light ? 0.15 : 0),
                radius: 5,
                x: 0,
                y: 4
            )
        }
    }
    
    private var inactiveButton: some View {
        Button(action: {}) {
            HStack(spacing: 8) {
                Text("Create Application")
                    .font(.system(size: 17, weight: .semibold))
            }
            .frame(maxWidth: .infinity, minHeight: 52)
            .foregroundColor(SoftUI.Colors.textMuted)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(SoftUI.Colors.surfaceSecondary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(
                        SoftUI.Colors.border,
                        style: StrokeStyle(lineWidth: 2.5, dash: [5])
                    )
            )
            .clipShape(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
            )
        }
        .disabled(true)
    }
}

#Preview {
    VStack(spacing: 20) {
        GenerateButton(
            isActive: true,
            isGenerating: false,
            onGenerate: {}
        )
        
        GenerateButton(
            isActive: true,
            isGenerating: true,
            onGenerate: {}
        )
        
        GenerateButton(
            isActive: false,
            isGenerating: false,
            onGenerate: {}
        )
    }
    .padding()
}