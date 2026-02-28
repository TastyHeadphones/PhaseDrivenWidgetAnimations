import SwiftUI
import Foundation
import Combine
#if os(iOS) || os(tvOS)
import QuartzCore
#endif

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

public struct ClockHandPhaseDriver: Sendable, Equatable {
    public var period: TimeInterval
    public var referenceDate: Date
    public var phaseOffset: Double
    public var direction: ClockHandRotationDirection

    public init(
        period: TimeInterval,
        referenceDate: Date = .init(timeIntervalSince1970: 0),
        phaseOffset: Double = 0,
        direction: ClockHandRotationDirection = .clockwise
    ) {
        self.period = max(period, 0.000_001)
        self.referenceDate = referenceDate
        self.phaseOffset = phaseOffset
        self.direction = direction
    }

    public func phase(at date: Date = Date()) -> Double {
        let elapsed = date.timeIntervalSince(referenceDate)
        let raw = (elapsed / period) * direction.sign + phaseOffset
        return Self.wrapPhase(raw)
    }

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
}

public enum WidgetPhaseFallbackStrategy: Sendable, Equatable {
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
            let interval = max(driver.period / Double(safeCount), 0.001)
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
            let interval = max(driver.period / Double(safeCount), 0.001)
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

@MainActor
public final class ClockHandPhaseTicker: ObservableObject {
    public enum UpdateMode: Sendable, Equatable {
        case displayLink
        case timer(hz: Double)
    }

    @Published public private(set) var phase: Double
    @Published public private(set) var radians: Double

    public let driver: ClockHandPhaseDriver
    public let mode: UpdateMode

    private let dateProvider: @Sendable () -> Date
    private var timer: Timer?
#if os(iOS) || os(tvOS)
    private var displayLink: CADisplayLink?
    private var displayLinkProxy: DisplayLinkProxy?
#endif

    public init(
        driver: ClockHandPhaseDriver,
        mode: UpdateMode = .displayLink,
        dateProvider: @escaping @Sendable () -> Date = { Date() }
    ) {
        self.driver = driver
        self.mode = mode
        self.dateProvider = dateProvider

        let now = dateProvider()
        self.phase = driver.phase(at: now)
        self.radians = driver.radians(at: now)
    }

    deinit {
        timer?.invalidate()
#if os(iOS) || os(tvOS)
        displayLink?.invalidate()
#endif
    }

    public func start() {
        stop()
        tick()

        switch mode {
        case .displayLink:
#if os(iOS) || os(tvOS)
            let proxy = DisplayLinkProxy(owner: self)
            let link = CADisplayLink(target: proxy, selector: #selector(DisplayLinkProxy.tick))
            link.add(to: .main, forMode: .common)
            displayLinkProxy = proxy
            displayLink = link
#else
            startTimer(hz: 60)
#endif
        case let .timer(hz):
            startTimer(hz: hz)
        }
    }

    public func stop() {
        timer?.invalidate()
        timer = nil
#if os(iOS) || os(tvOS)
        displayLink?.invalidate()
        displayLink = nil
        displayLinkProxy = nil
#endif
    }

    public func tick() {
        let now = dateProvider()
        phase = driver.phase(at: now)
        radians = driver.radians(at: now)
    }

    private func startTimer(hz: Double) {
        let interval = 1.0 / max(hz, 1)
        let timer = Timer(timeInterval: interval, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.tick()
            }
        }

        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }
}

#if os(iOS) || os(tvOS)
@MainActor
private final class DisplayLinkProxy: NSObject {
    weak var owner: ClockHandPhaseTicker?

    init(owner: ClockHandPhaseTicker) {
        self.owner = owner
    }

    @objc
    func tick() {
        owner?.tick()
    }
}
#endif

public typealias PhaseClockDriver = ClockHandPhaseDriver
public typealias PhaseClockDirection = ClockHandRotationDirection
public typealias PhaseWidgetFallbackStrategy = WidgetPhaseFallbackStrategy

public struct PhaseClockView<Content: View>: View {
    @StateObject private var ticker: ClockHandPhaseTicker
    private let content: (Double) -> Content

    public init(
        driver: ClockHandPhaseDriver,
        mode: ClockHandPhaseTicker.UpdateMode = .displayLink,
        @ViewBuilder content: @escaping (Double) -> Content
    ) {
        _ticker = StateObject(wrappedValue: ClockHandPhaseTicker(driver: driver, mode: mode))
        self.content = content
    }

    public init(
        period: TimeInterval,
        phaseOffset: Double = 0,
        direction: ClockHandRotationDirection = .clockwise,
        mode: ClockHandPhaseTicker.UpdateMode = .displayLink,
        @ViewBuilder content: @escaping (Double) -> Content
    ) {
        let driver = ClockHandPhaseDriver(period: period, phaseOffset: phaseOffset, direction: direction)
        _ticker = StateObject(wrappedValue: ClockHandPhaseTicker(driver: driver, mode: mode))
        self.content = content
    }

    public var body: some View {
        content(ticker.phase)
            .onAppear {
                ticker.start()
            }
            .onDisappear {
                ticker.stop()
            }
    }
}
