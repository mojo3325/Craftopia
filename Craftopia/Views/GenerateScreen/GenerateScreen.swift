import SwiftUI

/// Main screen for generating HTML applications with Agent Swarm support
struct GenerateScreen: View {
    // MARK: - ViewModel
    @StateObject private var viewModel: GenerateScreenViewModel
    
    // MARK: - Initializers
    init(viewModel: GenerateScreenViewModel? = nil) {
        if let viewModel = viewModel {
            _viewModel = StateObject(wrappedValue: viewModel)
        } else {
            _viewModel = StateObject(wrappedValue: GenerateScreenViewModel())
        }
    }
    
    // MARK: - Body
    var body: some View {
            
        GenerationContentView(
            viewModel: viewModel,
            prompt: $viewModel.prompt,
            onGenerate: viewModel.handleGenerate,
            onReset: viewModel.handleReset
        )
        
    }
    

}

#Preview("Idle") {
    GenerateScreen()
}

#Preview("Generating") {
    let viewModel = GenerateScreenViewModel()
    viewModel.store.setGenerating(prompt: "Create a modern dashboard", mode: .single)
    return GenerateScreen(viewModel: viewModel)
}
