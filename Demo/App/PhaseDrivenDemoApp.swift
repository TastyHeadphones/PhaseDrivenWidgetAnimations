import SwiftUI

@main
struct PhaseDrivenDemoApp: App {
    @StateObject private var controls = DemoControls()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(controls)
        }
    }
}
