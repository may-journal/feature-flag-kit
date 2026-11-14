import Foundation

/// What every flag states, whatever value it holds, so a catalog can list mixed flags.
public protocol AnyFlag: Sendable {
    /// The name overrides use: `-flag.<name>` and `FLAG_<NAME>`.
    var name: String { get }
    /// The words the user reads beside the flag's toggle.
    var title: String { get }
    /// The day the flag should be gone from the app, or `FlagExpiry.never` for a setting.
    var expires: FlagExpiry { get }
    /// The settings key that holds the user's toggle.
    var settingsKey: String { get }
    /// The toggle this flag sits under, which turns it off while it is off, or nil.
    var parent: Flag<Bool>? { get }
    /// The environments the flag ships in. Elsewhere it reads its compiled default and its
    /// toggle hides.
    var availability: Set<FlagEnvironment> { get }
}

extension AnyFlag {
    /// A flag of the app's own type sits under no parent.
    public var parent: Flag<Bool>? { nil }
    /// A flag of the app's own type ships in every environment.
    public var availability: Set<FlagEnvironment> { Set(FlagEnvironment.allCases) }
}

/// One flag, defined once: its name, compiled default, title, expiry day and environments.
/// A flag with no expiry day is a permanent setting, which the expiry test never names.
public struct Flag<Value: FlagValue>: AnyFlag {
    public let name: String
    public let defaultValue: Value
    public let title: String
    public let expires: FlagExpiry
    public let settingsKey: String
    public let availability: Set<FlagEnvironment>
    /// The value the flag starts at in an environment, in place of `defaultValue`.
    public let environmentDefaults: [FlagEnvironment: Value]
    /// Holds the parent apart, since a struct can't hold a value of its own type.
    private let group: FlagGroup?

    /// The toggle this flag sits under, which turns it off while it is off, or nil.
    public var parent: Flag<Bool>? { group?.parent }

    /// Defines a flag whose toggle lives under `flag.<name>`, or under
    /// `legacySettingsKey` when an earlier release already stored it there. Leave out
    /// `expires` for a permanent setting, and `availability` for a flag in every environment.
    public init(
        _ name: String, default defaultValue: Value, title: String, expires: FlagExpiry = .never,
        legacySettingsKey: String? = nil,
        availability: Set<FlagEnvironment> = Set(FlagEnvironment.allCases),
        environmentDefaults: [FlagEnvironment: Value] = [:]
    ) {
        self.init(
            name, default: defaultValue, title: title, expires: expires,
            legacySettingsKey: legacySettingsKey, availability: availability,
            environmentDefaults: environmentDefaults, group: nil)
    }

    private init(
        _ name: String, default defaultValue: Value, title: String, expires: FlagExpiry,
        legacySettingsKey: String?, availability: Set<FlagEnvironment>,
        environmentDefaults: [FlagEnvironment: Value], group: FlagGroup?
    ) {
        self.name = name
        self.defaultValue = defaultValue
        self.title = title
        self.expires = expires
        self.settingsKey = legacySettingsKey ?? FlagEncoding.settingsKey(for: name)
        self.availability = availability
        self.environmentDefaults = environmentDefaults
        self.group = group
    }

    /// The value the flag starts at in `environment`: its default there, or `defaultValue`.
    public func defaultValue(in environment: FlagEnvironment) -> Value {
        environmentDefaults[environment] ?? defaultValue
    }

    /// The compiled default and each environment's default. A saved value equal to all of
    /// them needs no key, on this device or any device that syncs with it.
    var everyDefault: [Value] {
        [defaultValue] + environmentDefaults.values
    }
}

extension AnyFlag {
    /// Whether the flag itself ships in `environment`, whatever its parent says.
    public func ships(in environment: FlagEnvironment) -> Bool {
        availability.contains(environment)
    }
}

extension Flag where Value == Bool {
    /// Defines a toggle under `parent`, which reads off while the parent is off and keeps its
    /// own setting. A `parent` that has a parent of its own stops the app: one level deep.
    public init(
        _ name: String, default defaultValue: Bool, title: String, expires: FlagExpiry = .never,
        legacySettingsKey: String? = nil,
        availability: Set<FlagEnvironment> = Set(FlagEnvironment.allCases),
        environmentDefaults: [FlagEnvironment: Bool] = [:], parent: Flag<Bool>
    ) {
        precondition(
            parent.parent == nil,
            "Flag \"\(name)\" can't sit under \"\(parent.name)\", which sits under a parent: "
                + "a group is one level deep.")
        self.init(
            name, default: defaultValue, title: title, expires: expires,
            legacySettingsKey: legacySettingsKey, availability: availability,
            environmentDefaults: environmentDefaults, group: FlagGroup(parent: parent))
    }
}

/// A child flag's parent, kept in a class so `Flag` can name a `Flag`.
private final class FlagGroup: Sendable {
    let parent: Flag<Bool>

    init(parent: Flag<Bool>) {
        self.parent = parent
    }
}
