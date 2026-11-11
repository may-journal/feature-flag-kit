// swift-tools-version: 6.2
// The core product. See docs/architecture/04-code.md#platforms for the versions it states.
import PackageDescription

let package = Package(
    name: "FeatureFlagKit",
    platforms: [.iOS(.v26), .macOS(.v26)],
    products: [
        .library(name: "FeatureFlagKit", targets: ["FeatureFlagKit"]),
        .library(name: "FeatureFlagKitUI", targets: ["FeatureFlagKitUI"]),
        // For test targets only: the one target that imports XCTest.
        .library(name: "FeatureFlagKitTesting", targets: ["FeatureFlagKitTesting"]),
    ],
    dependencies: [
        .package(url: "https://github.com/may-journal/apple-ui-testing-library", from: "1.7.2")
    ],
    targets: [
        .target(name: "FeatureFlagKit"),
        .target(name: "FeatureFlagKitUI", dependencies: ["FeatureFlagKit"]),
        .target(name: "FeatureFlagKitTesting", dependencies: ["FeatureFlagKit"]),
        .testTarget(
            name: "FeatureFlagKitTests",
            dependencies: [
                "FeatureFlagKit",
                "FeatureFlagKitUI",
                "FeatureFlagKitTesting",
                .product(name: "UITestingLibrary", package: "apple-ui-testing-library"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
