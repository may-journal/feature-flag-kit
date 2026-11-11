import FeatureFlagKit
import FeatureFlagKitUI
import SwiftUI
import Testing
import UITestingLibrary

/// Requirement 0008: a setting that holds one of a list of choices.
extension FeatureFlagKitTests {
    @MainActor
    @Suite struct Choosing {
        /// Renders the sort setting's screen on `store` and checks it shows `choice`.
        private func expectSorted(by choice: String, on store: FlagStore) async throws {
            let screen = try Screen.render {
                SortSettingsScreen().environment(\.flagStore, store)
            }
            try await User(screen).sees(.text("Sorted by \(choice)"))
            try screen.close()
        }

        @Test func test0008_1() async throws {
            let store = FlagStore.isolated()
            let screen = try Screen.render {
                SortSettingsScreen().environment(\.flagStore, store)
            }
            let user = User(screen)
            try await user.sees(.text("Sorted by newest"))
            try await user.taps(.button("Oldest first"))
            try await user.sees(.text("Sorted by oldest"))
            try screen.close()
        }

        @Test func test0008_2() async throws {
            let store = FlagStore.isolated()
            store.settings.set("oldest", forKey: "browse.sortOrder")
            try await expectSorted(by: "oldest", on: store)
        }

        @Test func test0008_3() async throws {
            let store = FlagStore.isolated(
                arguments: FlagEncoding.arguments(ExampleFlags.sortOrder, .oldest))
            try await expectSorted(by: "oldest", on: store)
        }
    }
}
