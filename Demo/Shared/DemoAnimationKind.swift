import Foundation

enum DemoAnimationKind: String, CaseIterable, Identifiable, Codable {
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

    var id: String { rawValue }

    var title: String {
        switch self {
        case .horizontalSwing:
            return "Horizontal Swing"
        case .verticalSwing:
            return "Vertical Swing"
        case .shakeJitter:
            return "Shake / Jitter"
        case .orbit:
            return "Circular / Elliptical Orbit"
        case .parallaxDrift:
            return "Parallax Drift"
        case .continuousSpin:
            return "Continuous Spin"
        case .pendulumRotation:
            return "Pendulum Rotation"
        case .cardTilt3D:
            return "Card Tilt 3D"
        case .breathingScale:
            return "Breathing Scale"
        case .bounceScale:
            return "Bounce Scale"
        case .squashStretch:
            return "Squash & Stretch"
        case .opacityPulse:
            return "Opacity Pulse"
        case .blurPulse:
            return "Blur Pulse"
        case .shimmerSweep:
            return "Shimmer Sweep"
        case .strokeRunner:
            return "Stroke Runner"
        case .progressRing:
            return "Progress Ring"
        case .phaseWave:
            return "Phase Wave"
        case .gradientShift:
            return "Gradient Shift"
        case .hueSaturation:
            return "Hue / Saturation"
        case .blobBackground:
            return "Blob Background"
        case .spriteSheet:
            return "Sprite Sheet"
        case .imageSequence:
            return "Image Sequence"
        }
    }

    var category: String {
        switch self {
        case .horizontalSwing, .verticalSwing, .shakeJitter, .orbit, .parallaxDrift:
            return "Position"
        case .continuousSpin, .pendulumRotation, .cardTilt3D:
            return "Rotation / 3D"
        case .breathingScale, .bounceScale, .squashStretch:
            return "Scale"
        case .opacityPulse, .blurPulse, .shimmerSweep:
            return "Visual"
        case .strokeRunner, .progressRing, .phaseWave:
            return "Shape / Stroke"
        case .gradientShift, .hueSaturation, .blobBackground:
            return "Color / Gradient"
        case .spriteSheet, .imageSequence:
            return "Sprite"
        }
    }
}
