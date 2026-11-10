### 2026.11.10.1630

> A test forces flags at launch with one helper, spelled the way the store reads them.

- Feat: the `FeatureFlagKitTesting` product, on the core only, and the one target that imports XCTest.
- Feat: `FlagLaunch.arguments` and `FlagLaunch.environment` turn `FlagOverride` values into launch arguments and environment.
- Feat: `overrideFlags` and `overrideFlagsInEnvironment` on `XCUIApplication` add overrides, keeping the arguments and variables already set.
- Feat: `FlagValue.flagText` writes a value as launch text its type reads back, and `FlagEncoding.environment` spells one variable.
- Docs: requirement 0007, the README's Test section and the architecture views.
