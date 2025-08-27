import SwiftUI

/// Main content card container with glassmorphism styling
struct PromptInputCard: View {
    @Environment(\.colorScheme) var colorScheme
    let content: () -> AnyView
    
    init<Content: View>(@ViewBuilder content: @escaping () -> Content) {
        self.content = { AnyView(content()) }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            content()
        }
        .padding(24)
        .background(SoftUI.Colors.containerBackground)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: colorScheme == .dark ? [
                            Color.white.opacity(0.4),
                            Color.white.opacity(0.1)
                        ] : [],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1.5
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
        .padding(.horizontal, 5)
        .padding(.vertical, 8)
    }
}

#Preview {
    PromptInputCard {
        VStack {
            Text("Sample Content")
            Text("More content here")
        }
    }
    .padding()
}