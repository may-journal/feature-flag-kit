/// One place a flag's value can come from. A store asks its built-in sources
/// in order and takes the first value, so a debug screen can list them.
public protocol FlagSource: Sendable {
    /// What a debug screen shows as this source's name.
    var origin: FlagOrigin { get }
    /// The flag's value from this source, or nil when it sets none or its text
    /// does not parse, so the next source decides.
    func value<Value: FlagValue>(for flag: Flag<Value>) -> Value?
}

/// Reads `-flag.<name> <value>` pairs from the process's launch arguments.
struct LaunchArgumentSource: FlagSource {
    let arguments: [String]
    var origin: FlagOrigin { .launchArgument }

    init(_ arguments: [String]) {
        self.arguments = arguments
    }

    /// The value after the last `-flag.<name>`, as `UserDefaults` reads arguments.
    func value<Value: FlagValue>(for flag: Flag<Value>) -> Value? {
        let name = FlagEncoding.argument(for: flag.name)
        guard let index = arguments.lastIndex(of: name), index + 1 < arguments.count else {
            return nil
        }
        return Value(flagText: arguments[index + 1])
    }
}

/// Reads `FLAG_<NAME>` variables from the process's environment.
struct EnvironmentSource: FlagSource {
    let environment: [String: String]
    var origin: FlagOrigin { .environment }

    init(_ environment: [String: String]) {
        self.environment = environment
    }

    func value<Value: FlagValue>(for flag: Flag<Value>) -> Value? {
        environment[FlagEncoding.environmentVariable(for: flag.name)].flatMap(Value.init(flagText:))
    }
}

/// Reads the user's own toggles from the app's settings.
struct SettingsSource: FlagSource {
    let settings: any FlagSettings
    var origin: FlagOrigin { .user }

    init(_ settings: any FlagSettings) {
        self.settings = settings
    }

    func value<Value: FlagValue>(for flag: Flag<Value>) -> Value? {
        settings.object(forKey: flag.settingsKey).flatMap(Value.init(stored:))
    }
}
