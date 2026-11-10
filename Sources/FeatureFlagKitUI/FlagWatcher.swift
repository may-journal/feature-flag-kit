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

    /// Listens to `store` for changes to the flag `name`, or to every flag when nil.
    /// Calling it again with the same settings keeps the listener it has.
    func watch(_ store: FlagStore, name: String? = nil) {
        let id = Self.identity(of: store.settings)
        guard task == nil || id != settingsID else { return }
        task?.cancel()
        settingsID = id
        // Make the stream now, so a change before the task first runs still reaches it.
        let changes = store.changes()
        task = Task { [weak self] in
            for await changed in changes where name == nil || changed == name {
                self?.version += 1
            }
        }
    }

    /// The settings object's identity, or nil for a value type, which keeps the first listener.
    private static func identity(of settings: any FlagSettings) -> ObjectIdentifier? {
        guard type(of: settings) is AnyClass else { return nil }
        return ObjectIdentifier(settings as AnyObject)
    }

    isolated deinit {
        task?.cancel()
    }
}
