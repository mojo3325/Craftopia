import SwiftUI

// MARK: - Matrix Rain View (Optimized Timeline-driven Rendering)
struct MatrixRainView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var columns: [MatrixColumn] = []
    @State private var screenHeight: CGFloat = 0
    @State private var screenWidth: CGFloat = 0
    @State private var animationTime: TimeInterval = 0
    @State private var timer: Timer?

    // Exposed control for fall speed
    var speedMultiplier: CGFloat = 1.0

    // MARK: - Tuning (Optimized for performance)
    private let glyphSize: CGFloat = 16
    private let verticalSpacing: CGFloat = 2
    private let columnSpacing: CGFloat = 3
    private var lineHeight: CGFloat { glyphSize + verticalSpacing }
    private var columnWidth: CGFloat { glyphSize + columnSpacing }
    private let maxStreamsPerColumn: Int = 2
    private let frameInterval: TimeInterval = 1.0 / 30.0 // Reduced frame rate

    // MARK: - Colors (authentic Matrix colors)
    private var matrixGreen: Color {
        Color(red: 0, green: 1, blue: 0.255)
    }

    private var brightGreen: Color { Color(red: 0.6, green: 1, blue: 0.6) }
    private var darkGreen: Color { Color(red: 0, green: 0.23, blue: 0) }
    private var matrixBackground: Color { .black }

    // MARK: - Character Set (simplified for performance)
    private let matrixChars: [String] = {
        let katakana = [
            "ア","イ","ウ","エ","オ","カ","キ","ク","ケ","コ","サ","シ","ス","セ","ソ",
            "タ","チ","ツ","テ","ト","ナ","ニ","ヌ","ネ","ノ","ハ","ヒ","フ","ヘ","ホ",
            "マ","ミ","ム","メ","モ","ヤ","ユ","ヨ","ラ","リ","ル","レ","ロ","ワ","ヲ","ン"
        ]
        let numerics = ["0","1","2","3","4","5","6","7","8","9"]
        let symbols = [":",".","=","\"","*","+","-","|","<",">"]
        return katakana + numerics + symbols
    }()

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                matrixBackground
                    .ignoresSafeArea()
                
                // Matrix streams
                ForEach(columns, id: \.id) { column in
                    ForEach(column.streams, id: \.id) { stream in
                        MatrixStreamView(
                            stream: stream, 
                            x: column.x, 
                            animationTime: animationTime,
                            chars: matrixChars,
                            lineHeight: lineHeight,
                            glyphSize: glyphSize,
                            speedMultiplier: speedMultiplier,
                            brightGreen: brightGreen,
                            darkGreen: darkGreen,
                            matrixGreen: matrixGreen,
                            canvasSize: geometry.size
                        )
                    }
                }
            }
            .onAppear {
                screenWidth = geometry.size.width
                screenHeight = geometry.size.height
                print("MatrixRainView onAppear: \(screenWidth)x\(screenHeight)")
                setupColumns()
                startAnimation()
            }
            .onDisappear {
                stopAnimation()
            }
            .onChange(of: geometry.size) { _, newSize in
                screenWidth = newSize.width
                screenHeight = newSize.height
                setupColumns()
            }
        }
    }
    
    private func startAnimation() {
        stopAnimation()
        print("MatrixRainView: Starting Timer animation")
        timer = Timer.scheduledTimer(withTimeInterval: 1.0/30.0, repeats: true) { _ in
            animationTime += 1.0/30.0
        }
    }
    
    private func stopAnimation() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Setup
    private func setupColumns() {
        guard screenWidth > 0, screenHeight > 0 else { return }
        columns.removeAll()
        let count = max(1, Int((screenWidth / columnWidth).rounded(.down)))
        let travelHeightBase = screenHeight + (32.0 * lineHeight) + 40.0
        
        for i in 0..<count {
            let x = CGFloat(i) * columnWidth + columnWidth * 0.5
            let streamCount = Int.random(in: 1...maxStreamsPerColumn)
            var seeds: [MatrixStream] = []
            for _ in 0..<streamCount {
                let length = Int.random(in: 12...25)
                // Simpler speed calculation
                let rowsPerSecond = CGFloat.random(in: 15...25)
                let speed = rowsPerSecond * lineHeight
                let phase = CGFloat.random(in: 0...(travelHeightBase))
                let changeInterval = Double.random(in: 0.08...0.15)
                let charSeed = UInt64.random(in: 0...UInt64.max)
                seeds.append(MatrixStream(id: UUID(), length: length, speed: speed, phase: phase, changeInterval: changeInterval, charSeed: charSeed))
            }
            columns.append(MatrixColumn(id: UUID(), x: x, streams: seeds))
        }
        
        print("MatrixRainView setupColumns: \(columns.count) columns, \(columns.flatMap { $0.streams }.count) streams")
    }

    // MARK: - Drawing
    private func draw(stream: MatrixStream, atX x: CGFloat, time t: TimeInterval, in context: inout GraphicsContext, canvasSize: CGSize) {
        // Use time directly since it's already counting from 0
        let timeNonNegative = max(0.0, t)
        let effectiveHeight = canvasSize.height + CGFloat(stream.length) * lineHeight + 40.0
        var headY = -stream.phase + (stream.speed * CGFloat(timeNonNegative) * max(0.1, speedMultiplier))
        headY = headY.truncatingRemainder(dividingBy: effectiveHeight)
        if headY < -CGFloat(stream.length) * lineHeight { headY += effectiveHeight }

        // Head flash cadence (deterministic)
        let flashFrame = Int((timeNonNegative / 0.25).rounded(.down))
        let headFlash = hashedBits(stream.charSeed ^ UInt64(bitPattern: Int64(flashFrame))) & 3 == 0

        for i in 0..<stream.length {
            let y = headY - CGFloat(i) * lineHeight
            if y < -lineHeight || y > canvasSize.height + lineHeight { continue }

            // Character generation: deterministic and time-evolving
            let frameIndex = Int((timeNonNegative / stream.changeInterval).rounded(.down))
            let rnd = hashedBits(stream.charSeed &+ UInt64(i) &+ UInt64(bitPattern: Int64(frameIndex * 131)))
            let char = matrixChars[Int(rnd % UInt64(matrixChars.count))]

            let isHead = (i == 0)
            let isNearHead = i <= 2
            let fadeRatio = 1.0 - (CGFloat(i) / CGFloat(stream.length))
            
            // Simplified color and opacity
            let baseColor: Color
            let opacity: Double
            
            if isHead {
                baseColor = headFlash ? .white : brightGreen
                opacity = 1.0
            } else if isNearHead {
                baseColor = brightGreen
                opacity = 0.8 * fadeRatio
            } else {
                baseColor = darkGreen
                opacity = max(0.15, 0.5 * fadeRatio)
            }

            let text = Text(char)
                .font(.system(size: glyphSize, weight: .medium, design: .monospaced))
                .foregroundStyle(baseColor.opacity(opacity))

            // Minimal glow only for head
            if isHead {
                context.drawLayer { layer in
                    layer.addFilter(.shadow(color: matrixGreen.opacity(0.4), radius: 3, x: 0, y: 0))
                    layer.draw(text, at: CGPoint(x: x, y: y))
                }
            } else {
                context.draw(text, at: CGPoint(x: x, y: y))
            }
        }
    }
}

