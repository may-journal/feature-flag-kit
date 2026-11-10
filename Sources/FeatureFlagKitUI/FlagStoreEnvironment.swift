import FeatureFlagKit
import SwiftUI

extension EnvironmentValues {
    /// The store `@FlagState` and `FlagDebugView` read. It defaults to the live store, so an
    /// app sets it only to swap in another store, such as `FlagStore.isolated()` in a test.
    @Entry public var flagStore: FlagStore = liveFlagStore
}

/// The live store, built once, which every read of the default environment shares.
private let liveFlagStore = FlagStore.live()
