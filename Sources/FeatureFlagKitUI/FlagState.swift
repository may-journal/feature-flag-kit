import FeatureFlagKit
import SwiftUI

/// Reads a flag in a view from the environment's `flagStore`, and redraws the view when
/// the flag's toggle changes. `$name` is a binding that writes the user's toggle.
///
/// ```swift
/// @FlagState(AppFlags.onThisDay) private var onThisDay
/// ```
@MainActor @propertyWrapper
public struct FlagState<Value: FlagValue>: @MainActor DynamicProperty {
    @Environment(\.flagStore) private var store
    @State private var watcher = FlagWatcher()
    private let definition: Flag<Value>

    /// Reads `definition`, the flag the app defined once in its catalog.
    public init(_ definition: Flag<Value>) {
        self.definition = definition
    }

    /// The flag's value, from the first layer that sets it.
    public var wrappedValue: Value {
        _ = watcher.version
        return store[definition]
    }

    /// A binding whose writes save the user's toggle, which an override still beats.
    public var projectedValue: Binding<Value> {
        let store = store
        let definition = definition
        return Binding(
            get: { store[definition] },
            set: { store.set($0, for: definition) }
        )
    }

    public func update() {
        watcher.watch(store, name: definition.name)
    }
}
