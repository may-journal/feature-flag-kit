import FeatureFlagKit
import Observation
import SwiftUI

/// Counts the changes a store reports, so a view that reads `version` redraws on each one.
/// It listens to one store's changes at a time.
@MainActor @Observable
final class FlagWatcher {
    /// Goes up by one for each change to a watched flag.
    private(set) var version = 0
    /// The store's callback, which keeps its change signal alive and ends when freed. No task
    /// waits between changes, so a view that reads a flag leaves no work pending.
    @ObservationIgnored private var observation: FlagObservation?
    @ObservationIgnored private var changesID: ObjectIdentifier?

    /// Listens to `store` for changes to the flags in `names`, or to every flag when nil.
    /// Calling it again with a store that hears the same changes keeps the listener it has.
    func watch(_ store: FlagStore, names: Set<String>? = nil) {
        if observation != nil, store.changesID == changesID { return }
        changesID = store.changesID
        observation = store.observeChanges { [weak self] changed in
            guard names?.contains(changed) ?? true else { return }
            Task { @MainActor in self?.version += 1 }
        }
    }
}

/// The environment's `flagStore`, read so that a change to a flag in `names`, or to any flag
/// when nil, redraws the view. `@FlagState` and `FlagDebugView` both read it this way.
@MainActor
struct WatchedFlagStore: @MainActor DynamicProperty {
    @Environment(\.flagStore) private var environmentStore
    @State private var watcher = FlagWatcher()
    private let names: Set<String>?

    init(names: Set<String>? = nil) {
        self.names = names
    }

    /// The store, read with the change count so the view redraws on each change.
    var store: FlagStore {
        _ = watcher.version
        return environmentStore
    }

    func update() {
        watcher.watch(environmentStore, names: names)
    }
}
