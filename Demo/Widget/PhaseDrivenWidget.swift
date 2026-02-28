import SwiftUI
import WidgetKit

struct PhaseDrivenEntry: TimelineEntry {
    let date: Date
    let animation: DemoAnimationKind
}

private enum WidgetTimelineFactory {
    static func makeEntries(
        from currentDate: Date,
        animation: DemoAnimationKind,
        horizon: TimeInterval = 6 * 60 * 60
    ) -> [PhaseDrivenEntry] {
        let interval: TimeInterval = 30 * 60
        let end = currentDate.addingTimeInterval(horizon)
        var entries: [PhaseDrivenEntry] = []
        var pointer = currentDate

        while pointer <= end {
            entries.append(PhaseDrivenEntry(date: pointer, animation: animation))
            pointer = pointer.addingTimeInterval(interval)
        }

        return entries
    }

    static func snapshot(animation: DemoAnimationKind, date: Date = Date()) -> PhaseDrivenEntry {
        PhaseDrivenEntry(date: date, animation: animation)
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
        let refresh = entries.last?.date.addingTimeInterval(30 * 60) ?? Date().addingTimeInterval(30 * 60)
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

            WidgetAnimationRenderable(kind: entry.animation)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
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
