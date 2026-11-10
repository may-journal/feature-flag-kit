import FeatureFlagKit

/// One flag forced to one value, the way a test hands it to a launch.
public struct FlagOverride: Sendable, Equatable {
    /// The flag's name, as `FlagEncoding` spells it.
    public let name: String
    /// The value as launch text, which the flag's type parses back.
    public let text: String

    /// Forces `flag` to `value`.
    public init<Value: FlagValue & CustomStringConvertible>(_ flag: Flag<Value>, _ value: Value) {
        name = flag.name
        text = value.description
    }

    /// Forces `flag` to `value`, so a call reads `.set(AppFlags.onThisDay, true)`.
    public static func set<Value: FlagValue & CustomStringConvertible>(
        _ flag: Flag<Value>, _ value: Value
    ) -> FlagOverride {
        FlagOverride(flag, value)
    }
}

/// Turns flag overrides into what a launch carries, through `FlagEncoding`.
public enum FlagLaunch {
    /// The launch arguments, `-flag.<name> <value>` per override, to append to a launch's own.
    public static func arguments(_ overrides: FlagOverride...) -> [String] {
        arguments(overrides)
    }

    /// The launch arguments, `-flag.<name> <value>` per override, to append to a launch's own.
    public static func arguments(_ overrides: [FlagOverride]) -> [String] {
        overrides.flatMap { [FlagEncoding.argument(for: $0.name), $0.text] }
    }

    /// The environment, `FLAG_<NAME>` per override, to merge into a launch's own.
    public static func environment(_ overrides: FlagOverride...) -> [String: String] {
        environment(overrides)
    }

    /// The environment, `FLAG_<NAME>` per override, to merge into a launch's own.
    /// A later override of the same flag wins, as it does in the arguments.
    public static func environment(_ overrides: [FlagOverride]) -> [String: String] {
        var environment: [String: String] = [:]
        for override in overrides {
            environment[FlagEncoding.environmentVariable(for: override.name)] = override.text
        }
        return environment
    }
}
