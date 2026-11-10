import FeatureFlagKit

/// One flag forced to one value, spelled by the core's `FlagEncoding`.
public struct FlagOverride: Sendable, Equatable {
    /// The launch arguments that force the flag: `-flag.<name>` and its value.
    public let arguments: [String]
    /// The environment variable that forces the flag: `FLAG_<NAME>` and its value.
    public let environment: [String: String]

    /// Forces `flag` to `value`, so a call reads `.set(AppFlags.onThisDay, true)`.
    public static func set<Value: FlagValue>(_ flag: Flag<Value>, _ value: Value) -> FlagOverride {
        FlagOverride(
            arguments: FlagEncoding.arguments(flag, value),
            environment: FlagEncoding.environment(flag, value))
    }
}

/// Turns flag overrides into what a launch carries.
public enum FlagLaunch {
    /// The launch arguments for every override, to append to a launch's own.
    public static func arguments(_ overrides: FlagOverride...) -> [String] {
        arguments(overrides)
    }

    /// The launch arguments for every override, to append to a launch's own.
    public static func arguments(_ overrides: [FlagOverride]) -> [String] {
        overrides.flatMap(\.arguments)
    }

    /// The environment for every override, to merge into a launch's own.
    public static func environment(_ overrides: FlagOverride...) -> [String: String] {
        environment(overrides)
    }

    /// The environment for every override, to merge into a launch's own.
    /// A later override of the same flag wins, as it does in the arguments.
    public static func environment(_ overrides: [FlagOverride]) -> [String: String] {
        overrides.reduce(into: [:]) { environment, override in
            environment.merge(override.environment) { _, later in later }
        }
    }
}
