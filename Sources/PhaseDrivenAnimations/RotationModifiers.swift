import SwiftUI
import ClockHandRotationKit

private enum ClockHandRotationTiming {
    static let minimumDuration: CGFloat = 0.1
    static let defaultCycleDuration: CGFloat = 6

    static func spinPeriod(turnsPerCycle: Double, cycleDuration: CGFloat) -> CGFloat? {
        guard turnsPerCycle != 0 else {
            return nil
        }

        let duration = max(minimumDuration, abs(cycleDuration / CGFloat(turnsPerCycle)))
        return turnsPerCycle >= 0 ? duration : -duration
    }

    static func pendulumPeriod(cyclesPerTurn: Double, cycleDuration: CGFloat) -> CGFloat? {
        guard cyclesPerTurn != 0 else {
            return nil
        }

        let duration = max(minimumDuration, abs(cycleDuration / CGFloat(cyclesPerTurn)))
        return cyclesPerTurn >= 0 ? duration : -duration
    }
}

private enum ClockHandPendulumDirection {
    case horizontal
    case vertical
}

private enum ClockHandPendulumMath {
    static func direction(for anchor: UnitPoint) -> ClockHandPendulumDirection {
        if anchor.y <= 0.05 || anchor.y >= 0.95 {
            return .horizontal
        }
        return .vertical
    }

    static func distance(maxAngle: Angle, anchor: UnitPoint) -> CGFloat {
        let magnitude = max(2, CGFloat(abs(maxAngle.radians)) * 96)
        let angleSign: CGFloat = maxAngle.radians >= 0 ? 1 : -1
        let anchorSign: CGFloat = (anchor.x >= 0.95 || anchor.y >= 0.95) ? -1 : 1
        return magnitude * angleSign * anchorSign
    }
}

private struct ClockHandSwingModifier: ViewModifier {
    let duration: CGFloat
    let direction: ClockHandPendulumDirection
    let distance: CGFloat

    private var alignment: Alignment {
        if direction == .vertical {
            return distance > 0 ? .top : .bottom
        }
        return distance > 0 ? .leading : .trailing
    }

    @ViewBuilder
    private func overlay(content: Content) -> some View {
        let alignment = alignment

        GeometryReader { proxy in
            let size = proxy.size
            let extendLength = direction == .vertical ? size.height : size.width
            let length: CGFloat = abs(distance) + extendLength
            let innerDiameter = (length + extendLength) / 2
            let outerAlignment: Alignment = {
                if direction == .vertical {
                    return distance > 0 ? .bottom : .top
                }
                return distance > 0 ? .trailing : .leading
            }()

            ZStack(alignment: outerAlignment) {
                Color.clear
                ZStack(alignment: alignment) {
                    Color.clear
                    ZStack(alignment: alignment) {
                        Color.clear
                        content.clockHandRotationEffect(period: .custom(duration))
                    }
                    .frame(width: innerDiameter, height: innerDiameter)
                    .clockHandRotationEffect(period: .custom(-duration / 2))
                }
                .frame(width: length, height: length)
                .clockHandRotationEffect(period: .custom(duration))
            }
            .frame(width: size.width, height: size.height, alignment: alignment)
        }
    }

    func body(content: Content) -> some View {
        content.hidden()
            .overlay(overlay(content: content))
    }
}

public struct ContinuousSpinModifier: AnimatableModifier {
    public var phase: Double
    public var turnsPerCycle: Double
    public var cycleDuration: CGFloat

    public init(
        phase: Double,
        turnsPerCycle: Double = 1,
        cycleDuration: CGFloat = 6
    ) {
        self.phase = phase
        self.turnsPerCycle = turnsPerCycle
        self.cycleDuration = cycleDuration
    }

    public var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }

    @ViewBuilder
    public func body(content: Content) -> some View {
        if let period = ClockHandRotationTiming.spinPeriod(turnsPerCycle: turnsPerCycle, cycleDuration: cycleDuration) {
            content.clockHandRotationEffect(period: .custom(period))
        } else {
            content
        }
    }
}

public struct PendulumSwingRotationModifier: AnimatableModifier {
    public var phase: Double
    public var maxAngle: Angle
    public var cyclesPerTurn: Double
    public var anchor: UnitPoint
    public var cycleDuration: CGFloat

    public init(
        phase: Double,
        maxAngle: Angle = .degrees(20),
        cyclesPerTurn: Double = 1,
        anchor: UnitPoint = .top,
        cycleDuration: CGFloat = 6
    ) {
        self.phase = phase
        self.maxAngle = maxAngle
        self.cyclesPerTurn = cyclesPerTurn
        self.anchor = anchor
        self.cycleDuration = cycleDuration
    }

    public var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }

    @ViewBuilder
    public func body(content: Content) -> some View {
        if let period = ClockHandRotationTiming.pendulumPeriod(cyclesPerTurn: cyclesPerTurn, cycleDuration: cycleDuration) {
            content.modifier(
                ClockHandSwingModifier(
                    duration: period,
                    direction: ClockHandPendulumMath.direction(for: anchor),
                    distance: ClockHandPendulumMath.distance(maxAngle: maxAngle, anchor: anchor)
                )
            )
        } else {
            content
        }
    }
}

public struct CardTilt3DModifier: AnimatableModifier {
    public var phase: Double
    public var maxX: Angle
    public var maxY: Angle
    public var perspective: CGFloat

    public init(
        phase: Double,
        maxX: Angle = .degrees(6),
        maxY: Angle = .degrees(8),
        perspective: CGFloat = 0.7
    ) {
        self.phase = phase
        self.maxX = maxX
        self.maxY = maxY
        self.perspective = perspective
    }

    public var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }

    public func body(content: Content) -> some View {
        let theta = PhaseMath.radians(phase)
        let x = sin(theta) * maxX.degrees
        let y = cos(theta * 0.9) * maxY.degrees

        return content
            .rotation3DEffect(.degrees(x), axis: (x: 1, y: 0, z: 0), perspective: perspective)
            .rotation3DEffect(.degrees(y), axis: (x: 0, y: 1, z: 0), perspective: perspective)
    }
}

public extension View {
    func phaseContinuousSpin(
        _ phase: Double,
        turnsPerCycle: Double = 1,
        cycleDuration: CGFloat = 6
    ) -> some View {
        modifier(ContinuousSpinModifier(phase: phase, turnsPerCycle: turnsPerCycle, cycleDuration: cycleDuration))
    }

    func phasePendulumRotation(
        _ phase: Double,
        maxAngle: Angle = .degrees(20),
        cyclesPerTurn: Double = 1,
        anchor: UnitPoint = .top,
        cycleDuration: CGFloat = 6
    ) -> some View {
        modifier(
            PendulumSwingRotationModifier(
                phase: phase,
                maxAngle: maxAngle,
                cyclesPerTurn: cyclesPerTurn,
                anchor: anchor,
                cycleDuration: cycleDuration
            )
        )
    }

    func phaseCardTilt3D(
        _ phase: Double,
        maxX: Angle = .degrees(6),
        maxY: Angle = .degrees(8),
        perspective: CGFloat = 0.7
    ) -> some View {
        modifier(CardTilt3DModifier(phase: phase, maxX: maxX, maxY: maxY, perspective: perspective))
    }
}
