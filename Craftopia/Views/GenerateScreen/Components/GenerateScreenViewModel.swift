import SwiftUI
import Combine

/// Simplified ViewModel for GenerateScreen using unified service
@MainActor
class GenerateScreenViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var prompt = ""
    @Published private(set) var state = GenerationState()
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Dependencies
    let store: GenerationStore
    let generationService: GenerationService
    
    // MARK: - Initialization
    init() {
        // Use secure API configuration with proper error handling
        guard let apiKey = SecureAPIConfig.cerebrasAPIKey, SecureAPIConfig.isAPIKeyConfigured else {            
            // Create a dummy service that will show configuration error to user
            let store = GenerationStore()
            self.store = store
            // Use empty key - service will handle validation and show proper error
            self.generationService = GenerationService(apiKey: "", store: store)
            
            // Set initial error state to inform user about configuration
            DispatchQueue.main.async {
                store.setError(error: SecureAPIConfig.configurationErrorMessage)
            }
            
            // Still set up reactive binding
            setupStateBinding()
            return
        }
        
        let store = GenerationStore()
        
        self.store = store
        self.generationService = GenerationService(apiKey: apiKey, store: store)
        
        setupStateBinding()
    }
    
    /// Set up reactive state binding between store and view model
    private func setupStateBinding() {
        // Forward store state changes to a published state property so views update reactively
        self.store.$state
            .removeDuplicates { lhs, rhs in
                lhs.status == rhs.status &&
                lhs.mode == rhs.mode &&
                lhs.html == rhs.html &&
                lhs.error == rhs.error &&
                lhs.swarmPhase == rhs.swarmPhase
            }
            // Throttle to reduce main-thread re-render pressure during generation
            .throttle(for: .milliseconds(33), scheduler: DispatchQueue.main, latest: true)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newState in
                self?.state = newState
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    func handleGenerate() {
        let trimmedPrompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedPrompt.isEmpty else { return }
        
        Task {
            await generationService.generateHtml(prompt: trimmedPrompt)
        }
    }
    
    func handleReset() {
        generationService.reset()
        prompt = ""
    }
    
    func toggleGenerationMode() {
        generationService.toggleGenerationMode()
    }
    
    // MARK: - Computed Properties (Direct access to unified state)
    
    var currentState: GenerationState {
        state
    }
    
    var isGenerating: Bool {
        state.isGenerating
    }
    
    var hasError: Bool {
        state.hasError
    }
    
    var hasSuccess: Bool {
        state.isSuccess
    }
    
    var generatedContent: String? {
        state.html
    }
    
    var errorMessage: String? {
        state.error
    }
    
    var executionProgress: Double {
        state.executionProgress
    }
    
    var currentPhaseDescription: String {
        state.currentPhaseDescription
    }
    
    var isSwarmMode: Bool {
        generationService.isSwarmMode
    }
    
    var executionSummary: String {
        store.executionSummary
    }
    
    // MARK: - API Configuration
    
    /// Check if API key is properly configured
    var isAPIConfigured: Bool {
        SecureAPIConfig.isAPIKeyConfigured
    }
    
    /// Get configuration error message
    var configurationErrorMessage: String {
        SecureAPIConfig.configurationErrorMessage
    }
    
    /// Set API key at runtime (useful for settings screen)
    func setAPIKey(_ key: String) -> Bool {
        let success = SecureAPIConfig.setCerebrasAPIKey(key)
        return success
    }
}
