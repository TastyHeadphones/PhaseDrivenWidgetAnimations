import SwiftUI
import PhaseDrivenAnimations

struct WidgetAnimationRenderable: View {
    let kind: DemoAnimationKind
    let phase: Double

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
            card.phaseHorizontalSwing(phase, amplitude: 8)
        case .verticalSwing:
            card.phaseVerticalSwing(phase, amplitude: 8)
        case .shakeJitter:
            card.phaseShake(phase, amplitude: 4, frequency: 8, jitter: 0.3)
        case .orbit:
            card.phaseOrbit(phase, radiusX: 12, radiusY: 8)
        case .parallaxDrift:
            ZStack {
                PhaseParallaxLayer(phase: phase, depth: 0.5, xAmplitude: 8, yAmplitude: 5) {
                    Circle().fill(.cyan.opacity(0.6)).frame(width: 34)
                }
                PhaseParallaxLayer(phase: phase, depth: 1.1, xAmplitude: 8, yAmplitude: 5) {
                    Circle().fill(.mint.opacity(0.8)).frame(width: 52)
                }
            }

        case .continuousSpin:
            card.phaseContinuousSpin(phase)
        case .pendulumRotation:
            VStack(spacing: 0) {
                Capsule().fill(.white.opacity(0.4)).frame(width: 3, height: 18)
                Circle().fill(.orange).frame(width: 38)
            }
            .phasePendulumRotation(phase, maxAngle: .degrees(24), anchor: .top)
        case .cardTilt3D:
            card.phaseCardTilt3D(phase)

        case .breathingScale:
            card.phaseBreathingScale(phase)
        case .bounceScale:
            card.phaseBounceScale(phase)
        case .squashStretch:
            card.phaseSquashStretch(phase, amount: 0.18, yOffsetCoupling: 5)

        case .opacityPulse:
            card.phaseOpacityPulse(phase, min: 0.25, max: 1)
        case .blurPulse:
            card.phaseBlurPulse(phase, minRadius: 0, maxRadius: 4)
        case .shimmerSweep:
            card.phaseShimmer(phase, bandFraction: 0.24)

        case .strokeRunner:
            Circle()
                .phaseStrokeRunner(phase, span: 0.24, color: .indigo, style: StrokeStyle(lineWidth: 6, lineCap: .round))

        case .progressRing:
            AnimatedProgressRing(
                phase: phase,
                startAngle: .degrees(-90),
                lineCap: .round,
                lineWidth: 6,
                trackColor: .gray.opacity(0.2),
                progressColor: .mint
            )

        case .phaseWave:
            PhaseWaveShape(phase: phase, amplitude: 8, wavelength: 44)
                .stroke(.cyan, style: StrokeStyle(lineWidth: 3, lineCap: .round))

        case .gradientShift:
            card.phaseGradientShift(phase, colors: [.pink, .orange, .yellow, .mint, .cyan])
        case .hueSaturation:
            card.phaseHueSaturation(phase, maxHueDegrees: 24, saturationAmplitude: 0.35, baseSaturation: 1)
        case .blobBackground:
            AnimatedBlobBackground(
                phase: phase,
                blobs: [
                    .init(id: 0, color: .pink, size: 90, depth: 1.1),
                    .init(id: 1, color: .cyan, size: 110, depth: 0.8)
                ],
                blurRadius: 16
            )

        case .spriteSheet:
            WidgetSpriteSheet(rows: 4, cols: 4)
                .phaseSpriteSheet(phase, rows: 4, cols: 4, fps: 8)

        case .imageSequence:
            Color.clear
                .phaseImageSequence(
                    phase,
                    fps: 8,
                    images: [
                        Image(systemName: "sun.max.fill"),
                        Image(systemName: "cloud.sun.fill"),
                        Image(systemName: "cloud.fill"),
                        Image(systemName: "cloud.rain.fill"),
                        Image(systemName: "cloud.bolt.rain.fill"),
                        Image(systemName: "moon.stars.fill")
                    ]
                )
        }
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
