import SwiftUI
import AVKit
import AVFoundation
import UIKit

// MARK: - Matrix Video View (High Performance Full-Screen)
struct MatrixVideoView: View {
    @State private var player: AVPlayer?
    @State private var playerLooper: AVPlayerLooper?
    @Environment(\.colorScheme) private var colorScheme
    
    // Video configuration
    private let videoName = "matrix_rain" // Video file name without extension
    private let videoExtension = "mp4"
    
    // Zoom configuration for larger symbols
    let zoomScale: CGFloat
    
    // Initializer with customizable zoom
    init(zoomScale: CGFloat = 1.5) {
        self.zoomScale = zoomScale
    }
    
    var body: some View {
        ZStack {
            // Full black background
            Color.black
                .ignoresSafeArea(.all)
            
            if let player = player {
                FullScreenVideoPlayer(player: player, zoomScale: zoomScale)
                    .ignoresSafeArea(.all)
            } else {
                // Fallback view while loading
                MatrixRainView()
                    .ignoresSafeArea(.all)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.all)
        .onAppear {
            setupVideoPlayer()
        }
        .onDisappear {
            cleanupPlayer()
        }
    }
    
    // MARK: - Video Setup
    private func setupVideoPlayer() {
        guard let videoURL = getVideoURL() else {
            return
        }
        
        // Create player with local video
        let playerItem = AVPlayerItem(url: videoURL)
        let queuePlayer = AVQueuePlayer(playerItem: playerItem)
        
        // Setup seamless looping
        playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
        
        // Configure player settings for optimal performance
        queuePlayer.isMuted = true // No audio needed
        queuePlayer.allowsExternalPlayback = false
        
        // Set video to fill mode and play
        player = queuePlayer
        queuePlayer.play()
    }
    
    private func getVideoURL() -> URL? {
        // Try to find video in main bundle
        if let url = Bundle.main.url(forResource: videoName, withExtension: videoExtension) {
            return url
        }
        
        // Alternative: try without extension (in case it's included in filename)
        if let url = Bundle.main.url(forResource: videoName, withExtension: nil) {
            return url
        }
        
        return nil
    }
    
    private func cleanupPlayer() {
        player?.pause()
        playerLooper?.disableLooping()
        playerLooper = nil
        player = nil
    }
}

// MARK: - Full-Screen Video Player (UIKit Bridge)
struct FullScreenVideoPlayer: UIViewRepresentable {
    let player: AVPlayer
    let zoomScale: CGFloat
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill // Fill entire screen
        playerLayer.backgroundColor = UIColor.black.cgColor
        
        view.layer.addSublayer(playerLayer)
        
        // Store the layer for updates
        context.coordinator.playerLayer = playerLayer
        context.coordinator.zoomScale = zoomScale
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Update layer frame with zoom scale applied
        DispatchQueue.main.async {
            guard let playerLayer = context.coordinator.playerLayer else { return }
            
            let bounds = uiView.bounds
            let zoomedWidth = bounds.width * context.coordinator.zoomScale
            let zoomedHeight = bounds.height * context.coordinator.zoomScale
            
            // Center the zoomed content
            let offsetX = (bounds.width - zoomedWidth) / 2
            let offsetY = (bounds.height - zoomedHeight) / 2
            
            playerLayer.frame = CGRect(
                x: offsetX,
                y: offsetY,
                width: zoomedWidth,
                height: zoomedHeight
            )
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject {
        var playerLayer: AVPlayerLayer?
        var zoomScale: CGFloat = 1.0
    }
}

// MARK: - Preview
#Preview("Matrix Video - Default Zoom") {
    MatrixVideoView()
        .preferredColorScheme(.dark)
}

#Preview("Matrix Video - Large Symbols") {
    MatrixVideoView(zoomScale: 2.0)
        .preferredColorScheme(.dark)
}

#Preview("Matrix Video - Extra Large Symbols") {
    MatrixVideoView(zoomScale: 2.5)
        .preferredColorScheme(.dark)
}

#Preview("Fallback Matrix") {
    MatrixRainView()
}
