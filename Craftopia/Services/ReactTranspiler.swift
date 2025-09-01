import Foundation

/// Service for transpiling React code to HTML that can be displayed in WebView
class ReactTranspiler {
    
    /// Creates a complete HTML document from React code with all necessary dependencies
    func createHTMLFromReactCode(_ reactCode: String, customCSS: String = "") -> String {
        let processedCode = processReactCode(reactCode)
        
        return """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <title>React App</title>
            
            <!-- React 18 CDN -->
            <script crossorigin src="https://unpkg.com/react@18/umd/react.development.js"></script>
            <script crossorigin src="https://unpkg.com/react-dom@18/umd/react-dom.development.js"></script>
            
            <!-- Babel Standalone for JSX transpilation -->
            <script src="https://unpkg.com/@babel/standalone/babel.min.js"></script>
            
            <style>
                /* Base styles for React apps */
                :root {
                    color-scheme: light dark;
                }
                
                * {
                    box-sizing: border-box;
                    margin: 0;
                    padding: 0;
                }
                
                body {
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
                    line-height: 1.6;
                    color: #333;
                    background-color: #f5f5f5;
                    margin: 0;
                    padding: 0;
                    -webkit-font-smoothing: antialiased;
                    -moz-osx-font-smoothing: grayscale;
                }
                
                #root {
                    min-height: 100vh;
                    display: flex;
                    flex-direction: column;
                }
                
                /* React app container styles */
                .App {
                    max-width: 800px;
                    width: 100%;
                    margin: 0 auto;
                    padding: 20px;
                    background: white;
                    border-radius: 12px;
                    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
                    min-height: calc(100vh - 40px);
                }
                
                /* Form elements */
                input, textarea, select {
                    padding: 12px 16px;
                    border: 2px solid #e1e5e9;
                    border-radius: 8px;
                    font-size: 16px;
                    font-family: inherit;
                    transition: border-color 0.2s ease;
                    width: 100%;
                    margin-bottom: 12px;
                }
                
                input:focus, textarea:focus, select:focus {
                    outline: none;
                    border-color: #007AFF;
                    box-shadow: 0 0 0 3px rgba(0, 122, 255, 0.1);
                }
                
                /* Buttons */
                button {
                    padding: 12px 24px;
                    background: linear-gradient(135deg, #007AFF, #5856D6);
                    color: white;
                    border: none;
                    border-radius: 8px;
                    font-size: 16px;
                    font-weight: 600;
                    cursor: pointer;
                    transition: all 0.2s ease;
                    min-height: 44px;
                    display: inline-flex;
                    align-items: center;
                    justify-content: center;
                }
                
                button:hover {
                    transform: translateY(-1px);
                    box-shadow: 0 4px 12px rgba(0, 122, 255, 0.3);
                }
                
                button:active {
                    transform: translateY(0);
                }
                
                button:disabled {
                    opacity: 0.6;
                    cursor: not-allowed;
                    transform: none;
                }
                
                /* Secondary button */
                .btn-secondary {
                    background: #f8f9fa;
                    color: #333;
                    border: 2px solid #e1e5e9;
                }
                
                .btn-secondary:hover {
                    background: #e9ecef;
                    border-color: #adb5bd;
                }
                
                /* Lists */
                ul, ol {
                    list-style: none;
                    padding: 0;
                }
                
                li {
                    padding: 12px 16px;
                    margin: 8px 0;
                    background: #f8f9fa;
                    border-radius: 8px;
                    border-left: 4px solid #007AFF;
                    display: flex;
                    align-items: center;
                    justify-content: space-between;
                }
                
                /* Cards */
                .card {
                    background: white;
                    border-radius: 12px;
                    padding: 20px;
                    margin: 12px 0;
                    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
                    border: 1px solid #e1e5e9;
                }
                
                /* Responsive */
                @media (max-width: 768px) {
                    .App {
                        margin: 10px;
                        padding: 16px;
                        border-radius: 8px;
                        min-height: calc(100vh - 20px);
                    }
                    
                    button {
                        width: 100%;
                        margin: 4px 0;
                    }
                }
                
                /* Dark mode support */
                @media (prefers-color-scheme: dark) {
                    body {
                        background-color: #1c1c1e;
                        color: #ffffff;
                    }
                    
                    .App {
                        background: #2c2c2e;
                        box-shadow: 0 2px 10px rgba(0,0,0,0.3);
                    }
                    
                    input, textarea, select {
                        background: #3a3a3c;
                        border-color: #48484a;
                        color: #ffffff;
                    }
                    
                    .btn-secondary {
                        background: #3a3a3c;
                        color: #ffffff;
                        border-color: #48484a;
                    }
                    
                    .btn-secondary:hover {
                        background: #48484a;
                    }
                    
                    li {
                        background: #3a3a3c;
                        color: #ffffff;
                    }
                    
                    .card {
                        background: #2c2c2e;
                        border-color: #48484a;
                    }
                }
                
                /* Custom CSS from props */
                \(customCSS)
            </style>
        </head>
        <body>
            <div id="root"></div>
            
            <script type="text/babel">
                \(processedCode)
                
                // Render the app
                const root = ReactDOM.createRoot(document.getElementById('root'));
                root.render(<App />);
            </script>
        </body>
        </html>
        """
    }
    
