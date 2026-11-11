import Foundation

/// Hears every `UserDefaults` change until it is freed.
/// Unchecked because `token` is set once, before any other thread sees it.
final class DefaultsObserver: @unchecked Sendable {
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
final class SignalRegistry: @unchecked Sendable {
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
