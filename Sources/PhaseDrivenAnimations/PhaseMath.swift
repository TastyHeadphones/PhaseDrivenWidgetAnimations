import Foundation
import SwiftUI

public enum PhaseMath {
    public static let twoPi = Double.pi * 2

    public static func wrap(_ phase: Double) -> Double {
        let remainder = phase.truncatingRemainder(dividingBy: 1)
        return remainder >= 0 ? remainder : remainder + 1
    }

    public static func radians(_ phase: Double) -> Double {
        wrap(phase) * twoPi
    }

    public static func oscillating(_ phase: Double, min: Double = -1, max: Double = 1) -> Double {
        let normalized = (sin(radians(phase)) + 1) * 0.5
        return min + (max - min) * normalized
    }

    public static func triangle(_ phase: Double) -> Double {
        let p = wrap(phase)
        return p < 0.5 ? p * 2 : (1 - p) * 2
    }

    public static func easeOutBounce(_ phase: Double) -> Double {
        let x = wrap(phase)
        if x < 1 / 2.75 {
            return 7.5625 * x * x
        } else if x < 2 / 2.75 {
            let t = x - 1.5 / 2.75
            return 7.5625 * t * t + 0.75
        } else if x < 2.5 / 2.75 {
            let t = x - 2.25 / 2.75
            return 7.5625 * t * t + 0.9375
        } else {
            let t = x - 2.625 / 2.75
            return 7.5625 * t * t + 0.984375
        }
    }

    public static func clamp<T: Comparable>(_ value: T, min: T, max: T) -> T {
        Swift.min(Swift.max(value, min), max)
    }
}

public struct PhaseMapper: Sendable {
    public init() {}

    public func unit(_ phase: Double) -> Double {
        PhaseMath.wrap(phase)
    }

    public func radians(_ phase: Double) -> Double {
        PhaseMath.radians(phase)
    }

    public func range(_ phase: Double, from lower: Double, to upper: Double) -> Double {
        lower + (upper - lower) * PhaseMath.wrap(phase)
    }

    public func oscillation(_ phase: Double, amplitude: Double) -> Double {
        sin(PhaseMath.radians(phase)) * amplitude
    }
}
