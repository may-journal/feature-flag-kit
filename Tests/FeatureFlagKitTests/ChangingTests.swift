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

        @Test func test0006_3() async throws {
            let store = FlagStore.isolated()
            store.set(true, for: ExampleFlags.onThisDay)
            store.set(5, for: ExampleFlags.gridColumns)
            let (screen, user) = try render(store)
            try await confirmResetAll(user)
            try await user.sees(.text("Off, from default"))
            try await user.sees(.text("3, from default"))
            try screen.close()
        }

        @Test func test0006_4() async throws {
            let store = FlagStore.isolated(
                arguments: FlagEncoding.arguments(ExampleFlags.onThisDay, true))
            store.set(5, for: ExampleFlags.gridColumns)
            let (screen, user) = try render(store)
            try await confirmResetAll(user)
            try await user.sees(.text("3, from default"))
            try await user.sees(.text("On, from launch argument"))
            try screen.close()
        }

        @Test func test0006_5() async throws {
            let store = FlagStore.isolated(in: .production)
            store.set(true, for: ExampleFlags.mentions)
            store.set(5, for: ExampleFlags.gridColumns)
            let catalog = FlagCatalog([ExampleFlags.gridColumns, ExampleFlags.mentions])
            let screen = try Screen.render {
                FlagDebugView(catalog: catalog).environment(\.flagStore, store)
            }
            let user = User(screen)
            try await confirmResetAll(user)
            try await user.sees(.text("3, from default"))
            let saved = store.settings.object(forKey: ExampleFlags.mentions.settingsKey)
            #expect(saved as? Bool == true)
            try screen.close()
        }

        /// Taps "Reset all", then the dialog's own "Reset all", which covers the screen.
        private func confirmResetAll(_ user: User) async throws {
            try await user.taps(.button("Reset all"))
            try await user.taps(.button("Reset all"))
        }
    }
}
