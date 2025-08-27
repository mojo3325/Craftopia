import SwiftUI

/// Text input area for prompts
struct PromptTextInput: View {
    @Binding var prompt: String
    let isGenerating: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Describe what you want to create:")
                .font(.caption)
                .foregroundColor(SoftUI.Colors.textMuted)
            
            TextEditor(text: $prompt)
                .frame(minHeight: 120)
                .scrollContentBackground(.hidden)
                .padding(16)
                .background(Color.clear)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(
                        cornerRadius: 12,
                        style: .circular
                    )
                    .stroke(
                        SoftUI.Colors.border,
                        lineWidth: 1
                    )
                )
                .disabled(isGenerating)
        }
    }
}

#Preview {
    PromptTextInput(
        prompt: .constant("Sample prompt text"),
        isGenerating: false
    )
    .padding()
}