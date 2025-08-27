import SwiftUI

// MARK: - Theme Adaptive Matrix Background

/// A theme-aware matrix background that adapts overlay colors and opacity 
/// based on the current color scheme for optimal readability and visual appeal
struct MatrixRainCode: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            // Full-screen matrix video background
            MatrixVideoView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            
            // Theme-adaptive overlay for readability
            overlayColor
                .ignoresSafeArea(.all)
        }
    }
    
    // MARK: - Private Computed Properties
    
    /// Dynamic overlay color that adapts to the current theme
    private var overlayColor: Color {
        switch colorScheme {
        case .dark:
            // Dark theme: Subtle dark overlay to maintain the cyberpunk aesthetic
            // while ensuring content readability
            return Color.black.opacity(0.4)
        case .light:
            // Light theme: More prominent overlay with slight blue tint 
            // to maintain matrix aesthetic while ensuring good contrast
            return Color.black.opacity(0.4)
        @unknown default:
            // Fallback for future color scheme additions
            return Color.black.opacity(0.5)
        }
    }
}

// MARK: - Preview

#Preview("Dark Theme") {
    MatrixRainCode()
        .preferredColorScheme(.dark)
}

#Preview("Light Theme") {
    MatrixRainCode()
        .preferredColorScheme(.light)
}
