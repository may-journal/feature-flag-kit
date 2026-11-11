import XCTest

/// An app a UI test launches, holding the arguments and environment its next
/// launch passes. `XCUIApplication` is one; a unit test can stand in its own,
/// since `XCUIApplication` runs only in a UI test bundle.
@MainActor
public protocol FlagLaunching: AnyObject {
    var launchArguments: [String] { get set }
    var launchEnvironment: [String: String] { get set }
}

extension FlagLaunching {
    /// Appends `overrides` to `launchArguments`, after any arguments already set,
    /// so the next launch forces those flags.
    public func overrideFlags(_ overrides: FlagOverride...) {
        launchArguments += FlagLaunch.arguments(overrides)
    }

    /// Merges `overrides` into `launchEnvironment`, keeping every other variable,
    /// so the next launch forces those flags.
    public func overrideFlagsInEnvironment(_ overrides: FlagOverride...) {
        launchEnvironment.merge(FlagLaunch.environment(overrides)) { _, override in override }
    }
}

extension XCUIApplication: FlagLaunching {}
