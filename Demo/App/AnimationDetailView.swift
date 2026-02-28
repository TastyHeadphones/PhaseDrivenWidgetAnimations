import SwiftUI
import PhaseDrivenAnimations

struct AnimationDetailView: View {
    @Binding var selectedKind: DemoAnimationKind

    @EnvironmentObject private var controls: DemoControls
    @State private var showingAnimationPicker = false

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    stage(height: stageHeight(for: proxy.size))
                    controlsPanel
                        .padding(.horizontal, 16)
                        .padding(.vertical, 18)
                }
            }
            .scrollIndicators(.hidden)
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        }
        .navigationTitle(selectedKind.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAnimationPicker = true
                } label: {
                    Label("Animations", systemImage: "list.bullet")
                }
            }
        }
        .sheet(isPresented: $showingAnimationPicker) {
            AnimationPickerSheet(selectedKind: $selectedKind)
        }
    }

    private func stageHeight(for size: CGSize) -> CGFloat {
        min(max(size.height * 0.56, 420), 620)
    }

    @ViewBuilder
    private func stage(height: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(
                colors: [
                    Color(red: 0.07, green: 0.15, blue: 0.26),
                    Color(red: 0.05, green: 0.12, blue: 0.21),
                    Color(red: 0.03, green: 0.1, blue: 0.17)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [Color.white.opacity(0.18), .clear],
                center: .topLeading,
                startRadius: 0,
                endRadius: 420
            )

            PhaseClockView(period: controls.period) { phase in
                DemoAnimationRenderable(kind: selectedKind, phase: phase, controls: controls)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(.horizontal, 16)
            .padding(.top, 76)
            .padding(.bottom, 28)

            VStack(alignment: .leading, spacing: 6) {
                Text(selectedKind.title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                Text(selectedKind.rawValue)
                    .font(.caption.monospaced())
                    .foregroundStyle(.white.opacity(0.75))
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
    }

    private var controlsPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            GroupBox("Timing") {
                SliderRow(title: "Period", value: $controls.period, range: 0.8...8, format: "%.2fs")
            }

            GroupBox("Motion") {
                SliderRow(title: "Amplitude", value: $controls.amplitude, range: 2...80, format: "%.1f")
                SliderRow(title: "Secondary", value: $controls.secondaryAmplitude, range: 0...60, format: "%.1f")
                SliderRow(title: "Depth", value: $controls.depth, range: 0.1...2.2, format: "%.2f")
            }

            GroupBox("Visual") {
                SliderRow(title: "Blur", value: $controls.blurRadius, range: 0...24, format: "%.1f")
                SliderRow(title: "Shimmer Band", value: $controls.shimmerBand, range: 0.1...0.8, format: "%.2f")
            }

            GroupBox("Shape / Stroke") {
                SliderRow(title: "Line Width", value: $controls.lineWidth, range: 1...22, format: "%.1f")
                SliderRow(title: "Runner Span", value: $controls.runnerSpan, range: 0.05...0.95, format: "%.2f")
                SliderRow(title: "Wave Amp", value: $controls.waveAmplitude, range: 2...40, format: "%.1f")
                SliderRow(title: "Wave Length", value: $controls.waveLength, range: 20...220, format: "%.1f")
            }

            GroupBox("Color") {
                SliderRow(title: "Hue", value: $controls.hueDegrees, range: 0...90, format: "%.1f°")
                SliderRow(title: "Sat Amp", value: $controls.saturationAmplitude, range: 0...1, format: "%.2f")
            }

            GroupBox("Sprite") {
                SliderRow(title: "FPS", value: $controls.spriteFPS, range: 1...24, format: "%.1f")
                Stepper("Rows: \(controls.spriteRows)", value: $controls.spriteRows, in: 1...8)
                Stepper("Cols: \(controls.spriteCols)", value: $controls.spriteCols, in: 1...8)
            }
        }
    }
}

private struct AnimationPickerSheet: View {
    @Binding var selectedKind: DemoAnimationKind
    @Environment(\.dismiss) private var dismiss

    private var grouped: [(String, [DemoAnimationKind])] {
        Dictionary(grouping: DemoAnimationKind.allCases, by: { $0.category })
            .map { ($0.key, $0.value.sorted(by: { $0.title < $1.title })) }
            .sorted(by: { $0.0 < $1.0 })
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(grouped, id: \.0) { category, items in
                    Section(category) {
                        ForEach(items) { kind in
                            Button {
                                selectedKind = kind
                                dismiss()
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(kind.title)
                                        Text(kind.rawValue)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    if kind == selectedKind {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.tint)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .navigationTitle("Animations")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

private struct SliderRow<Value: BinaryFloatingPoint>: View {
    let title: String
    @Binding var value: Value
    let range: ClosedRange<Value>
    let format: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                Spacer()
                Text(String(format: format, Double(value)))
                    .font(.footnote.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            Slider(
                value: Binding(
                    get: { Double(value) },
                    set: { value = Value($0) }
                ),
                in: Double(range.lowerBound)...Double(range.upperBound)
            )
        }
    }
}
