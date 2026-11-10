import Foundation

/// Tells listeners each watched flag whose stored toggle changed, for all stores sharing settings.
/// Unchecked because the lock guards `listeners` and `watched`.
final class FlagChangeSignal: @unchecked Sendable {
    /// A watched flag's name and the last stored value this signal saw.
    private struct Watched {
        let name: String
        var stored: Any?
    }

    private let settings: any FlagSettings
    private let lock = NSLock()
    private var listeners: [UUID: AsyncStream<String>.Continuation] = [:]
    private var watched: [String: Watched] = [:]
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

    func stream() -> AsyncStream<String> {
        let (stream, continuation) = AsyncStream<String>.makeStream()
        let id = UUID()
        lock.withLock { listeners[id] = continuation }
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

    /// Sends each watched flag whose stored value changed since the last check.
    /// With `key`, checks only the flag under that key.
    func check(key: String? = nil) {
        let keys = lock.withLock { key.map { [$0] } ?? Array(watched.keys) }
        // Read outside the lock, since a settings read may run other code.
        let now = keys.map { ($0, settings.object(forKey: $0)) }
        let names = lock.withLock {
            now.compactMap { key, stored -> String? in
                guard let entry = watched[key], !Self.same(entry.stored, stored) else { return nil }
                watched[key]?.stored = stored
                return entry.name
            }
        }
        let current = lock.withLock { Array(listeners.values) }
        for name in names {
            for listener in current {
                listener.yield(name)
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
