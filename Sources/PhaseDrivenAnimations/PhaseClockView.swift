import SwiftUI
import Foundation
@preconcurrency import ClockHandRotationKit

public enum ClockHandRotationDirection: Sendable {
    case clockwise
    case counterClockwise

    var sign: Double {
        switch self {
        case .clockwise:
            return 1
        case .counterClockwise:
            return -1
        }
    }
}

/// Clock-hand phase model driven by `ClockHandRotationKit` periods.
public struct ClockHandPhaseDriver: Equatable {
    public var clockPeriod: ClockHandRotationPeriod
    public var phaseOffset: Double
    public var direction: ClockHandRotationDirection
    public var timeZone: TimeZone

    public init(
        period: TimeInterval,
        phaseOffset: Double = 0,
        direction: ClockHandRotationDirection = .clockwise,
        timeZone: TimeZone = .current
    ) {
        self.clockPeriod = .custom(abs(period))
        self.phaseOffset = phaseOffset
        self.direction = direction
        self.timeZone = timeZone
    }

    public init(
        clockPeriod: ClockHandRotationPeriod,
        phaseOffset: Double = 0,
        direction: ClockHandRotationDirection = .clockwise,
        timeZone: TimeZone = .current
    ) {
        self.clockPeriod = clockPeriod
        self.phaseOffset = phaseOffset
        self.direction = direction
        self.timeZone = timeZone
    }

    /// Returns a wrapped phase in `[0, 1)` for a given date.
    public func phase(at date: Date = Date()) -> Double {
        let base = Self.basePhase(for: date, period: clockPeriod, timeZone: timeZone)
        return Self.wrapPhase(base * direction.sign + phaseOffset)
    }

    /// Returns radians in `[0, 2π)` for a given date.
    public func radians(at date: Date = Date()) -> Double {
        Self.radians(for: phase(at: date))
    }

    public static func wrapPhase(_ value: Double) -> Double {
        let remainder = value.truncatingRemainder(dividingBy: 1)
        return remainder >= 0 ? remainder : remainder + 1
    }

    public static func radians(for phase: Double) -> Double {
        wrapPhase(phase) * 2 * .pi
    }

    private static func basePhase(for date: Date, period: ClockHandRotationPeriod, timeZone: TimeZone) -> Double {
        switch period {
        case let .custom(duration):
            let safe = max(abs(duration), 0.000_001)
            return wrapPhase(date.timeIntervalSince1970 / safe)
        case .secondHand:
            let calendar = Calendar(identifier: .gregorian)
            let components = calendar.dateComponents(in: timeZone, from: date)
            let second = Double(components.second ?? 0)
            let nanosecond = Double(components.nanosecond ?? 0)
            return wrapPhase((second + nanosecond / 1_000_000_000) / 60)
        case .minuteHand:
            let calendar = Calendar(identifier: .gregorian)
            let components = calendar.dateComponents(in: timeZone, from: date)
            let minute = Double(components.minute ?? 0)
            let second = Double(components.second ?? 0)
            return wrapPhase((minute + second / 60) / 60)
        case .hourHand:
            let calendar = Calendar(identifier: .gregorian)
            let components = calendar.dateComponents(in: timeZone, from: date)
            let hour = Double((components.hour ?? 0) % 12)
            let minute = Double(components.minute ?? 0)
            return wrapPhase((hour + minute / 60) / 12)
        @unknown default:
            return wrapPhase(date.timeIntervalSince1970 / 60)
        }
    }
}

/// WidgetKit snapshots are not rendered continuously.
public enum WidgetPhaseFallbackStrategy: Equatable {
    case fixed(phase: Double)
    case sampled(every: TimeInterval)
    case entriesPerCycle(Int)

    public func phase(for date: Date, driver: ClockHandPhaseDriver) -> Double {
        switch self {
        case let .fixed(phase):
            return ClockHandPhaseDriver.wrapPhase(phase)
        case let .sampled(interval):
            let snapped = snap(date: date, interval: interval)
            return driver.phase(at: snapped)
        case let .entriesPerCycle(count):
            let safeCount = max(count, 1)
            let interval = max(driver.periodDuration / Double(safeCount), 0.001)
            let snapped = snap(date: date, interval: interval)
            return driver.phase(at: snapped)
        }
    }

    public func timelineDates(
        from startDate: Date,
        horizon: TimeInterval,
        driver: ClockHandPhaseDriver
    ) -> [Date] {
        switch self {
        case .fixed:
            return [startDate]
        case let .sampled(interval):
            return sampledDates(from: startDate, horizon: horizon, interval: interval)
        case let .entriesPerCycle(count):
            let safeCount = max(count, 1)
            let interval = max(driver.periodDuration / Double(safeCount), 0.001)
            return sampledDates(from: startDate, horizon: horizon, interval: interval)
        }
    }

    private func sampledDates(from start: Date, horizon: TimeInterval, interval: TimeInterval) -> [Date] {
        let safeInterval = max(interval, 0.001)
        let end = start.addingTimeInterval(max(horizon, 0))
        var current = snap(date: start, interval: safeInterval)
        var result: [Date] = []

        while current <= end {
            result.append(current)
            current = current.addingTimeInterval(safeInterval)
        }

        if result.isEmpty {
            result = [start]
        }

        return result
    }

    private func snap(date: Date, interval: TimeInterval) -> Date {
        let safeInterval = max(interval, 0.001)
        let seconds = date.timeIntervalSince1970
        let snapped = floor(seconds / safeInterval) * safeInterval
        return Date(timeIntervalSince1970: snapped)
    }
}

public typealias PhaseClockDriver = ClockHandPhaseDriver
public typealias PhaseClockDirection = ClockHandRotationDirection
public typealias PhaseWidgetFallbackStrategy = WidgetPhaseFallbackStrategy

private extension ClockHandPhaseDriver {
    var periodDuration: TimeInterval {
        switch clockPeriod {
        case let .custom(duration):
            return max(abs(duration), 0.000_001)
        case .secondHand:
            return 60
        case .minuteHand:
            return 3600
        case .hourHand:
            return 43_200
        @unknown default:
            return 60
        }
    }

    var timelineInterval: TimeInterval {
        max(periodDuration / 240, 1.0 / 60)
    }
}

public struct PhaseClockView<Content: View>: View {
    private let driver: ClockHandPhaseDriver
    private let content: (Double) -> Content

    public init(
        driver: ClockHandPhaseDriver,
        @ViewBuilder content: @escaping (Double) -> Content
    ) {
        self.driver = driver
        self.content = content
    }

    public init(
        period: TimeInterval,
        phaseOffset: Double = 0,
        direction: ClockHandRotationDirection = .clockwise,
        timeZone: TimeZone = .current,
        @ViewBuilder content: @escaping (Double) -> Content
    ) {
        self.driver = ClockHandPhaseDriver(
            period: period,
            phaseOffset: phaseOffset,
            direction: direction,
            timeZone: timeZone
        )
        self.content = content
    }

    public var body: some View {
        TimelineView(.animation(minimumInterval: driver.timelineInterval, paused: false)) { timeline in
            content(driver.phase(at: timeline.date))
        }
    }
}
