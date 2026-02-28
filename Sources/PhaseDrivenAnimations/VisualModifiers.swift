import SwiftUI

public struct OpacityPulseModifier: AnimatableModifier {
    public var phase: Double
    public var minOpacity: Double
    public var maxOpacity: Double

    public init(phase: Double, minOpacity: Double = 0.35, maxOpacity: Double = 1) {
        self.phase = phase
        self.minOpacity = minOpacity
        self.maxOpacity = maxOpacity
    }

    public var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }

    public func body(content: Content) -> some View {
        let opacity = PhaseMath.oscillating(phase, min: minOpacity, max: maxOpacity)
        return content.opacity(opacity)
    }
}

public struct BlurPulseModifier: AnimatableModifier {
    public var phase: Double
    public var minRadius: CGFloat
    public var maxRadius: CGFloat

    public init(phase: Double, minRadius: CGFloat = 0, maxRadius: CGFloat = 10) {
        self.phase = phase
        self.minRadius = minRadius
        self.maxRadius = maxRadius
    }

    public var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }

    public func body(content: Content) -> some View {
        let lo = min(minRadius, maxRadius)
        let hi = max(minRadius, maxRadius)
        let radius = PhaseMath.oscillating(phase, min: Double(lo), max: Double(hi))
        return content.blur(radius: CGFloat(PhaseMath.clamp(radius, min: Double(lo), max: Double(hi))))
    }
}

public struct ShimmerSweepModifier: AnimatableModifier {
    public var phase: Double
    public var bandFraction: CGFloat
    public var angle: Angle
    public var opacity: Double

    public init(
        phase: Double,
        bandFraction: CGFloat = 0.25,
        angle: Angle = .degrees(20),
        opacity: Double = 0.85
    ) {
        self.phase = phase
        self.bandFraction = bandFraction
        self.angle = angle
        self.opacity = opacity
    }

    public var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }

    public func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { proxy in
                    let widthFraction = PhaseMath.clamp(Double(bandFraction), min: 0.05, max: 1)
                    let bandWidth = proxy.size.width * CGFloat(widthFraction)
                    let progress = PhaseMath.wrap(phase)
                    let startX = -bandWidth
                    let endX = proxy.size.width + bandWidth
                    let x = startX + (endX - startX) * CGFloat(progress)

                    LinearGradient(
                        colors: [.clear, .white.opacity(opacity), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(width: bandWidth, height: proxy.size.height * 1.6)
                    .rotationEffect(angle)
                    .offset(x: x - bandWidth * 0.5)
                }
                .allowsHitTesting(false)
                .blendMode(.plusLighter)
            }
            .mask(content)
    }
}

public extension View {
    func phaseOpacityPulse(_ phase: Double, min: Double = 0.35, max: Double = 1) -> some View {
        modifier(OpacityPulseModifier(phase: phase, minOpacity: min, maxOpacity: max))
    }

    func phaseBlurPulse(_ phase: Double, minRadius: CGFloat = 0, maxRadius: CGFloat = 10) -> some View {
        modifier(BlurPulseModifier(phase: phase, minRadius: minRadius, maxRadius: maxRadius))
    }

    func phaseShimmer(
        _ phase: Double,
        bandFraction: CGFloat = 0.25,
        angle: Angle = .degrees(20),
        opacity: Double = 0.85
    ) -> some View {
        modifier(ShimmerSweepModifier(phase: phase, bandFraction: bandFraction, angle: angle, opacity: opacity))
    }
}
