import Foundation

/// Tells listeners each change to a watched flag's stored value, for all stores sharing settings.
/// Unchecked because the lock guards its state.
final class FlagChangeSignal: @unchecked Sendable {
    /// A watched flag's name and the last stored value this signal saw.
    private struct Watched {
        let name: String
        var stored: Any?
    }

    private let settings: any FlagSettings
    private let lock = NSLock()
    private var listeners: [UUID: @Sendable (FlagChange) -> Void] = [:]
    private var watched: [String: Watched] = [:]
    /// Keys an import is writing now, so a change seen on one is marked as an import.
    private var importing: [String: Int] = [:]
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
        _ element: @escaping @Sendable (FlagChange) -> Element?
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
        lock.withLock {
            if watched[flag.settingsKey] == nil {
                watched[flag.settingsKey] = Watched(name: flag.name, stored: stored)
            }
        }
    }

    /// Runs `write`, which sets `keys`, and reports each change to them as an import, even one
    /// a settings notification reports before `write` returns.
    func importing(_ keys: [String], _ write: () -> Void) {
        lock.withLock {
            for key in keys {
                importing[key, default: 0] += 1
            }
        }
        defer {
            lock.withLock {
                for key in keys {
                    importing[key, default: 1] -= 1
                    if importing[key] == 0 { importing[key] = nil }
                }
            }
        }
        write()
        for key in keys {
            check(key: key)
        }
    }

    /// Sends each watched flag whose stored value changed since the last check.
    /// With `key`, checks only the flag under that key.
    func check(key: String? = nil) {
        let keys = lock.withLock { key.map { [$0] } ?? Array(watched.keys) }
        // Read outside the lock, since a settings read may run other code.
        let now = keys.map { ($0, settings.object(forKey: $0)) }
        let changes = lock.withLock {
            now.compactMap { key, stored -> FlagChange? in
                guard let entry = watched[key], !Self.same(entry.stored, stored) else { return nil }
                watched[key]?.stored = stored
                return FlagChange(
                    name: entry.name, key: key, rawValue: stored.flatMap(FlagRawValue.init),
                    writer: importing[key] == nil ? .app : .import)
            }
        }
        let current = lock.withLock { Array(listeners.values) }
        for change in changes {
            for listener in current {
                listener(change)
            }
        }
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