// MARK: - Models (seed-only, no per-frame mutation)
struct MatrixColumn: Identifiable {
    let id: UUID
    let x: CGFloat
    var streams: [MatrixStream]
}

struct MatrixStream: Identifiable {
    let id: UUID
    let length: Int
    let speed: CGFloat
    let phase: CGFloat
    let changeInterval: Double
    let charSeed: UInt64
}

// MARK: - Hash Utility
@inline(__always)
private func hashedBits(_ x: UInt64) -> UInt64 {
    var v = x
    v ^= v >> 33
    v &*= 0xff51afd7ed558ccd
    v ^= v >> 33
    v &*= 0xc4ceb9fe1a85ec53
    v ^= v >> 33
    return v
}

// MARK: - Matrix Stream View Component
struct MatrixStreamView: View {
    let stream: MatrixStream
    let x: CGFloat
    let animationTime: TimeInterval
    let chars: [String]
    let lineHeight: CGFloat
    let glyphSize: CGFloat
    let speedMultiplier: CGFloat
    let brightGreen: Color
    let darkGreen: Color
    let matrixGreen: Color
    let canvasSize: CGSize
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<stream.length, id: \.self) { i in
                characterView(at: i)
            }
        }
        .offset(x: x - canvasSize.width/2, y: yOffset)
    }
    
    private var yOffset: CGFloat {
        let timeNonNegative = max(0.0, animationTime)
        let effectiveHeight = canvasSize.height + CGFloat(stream.length) * lineHeight + 40.0
        var headY = -stream.phase + (stream.speed * CGFloat(timeNonNegative) * max(0.1, speedMultiplier))
        headY = headY.truncatingRemainder(dividingBy: effectiveHeight)
        if headY < -CGFloat(stream.length) * lineHeight { headY += effectiveHeight }
        return headY - canvasSize.height/2
    }
    
    private func characterView(at index: Int) -> some View {
        let timeNonNegative = max(0.0, animationTime)
        let frameIndex = Int((timeNonNegative / stream.changeInterval).rounded(.down))
        let rnd = hashedBits(stream.charSeed &+ UInt64(index) &+ UInt64(bitPattern: Int64(frameIndex * 131)))
        let char = chars[Int(rnd % UInt64(chars.count))]
        
        let isHead = (index == 0)
        let isNearHead = index <= 2
        let fadeRatio = 1.0 - (CGFloat(index) / CGFloat(stream.length))
        
        let flashFrame = Int((timeNonNegative / 0.25).rounded(.down))
        let headFlash = hashedBits(stream.charSeed ^ UInt64(bitPattern: Int64(flashFrame))) & 3 == 0
        
        let baseColor: Color
        let opacity: Double
        
        if isHead {
            baseColor = headFlash ? .white : brightGreen
            opacity = 1.0
        } else if isNearHead {
            baseColor = brightGreen
            opacity = 0.8 * fadeRatio
        } else {
            baseColor = darkGreen
            opacity = max(0.15, 0.5 * fadeRatio)
        }
        
        return Text(char)
            .font(.system(size: glyphSize, weight: .medium, design: .monospaced))
            .foregroundColor(baseColor.opacity(opacity))
            .shadow(color: isHead ? matrixGreen.opacity(0.4) : .clear, radius: isHead ? 3 : 0)
            .frame(height: lineHeight)
    }
}

#Preview("Matrix Rain Effect") {
    MatrixRainView(speedMultiplier: 1.2)
        .frame(height: 400)
        .background(.black)
        .preferredColorScheme(.dark)
}

#Preview("Full Screen Matrix") {
    MatrixRainView(speedMultiplier: 1.0)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .background(.black)
        .preferredColorScheme(.dark)
}

#Preview("Slow Matrix") {
    MatrixRainView(speedMultiplier: 0.6)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .background(.black)
        .preferredColorScheme(.dark)
}
