# PhaseDrivenWidgetAnimations

iOS 17+ / Swift 5.9 reference repository for phase-driven SwiftUI animations, including app and widget demos.

## What is included

- `PhaseDrivenAnimations` SPM library
  - Position, rotation/3D, scale, visual, shape/stroke, color/gradient, and sprite animations
  - `AnimatableModifier` / geometry-based implementations
  - Built-in clock-phase primitives:
    - `ClockHandPhaseDriver`
    - `ClockHandPhaseTicker`
    - `WidgetPhaseFallbackStrategy`
- Demo app + widget extension
  - Animation gallery with parameter controls
  - AppIntents widget animation selection

## Dependencies

- [ClockHandRotationKit](https://github.com/octree/ClockHandRotationKit) for rotation effects

## Setup

```bash
Scripts/bootstrap.sh
```

This generates `Demo/PhaseDrivenDemo.xcodeproj` (if `xcodegen` is installed) and resolves package dependencies.

## Widget fallback strategy

Home Screen widgets are timeline-driven, not continuously rendered. The demo uses sampled timeline entries via `WidgetPhaseFallbackStrategy` so widget state stays deterministic and clock-like.
