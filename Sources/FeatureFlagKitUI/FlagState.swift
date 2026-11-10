import FeatureFlagKit
import SwiftUI

/// Reads a flag in a view from the environment's `flagStore`, redrawing on each toggle change.
/// `$name` binds the user's own toggle, never an override, so Settings shows what it saved.
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

    /// A binding to the user's own toggle, which an override still beats.
    public var projectedValue: Binding<Value> {
        let store = store
        let definition = definition
        return Binding(
            get: { store.userValue(for: definition) },
            set: { store.set($0, for: definition) }
        )
    }

    public func update() {
        watcher.watch(store, name: definition.name)
    }
}

extension FlagStore {
    /// The user's own layer for `flag`: their toggle, or the default when they set none.
    func userValue<Value: FlagValue>(for flag: Flag<Value>) -> Value {
        settings.object(forKey: flag.settingsKey).flatMap(Value.init(stored:)) ?? flag.defaultValue
    }
}
