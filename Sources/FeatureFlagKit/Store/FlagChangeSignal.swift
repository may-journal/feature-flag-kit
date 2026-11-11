import Foundation

/// Tells listeners each change to a watched flag's stored value, for all stores sharing settings.
/// Unchecked because the lock guards its state.
final class FlagChangeSignal: @unchecked Sendable {
    /// A watched flag's name, the last stored value this signal saw, and how it imports a value.
    private struct Watched {
        let name: String
        var stored: Any?
        let importing: (@Sendable (FlagRawValue) -> FlagImport)?
    }

    /// One change as listeners hear it. `change` is nil when the stored value is not a
    /// property-list value, so a sync hook never mistakes it for a cleared one.
    struct Event: Sendable {
        let name: String
        let change: FlagChange?
    }

    private let settings: any FlagSettings
    private let lock = NSLock()
    private var listeners: [UUID: @Sendable (Event) -> Void] = [:]
    private var watched: [String: Watched] = [:]
    /// The value an import is writing under each key. A change to exactly that value is an
    /// import, and any other write to the key is the app's.
    private var imported: [String: FlagRawValue?] = [:]
    private let observer = DefaultsObserver()

    init(_ settings: any FlagSettings) {
        self.settings = settings
        guard settings is UserDefaults else { return }
        // Any defaults instance may write the same domain, so hear every one.
        observer.start { [weak self] in self?.check() }
    }

    /// The signal for `settings`, shared by every store over the same object.
    static func shared(for settings: any FlagSettings) -> FlagChangeSignal {
        guard type(of: settings) is AnyClass else { return FlagChangeSignal(settings) }
        return SignalRegistry.shared.signal(for: settings)
    }

    /// Streams each change, turned into an element by `element`, which may skip one with nil.
    func stream<Element: Sendable>(
        _ element: @escaping @Sendable (Event) -> Element?
    ) -> AsyncStream<Element> {
        let (stream, continuation) = AsyncStream<Element>.makeStream()
        let id = UUID()
        lock.withLock {
            listeners[id] = { change in
                if let value = element(change) {
                    continuation.yield(value)
                }
            }
        }
        continuation.onTermination = { [weak self] _ in
            self?.lock.withLock { _ = self?.listeners.removeValue(forKey: id) }
        }
        return stream
    }

    /// Starts watching a flag's settings key, from its value now.
    func watch(_ flag: some AnyFlag) {
        let isWatched = lock.withLock { watched[flag.settingsKey] != nil }
        guard !isWatched else { return }
        let stored = settings.object(forKey: flag.settingsKey)
        let importing = (flag as? any ImportableFlag)?.importing
        lock.withLock {
            if watched[flag.settingsKey] == nil {
                watched[flag.settingsKey] = Watched(
                    name: flag.name, stored: stored, importing: importing)
            }
        }
    }

    /// Writes `values` by key through each watched flag as `set` would, reported as imports.
    /// It skips a key no store watches and a value that does not read as its flag's type.
    func importValues(_ values: [String: FlagRawValue?]) {
        let writes = lock.withLock { values.compactMap(plannedWrite) }
        lock.withLock {
            for write in writes {
                imported[write.key] = .some(write.value)
            }
        }
        defer {
            lock.withLock {
                for write in writes {
                    imported[write.key] = nil
                }
            }
        }
        for write in writes {
            settings.set(write.value?.propertyList, forKey: write.key)
        }
        for write in writes {
            check(key: write.key)
        }
    }

    /// What an import writes under `key` for `raw`, where a nil value removes the key, or nil
    /// to skip it. Call it holding the lock.
    private func plannedWrite(key: String, raw: FlagRawValue?) -> (
        key: String, value: FlagRawValue?
    )? {
        guard let importing = watched[key]?.importing else { return nil }
        guard let raw else { return (key, nil) }
        switch importing(raw) {
        case .store(let value): return (key, value)
        case .remove: return (key, nil)
        case .skip: return nil
        }
    }

    /// Sends each watched flag whose stored value changed since the last check.
    /// With `key`, checks only the flag under that key.
    func check(key: String? = nil) {
        let keys = lock.withLock { key.map { [$0] } ?? Array(watched.keys) }
        // Read outside the lock, since a settings read may run other code.
        let now = keys.map { ($0, settings.object(forKey: $0)) }
        let events = lock.withLock {
            now.compactMap { key, stored -> Event? in
                guard let entry = watched[key], !Self.same(entry.stored, stored) else { return nil }
                watched[key]?.stored = stored
                return Event(name: entry.name, change: change(key: key, stored: stored))
            }
        }
        let current = lock.withLock { Array(listeners.values) }
        for event in events {
            for listener in current {
                listener(event)
            }
        }
    }

    /// The change to `key`, an import when an import is writing exactly `stored`. It is nil
    /// when `stored` is not a property-list value; call it holding the lock.
    private func change(key: String, stored: Any?) -> FlagChange? {
        let name = watched[key]?.name ?? key
        let raw = stored.flatMap(FlagRawValue.init(propertyList:))
        guard stored == nil || raw != nil else { return nil }
        let isImport = imported[key].map { $0 == raw } ?? false
        return FlagChange(name: name, key: key, rawValue: raw, writer: isImport ? .import : .app)
    }

    /// Whether two property-list values are equal.
    private static func same(_ lhs: Any?, _ rhs: Any?) -> Bool {
        switch (lhs, rhs) {
        case (nil, nil): true
        case (let lhs?, let rhs?): (lhs as? NSObject)?.isEqual(rhs) ?? false
        default: false
        }
    }
}

/// Hears every `UserDefaults` change until it is freed.
/// Unchecked because `token` is set once, before any other thread sees it.
private final class DefaultsObserver: @unchecked Sendable {
    private var token: (any NSObjectProtocol)?

    func start(_ onChange: @escaping @Sendable () -> Void) {
        token = NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification, object: nil, queue: nil
        ) { _ in onChange() }
    }

    deinit {
        if let token {
            NotificationCenter.default.removeObserver(token)
        }
    }
}

/// One signal per live settings object, held weakly so a dropped store frees it.
/// Unchecked because the lock guards `signals`.
private final class SignalRegistry: @unchecked Sendable {
    private struct Entry {
        weak var signal: FlagChangeSignal?
    }

    static let shared = SignalRegistry()
    private let lock = NSLock()
    private var signals: [ObjectIdentifier: Entry] = [:]

    func signal(for settings: any FlagSettings) -> FlagChangeSignal {
        // The signal holds `settings`, so the identifier stays its own while the signal lives.
        let id = ObjectIdentifier(settings as AnyObject)
        return lock.withLock {
            if let signal = signals[id]?.signal { return signal }
            signals = signals.filter { $0.value.signal != nil }
            let signal = FlagChangeSignal(settings)
            signals[id] = Entry(signal: signal)
            return signal
        }
    }
}
