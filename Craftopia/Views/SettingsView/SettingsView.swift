import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var darkModeEnabled: Bool = false
    @AppStorage("useAgentSwarm") private var useAgentSwarm: Bool = true
    @State private var contentHeight: CGFloat = 0
    @State private var showingLogs = false
    
    let generationService: GenerationService
    
    init(generationService: GenerationService) {
        self.generationService = generationService
    }

    private struct ContentHeightKey: PreferenceKey {
        static var defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Sheet background
                SoftUI.Colors.containerBackground
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    HStack(spacing: 12) {
                        Text("Settings")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(SoftUI.Colors.textHeading)
                            .padding(.top, 50)

                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 16)


                    // Content
                    VStack(spacing: 16) {
                        // Combined Appearance + About Card
                        VStack(alignment: .leading, spacing: 12) {

                            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
                            let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

                            VStack(spacing: 0) {
                                // Agent Mode toggle
                                Toggle(isOn: $useAgentSwarm) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Agent Swarm Mode")
                                            .font(.subheadline)
                                            .foregroundColor(SoftUI.Colors.textMain)
                                        Text(useAgentSwarm ? "Multiple AI agents collaborate" : "Single AI agent")
                                            .font(.caption)
                                            .foregroundColor(SoftUI.Colors.textMuted)
                                    }
                                }
                                .tint(SoftUI.Colors.switchOn)
                                .padding(12)

                                Divider().overlay(SoftUI.Colors.border)

                                // Dark mode toggle
                                Toggle(isOn: $darkModeEnabled) {
                                    Text("Dark Mode")
                                        .font(.subheadline)
                                        .foregroundColor(SoftUI.Colors.textMain)
                                }
                                .tint(SoftUI.Colors.switchOn)
                                .padding(12)

                                Divider().overlay(SoftUI.Colors.border)

                                // Logs section - Debug functionality
                                Button(action: { showingLogs = true }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Agent Logs")
                                                .font(.subheadline)
                                                .foregroundColor(SoftUI.Colors.textMain)
                                            Text("View generation logs for validation")
                                                .font(.caption)
                                                .foregroundColor(SoftUI.Colors.textMuted)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(SoftUI.Colors.textMuted)
                                    }
                                }
                                .padding(12)

                                Divider().overlay(SoftUI.Colors.border)

                                HStack {
                                    Text("App")
                                        .font(.subheadline)
                                        .foregroundColor(SoftUI.Colors.textMain)
                                    Spacer()
                                    Text("Craftopia")
                                        .font(.footnote)
                                        .foregroundColor(SoftUI.Colors.textMuted)
                                }
                                .padding(12)

                                Divider().overlay(SoftUI.Colors.border)

                                HStack {
                                    Text("Version")
                                        .font(.subheadline)
                                        .foregroundColor(SoftUI.Colors.textMain)
                                    Spacer()
                                    Text("v\(version) (\(build))")
                                        .font(.footnote)
                                        .foregroundColor(SoftUI.Colors.textMuted)
                                }
                                .padding(12)
                            }

                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 70)
                    }
                    .padding(.top, 16)
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .preference(key: ContentHeightKey.self, value: proxy.size.height + 36)
                        }
                    )
                    .onPreferenceChange(ContentHeightKey.self) { newValue in
                        contentHeight = newValue
                    }

                }
            }
        }
        .presentationDetents([
            .height(min(max(contentHeight, 120), UIScreen.main.bounds.height * 0.9))
        ])
        .presentationDragIndicator(.visible)
        .sheet(isPresented: $showingLogs) {
            LogsView(generationService: generationService)
        }
    }
}

#Preview {
    @Previewable @State var showingSettings = true
    
    // Create a mock GenerationService for preview
    let mockStore = GenerationStore()
    let mockService = GenerationService(apiKey: "mock", store: mockStore)

    VStack {
        
    }
    
    .sheet(isPresented: $showingSettings) {
        SettingsView(generationService: mockService)
    }
}
