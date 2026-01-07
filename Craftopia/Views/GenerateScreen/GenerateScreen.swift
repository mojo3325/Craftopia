import SwiftUI

/// Main screen (design mock).
/// Intentionally does NOT depend on API keys, networking, or generation state.
struct GenerateScreen: View {
    @State private var prompt: String

    init() {
        _prompt = State(initialValue: "Create a modern dashboard with cards and charts")
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                SoftUI.Colors.backgroundMain
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        Text("Create interactive applications from text descriptions")
                            .font(.body)
                            .foregroundColor(SoftUI.Colors.textMain)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .padding(.top, 50)

                        PromptInputCard {
                            PromptTextInput(prompt: $prompt, isGenerating: false)

                            GenerateButton(
                                isActive: true,
                                isGenerating: false,
                                onGenerate: {}
                            )

                            PromptExamplesSection(prompt: $prompt)
                        }
                    }
                    .padding(.horizontal)
                }
                .scrollIndicators(.hidden)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Craftopia")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(SoftUI.Colors.textHeading)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {}) {
                            ZStack {
                                Circle()
                                    .fill(SoftUI.Colors.containerBackground)
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Circle()
                                            .stroke(SoftUI.Colors.border, lineWidth: 1)
                                    )

                                Image(systemName: "gear")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(SoftUI.Colors.textMain)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

#Preview {
    GenerateScreen()
}
