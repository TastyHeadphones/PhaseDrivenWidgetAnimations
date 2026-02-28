import SwiftUI

public struct PhaseParallaxLayer<Content: View>: View {
    public var phase: Double
    public var depth: CGFloat
    public var xAmplitude: CGFloat
    public var yAmplitude: CGFloat
    private let content: () -> Content

    public init(
        phase: Double,
        depth: CGFloat,
        xAmplitude: CGFloat = 10,
        yAmplitude: CGFloat = 6,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.phase = phase
        self.depth = depth
        self.xAmplitude = xAmplitude
        self.yAmplitude = yAmplitude
        self.content = content
    }

    public var body: some View {
        content()
            .phaseParallaxDrift(phase, depth: depth, xAmplitude: xAmplitude, yAmplitude: yAmplitude)
    }
}
