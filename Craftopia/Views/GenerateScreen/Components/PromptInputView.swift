import SwiftUI

/// Main prompt input view with clean, modular architecture
struct PromptInputView: View {
    @State private var showingSettings = false
    @Binding var prompt: String
    let onGenerate: () -> Void
    let isGenerating: Bool
    let generationService: GenerationService
    
    private var isButtonActive: Bool {
        !prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isGenerating
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                SoftUI.Colors.backgroundMain
                    .ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        headerSection
                        promptInputCard
                    }
                    .padding(.horizontal)
                }
                .scrollIndicators(.hidden)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Craftopia")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(SoftUI.Colors.textHeading)
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        settingsButton
                    }
                }
                .sheet(isPresented: $showingSettings) {
                    SettingsView(generationService: generationService)
                }
            }
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        Text("Create interactive applications from text descriptions")
            .font(.body)
            .foregroundColor(SoftUI.Colors.textMain)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
            .padding(.top, 50)
    }
    
    private var promptInputCard: some View {
        PromptInputCard {
            PromptTextInput(
                prompt: $prompt,
                isGenerating: isGenerating
            )
            
            GenerateButton(
                isActive: isButtonActive,
                isGenerating: isGenerating,
                onGenerate: onGenerate
            )
            
            PromptExamplesSection(prompt: $prompt)
        }
    }
    
    private var settingsButton: some View {
        Button(action: { showingSettings = true }) {
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
    }
}

#Preview {
    // Create a mock GenerationService for preview
    let mockStore = GenerationStore()
    let mockService = GenerationService(apiKey: "mock", store: mockStore)
    
    ZStack {
        SoftUI.Colors.backgroundMain
            .ignoresSafeArea()
        PromptInputView(
            prompt: .constant(""),
            onGenerate: {},
            isGenerating: false,
            generationService: mockService
        )
    }
    
}
