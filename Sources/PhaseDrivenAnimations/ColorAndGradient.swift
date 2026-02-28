import SwiftUI

public struct GradientShiftModifier: AnimatableModifier {
    public var phase: Double
    public var colors: [Color]

    public init(phase: Double, colors: [Color]) {
        self.phase = phase
        self.colors = colors
    }

    public var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }

    public func body(content: Content) -> some View {
        let theta = PhaseMath.radians(phase)
        let start = UnitPoint(
            x: 0.5 + 0.5 * cos(theta),
            y: 0.5 + 0.5 * sin(theta)
        )
        let end = UnitPoint(
            x: 0.5 + 0.5 * cos(theta + .pi),
            y: 0.5 + 0.5 * sin(theta + .pi)
        )

        return content
            .overlay {
                LinearGradient(colors: colors, startPoint: start, endPoint: end)
            }
            .mask(content)
    }
}

public struct HueSaturationOscillationModifier: AnimatableModifier {
    public var phase: Double
    public var maxHueDegrees: Double
    public var saturationAmplitude: Double
    public var baseSaturation: Double

    public init(
        phase: Double,
        maxHueDegrees: Double = 25,
        saturationAmplitude: Double = 0.35,
        baseSaturation: Double = 1
    ) {
        self.phase = phase
        self.maxHueDegrees = maxHueDegrees
        self.saturationAmplitude = saturationAmplitude
        self.baseSaturation = baseSaturation
    }

    public var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }

    public func body(content: Content) -> some View {
        let theta = PhaseMath.radians(phase)
        let hueDegrees = sin(theta) * maxHueDegrees
        let saturation = baseSaturation + cos(theta * 0.8) * saturationAmplitude

        return content
            .hueRotation(.degrees(hueDegrees))
            .saturation(PhaseMath.clamp(saturation, min: 0, max: 2))
    }
}

public struct AnimatedBlobBackground: View {
    public struct Blob: Identifiable, Sendable {
        public var id: Int
        public var color: Color
        public var size: CGFloat
        public var depth: CGFloat
        public var xBias: CGFloat
        public var yBias: CGFloat

        public init(id: Int, color: Color, size: CGFloat, depth: CGFloat, xBias: CGFloat = 0, yBias: CGFloat = 0) {
            self.id = id
            self.color = color
            self.size = size
            self.depth = depth
            self.xBias = xBias
            self.yBias = yBias
        }
    }

    public var phase: Double
    public var blobs: [Blob]
    public var blurRadius: CGFloat

    public init(phase: Double, blobs: [Blob], blurRadius: CGFloat = 24) {
        self.phase = phase
        self.blobs = blobs
        self.blurRadius = blurRadius
    }

    public var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(blobs) { blob in
                    let theta = PhaseMath.radians(phase) + Double(blob.id) * 0.9
                    let driftX = cos(theta * (0.7 + Double(blob.depth) * 0.2)) * proxy.size.width * 0.15 * blob.depth
                    let driftY = sin(theta * (1.1 + Double(blob.depth) * 0.2)) * proxy.size.height * 0.12 * blob.depth

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [blob.color.opacity(0.95), blob.color.opacity(0.2), .clear],
                                center: .center,
                                startRadius: 8,
                                endRadius: blob.size * 0.6
                            )
                        )
                        .frame(width: blob.size, height: blob.size)
                        .offset(x: driftX + blob.xBias, y: driftY + blob.yBias)
                        .blendMode(.plusLighter)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .blur(radius: blurRadius)
        }
    }
}

public extension View {
    func phaseGradientShift(_ phase: Double, colors: [Color]) -> some View {
        modifier(GradientShiftModifier(phase: phase, colors: colors))
    }

    func phaseHueSaturation(
        _ phase: Double,
        maxHueDegrees: Double = 25,
        saturationAmplitude: Double = 0.35,
        baseSaturation: Double = 1
    ) -> some View {
        modifier(
            HueSaturationOscillationModifier(
                phase: phase,
                maxHueDegrees: maxHueDegrees,
                saturationAmplitude: saturationAmplitude,
                baseSaturation: baseSaturation
            )
        )
    }
}
