import SwiftUI

final class DemoControls: ObservableObject {
    @Published var period: TimeInterval = 2.4
    @Published var amplitude: CGFloat = 18
    @Published var secondaryAmplitude: CGFloat = 10
    @Published var depth: CGFloat = 1.0

    @Published var blurRadius: CGFloat = 10
    @Published var shimmerBand: CGFloat = 0.28

    @Published var lineWidth: CGFloat = 8
    @Published var runnerSpan: Double = 0.22

    @Published var waveAmplitude: CGFloat = 10
    @Published var waveLength: CGFloat = 72

    @Published var hueDegrees: Double = 24
    @Published var saturationAmplitude: Double = 0.35

    @Published var spriteFPS: Double = 8
    @Published var spriteRows: Int = 4
    @Published var spriteCols: Int = 4

    var sampleSequenceColors: [Color] {
        [.red, .orange, .yellow, .green, .cyan, .blue, .indigo, .pink]
    }
}
