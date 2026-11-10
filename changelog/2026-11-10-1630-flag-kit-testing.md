### 2026.11.10.1630

> A test forces flags at launch with one helper, spelled the way the store reads them.

- Feat: the `FeatureFlagKitTesting` product, on the core only, and the one target that imports XCTest.
- Feat: `FlagLaunch.arguments` and `FlagLaunch.environment` turn `FlagOverride` values into launch arguments and environment.
- Feat: `overrideFlags` on `XCUIApplication` appends overrides to its launch arguments, keeping those already set.
- Docs: requirement 0007, the README's Test section and the architecture views.
