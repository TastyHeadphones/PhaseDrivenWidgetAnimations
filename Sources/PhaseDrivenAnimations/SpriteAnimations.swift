import SwiftUI

public struct SpriteSheetPhaseMapping: Sendable, Equatable {
    public var rows: Int
    public var cols: Int
    public var fps: Double
    public var cycleDuration: TimeInterval?

    public init(rows: Int, cols: Int, fps: Double, cycleDuration: TimeInterval? = nil) {
        self.rows = max(rows, 1)
        self.cols = max(cols, 1)
        self.fps = max(fps, 1)
        self.cycleDuration = cycleDuration
    }

    public var frameCount: Int {
        rows * cols
    }

    public func frameIndex(for phase: Double) -> Int {
        let normalized = PhaseMath.wrap(phase)
        let duration = cycleDuration ?? Double(frameCount) / fps
        let elapsed = normalized * duration
        let rawIndex = Int(floor(elapsed * fps))
        return max(0, min(frameCount - 1, rawIndex % frameCount))
    }
}

public struct ImageSequencePhaseMapping: Sendable, Equatable {
    public var frameCount: Int
    public var fps: Double
    public var cycleDuration: TimeInterval?

    public init(frameCount: Int, fps: Double, cycleDuration: TimeInterval? = nil) {
        self.frameCount = max(frameCount, 1)
        self.fps = max(fps, 1)
        self.cycleDuration = cycleDuration
    }

    public func frameIndex(for phase: Double) -> Int {
        let normalized = PhaseMath.wrap(phase)
        let duration = cycleDuration ?? Double(frameCount) / fps
        let elapsed = normalized * duration
        let rawIndex = Int(floor(elapsed * fps))
        return max(0, min(frameCount - 1, rawIndex % frameCount))
    }
}

public struct SpriteSheetFrameModifier: AnimatableModifier {
    public var phase: Double
    public var mapping: SpriteSheetPhaseMapping

    public init(phase: Double, mapping: SpriteSheetPhaseMapping) {
        self.phase = phase
        self.mapping = mapping
    }

    public var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }

    public func body(content: Content) -> some View {
        GeometryReader { proxy in
            let index = mapping.frameIndex(for: phase)
            let row = index / mapping.cols
            let col = index % mapping.cols

            content
                .scaleEffect(x: CGFloat(mapping.cols), y: CGFloat(mapping.rows), anchor: .topLeading)
                .offset(
                    x: -CGFloat(col) * proxy.size.width,
                    y: -CGFloat(row) * proxy.size.height
                )
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .topLeading)
        }
        .clipped()
    }
}

public struct ImageSequencePhaseModifier: AnimatableModifier {
    public var phase: Double
    public var mapping: ImageSequencePhaseMapping
    public var images: [Image]

    public init(phase: Double, mapping: ImageSequencePhaseMapping, images: [Image]) {
        self.phase = phase
        self.mapping = mapping
        self.images = images
    }

    public var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }

    public func body(content: Content) -> some View {
        if images.isEmpty {
            content
        } else {
            let index = mapping.frameIndex(for: phase)
            ZStack {
                content.hidden()
                images[min(index, images.count - 1)]
                    .resizable()
                    .scaledToFill()
            }
            .clipped()
        }
    }
}

public extension View {
    func phaseSpriteSheet(
        _ phase: Double,
        rows: Int,
        cols: Int,
        fps: Double,
        cycleDuration: TimeInterval? = nil
    ) -> some View {
        let mapping = SpriteSheetPhaseMapping(rows: rows, cols: cols, fps: fps, cycleDuration: cycleDuration)
        return modifier(SpriteSheetFrameModifier(phase: phase, mapping: mapping))
    }

    func phaseImageSequence(
        _ phase: Double,
        fps: Double,
        images: [Image],
        cycleDuration: TimeInterval? = nil
    ) -> some View {
        let mapping = ImageSequencePhaseMapping(frameCount: max(images.count, 1), fps: fps, cycleDuration: cycleDuration)
        return modifier(ImageSequencePhaseModifier(phase: phase, mapping: mapping, images: images))
    }
}
