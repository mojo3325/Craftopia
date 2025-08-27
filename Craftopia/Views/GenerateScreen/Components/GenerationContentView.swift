import SwiftUI

/// Simplified view component that handles generation UI based on unified state
struct GenerationContentView: View {
    @ObservedObject var viewModel: GenerateScreenViewModel
    @Binding var prompt: String
    @State private var showingError = false
    @State private var currentError: String? = nil
    
    let onGenerate: () -> Void
    let onReset: () -> Void
    
    var body: some View {
        ZStack {
            if showingError {
                GenerationErrorView(
                    error: currentError,
                    onBackToStart: {
                        showingError = false
                        onReset()
                    }
                )
                .transition(.opacity)
            } else {
                mainContent
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showingError)
        .animation(
            .easeInOut(duration: 0.3),
            value: viewModel.currentState.status
        )
    }
    
    // MARK: - Main Content
    private var mainContent: some View {
        ZStack {
            switch viewModel.currentState.status {
            case .idle:
                PromptInputView(
                    prompt: $prompt,
                    onGenerate: onGenerate,
                    isGenerating: false,
                    generationService: viewModel.generationService
                )
                .transition(.opacity)
                
            case .generating:
                StatusView(
                    status: .generating,
                    error: nil,
                    currentPhaseDescription: viewModel.currentPhaseDescription
                )
                .transition(.opacity)
                
            case .success:
                if let html = viewModel.generatedContent {
                    HtmlViewerScreen(
                        html: html,
                        onBack: onReset,
                        onNew: onReset
                    )
                    .transition(.opacity)
                } else {
                    PromptInputView(
                        prompt: $prompt,
                        onGenerate: onGenerate,
                        isGenerating: false,
                        generationService: viewModel.generationService
                    )
                }
                
            case .error:
                EmptyView()
                    .onAppear {
                        handleError(viewModel.errorMessage)
                    }
            }
        }
    }
    
    private func handleError(_ error: String?) {
        currentError = error
        showingError = true
    }
}

#Preview("Idle") {
    let mockStore = GenerationStore()
    let mockService = GenerationService(apiKey: "mock", store: mockStore)
    let viewModel = GenerateScreenViewModel()
    
    GenerationContentView(
        viewModel: viewModel,
        prompt: .constant("Test prompt"),
        onGenerate: { },
        onReset: { }
    )
}

#Preview("Generating") {
    let mockStore = GenerationStore()
    let mockService = GenerationService(apiKey: "mock", store: mockStore)
    let viewModel = GenerateScreenViewModel()
    viewModel.store.setGenerating(prompt: "Create a modern dashboard", mode: .single)
    
    return GenerationContentView(
        viewModel: viewModel,
        prompt: .constant("Create a modern dashboard"),
        onGenerate: { },
        onReset: { }
    )
}

#Preview("Success") {
    let mockStore = GenerationStore()
    let mockService = GenerationService(apiKey: "mock", store: mockStore)
    let viewModel = GenerateScreenViewModel()
    viewModel.store.setGenerating(prompt: "Test prompt", mode: .single)
    viewModel.store.setSuccess(html: "<html><body><h1>Generated HTML</h1></body></html>")
    
    return GenerationContentView(
        viewModel: viewModel,
        prompt: .constant("Test prompt"),
        onGenerate: { },
        onReset: { }
    )
}
