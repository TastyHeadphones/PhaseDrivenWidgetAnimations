import Foundation
import AppIntents

enum WidgetAnimationOption: String, CaseIterable, AppEnum {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Animation"

    static var caseDisplayRepresentations: [WidgetAnimationOption: DisplayRepresentation] = [
        .horizontalSwing: "Horizontal Swing",
        .verticalSwing: "Vertical Swing",
        .shakeJitter: "Shake / Jitter",
        .orbit: "Orbit",
        .parallaxDrift: "Parallax Drift",
        .continuousSpin: "Continuous Spin",
        .pendulumRotation: "Pendulum Rotation",
        .cardTilt3D: "Card Tilt 3D",
        .breathingScale: "Breathing Scale",
        .bounceScale: "Bounce Scale",
        .squashStretch: "Squash & Stretch",
        .opacityPulse: "Opacity Pulse",
        .blurPulse: "Blur Pulse",
        .shimmerSweep: "Shimmer Sweep",
        .strokeRunner: "Stroke Runner",
        .progressRing: "Progress Ring",
        .phaseWave: "Phase Wave",
        .gradientShift: "Gradient Shift",
        .hueSaturation: "Hue / Saturation",
        .blobBackground: "Blob Background",
        .spriteSheet: "Sprite Sheet",
        .imageSequence: "Image Sequence"
    ]

    case horizontalSwing
    case verticalSwing
    case shakeJitter
    case orbit
    case parallaxDrift

    case continuousSpin
    case pendulumRotation
    case cardTilt3D

    case breathingScale
    case bounceScale
    case squashStretch

    case opacityPulse
    case blurPulse
    case shimmerSweep

    case strokeRunner
    case progressRing
    case phaseWave

    case gradientShift
    case hueSaturation
    case blobBackground

    case spriteSheet
    case imageSequence

    var demoKind: DemoAnimationKind {
        DemoAnimationKind(rawValue: rawValue) ?? .horizontalSwing
    }
}

struct WidgetAnimationOptionsProvider: DynamicOptionsProvider {
    func results() async throws -> [WidgetAnimationOption] {
        WidgetAnimationOption.allCases
    }
}

struct PhaseAnimationSelectionIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Phase Animation"
    static var description = IntentDescription("Choose which animation this widget renders.")
    static var parameterSummary: some ParameterSummary {
        Summary("Animation: \(\.$animation)")
    }

    @Parameter(title: "Animation", optionsProvider: WidgetAnimationOptionsProvider())
    var animation: WidgetAnimationOption?

    init() {
        animation = .continuousSpin
    }
}
