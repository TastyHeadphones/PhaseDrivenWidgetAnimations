import SwiftUI

public struct BreathingScaleModifier: AnimatableModifier {
    public var phase: Double
    public var amplitude: CGFloat
    public var baseline: CGFloat

    public init(phase: Double, amplitude: CGFloat = 0.08, baseline: CGFloat = 1) {
        self.phase = phase
        self.amplitude = amplitude
        self.baseline = baseline
    }

    public var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }

    public func body(content: Content) -> some View {
        let s = baseline + CGFloat(sin(PhaseMath.radians(phase))) * amplitude
        return content.scaleEffect(max(0.001, s))
    }
}

public struct BounceScaleModifier: AnimatableModifier {
    public var phase: Double
    public var amplitude: CGFloat
    public var baseline: CGFloat

    public init(phase: Double, amplitude: CGFloat = 0.24, baseline: CGFloat = 1) {
        self.phase = phase
        self.amplitude = amplitude
        self.baseline = baseline
    }

    public var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }

    public func body(content: Content) -> some View {
        let pingPong = PhaseMath.triangle(phase)
        let bounced = PhaseMath.easeOutBounce(pingPong)
        let scale = baseline + amplitude * CGFloat(bounced)
        return content.scaleEffect(max(0.001, scale))
    }
}

public struct SquashStretchModifier: AnimatableModifier {
    public var phase: Double
    public var amount: CGFloat
    public var yOffsetCoupling: CGFloat

    public init(phase: Double, amount: CGFloat = 0.16, yOffsetCoupling: CGFloat = 8) {
        self.phase = phase
        self.amount = amount
        self.yOffsetCoupling = yOffsetCoupling
    }

    public var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }

    public func body(content: Content) -> some View {
        let pulse = CGFloat(sin(PhaseMath.radians(phase)))
        let xScale = 1 + amount * pulse
        let yScale = 1 - amount * pulse
        let yOffset = -abs(pulse) * yOffsetCoupling

        return content
            .scaleEffect(x: max(0.001, xScale), y: max(0.001, yScale), anchor: .center)
            .offset(y: yOffset)
    }
}

public extension View {
    func phaseBreathingScale(_ phase: Double, amplitude: CGFloat = 0.08, baseline: CGFloat = 1) -> some View {
        modifier(BreathingScaleModifier(phase: phase, amplitude: amplitude, baseline: baseline))
    }

    func phaseBounceScale(_ phase: Double, amplitude: CGFloat = 0.24, baseline: CGFloat = 1) -> some View {
        modifier(BounceScaleModifier(phase: phase, amplitude: amplitude, baseline: baseline))
    }

    func phaseSquashStretch(_ phase: Double, amount: CGFloat = 0.16, yOffsetCoupling: CGFloat = 8) -> some View {
        modifier(SquashStretchModifier(phase: phase, amount: amount, yOffsetCoupling: yOffsetCoupling))
    }
}
