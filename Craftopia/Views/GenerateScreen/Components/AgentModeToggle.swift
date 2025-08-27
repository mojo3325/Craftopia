import SwiftUI

/// View component that provides a toggle for switching between single agent and swarm modes
struct AgentModeToggle: View {
    @Binding var useAgentSwarm: Bool
    
    var body: some View {
        HStack {
            Text("Agent Mode")
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
            
            HStack(spacing: 8) {
                Text("Single")
                    .font(.caption)
                    .foregroundColor(useAgentSwarm ? .secondary : .primary)
                
                Toggle("", isOn: $useAgentSwarm)
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                    .scaleEffect(0.8)
                
                Text("Swarm")
                    .font(.caption)
                    .foregroundColor(useAgentSwarm ? .primary : .secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal, 16)
    }
}

#Preview {
    VStack(spacing: 20) {
        AgentModeToggle(useAgentSwarm: .constant(true))
        AgentModeToggle(useAgentSwarm: .constant(false))
    }
    .padding()
}