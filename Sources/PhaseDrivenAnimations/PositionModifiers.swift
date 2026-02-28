import SwiftUI

public struct HorizontalSwingEffect: GeometryEffect {
    public var phase: Double
    public var amplitude: CGFloat
    public var cyclesPerTurn: Double

    public init(phase: Double, amplitude: CGFloat, cyclesPerTurn: Double = 1) {
        self.phase = phase
        self.amplitude = amplitude
        self.cyclesPerTurn = cyclesPerTurn
    }

    public var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }

    public func effectValue(size: CGSize) -> ProjectionTransform {
        let theta = PhaseMath.radians(phase) * cyclesPerTurn
        return ProjectionTransform(CGAffineTransform(translationX: amplitude * CGFloat(sin(theta)), y: 0))
    }
}

public struct VerticalSwingEffect: GeometryEffect {
    public var phase: Double
    public var amplitude: CGFloat
    public var cyclesPerTurn: Double

    public init(phase: Double, amplitude: CGFloat, cyclesPerTurn: Double = 1) {
        self.phase = phase
        self.amplitude = amplitude
        self.cyclesPerTurn = cyclesPerTurn
    }

    public var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }

    public func effectValue(size: CGSize) -> ProjectionTransform {
        let theta = PhaseMath.radians(phase) * cyclesPerTurn
        return ProjectionTransform(CGAffineTransform(translationX: 0, y: amplitude * CGFloat(sin(theta))))
    }
}

public struct ShakeJitterEffect: GeometryEffect {
    public var phase: Double
    public var amplitude: CGFloat
    public var frequency: Double
    public var jitter: Double
    public var seed: Double

    public init(
        phase: Double,
        amplitude: CGFloat,
        frequency: Double = 8,
        jitter: Double = 0.25,
        seed: Double = 0.314
    ) {
        self.phase = phase
        self.amplitude = amplitude
        self.frequency = frequency
        self.jitter = jitter
        self.seed = seed
    }

    public var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }

    public func effectValue(size: CGSize) -> ProjectionTransform {
        let theta = PhaseMath.radians(phase) * frequency
        let baseX = sin(theta)
        let baseY = cos(theta * 0.5)

        let jitterX = sin(theta * 2.73 + seed) * jitter
        let jitterY = cos(theta * 3.19 + seed * 1.31) * jitter

        let dx = amplitude * CGFloat(baseX + jitterX)
        let dy = amplitude * CGFloat(baseY * 0.4 + jitterY * 0.8)

        return ProjectionTransform(CGAffineTransform(translationX: dx, y: dy))
    }
}

public struct OrbitEffect: GeometryEffect {
    public var phase: Double
    public var radiusX: CGFloat
    public var radiusY: CGFloat
    public var turnsPerCycle: Double

    public init(phase: Double, radiusX: CGFloat, radiusY: CGFloat, turnsPerCycle: Double = 1) {
        self.phase = phase
        self.radiusX = radiusX
        self.radiusY = radiusY
        self.turnsPerCycle = turnsPerCycle
    }

    public var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }

    public func effectValue(size: CGSize) -> ProjectionTransform {
        let theta = PhaseMath.radians(phase) * turnsPerCycle
        let x = cos(theta) * radiusX
        let y = sin(theta) * radiusY
        return ProjectionTransform(CGAffineTransform(translationX: x, y: y))
    }
}

public struct ParallaxDriftEffect: GeometryEffect {
    public var phase: Double
    public var depth: CGFloat
    public var xAmplitude: CGFloat
    public var yAmplitude: CGFloat

    public init(phase: Double, depth: CGFloat, xAmplitude: CGFloat = 10, yAmplitude: CGFloat = 6) {
        self.phase = phase
        self.depth = depth
        self.xAmplitude = xAmplitude
        self.yAmplitude = yAmplitude
    }

    public var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }

    public func effectValue(size: CGSize) -> ProjectionTransform {
        let wrappedDepth = max(0, depth)
        let theta = PhaseMath.radians(phase)

        let dx = sin(theta + Double(wrappedDepth) * 0.8) * xAmplitude * wrappedDepth
        let dy = cos(theta * 0.67 + Double(wrappedDepth) * 1.7) * yAmplitude * wrappedDepth

        return ProjectionTransform(CGAffineTransform(translationX: dx, y: dy))
    }
}

public extension View {
    func phaseHorizontalSwing(_ phase: Double, amplitude: CGFloat, cyclesPerTurn: Double = 1) -> some View {
        modifier(HorizontalSwingEffect(phase: phase, amplitude: amplitude, cyclesPerTurn: cyclesPerTurn))
    }

    func phaseVerticalSwing(_ phase: Double, amplitude: CGFloat, cyclesPerTurn: Double = 1) -> some View {
        modifier(VerticalSwingEffect(phase: phase, amplitude: amplitude, cyclesPerTurn: cyclesPerTurn))
    }

    func phaseShake(
        _ phase: Double,
        amplitude: CGFloat,
        frequency: Double = 8,
        jitter: Double = 0.25,
        seed: Double = 0.314
    ) -> some View {
        modifier(ShakeJitterEffect(phase: phase, amplitude: amplitude, frequency: frequency, jitter: jitter, seed: seed))
    }

    func phaseOrbit(_ phase: Double, radiusX: CGFloat, radiusY: CGFloat, turnsPerCycle: Double = 1) -> some View {
        modifier(OrbitEffect(phase: phase, radiusX: radiusX, radiusY: radiusY, turnsPerCycle: turnsPerCycle))
    }

    func phaseParallaxDrift(_ phase: Double, depth: CGFloat, xAmplitude: CGFloat = 10, yAmplitude: CGFloat = 6) -> some View {
        modifier(ParallaxDriftEffect(phase: phase, depth: depth, xAmplitude: xAmplitude, yAmplitude: yAmplitude))
    }
}
