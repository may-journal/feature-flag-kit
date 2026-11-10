import FeatureFlagKit
import FeatureFlagKitUI
import SwiftUI
import Testing
import UITestingLibrary

/// Requirement 0006: changing a number flag and resetting every flag from the debug screen.
extension FeatureFlagKitTests {
    @MainActor
    @Suite struct Changing {
        /// Renders the debug screen for the example catalog on `store`.
        private func render(_ store: FlagStore) throws -> (Screen, User) {
            let screen = try Screen.render {
                FlagDebugView(catalog: ExampleFlags.catalog).environment(\.flagStore, store)
            }
            return (screen, User(screen))
        }

        @Test func test0006_1() async throws {
            let (screen, user) = try render(.isolated())
            try await user.clears(.role(.textField, "Grid columns"))
            try await user.types("4")
            try await user.presses(.enter)
            try await user.sees(.text("4, from user setting"))
            try screen.close()
        }

        @Test func test0006_2() async throws {
            let store = FlagStore.isolated()
            store.set(5, for: ExampleFlags.gridColumns)
            let (screen, user) = try render(store)
            try await user.taps(.button("Reset all"))
            try await user.taps(.button("Cancel"))
            try await user.sees(.text("5, from user setting"))
            try screen.close()
        }
    }
}
