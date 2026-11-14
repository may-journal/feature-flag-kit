import Foundation

/// Answers what each flag is and where that came from. Precedence: availability, an off
/// parent, launch argument, variable, user toggle, environment default, compiled default.
public struct FlagStore: Sendable {
    /// The sources asked in order; the first that sets a flag wins. In production it holds
    /// only the user's settings, so no launch argument or variable forces a flag.
    public let sources: [any FlagSource]
    /// Where `set(_:for:)` writes the user's toggle.
    public let settings: any FlagSettings
    /// Who sees this build, which decides the flags it ships and whether overrides apply.
    public let environment: FlagEnvironment
    /// Where `environment` came from, such as the app's Info.plist.
    public let environmentSource: FlagEnvironmentSource
    private let signal: FlagChangeSignal

    init(
        sources: [any FlagSource], settings: any FlagSettings, environment: FlagEnvironment,
        environmentSource: FlagEnvironmentSource
    ) {
        self.sources = sources
        self.settings = settings
        self.environment = environment
        self.environmentSource = environmentSource
        signal = .shared(for: settings)
    }

    /// The store an app uses: this process's overrides, then the user's toggles in `defaults`.
    /// Its environment is `in`, else `bundle`'s Info.plist key, else debug or production by build.
    public static func live(
        defaults: UserDefaults = .standard, process: ProcessInfo = .processInfo,
        bundle: Bundle = .main, in environment: FlagEnvironment? = nil
    ) -> FlagStore {
        let (found, source) =
            environment.map { ($0, FlagEnvironmentSource.app) } ?? FlagEnvironment.reading(bundle)
        return standard(
            arguments: process.arguments, variables: process.environment, settings: defaults,
            environment: found, source: source)
    }

    /// A fresh store with its toggles in memory, for one test, in the debug environment
    /// unless `in` names another. Pass launch arguments or environment variables to override
    /// flags, as a launch would.
    public static func isolated(
        arguments: [String] = [], environment: [String: String] = [:],
        in flagEnvironment: FlagEnvironment = .debug
    ) -> FlagStore {
        standard(
            arguments: arguments, variables: environment, settings: InMemoryFlagSettings(),
            environment: flagEnvironment, source: .app)
    }

    private static func standard(
        arguments: [String], variables: [String: String], settings: any FlagSettings,
        environment: FlagEnvironment, source: FlagEnvironmentSource
    ) -> FlagStore {
        let overrides: [any FlagSource] =
            environment.takesOverrides
            ? [LaunchArgumentSource(arguments), EnvironmentSource(variables)] : []
        return FlagStore(
            sources: overrides + [SettingsSource(settings)], settings: settings,
            environment: environment, environmentSource: source)
    }

    /// Whether `flag` ships in this store's environment, and its parent too, so an app's
    /// Settings shows its toggle only then.
    public func isAvailable(_ flag: any AnyFlag) -> Bool {
        flag.availability.contains(environment)
            && (flag.parent.map { $0.availability.contains(environment) } ?? true)
    }

    /// The flag's value and its source; a flag missing from this environment reads its compiled
    /// default. A parent that is off or missing turns a child off, even over the child's override.
    public func resolve<Value: FlagValue>(_ flag: Flag<Value>) -> FlagResolution<Value> {
        guard flag.availability.contains(environment) else {
            signal.watch(flag)
            return FlagResolution(value: flag.defaultValue, origin: .unavailable(in: environment))
        }
        // Only a `Flag<Bool>` can name a parent, so `Value` is `Bool` whenever there is one.
        if let parent = flag.parent, !isAvailable(parent) || !resolve(parent).value,
            let off = false as? Value
        {
            signal.watch(flag)
            return FlagResolution(value: off, origin: .parent(parent))
        }
        return ownResolution(flag)
    }

    /// The flag's value from its own layers, ignoring its parent. A debug screen names an
    /// override this finds, even while an off parent hides it.
    package func ownResolution<Value: FlagValue>(_ flag: Flag<Value>) -> FlagResolution<Value> {
        signal.watch(flag)
        for source in sources {
            if let value = source.value(for: flag) {
                return FlagResolution(value: value, origin: source.origin)
            }
        }
        if let value = flag.environmentDefaults[environment] {
            return FlagResolution(value: value, origin: .environmentDefault(environment))
        }
        return FlagResolution(value: flag.defaultValue, origin: .compiledDefault)
    }

    /// The flag's value, as `resolve(_:)` decides it.
    public subscript<Value: FlagValue>(_ flag: Flag<Value>) -> Value {
        resolve(flag).value
    }

    /// Saves the user's toggle, which an override still beats. The default for this
    /// environment, or nil, removes the key, so the flag follows a later release's default.
    public func set<Value: FlagValue>(_ value: Value?, for flag: Flag<Value>) {
        signal.watch(flag)
        if let value, value != flag.defaultValue(in: environment) {
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

    /// The names of flags read or set through any store over these settings whose toggle
    /// changes, including direct `UserDefaults` writes. A parent's change names its children.
    public func changes() -> AsyncStream<String> {
        signal.stream { $0.name }
    }

    /// Each later change to the user's layer for a flag in `catalog`, as heard by `changes()`.
    /// A sync hook sends the app's writes to another store and skips the imports.
    public func userChanges(in catalog: FlagCatalog) -> AsyncStream<FlagChange> {
        let keys = Set(catalog.map(\.settingsKey))
        let stream = signal.stream { event in
            event.change.flatMap { keys.contains($0.key) ? $0 : nil }
        }
        for flag in catalog {
            signal.watch(flag)
        }
        return stream
    }

    /// Writes another store's values by settings key, as `set` would, with nil to clear one.
    /// Each change is an import; a key no store watches, or a value of another type, is skipped.
    public func importUserValues(_ values: [String: FlagRawValue?]) {
        signal.importValues(values, in: environment)
    }

    /// Calls `onChange` with each changed flag's name, as `changes()` streams it, until the
    /// returned observation is freed. No task waits between changes.
    package func observeChanges(_ onChange: @escaping @Sendable (String) -> Void)
        -> FlagObservation
    {
        signal.observe { onChange($0.name) }
    }

    /// Equal for stores whose `changes()` hear the same writes, so a listener keeps its stream.
    package var changesID: ObjectIdentifier {
        ObjectIdentifier(signal)
    }

    /// The user's own layer for `flag`: their setting, or this environment's default when
    /// they set none.
    package func userValue<Value: FlagValue>(for flag: Flag<Value>) -> Value {
        SettingsSource(settings).value(for: flag) ?? flag.defaultValue(in: environment)
    }
}
