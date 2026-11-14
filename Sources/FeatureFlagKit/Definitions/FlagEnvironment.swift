import Foundation

/// Who sees a build: the developer, the team's testers, or everyone, as the app declares it.
/// The name differs from SwiftUI's `Environment`, so an app can import both.
public enum FlagEnvironment: String, Sendable, Hashable, CaseIterable, CustomStringConvertible {
    /// A build from Xcode, on a simulator or the developer's own device.
    case debug
    /// A build the team tests before release, such as TestFlight.
    case `internal`
    /// The build everyone gets from the App Store.
    case production

    /// The Info.plist key an app sets per build configuration to one of the raw values.
    public static let infoPlistKey = "FeatureFlagEnvironment"

    public var description: String { rawValue }

    /// Whether launch arguments and environment variables can force a flag in this build.
    /// They can't in production, where only the user's own settings change a flag.
    public var takesOverrides: Bool { self != .production }

    /// The environment `bundle` names under `infoPlistKey`, or, when it names none, debug
    /// in a `DEBUG` build and production otherwise.
    static func reading(_ bundle: Bundle) -> (FlagEnvironment, FlagEnvironmentSource) {
        if let text = bundle.object(forInfoDictionaryKey: infoPlistKey) as? String,
            let named = FlagEnvironment(rawValue: text)
        {
            return (named, .infoPlist)
        }
        #if DEBUG
        return (.debug, .debugBuild)
        #else
        return (.production, .releaseBuild)
        #endif
    }
}

/// Where a store's environment came from, so a debug screen can say why it is what it is.
public enum FlagEnvironmentSource: String, Sendable, Hashable, CustomStringConvertible {
    /// The app's Info.plist key.
    case infoPlist = "Info.plist"
    /// No key, in a build compiled with `DEBUG`.
    case debugBuild = "a Debug build"
    /// No key, in a build compiled without `DEBUG`.
    case releaseBuild = "a release build"
    /// Code that made the store, such as a test.
    case app = "the app"

    public var description: String { rawValue }
}
