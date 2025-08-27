import SwiftUI

/// Individual prompt example component
struct PromptExample: View {
    let title: String
    let description: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(SoftUI.Colors.blueAccent)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(SoftUI.Colors.textMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Color.clear)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .circular)
                    .stroke(SoftUI.Colors.border, lineWidth: 1.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    PromptExample(
        title: "Calculator",
        description: "Create calculator with a nice design",
        onTap: {}
    )
    .padding()
}