// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PhaseDrivenWidgetAnimations",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PhaseDrivenAnimations",
            targets: ["PhaseDrivenAnimations"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/octree/ClockHandRotationKit.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "PhaseDrivenAnimations",
            dependencies: [
                .product(name: "ClockHandRotationKit", package: "ClockHandRotationKit")
            ]
        ),
        .testTarget(
            name: "PhaseDrivenAnimationsTests",
            dependencies: ["PhaseDrivenAnimations"]
        )
    ]
)
