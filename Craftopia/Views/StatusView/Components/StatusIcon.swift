import SwiftUI

/// Component for displaying status-specific icons
struct StatusIcon: View {
    let status: GenerationStatus
    
    var body: some View {
        Group {
            switch status {
            case .idle:
                Image(systemName: "sparkles")
                    .font(.system(size: StatusViewHelpers.iconSize))
                    .foregroundColor(SoftUI.Colors.bluePrimary)
                    
            case .generating:
                Image(systemName: "rectangle.stack.fill")
                    .font(.system(size: StatusViewHelpers.iconSize))
                    .foregroundColor(.white)
                    
            case .success:
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: StatusViewHelpers.iconSize))
                    .foregroundColor(.statusSuccess)
                    
            case .error:
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: StatusViewHelpers.iconSize))
                    .foregroundColor(.statusError)
            }
        }
    }
}

#Preview("Idle") {
    StatusIcon(status: .idle)
}

#Preview("Generating") {
    StatusIcon(status: .generating)
}

#Preview("Success") {
    StatusIcon(status: .success)
}

#Preview("Error") {
    StatusIcon(status: .error)
}

#Preview("Matrix Rain Test") {
    MatrixRainView(speedMultiplier: 1.0)
        .frame(height: 200)
        .background(.black)
}
