import XCTest

/// An app a UI test launches, holding the arguments its next launch passes.
/// `XCUIApplication` is one; a unit test can stand in its own, since
/// `XCUIApplication` runs only in a UI test bundle.
@MainActor
public protocol FlagLaunching: AnyObject {
    var launchArguments: [String] { get set }
}

extension FlagLaunching {
    /// Appends `overrides` to `launchArguments`, after any arguments already set,
    /// so the next launch forces those flags.
    public func overrideFlags(_ overrides: FlagOverride...) {
        launchArguments += FlagLaunch.arguments(overrides)
    }
}

extension XCUIApplication: FlagLaunching {}
