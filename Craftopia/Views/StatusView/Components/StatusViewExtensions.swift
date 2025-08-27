import SwiftUI

// MARK: - StatusView Extensions

extension View {
    /// Apply standard styling for status containers
    func statusContainerStyle() -> some View {
        self
            .softContainerStyle()
            .padding(.horizontal)
    }
}

// MARK: - Status Colors Extension

extension Color {
    /// Success color for status displays
    static var statusSuccess: Color {
        Color(hex: "28a745")
    }
    
    /// Error color for status displays
    static var statusError: Color {
        Color(hex: "dc3545")
    }
}

// MARK: - Status View Helpers

struct StatusViewHelpers {
    
    /// Standard spacing for status components
    static let standardSpacing: CGFloat = 16
    
    /// Icon size for status displays
    static let iconSize: CGFloat = 48
    
    /// Standard corner radius for error containers
    static let errorContainerRadius: CGFloat = 12
}