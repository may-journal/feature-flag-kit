import Foundation

/// What every flag states, whatever value it holds, so a catalog can list mixed flags.
public protocol AnyFlag: Sendable {
    /// The name overrides use: `-flag.<name>` and `FLAG_<NAME>`.
    var name: String { get }
    /// The words the user reads beside the flag's toggle.
    var title: String { get }
    /// The day the flag should be gone from the app.
    var expires: FlagExpiry { get }
    /// The settings key that holds the user's toggle.
    var settingsKey: String { get }
}

/// One flag, defined once: its name, compiled default, title and expiry day.
public struct Flag<Value: FlagValue>: AnyFlag {
    public let name: String
    public let defaultValue: Value
    public let title: String
    public let expires: FlagExpiry
    public let settingsKey: String

    /// Defines a flag whose toggle lives under `flag.<name>`, or under
    /// `legacySettingsKey` when an earlier release already stored it there.
    public init(
        _ name: String, default defaultValue: Value, title: String, expires: FlagExpiry,
        legacySettingsKey: String? = nil
    ) {
        self.name = name
        self.defaultValue = defaultValue
        self.title = title
        self.expires = expires
        self.settingsKey = legacySettingsKey ?? FlagEncoding.settingsKey(for: name)
    }
}
