import Foundation

/// Answers what each flag is and where that came from. Precedence: launch
/// argument, environment, the user's toggle, then the compiled default.
public struct FlagStore: Sendable {
    /// The sources asked in order; the first that sets a flag wins.
    public let sources: [any FlagSource]
    /// Where `set(_:for:)` writes the user's toggle.
    public let settings: any FlagSettings
    private let signal: FlagChangeSignal

    init(sources: [any FlagSource], settings: any FlagSettings) {
        self.sources = sources
        self.settings = settings
        signal = .shared(for: settings)
    }

    /// The store an app uses: this process's launch arguments and environment,
    /// then the user's toggles in `defaults`.
    public static func live(
        defaults: UserDefaults = .standard, process: ProcessInfo = .processInfo
    ) -> FlagStore {
        standard(arguments: process.arguments, environment: process.environment, settings: defaults)
    }

    /// A fresh store with its toggles in memory, for one test. Pass launch
    /// arguments or environment variables to override flags, as a launch would.
    public static func isolated(
        arguments: [String] = [], environment: [String: String] = [:]
    ) -> FlagStore {
        standard(arguments: arguments, environment: environment, settings: InMemoryFlagSettings())
    }

    private static func standard(
        arguments: [String], environment: [String: String], settings: any FlagSettings
    ) -> FlagStore {
        let sources: [any FlagSource] = [
            LaunchArgumentSource(arguments), EnvironmentSource(environment),
            SettingsSource(settings),
        ]
        return FlagStore(sources: sources, settings: settings)
    }

    /// The flag's value and the source that supplied it.
    public func resolve<Value: FlagValue>(_ flag: Flag<Value>) -> FlagResolution<Value> {
        signal.watch(flag)
        for source in sources {
            if let value = source.value(for: flag) {
                return FlagResolution(value: value, origin: source.origin)
            }
        }
        return FlagResolution(value: flag.defaultValue, origin: .compiledDefault)
    }

    /// The flag's value, from the first source that sets it.
    public subscript<Value: FlagValue>(_ flag: Flag<Value>) -> Value {
        resolve(flag).value
    }

    /// Saves the user's toggle, which an override still beats. The default or nil
    /// removes the key, so the flag follows a later release's default.
    public func set<Value: FlagValue>(_ value: Value?, for flag: Flag<Value>) {
        signal.watch(flag)
        if let value, value != flag.defaultValue {
            settings.set(value.stored, forKey: flag.settingsKey)
        } else {
            settings.removeObject(forKey: flag.settingsKey)
        }
        signal.check(key: flag.settingsKey)
    }

    /// Forgets the user's toggle, so the flag falls back to its default.
    public func reset(_ flag: some AnyFlag) {
        signal.watch(flag)
        settings.removeObject(forKey: flag.settingsKey)
        signal.check(key: flag.settingsKey)
    }

    /// The names of flags read or set through any store over these settings
    /// whose toggle changes, from now on, including direct `UserDefaults` writes.
    public func changes() -> AsyncStream<String> {
        signal.stream()
    }

    /// Equal for stores whose `changes()` hear the same writes, so a listener keeps its stream.
    package var changesID: ObjectIdentifier {
        ObjectIdentifier(signal)
    }

    /// The user's own layer for `flag`: their setting, or the default when they set none.
    package func userValue<Value: FlagValue>(for flag: Flag<Value>) -> Value {
        SettingsSource(settings).value(for: flag) ?? flag.defaultValue
    }
}
