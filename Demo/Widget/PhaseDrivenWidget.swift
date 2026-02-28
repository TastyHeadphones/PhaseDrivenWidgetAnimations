import SwiftUI
import WidgetKit
import PhaseDrivenAnimations

struct PhaseDrivenEntry: TimelineEntry {
    let date: Date
    let phase: Double
    let animation: DemoAnimationKind
}

private enum WidgetTimelineFactory {
    static let driver = ClockHandPhaseDriver(period: 8)
    static let strategy = WidgetPhaseFallbackStrategy.sampled(every: 5)
    static let speedMultiplier = 3.0

    static func makeEntries(
        from currentDate: Date,
        animation: DemoAnimationKind,
        horizon: TimeInterval = 2 * 60 * 60
    ) -> [PhaseDrivenEntry] {
        let dates = strategy.timelineDates(from: currentDate, horizon: horizon, driver: driver)
        return dates.map { date in
            let phase = speedAdjusted(strategy.phase(for: date, driver: driver))
            return PhaseDrivenEntry(date: date, phase: phase, animation: animation)
        }
    }

    static func snapshot(animation: DemoAnimationKind, date: Date = Date()) -> PhaseDrivenEntry {
        let phase = speedAdjusted(strategy.phase(for: date, driver: driver))
        return PhaseDrivenEntry(date: date, phase: phase, animation: animation)
    }

    private static func speedAdjusted(_ phase: Double) -> Double {
        ClockHandPhaseDriver.wrapPhase(phase * speedMultiplier)
    }
}

struct PhaseDrivenIntentProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> PhaseDrivenEntry {
        WidgetTimelineFactory.snapshot(animation: .horizontalSwing)
    }

    func snapshot(for configuration: PhaseAnimationSelectionIntent, in context: Context) async -> PhaseDrivenEntry {
        WidgetTimelineFactory.snapshot(animation: (configuration.animation ?? .horizontalSwing).demoKind)
    }

    func timeline(for configuration: PhaseAnimationSelectionIntent, in context: Context) async -> Timeline<PhaseDrivenEntry> {
        let selected = (configuration.animation ?? .horizontalSwing).demoKind
        let entries = WidgetTimelineFactory.makeEntries(from: Date(), animation: selected)
        let refresh = entries.last?.date.addingTimeInterval(5) ?? Date().addingTimeInterval(5)
        return Timeline(entries: entries, policy: .after(refresh))
    }
}

struct PhaseDrivenWidgetEntryView: View {
    var entry: PhaseDrivenEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(entry.animation.title)
                .font(.caption2.weight(.semibold))
                .lineLimit(1)
                .foregroundStyle(.secondary)

            WidgetAnimationRenderable(kind: entry.animation, phase: entry.phase)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .widgetSwing(duration: 4, direction: .horizontal, distance: 96)
                .widgetSwing(duration: 1.2, direction: .vertical, distance: 24)
        }
        .animation(.easeInOut(duration: 0.9), value: entry.phase)
        .padding(12)
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [Color(uiColor: .secondarySystemBackground), Color(uiColor: .systemBackground)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

struct PhaseDrivenWidget: Widget {
    private let kind = "PhaseDrivenWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: PhaseAnimationSelectionIntent.self,
            provider: PhaseDrivenIntentProvider()
        ) { entry in
            PhaseDrivenWidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .configurationDisplayName("Phase Animations")
        .description("Phase-driven widget snapshots with selectable animation type.")
    }
}

#Preview(as: .systemSmall) {
    PhaseDrivenWidget()
} timeline: {
    WidgetTimelineFactory.snapshot(animation: .horizontalSwing)
    WidgetTimelineFactory.snapshot(animation: .progressRing)
}
