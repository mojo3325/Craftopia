import SwiftUI

#if canImport(AppKit)
import AppKit
#endif

/// View for displaying and managing agent generation logs
struct LogsView: View {
    @StateObject private var generationService: GenerationService
    @State private var logFiles: [URL] = []
    @State private var selectedLogContent: String = ""
    @State private var showingLogViewer = false
    @State private var isLoading = false
    
    init(generationService: GenerationService) {
        self._generationService = StateObject(wrappedValue: generationService)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Agent Validation Logs")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Logs are saved to validate the multi-agent generation system")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Logs Directory Info
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "folder")
                            .foregroundColor(.blue)
                        Text("Logs Directory")
                            .fontWeight(.medium)
                        Spacer()
                    }
                    
                    Text(generationService.logsDirectoryPath)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(6)
                    
                    #if canImport(AppKit)
                    Button(action: openLogsDirectory) {
                        HStack {
                            Image(systemName: "arrow.up.right.square")
                            Text("Open in Finder")
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                    #endif
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                
                // Log Files List
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "doc.text")
                            .foregroundColor(.green)
                        Text("Recent Log Files")
                            .fontWeight(.medium)
                        Spacer()
                        Button("Refresh", action: loadLogFiles)
                            .font(.caption)
                    }
                    
                    if isLoading {
                        ProgressView("Loading logs...")
                            .frame(maxWidth: .infinity)
                            .padding(20)
                    } else if logFiles.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "doc.text.below.ecg")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                            Text("No logs available")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("Generate some content to create logs")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(20)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(logFiles, id: \.absoluteString) { logFile in
                                    LogFileRow(logFile: logFile) {
                                        loadLogContent(from: logFile)
                                    }
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                        .frame(maxHeight: 300)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                
                Spacer()
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Agent Logs")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadLogFiles()
            }
            .sheet(isPresented: $showingLogViewer) {
                LogContentViewer(content: selectedLogContent)
            }
        }
    }
    
    private func loadLogFiles() {
        isLoading = true
        Task {
            let files = await generationService.getLogFiles()
            DispatchQueue.main.async {
                self.logFiles = files
                self.isLoading = false
            }
        }
    }
    
    #if canImport(AppKit)
    private func openLogsDirectory() {
        let url = URL(fileURLWithPath: generationService.logsDirectoryPath)
        NSWorkspace.shared.open(url)
    }
    #endif
    
    private func loadLogContent(from url: URL) {
        do {
            selectedLogContent = try String(contentsOf: url, encoding: .utf8)
            showingLogViewer = true
        } catch {
            selectedLogContent = "Error loading log file: \(error.localizedDescription)"
            showingLogViewer = true
        }
    }
}

/// Row component for displaying individual log files
struct LogFileRow: View {
    let logFile: URL
    let onTap: () -> Void
    
    @State private var fileSize: String = ""
    @State private var creationDate: String = ""
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(logFile.deletingPathExtension().lastPathComponent)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    HStack {
                        Text(creationDate)
                        Spacer()
                        Text(fileSize)
                    }
                    .font(.caption2)
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .onAppear {
            loadFileInfo()
        }
    }
    
    private func loadFileInfo() {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: logFile.path)
            
            if let size = attributes[.size] as? NSNumber {
                let byteCount = size.intValue
                fileSize = ByteCountFormatter.string(fromByteCount: Int64(byteCount), countStyle: .file)
            }
            
            if let date = attributes[.creationDate] as? Date {
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                formatter.timeStyle = .short
                creationDate = formatter.string(from: date)
            }
        } catch {
            fileSize = "Unknown"
            creationDate = "Unknown"
        }
    }
}

/// Modal view for displaying log content
struct LogContentViewer: View {
    let content: String
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(content)
                    .font(.system(.caption, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .navigationTitle("Log Content")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

#if DEBUG
struct LogsView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a mock GenerationService for preview
        let mockStore = GenerationStore()
        let mockService = GenerationService(apiKey: "mock", store: mockStore)
        
        LogsView(generationService: mockService)
    }
}
#endif