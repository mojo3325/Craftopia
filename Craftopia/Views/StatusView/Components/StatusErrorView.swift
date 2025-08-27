import SwiftUI

/// Component for displaying error messages with proper styling
struct StatusErrorView: View {
    let error: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Error:")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.statusError)
            
            Text(error)
                .font(.caption)
                .foregroundColor(.statusError)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .background(Color.statusError.opacity(0.06))
        .cornerRadius(StatusViewHelpers.errorContainerRadius)
    }
}

#Preview("Short Error") {
    StatusErrorView(error: "Failed to connect to API")
        .padding()
}

#Preview("Long Error") {
    StatusErrorView(error: "The server is currently experiencing issues. Please check your internet connection and try again in a few minutes.")
        .padding()
}