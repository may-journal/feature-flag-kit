import FeatureFlagKit
import Observation
import SwiftUI

/// Counts the changes a store reports, so a view that reads `version` redraws on each one.
/// It listens to one store's changes at a time.
@MainActor @Observable
final class FlagWatcher {
    /// Goes up by one for each change to a watched flag.
    private(set) var version = 0
    @ObservationIgnored private var task: Task<Void, Never>?
    /// Names the running listener, so one that ends after it was replaced leaves `task` alone.
    @ObservationIgnored private var listener: UUID?
    @ObservationIgnored private var changesID: ObjectIdentifier?
    /// Held so the store's change signal lives as long as the listener, even when the
    /// environment hands each read a fresh store.
    @ObservationIgnored private var store: FlagStore?

    /// Listens to `store` for changes to the flag `name`, or to every flag when nil.
    /// Calling it again with a store that hears the same changes keeps the listener it has.
    func watch(_ store: FlagStore, name: String? = nil) {
        if task != nil, store.changesID == changesID { return }
        task?.cancel()
        changesID = store.changesID
        self.store = store
        let listener = UUID()
        self.listener = listener
        // Make the stream now, so a change before the task first runs still reaches it.
        let changes = store.changes()
        task = Task { [weak self] in
            for await changed in changes where name == nil || changed == name {
                self?.version += 1
            }
            // The stream ended, so the next watch starts a new listener.
            if self?.listener == listener {
                self?.task = nil
            }
        }
    }

    isolated deinit {
        task?.cancel()
    }
}

/// The environment's `flagStore`, read so that a change to the flag `name`, or to any flag
/// when nil, redraws the view. `@FlagState` and `FlagDebugView` both read the store this way.
@MainActor
struct WatchedFlagStore: @MainActor DynamicProperty {
    @Environment(\.flagStore) private var environmentStore
    @State private var watcher = FlagWatcher()
    private let name: String?

    init(name: String? = nil) {
        self.name = name
    }

    /// The store, read with the change count so the view redraws on each change.
    var store: FlagStore {
        _ = watcher.version
        return environmentStore
    }

    func update() {
        watcher.watch(environmentStore, name: name)
    }
}
