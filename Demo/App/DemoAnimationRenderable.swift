import SwiftUI
import PhaseDrivenAnimations

struct DemoAnimationRenderable: View {
    let kind: DemoAnimationKind
    let phase: Double
    @ObservedObject var controls: DemoControls

    var body: some View {
        GeometryReader { proxy in
            render(in: proxy.size)
                .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }

    private func baseSide(for size: CGSize) -> CGFloat {
        max(180, min(size.width, size.height) * 0.56)
    }

    private func baseCard(in size: CGSize) -> some View {
        let side = baseSide(for: size)

        return RoundedRectangle(cornerRadius: side * 0.17, style: .continuous)
            .fill(.blue.gradient)
            .frame(width: side, height: side)
            .overlay {
                Image(systemName: "sparkles")
                    .font(.system(size: side * 0.28, weight: .bold))
                    .foregroundStyle(.white)
            }
    }

    @ViewBuilder
    private func render(in size: CGSize) -> some View {
        let side = baseSide(for: size)

        switch kind {
        case .horizontalSwing:
            baseCard(in: size)
                .phaseHorizontalSwing(phase, amplitude: controls.amplitude)

        case .verticalSwing:
            baseCard(in: size)
                .phaseVerticalSwing(phase, amplitude: controls.amplitude)

        case .shakeJitter:
            baseCard(in: size)
                .phaseShake(phase, amplitude: controls.amplitude * 0.35, frequency: 9, jitter: 0.4)

        case .orbit:
            baseCard(in: size)
                .phaseOrbit(phase, radiusX: controls.amplitude, radiusY: controls.secondaryAmplitude)

        case .parallaxDrift:
            ZStack {
                PhaseParallaxLayer(phase: phase, depth: 0.35, xAmplitude: controls.amplitude, yAmplitude: controls.secondaryAmplitude) {
                    Circle().fill(.teal.opacity(0.4)).frame(width: side * 0.52)
                }
                PhaseParallaxLayer(phase: phase, depth: 0.7, xAmplitude: controls.amplitude, yAmplitude: controls.secondaryAmplitude) {
                    Circle().fill(.mint.opacity(0.5)).frame(width: side * 0.78)
                }
                PhaseParallaxLayer(phase: phase, depth: 1.1, xAmplitude: controls.amplitude, yAmplitude: controls.secondaryAmplitude) {
                    Circle().fill(.cyan.opacity(0.7)).frame(width: side)
                }
            }
            .frame(width: min(size.width - 20, side * 1.45), height: side * 1.15)

        case .continuousSpin:
            baseCard(in: size)
                .phaseContinuousSpin(phase, turnsPerCycle: 1)

        case .pendulumRotation:
            VStack(spacing: 0) {
                Capsule().fill(.gray.opacity(0.5)).frame(width: 4, height: side * 0.26)
                Circle().fill(.orange.gradient).frame(width: side * 0.56, height: side * 0.56)
            }
            .phasePendulumRotation(phase, maxAngle: .degrees(30), anchor: .top)

        case .cardTilt3D:
            baseCard(in: size)
                .phaseCardTilt3D(phase, maxX: .degrees(8), maxY: .degrees(12), perspective: 0.8)

        case .breathingScale:
            baseCard(in: size)
                .phaseBreathingScale(phase, amplitude: 0.14)

        case .bounceScale:
            baseCard(in: size)
                .phaseBounceScale(phase, amplitude: 0.3)

        case .squashStretch:
            baseCard(in: size)
                .phaseSquashStretch(phase, amount: 0.2, yOffsetCoupling: controls.secondaryAmplitude)

        case .opacityPulse:
            baseCard(in: size)
                .phaseOpacityPulse(phase, min: 0.2, max: 1)

        case .blurPulse:
            baseCard(in: size)
                .phaseBlurPulse(phase, minRadius: 0, maxRadius: controls.blurRadius)

        case .shimmerSweep:
            baseCard(in: size)
                .phaseShimmer(phase, bandFraction: controls.shimmerBand, angle: .degrees(22))

        case .strokeRunner:
            Circle()
                .phaseStrokeRunner(
                    phase,
                    span: controls.runnerSpan,
                    color: .indigo,
                    style: StrokeStyle(lineWidth: controls.lineWidth, lineCap: .round)
                )
                .frame(width: side * 1.05, height: side * 1.05)

        case .progressRing:
            AnimatedProgressRing(
                phase: phase,
                startAngle: .degrees(-90),
                lineCap: .round,
                lineWidth: controls.lineWidth,
                trackColor: .gray.opacity(0.2),
                progressColor: .mint
            )
            .frame(width: side * 1.05, height: side * 1.05)

        case .phaseWave:
            PhaseWaveCanvas(
                phase: phase,
                amplitude: controls.waveAmplitude,
                wavelength: controls.waveLength,
                strokeStyle: StrokeStyle(lineWidth: controls.lineWidth * 0.45, lineCap: .round),
                color: .cyan
            )
            .frame(width: min(size.width - 20, side * 1.7), height: side * 0.82)

        case .gradientShift:
            baseCard(in: size)
                .phaseGradientShift(phase, colors: [.red, .orange, .yellow, .green, .blue])

        case .hueSaturation:
            baseCard(in: size)
                .phaseHueSaturation(
                    phase,
                    maxHueDegrees: controls.hueDegrees,
                    saturationAmplitude: controls.saturationAmplitude,
                    baseSaturation: 1
                )

        case .blobBackground:
            ZStack {
                AnimatedBlobBackground(
                    phase: phase,
                    blobs: [
                        .init(id: 0, color: .pink, size: side * 0.82, depth: 0.9, xBias: -24, yBias: -8),
                        .init(id: 1, color: .blue, size: side * 0.92, depth: 1.2, xBias: 26, yBias: 20),
                        .init(id: 2, color: .mint, size: side * 0.72, depth: 0.75, xBias: -20, yBias: 32)
                    ],
                    blurRadius: side * 0.13
                )
                Text("Blob")
                    .font(.title.weight(.bold))
                    .foregroundStyle(.white)
            }
            .frame(width: min(size.width - 20, side * 1.55), height: side * 1.1)
            .background(.black.opacity(0.82))
            .clipShape(RoundedRectangle(cornerRadius: side * 0.14, style: .continuous))

        case .spriteSheet:
            SpriteSheetSample(rows: controls.spriteRows, cols: controls.spriteCols)
                .phaseSpriteSheet(
                    phase,
                    rows: controls.spriteRows,
                    cols: controls.spriteCols,
                    fps: controls.spriteFPS
                )
                .frame(width: side * 0.84, height: side * 0.84)
                .overlay {
                    RoundedRectangle(cornerRadius: side * 0.08).stroke(.primary.opacity(0.2), lineWidth: 1)
                }

        case .imageSequence:
            Color.clear
                .phaseImageSequence(phase, fps: controls.spriteFPS, images: symbolSequence)
                .frame(width: side * 0.9, height: side * 0.9)
                .foregroundStyle(.orange)
        }
    }

    private var symbolSequence: [Image] {
        [
            Image(systemName: "sun.max.fill"),
            Image(systemName: "cloud.sun.fill"),
            Image(systemName: "cloud.fill"),
            Image(systemName: "cloud.drizzle.fill"),
            Image(systemName: "cloud.rain.fill"),
            Image(systemName: "cloud.bolt.rain.fill"),
            Image(systemName: "wind"),
            Image(systemName: "moon.stars.fill")
        ]
    }
}

private struct SpriteSheetSample: View {
    let rows: Int
    let cols: Int

    var body: some View {
        GeometryReader { proxy in
            let safeRows = max(rows, 1)
            let safeCols = max(cols, 1)
            let cellWidth = proxy.size.width / CGFloat(safeCols)
            let cellHeight = proxy.size.height / CGFloat(safeRows)

            ZStack(alignment: .topLeading) {
                ForEach(0..<(safeRows * safeCols), id: \.self) { idx in
                    let row = idx / safeCols
                    let col = idx % safeCols

                    Rectangle()
                        .fill(Color(hue: Double(idx) / Double(safeRows * safeCols), saturation: 0.75, brightness: 0.95))
                        .frame(width: cellWidth, height: cellHeight)
                        .overlay {
                            Text("\(idx)")
                                .font(.caption2.monospacedDigit())
                                .foregroundStyle(.white)
                        }
                        .offset(x: CGFloat(col) * cellWidth, y: CGFloat(row) * cellHeight)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .topLeading)
        }
    }
}
