import Foundation

/// Where the user's toggles are kept: `UserDefaults` in the app, or memory in a test.
public protocol FlagSettings: Sendable {
    func object(forKey key: String) -> Any?
    func set(_ value: Any?, forKey key: String)
    func removeObject(forKey key: String)
}

extension UserDefaults: FlagSettings {}

/// Toggles kept in memory only, so each test starts from the compiled defaults.
/// Unchecked because the lock guards `values`, which hold property-list values.
final class InMemoryFlagSettings: FlagSettings, @unchecked Sendable {
    private let lock = NSLock()
    private var values: [String: Any] = [:]

    init() {}

    func object(forKey key: String) -> Any? {
        lock.withLock { values[key] }
    }

    func set(_ value: Any?, forKey key: String) {
        guard let value else { return removeObject(forKey: key) }
        lock.withLock { values[key] = value }
    }

    func removeObject(forKey key: String) {
        lock.withLock { values[key] = nil }
    }
}
