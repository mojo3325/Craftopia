import SwiftUI
import WebKit

/// WebView for displaying generated HTML or React applications
struct HtmlWebView: UIViewRepresentable {
    
    let reactCode: String
    private var html: String
    @AppStorage("isDarkMode") private var darkModeEnabled: Bool = false
    @Binding var shouldReload: Bool
        
    // New initializer for React code
    init(reactCode: String, shouldReload: Binding<Bool>) {
        let transpiler = ReactTranspiler()
        self.reactCode = reactCode
        self.html = transpiler.createHTMLFromReactCode(reactCode)
        self._shouldReload = shouldReload
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        
        // Security settings
        webView.configuration.allowsInlineMediaPlayback = true
        
        // Disable zooming for more native feel
        webView.scrollView.maximumZoomScale = 1.0
        webView.scrollView.minimumZoomScale = 1.0
        webView.scrollView.bounces = false
        
        // Mobile display settings
        webView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = false
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // Check if reload is requested
        if shouldReload {
            DispatchQueue.main.async {
                shouldReload = false
            }
        }
        
        // Get current interface style from environment
        let backgroundColor = darkModeEnabled ? "#2C2C2E" : "#FFFFFF"
        let textColor = darkModeEnabled ? "#EBEBF5" : "#000000"
        
        // Inject CSS to disable zooming and selection, plus dark mode support
        let injectedCSS = """
        <style>
        :root {
            color-scheme: \(darkModeEnabled ? "dark" : "light");
        }
        
        body {
            -webkit-user-select: none;
            -webkit-touch-callout: none;
            user-select: none;
            margin: 0;
            padding: 0;
            overflow-x: hidden;
            background-color: \(backgroundColor) !important;
            color: \(textColor) !important;
        }
        
        /* Disable double tap for zooming */
        * {
            touch-action: manipulation;
        }
        
        /* Hide scrollbars */
        ::-webkit-scrollbar {
            display: none;
        }
        
        /* Dark mode adjustments */
        @media (prefers-color-scheme: dark) {
            body {
                background-color: #2C2C2E !important;
                color: #EBEBF5 !important;
            }
            
            /* Adjust other elements for dark mode */
            input, textarea, select {
                background-color: #3A3A3C !important;
                color: #EBEBF5 !important;
                border-color: #48484A !important;
            }
            
            button {
                background-color: #186DEE !important;
                color: white !important;
            }
        }
        </style>
        """
        
        // Add viewport meta tag
        let viewportMeta = """
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, shrink-to-fit=no">
        """
        
        // Combine HTML with injected styles
        let fullHtml = """
        <!DOCTYPE html>
        <html>
        <head>
            \(viewportMeta)
            \(injectedCSS)
        </head>
        <body>
            \(html)
        </body>
        </html>
        """
        
        webView.loadHTMLString(fullHtml, baseURL: nil)
    }
}

/// React app viewer screen
struct HtmlViewerScreen: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var shouldReload = false
    let reactCode: String
    let onBack: () -> Void
    let onNew: () -> Void
    
    var body: some View {
        NavigationStack {
        ZStack {
            SoftUI.Colors.containerBackground
                .ignoresSafeArea()
    
        VStack(spacing: 0) {
            HtmlWebView(reactCode: reactCode, shouldReload: $shouldReload)
                .background(SoftUI.Colors.containerBackground)
        }
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: onBack) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                            
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                }
                .font(.system(size: 16, weight: .medium))
                    
                .foregroundColor(SoftUI.Colors.textSecondary)
                .background(
                    SoftUI.Colors.containerBackground
                )
                .clipShape(RoundedRectangle(cornerRadius: 15, style: .circular))
                .overlay(
                    Group {
                        if colorScheme == .dark {
                            RoundedRectangle(cornerRadius: 12, style: .circular)
                                .stroke(
                                    LinearGradient(

                                        colors: [
                                            Color(hex: "#3B3C3F"),
                                            Color(hex: "#15171C")
                                        ],

                                        startPoint: .top,
                                        endPoint: .bottom
                                    ),
                                    lineWidth: 1.5
                                )
                        }
                    }
                )
                .shadow(color: SoftUI.Colors.shadowRGBA.opacity(
                    colorScheme == .light ? 1 : 0
                ), radius: 1, x: 0, y: 1)
                .shadow(color: SoftUI.Colors.shadowRGBA.opacity(
                    colorScheme == .light ? 0.15 : 0
                ), radius: 7, x: 0, y: 4)            
            }
            ToolbarItem(placement: .principal) {
                Text("Mini App")
                    .font(.headline)
                    .foregroundColor(SoftUI.Colors.textHeading)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    shouldReload = true
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(SoftUI.Colors.textSecondary)
                        .frame(width: 44, height: 34, alignment: .center)
                }
                .background(
                    SoftUI.Colors.containerBackground
                )
                .clipShape(RoundedRectangle(cornerRadius: 15, style: .circular))
                .overlay(
                    Group {
                        if colorScheme == .dark {
                            RoundedRectangle(cornerRadius: 12, style: .circular)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: "#3B3C3F"),
                                            Color(hex: "#15171C")
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ),
                                    lineWidth: 1.5
                                )
                        }
                    }
                )
                .shadow(color: SoftUI.Colors.shadowRGBA.opacity(
                    colorScheme == .light ? 1 : 0
                ), radius: 1, x: 0, y: 1)
                .shadow(color: SoftUI.Colors.shadowRGBA.opacity(
                    colorScheme == .light ? 0.15 : 0
                ), radius: 7, x: 0, y: 4)
            }
        })
        }
        }
    }
}

#Preview {
    VStack {
        HtmlViewerScreen(
            reactCode: """
                function App() {
                    const [count, setCount] = useState(0);
                    
                    return (
                        <div className="App">
                            <h1>Hello React!</h1>
                            <p>Count: {count}</p>
                            <button onClick={() => setCount(count + 1)}>
                                Increment: {count}
                            </button>
                        </div>
                    );
                }
                """, onBack: {}, onNew: {},
                    
                
            )
            .frame(height: 300)
        }
        .preferredColorScheme(.light)
}
