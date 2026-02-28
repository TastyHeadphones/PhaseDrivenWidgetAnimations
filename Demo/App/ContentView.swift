import SwiftUI

struct ContentView: View {
    @State private var selected: DemoAnimationKind = .horizontalSwing
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        if horizontalSizeClass == .compact {
            NavigationStack {
                AnimationDetailView(selectedKind: $selected)
                    .id(selected.id)
                    .navigationBarTitleDisplayMode(.inline)
            }
        } else {
            NavigationSplitView {
                AnimationGalleryView(selected: $selected)
                    .navigationTitle("Phase Gallery")
            } detail: {
                AnimationDetailView(selectedKind: $selected)
                    .id(selected.id)
            }
        }
    }
}
