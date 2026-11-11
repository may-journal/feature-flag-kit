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
    private var watched: WatchedFlagStore
    private let definition: Flag<Value>

    /// Reads `definition`, the flag the app defined once in its catalog. A child also redraws
    /// when its parent changes.
    public init(_ definition: Flag<Value>) {
        self.definition = definition
        let parent = definition.parent.map { [$0.name] } ?? []
        watched = WatchedFlagStore(names: Set([definition.name] + parent))
    }

    /// The flag's value, from the first layer that sets it, and off while its parent is off.
    public var wrappedValue: Value {
        watched.store[definition]
    }

    /// A binding to the user's own toggle, which an override or an off parent still beats.
    public var projectedValue: Binding<Value> {
        watched.store.userBinding(for: definition)
    }
}
