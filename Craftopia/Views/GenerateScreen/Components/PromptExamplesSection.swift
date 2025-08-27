import SwiftUI

/// Collapsible section containing prompt examples
struct PromptExamplesSection: View {
    @Binding var prompt: String
    @State private var isExamplesExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header button
            Button(action: toggleExpansion) {
                HStack {
                    Text("Examples")
                        .font(.caption)
                        .foregroundColor(SoftUI.Colors.textMuted)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(SoftUI.Colors.textMuted)
                        .rotationEffect(.degrees(isExamplesExpanded ? 180 : 0))
                        .animation(
                            .spring(response: 0.4, dampingFraction: 0.85),
                            value: isExamplesExpanded
                        )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(SoftUI.Colors.containerBackground.opacity(0.001))
                .accessibilityAddTraits(.isButton)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Examples content
            if isExamplesExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    PromptExample(
                        title: "Calculator",
                        description: "Create calculator with a nice design",
                        onTap: { prompt = "Create a beautiful calculator." }
                    )
                    
                    PromptExample(
                        title: "Tip Calculator",
                        description: "Create a tip calculator with a nice design",
                        onTap: { prompt = "Create a tips calculator for more than 2 people." }
                    )
                    
                    PromptExample(
                        title: "Weight Converter",
                        description: "Create a weight converter with a nice design",
                        onTap: { prompt = "Create a weight units converter with a nice design" }
                    )
                    
                    PromptExample(
                        title: "Todo list",
                        description: "Create a todo list with the ability to add and delete",
                        onTap: { prompt = "Create todo list with the ability to add and delete" }
                    )
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .transition(
                    .asymmetric(
                        insertion: .opacity.combined(
                            with: .scale(scale: 0.96, anchor: .top)
                        ),
                        removal: .opacity.combined(
                            with: .scale(scale: 0.96, anchor: .top)
                        )
                    )
                )
            }
        }
    }
    
    private func toggleExpansion() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            isExamplesExpanded.toggle()
        }
    }
}

#Preview {
    PromptExamplesSection(prompt: .constant(""))
        .padding()
}