    /// Processes React code to make it compatible with browser environment
    private func processReactCode(_ code: String) -> String {
        var processedCode = code
        
        // Remove import statements (React is loaded via CDN)
        processedCode = processedCode.replacingOccurrences(
            of: #"import\s+.*?from\s+['"].*?['"];?\s*\n?"#,
            with: "",
            options: .regularExpression
        )
        
        // Remove export default
        processedCode = processedCode.replacingOccurrences(
            of: "export default ",
            with: ""
        )
        
        // Remove export const/function
        processedCode = processedCode.replacingOccurrences(
            of: #"export\s+(const|function|class)"#,
            with: "$1",
            options: .regularExpression
        )
        
        // Handle React.useState if React is not destructured
        processedCode = processedCode.replacingOccurrences(
            of: "React.useState",
            with: "useState"
        )
        
        processedCode = processedCode.replacingOccurrences(
            of: "React.useEffect",
            with: "useEffect"
        )
        
        processedCode = processedCode.replacingOccurrences(
            of: "React.useCallback",
            with: "useCallback"
        )
        
        processedCode = processedCode.replacingOccurrences(
            of: "React.useMemo",
            with: "useMemo"
        )
        
        // Add React hooks destructuring if not present
        if !processedCode.contains("const { useState") && processedCode.contains("useState") {
            processedCode = "const { useState, useEffect, useCallback, useMemo } = React;\n\n" + processedCode
        }
        
        return processedCode
    }
}

// MARK: - React Templates

extension ReactTranspiler {
    
    /// Generates a basic React component template
    static func basicTemplate(componentName: String = "App") -> String {
        return """
        function \(componentName)() {
            const [count, setCount] = useState(0);
            
            return (
                <div className="App">
                    <h1>Hello React!</h1>
                    <p>Count: {count}</p>
                    <button onClick={() => setCount(count + 1)}>
                        Increment
                    </button>
                </div>
            );
        }
        """
    }
    
    /// Generates a form template
    static func formTemplate() -> String {
        return """
        function App() {
            const [formData, setFormData] = useState({
                name: '',
                email: ''
            });
            
            const handleSubmit = (e) => {
                e.preventDefault();
                alert(`Hello ${formData.name}!`);
            };
            
            const handleChange = (e) => {
                setFormData({
                    ...formData,
                    [e.target.name]: e.target.value
                });
            };
            
            return (
                <div className="App">
                    <h1>Contact Form</h1>
                    <form onSubmit={handleSubmit}>
                        <input
                            type="text"
                            name="name"
                            placeholder="Your name"
                            value={formData.name}
                            onChange={handleChange}
                            required
                        />
                        <input
                            type="email"
                            name="email"
                            placeholder="Your email"
                            value={formData.email}
                            onChange={handleChange}
                            required
                        />
                        <button type="submit">Submit</button>
                    </form>
                </div>
            );
        }
        """
    }
}