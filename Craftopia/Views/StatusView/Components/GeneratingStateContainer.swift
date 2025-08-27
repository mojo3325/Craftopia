import SwiftUI

// MARK: - Generating State Container

/// A floating glassmorphism container for the generating state with theme-adaptive styling
/// Provides a clean, readable overlay for status content on the matrix background
struct GeneratingStateContainer: View {
    let status: GenerationStatus
    let error: String?
    let currentPhaseDescription: String
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 16) {
                // Status icon with theme-adaptive colors
                StatusIconView()
                
                // Status content
                StatusContent(status: status, currentPhaseDescription: currentPhaseDescription)
                
                // Error display if present
                if let error = error {
                    StatusErrorView(error: error)
                }
            }
            .padding(30)
            .background(backgroundMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(borderColor, lineWidth: 1)
            )
            .shadow(
                color: shadowColor,
                radius: shadowRadius,
                x: 0,
                y: shadowOffset
            )
            .padding(.horizontal)
            
            Spacer()
        }
    }
    
    // MARK: - Theme-Adaptive Properties
    
    /// Dynamic background material that adapts to theme
    private var backgroundMaterial: some ShapeStyle {
        return .ultraThinMaterial
    }
    
    /// Theme-adaptive border color
    private var borderColor: Color {
        return Color.gray.opacity(0.6)
    }
    
    /// Theme-adaptive shadow properties
    private var shadowColor: Color {
      return Color.black.opacity(0.4)
    }
    
    private var shadowRadius: CGFloat {
        switch colorScheme {
        case .dark:
            return 15
        case .light:
            return 20
        @unknown default:
            return 15
        }
    }
    
    private var shadowOffset: CGFloat {
        return 8
    }
}

// MARK: - Status Icon Component

/// Theme-adaptive status icon for the generating state
private struct StatusIconView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Image(systemName: "rectangle.stack.fill")
            .font(.largeTitle)
            .foregroundColor(iconColor)
    }
    
    private var iconColor: Color {
        switch colorScheme {
        case .dark:
            // Dark theme: Bright white for high contrast
            return .white
        case .light:
            // Light theme: Use heading color for consistency
            return SoftUI.Colors.textHeading
        @unknown default:
            return .white
        }
    }
}

// MARK: - Preview

#Preview("Dark Theme") {
    ZStack {
        Color.black.ignoresSafeArea()
        GeneratingStateContainer(status: .generating, error: nil, currentPhaseDescription: "💻 Generating application code...")
    }
    
}
