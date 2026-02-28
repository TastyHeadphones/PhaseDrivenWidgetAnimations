import SwiftUI

struct AnimationGalleryView: View {
    @Binding var selected: DemoAnimationKind

    private var grouped: [(category: String, items: [DemoAnimationKind])] {
        Dictionary(grouping: DemoAnimationKind.allCases, by: { $0.category })
            .map { ($0.key, $0.value.sorted(by: { $0.title < $1.title })) }
            .sorted(by: { $0.category < $1.category })
    }

    var body: some View {
        List {
            ForEach(grouped, id: \.category) { section in
                Section(section.category) {
                    ForEach(section.items) { kind in
                        Button {
                            selected = kind
                        } label: {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(kind.title)
                                    Text(kind.rawValue)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                if kind == selected {
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
    }
}
