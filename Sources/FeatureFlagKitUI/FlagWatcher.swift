import FeatureFlagKit
import Observation

/// Counts the toggle changes a store reports, so a view that reads `version` redraws
/// on each one. It listens to one store's settings at a time.
@MainActor @Observable
final class FlagWatcher {
    /// Goes up by one for each change to a watched flag.
    private(set) var version = 0
    @ObservationIgnored private var task: Task<Void, Never>?
    @ObservationIgnored private var settingsID: ObjectIdentifier?
    /// Held so the store's change signal lives as long as the listener, even when the
    /// environment hands each read a fresh live store.
    @ObservationIgnored private var store: FlagStore?

    /// Listens to `store` for changes to the flag `name`, or to every flag when nil.
    /// Calling it again with the same settings object keeps the listener it has.
    func watch(_ store: FlagStore, name: String? = nil) {
        let id = Self.identity(of: store.settings)
        if task != nil, let id, id == settingsID { return }
        task?.cancel()
        settingsID = id
        self.store = store
        // Make the stream now, so a change before the task first runs still reaches it.
        let changes = store.changes()
        task = Task { [weak self] in
            for await changed in changes where name == nil || changed == name {
                self?.version += 1
            }
            // The stream ended, so the next watch starts a new listener.
            self?.task = nil
        }
    }

    /// The settings object's identity, or nil for a value type, which has none to match.
    private static func identity(of settings: any FlagSettings) -> ObjectIdentifier? {
        guard type(of: settings) is AnyClass else { return nil }
        return ObjectIdentifier(settings as AnyObject)
    }

    isolated deinit {
        task?.cancel()
    }
}
