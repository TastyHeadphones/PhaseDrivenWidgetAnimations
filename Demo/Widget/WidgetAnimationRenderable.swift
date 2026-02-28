import SwiftUI
import ClockHandRotationKit

struct WidgetAnimationRenderable: View {
    let kind: DemoAnimationKind

    private var card: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(.blue.gradient)
            .frame(width: 72, height: 72)
            .overlay {
                Image(systemName: "sparkles")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
            }
    }

    var body: some View {
        switch kind {
        case .horizontalSwing:
            card.widgetSwing(duration: 2.2, direction: .horizontal, distance: 30)
        case .verticalSwing:
            card.widgetSwing(duration: 2.0, direction: .vertical, distance: 22)
        case .shakeJitter:
            card
                .widgetSwing(duration: 0.42, direction: .horizontal, distance: 10)
                .widgetSwing(duration: 0.31, direction: .vertical, distance: 7)
        case .orbit:
            ClockOrbit(radiusX: 28, radiusY: 16, period: 3.2) {
                card
            }
        case .parallaxDrift:
            ZStack {
                ClockOrbit(radiusX: 14, radiusY: 8, period: 4.2) {
                    Circle().fill(.cyan.opacity(0.55)).frame(width: 30)
                }
                ClockOrbit(radiusX: 24, radiusY: 12, period: 3.1) {
                    Circle().fill(.mint.opacity(0.72)).frame(width: 46)
                }
                ClockOrbit(radiusX: 34, radiusY: 18, period: 2.4) {
                    Circle().fill(.teal.opacity(0.78)).frame(width: 58)
                }
            }

        case .continuousSpin:
            card.clockHandRotationEffect(period: .custom(2.2))
        case .pendulumRotation:
            VStack(spacing: 0) {
                Capsule().fill(.white.opacity(0.4)).frame(width: 3, height: 18)
                Circle().fill(.orange).frame(width: 38, height: 38)
            }
            .widgetSwing(duration: 2.4, direction: .horizontal, distance: 32)
        case .cardTilt3D:
            card
                .clockHandRotationEffect(period: .custom(4.8), anchor: .topLeading)
                .widgetSwing(duration: 4.8, direction: .vertical, distance: 8)

        case .breathingScale:
            ZStack {
                Circle()
                    .fill(.blue.opacity(0.25))
                    .frame(width: 90, height: 90)
                    .clockHandRotationEffect(period: .custom(3.4), anchor: .top)
                card.widgetSwing(duration: 3.4, direction: .vertical, distance: 8)
            }
        case .bounceScale:
            card
                .widgetSwing(duration: 0.84, direction: .vertical, distance: 16)
                .clockHandRotationEffect(period: .custom(1.68), anchor: .bottom)
        case .squashStretch:
            card
                .widgetSwing(duration: 0.94, direction: .vertical, distance: 11)
                .clockHandRotationEffect(period: .custom(1.88), anchor: .bottomTrailing)

        case .opacityPulse:
            card
                .overlay {
                    LinearGradient(
                        colors: [.white.opacity(0.05), .white.opacity(0.9), .white.opacity(0.05)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .clockHandRotationEffect(period: .custom(2.1))
                    .blendMode(.plusLighter)
                }
                .mask(card)
        case .blurPulse:
            ZStack {
                card
                card
                    .blur(radius: 6)
                    .opacity(0.5)
                    .clockHandRotationEffect(period: .custom(1.6), anchor: .topLeading)
            }
        case .shimmerSweep:
            card
                .overlay {
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.85), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(width: 28, height: 110)
                    .clockHandRotationEffect(period: .custom(1.45))
                    .blendMode(.plusLighter)
                }
                .mask(card)

        case .strokeRunner:
            ClockRunnerRing(progress: 0.24, lineWidth: 6, period: 1.2, color: .indigo)
        case .progressRing:
            ClockRunnerRing(progress: 0.66, lineWidth: 6, period: 2.2, color: .mint)
        case .phaseWave:
            ClockWave()
                .widgetSwing(duration: 1.18, direction: .horizontal, distance: 14)

        case .gradientShift:
            card
                .overlay {
                    AngularGradient(
                        colors: [.pink, .orange, .yellow, .mint, .cyan, .pink],
                        center: .center
                    )
                    .clockHandRotationEffect(period: .custom(3.8))
                    .blendMode(.overlay)
                }
                .mask(card)
        case .hueSaturation:
            card
                .overlay {
                    AngularGradient(
                        colors: [.red, .yellow, .green, .blue, .purple, .red],
                        center: .center
                    )
                    .clockHandRotationEffect(period: .custom(2.8))
                    .blendMode(.hue)
                }
        case .blobBackground:
            ZStack {
                ClockOrbit(radiusX: 26, radiusY: 18, period: 3.2) {
                    Circle().fill(.pink.opacity(0.85)).frame(width: 84, height: 84)
                }
                ClockOrbit(radiusX: 34, radiusY: 16, period: -2.7) {
                    Circle().fill(.cyan.opacity(0.8)).frame(width: 94, height: 94)
                }
                Circle()
                    .fill(.black.opacity(0.2))
                    .frame(width: 66, height: 66)
                    .overlay {
                        Image(systemName: "drop.fill")
                            .foregroundStyle(.white)
                    }
            }
            .blur(radius: 5)

        case .spriteSheet:
            WidgetSpriteSheet(rows: 4, cols: 4)
                .clockHandRotationEffect(period: .custom(2.0))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

        case .imageSequence:
            SymbolWheel(symbols: symbolNames, radius: 28, period: 2.2)
                .foregroundStyle(.orange)
        }
    }

    private var symbolNames: [String] {
        [
            "sun.max.fill",
            "cloud.sun.fill",
            "cloud.fill",
            "cloud.rain.fill",
            "cloud.bolt.rain.fill",
            "moon.stars.fill"
        ]
    }
}

