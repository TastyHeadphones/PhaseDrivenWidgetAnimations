import SwiftUI

public struct StrokeTrimRunner<S: Shape>: View {
    public var shape: S
    public var phase: Double
    public var span: Double
    public var color: Color
    public var style: StrokeStyle

    public init(
        shape: S,
        phase: Double,
        span: Double = 0.2,
        color: Color = .accentColor,
        style: StrokeStyle = StrokeStyle(lineWidth: 4, lineCap: .round)
    ) {
        self.shape = shape
        self.phase = phase
        self.span = max(0.001, min(span, 1))
        self.color = color
        self.style = style
    }

    public var body: some View {
        let start = PhaseMath.wrap(phase)
        let end = start + span

        if end <= 1 {
            shape
                .trim(from: start, to: end)
                .stroke(color, style: style)
        } else {
            ZStack {
                shape
                    .trim(from: start, to: 1)
                    .stroke(color, style: style)
                shape
                    .trim(from: 0, to: end - 1)
                    .stroke(color, style: style)
            }
        }
    }
}

public struct AnimatedProgressRing: View {
    public var phase: Double
    public var startAngle: Angle
    public var lineCap: CGLineCap
    public var lineWidth: CGFloat
    public var trackColor: Color
    public var progressColor: Color

    public init(
        phase: Double,
        startAngle: Angle = .degrees(-90),
        lineCap: CGLineCap = .round,
        lineWidth: CGFloat = 10,
        trackColor: Color = .gray.opacity(0.2),
        progressColor: Color = .accentColor
    ) {
        self.phase = phase
        self.startAngle = startAngle
        self.lineCap = lineCap
        self.lineWidth = lineWidth
        self.trackColor = trackColor
        self.progressColor = progressColor
    }

    public var body: some View {
        let progress = max(0.001, PhaseMath.wrap(phase))
        let strokeStyle = StrokeStyle(lineWidth: lineWidth, lineCap: lineCap)

        return ZStack {
            Circle()
                .stroke(trackColor, style: strokeStyle)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(progressColor, style: strokeStyle)
                .rotationEffect(startAngle)
        }
    }
}

public struct PhaseWaveShape: Shape {
    public var phase: Double
    public var amplitude: CGFloat
    public var wavelength: CGFloat
    public var verticalShift: CGFloat

    public init(phase: Double, amplitude: CGFloat = 12, wavelength: CGFloat = 80, verticalShift: CGFloat = 0) {
        self.phase = phase
        self.amplitude = amplitude
        self.wavelength = max(1, wavelength)
        self.verticalShift = verticalShift
    }

    public var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let baseY = rect.midY + verticalShift
        let theta = PhaseMath.radians(phase)

        path.move(to: CGPoint(x: 0, y: baseY))

        let step: CGFloat = 3
        var x: CGFloat = 0
        while x <= rect.width {
            let normal = Double(x / wavelength) * 2 * Double.pi
            let y = baseY + CGFloat(sin(normal + theta)) * amplitude
            path.addLine(to: CGPoint(x: x, y: y))
            x += step
        }

        return path
    }
}

public struct PhaseWaveCanvas: View {
    public var phase: Double
    public var amplitude: CGFloat
    public var wavelength: CGFloat
    public var strokeStyle: StrokeStyle
    public var color: Color

    public init(
        phase: Double,
        amplitude: CGFloat = 12,
        wavelength: CGFloat = 80,
        strokeStyle: StrokeStyle = StrokeStyle(lineWidth: 3, lineCap: .round),
        color: Color = .accentColor
    ) {
        self.phase = phase
        self.amplitude = amplitude
        self.wavelength = wavelength
        self.strokeStyle = strokeStyle
        self.color = color
    }

    public var body: some View {
        Canvas { context, size in
            let rect = CGRect(origin: .zero, size: size)
            let path = PhaseWaveShape(phase: phase, amplitude: amplitude, wavelength: wavelength).path(in: rect)
            context.stroke(path, with: .color(color), style: strokeStyle)
        }
    }
}

public extension Shape {
    func phaseStrokeRunner(
        _ phase: Double,
        span: Double = 0.2,
        color: Color = .accentColor,
        style: StrokeStyle = StrokeStyle(lineWidth: 4, lineCap: .round)
    ) -> some View {
        StrokeTrimRunner(shape: self, phase: phase, span: span, color: color, style: style)
    }
}
