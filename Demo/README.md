# Demo App + Widget

Generate the Xcode project from this folder:

```bash
xcodegen generate --spec project.yml
```

Then open `PhaseDrivenDemo.xcodeproj` and run the `PhaseDrivenDemoApp` scheme.

The widget includes:
- `AppIntentConfiguration` (animation type selector)

The fallback phase behavior uses sampled timeline entries from `PhaseDrivenAnimations` (`WidgetPhaseFallbackStrategy`), not continuous frame updates, which keeps WidgetKit efficient and deterministic.