private struct ClockOrbit<Content: View>: View {
    let radiusX: CGFloat
    let radiusY: CGFloat
    let period: TimeInterval
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .offset(x: radiusX)
            .clockHandRotationEffect(period: .custom(period))
            .offset(y: radiusY)
            .clockHandRotationEffect(period: .custom(-period * 0.5))
    }
}

private struct ClockRunnerRing: View {
    let progress: Double
    let lineWidth: CGFloat
    let period: TimeInterval
    let color: Color

    var body: some View {
        ZStack {
            Circle()
                .stroke(.white.opacity(0.2), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: max(0.05, min(progress, 0.95)))
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .clockHandRotationEffect(period: .custom(period))
        }
    }
}

private struct ClockWave: View {
    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                Capsule()
                    .fill(Color.cyan.opacity(0.45 - Double(index) * 0.08))
                    .frame(width: 84 - CGFloat(index) * 14, height: 8)
                    .offset(y: CGFloat(index) * 10 - 10)
                    .clockHandRotationEffect(period: .custom(1.35 + Double(index) * 0.22))
            }
        }
        .frame(width: 96, height: 64)
    }
}

private struct SymbolWheel: View {
    let symbols: [String]
    let radius: CGFloat
    let period: TimeInterval

    var body: some View {
        ZStack {
            ForEach(symbols.indices, id: \.self) { index in
                let angle = Angle.degrees(Double(index) / Double(max(symbols.count, 1)) * 360)
                Image(systemName: symbols[index])
                    .font(.system(size: 16, weight: .semibold))
                    .offset(x: radius)
                    .rotationEffect(angle)
            }
        }
        .clockHandRotationEffect(period: .custom(period))
    }
}

private struct WidgetSpriteSheet: View {
    let rows: Int
    let cols: Int

    var body: some View {
        GeometryReader { proxy in
            let cellWidth = proxy.size.width / CGFloat(max(cols, 1))
            let cellHeight = proxy.size.height / CGFloat(max(rows, 1))

            ZStack(alignment: .topLeading) {
                ForEach(0..<(max(rows, 1) * max(cols, 1)), id: \.self) { index in
                    let row = index / max(cols, 1)
                    let col = index % max(cols, 1)

                    Rectangle()
                        .fill(Color(hue: Double(index) / Double(max(rows, 1) * max(cols, 1)), saturation: 0.8, brightness: 1))
                        .frame(width: cellWidth, height: cellHeight)
                        .offset(x: CGFloat(col) * cellWidth, y: CGFloat(row) * cellHeight)
                }
            }
        }
    }
}
