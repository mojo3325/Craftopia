import SwiftUI

// MARK: - Soft UI (Flat 2.0) Design Tokens

struct SoftUI {
    struct Colors {
        static var backgroundMain: Color { Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(hex: "07090D") : UIColor(hex: "F5F6F8")
        }) }
        static var backgroundSecondary: Color { Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(hex: "2C2C2E") : UIColor(hex: "E8ECF0")
        }) }
              static var containerBackground: LinearGradient {
            let topColor = Color(UIColor { trait in
                if trait.userInterfaceStyle == .dark {
                    return UIColor(hex: "#15171F")
                } else {
                    return UIColor.white
                }
            })
            let bottomColor = Color(UIColor { trait in
                if trait.userInterfaceStyle == .dark {
                    return UIColor(hex: "#0C0E12")
                } else {
                    return UIColor.white
                }
            })
            return LinearGradient(
                gradient: Gradient(colors: [topColor, bottomColor]),
                startPoint: .top,
                endPoint: .bottom
            )
        }


        static var border: Color { Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(hex: "3A3A3C") : UIColor(hex: "E3E6EB")
        }) }
        static var shadowRGBA: Color { Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor.black.withAlphaComponent(0.4) : UIColor(hex: "BABABA")
        }) }
        static var bluePrimary: Color { Color(hex: "186DEE") }
        static var blueAccent: Color { Color(hex: "1B77FD") }
        static var textHeading: Color { Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(hex: "FFFFFF") : UIColor(hex: "131B22")
        }) }
        static var textMain: Color { Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(hex: "EBEBF5") : UIColor(hex: "4B5669")
        }) }
        static var textSecondary: Color { Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(hex: "ABABAB") : UIColor(hex: "6B7684")
        }) }
        static var textMuted: Color { Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(hex: "8E8E93") : UIColor(hex: "99A1B3")
        }) }
        static var switchOn: Color { Color(hex: "3D78F2") }
        
        // Additional colors for better dark mode support
        static var surfaceSecondary: Color { Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor.clear : UIColor(hex: "F2F2F7")
        }) }
        static var surfaceTertiary: Color { Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(hex: "48484A") : UIColor(hex: "FAFBFC")
        }) }
        static var separatorOpaque: Color { Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(hex: "38383A") : UIColor(hex: "C6C6C8")
        }) }
        static var placeholderText: Color { Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(hex: "8E8E93") : UIColor(hex: "3C3C43").withAlphaComponent(0.3)
        }) }
    }

    struct Gradients {
        static var blueButton: LinearGradient {
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "6DA4FB"), Color(hex: "206CE5")]),
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    struct Metrics {
        static let containerRadius: CGFloat = 16
        static let buttonRadius: CGFloat = 12
        static let smallRadius: CGFloat = 10
    }
}

// MARK: - Soft UI View Modifiers

extension View {
    /// Soft UI container: white surface, thin border, soft shadow
    func softContainerStyle(cornerRadius: CGFloat = SoftUI.Metrics.containerRadius) -> some View {
        self
            .padding()
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(SoftUI.Colors.containerBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(SoftUI.Colors.border, lineWidth: 1)
            )
    }

    /// Soft UI text field: matte white surface, subtle border, very soft shadow
    func softTextFieldStyle(cornerRadius: CGFloat = SoftUI.Metrics.buttonRadius) -> some View {
        self
            .padding(16)
            .background(SoftUI.Colors.containerBackground)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(SoftUI.Colors.border, lineWidth: 1)
            )
            .shadow(color: SoftUI.Colors.shadowRGBA.opacity(0.6), radius: 6, x: 0, y: 2)
    }

    /// Soft UI primary button: blue gradient, white text, soft shadow
    func softPrimaryButtonStyle(
        isEnabled: Bool = true,
        cornerRadius: CGFloat = SoftUI.Metrics.buttonRadius
    ) -> some View {
        let gradient = isEnabled ? SoftUI.Gradients.blueButton : LinearGradient(gradient: Gradient(colors: [SoftUI.Colors.border, SoftUI.Colors.border]), startPoint: .top, endPoint: .bottom)
        return self
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .foregroundColor(.white)
            .background(gradient)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: SoftUI.Colors.shadowRGBA.opacity(0.5), radius: 6, x: 0, y: 6)
            .shadow(color: SoftUI.Colors.shadowRGBA.opacity(0.3), radius: 12, x: 0, y: 12)
    }

    /// Soft UI secondary button: neutral surface, thin border, soft shadow
    func softSecondaryButtonStyle(cornerRadius: CGFloat = SoftUI.Metrics.smallRadius) -> some View {
        self

    }

    /// Soft UI prompt example card: matte surface, border, slight shadow
    func softPromptExampleStyle(cornerRadius: CGFloat = SoftUI.Metrics.buttonRadius) -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(SoftUI.Colors.containerBackground)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(SoftUI.Colors.border, lineWidth: 1)
            )
            .shadow(color: SoftUI.Colors.shadowRGBA, radius: 8, x: 0, y: 3)
    }
}
