import FeatureFlagKit
import FeatureFlagKitUI
import SwiftUI
import Testing
import UITestingLibrary

/// Requirement 0005: the debug screen that lists every flag and where its value came from.
extension FeatureFlagKitTests {
    @MainActor
    @Suite struct Debugging {
        /// Renders the debug screen for `catalog`, the example one unless given, on `store`.
        private func render(_ store: FlagStore, catalog: FlagCatalog = ExampleFlags.catalog)
            throws -> (Screen, User)
        {
            let screen = try Screen.render {
                FlagDebugView(catalog: catalog).environment(\.flagStore, store)
            }
            return (screen, User(screen))
        }

        /// A store launched with `-flag.onThisDay YES`.
        private var launched: FlagStore {
            .isolated(arguments: FlagEncoding.arguments(ExampleFlags.onThisDay, true))
        }

        @Test func test0005_1() async throws {
            let (screen, user) = try render(.isolated())
            try await user.sees(.role(.toggle, "On This Day"))
            try await user.sees(.text("Expires 2099-01-01"))
            try await user.sees(.role(.textField, "Grid columns"))
            try await user.sees(.text("3, from default"))
            try await user.sees(.text("Expires 2098-06-30"))
            try screen.close()
        }

        @Test func test0005_2() async throws {
            let (screen, user) = try render(launched)
            try await user.sees(.text("On, from launch argument"))
            try screen.close()
        }

        @Test func test0005_3() async throws {
            let (screen, user) = try render(.isolated())
            try await user.taps(.role(.toggle, "On This Day"))
            try await user.sees(.text("On, from user setting"))
            try screen.close()
        }

        @Test func test0005_4() async throws {
            let (screen, user) = try render(launched)
            let toggle = try await user.sees(.role(.toggle, "On This Day"))
            #expect(!toggle.isEnabled)
            try await user.sees(.text("Set by the launch argument, which beats this setting."))
            try screen.close()
        }

        @Test func test0005_5() async throws {
            let store = FlagStore.isolated()
            store.set(true, for: ExampleFlags.onThisDay)
            store.set(5, for: ExampleFlags.gridColumns)
            let (screen, user) = try render(store)
            try await user.sees(.text("5, from user setting"))
            try await user.taps(.button("Reset all"))
            // The confirmation covers the screen, so this "Reset all" is the dialog's own.
            try await user.taps(.button("Reset all"))
            try await user.sees(.text("Off, from default"))
            try await user.sees(.text("3, from default"))
            try screen.close()
        }

        @Test func test0005_6() async throws {
            let (screen, user) = try render(.isolated())
            try await user.sees(.role(.toggle, "On This Day"))
            let spoken = await user.reads().map(\.spoken)
            let title = try #require(spoken.firstIndex { $0.hasPrefix("On This Day") })
            #expect(
                Array(spoken.dropFirst(title + 1).prefix(2)) == [
                    "Off, from default", "Expires 2099-01-01",
                ])
            try screen.close()
        }

        @Test func test0005_7() async throws {
            let catalog = FlagCatalog([ExampleFlags.onThisDay, CustomFlag()])
            let (screen, user) = try render(.isolated(), catalog: catalog)
            try await user.sees(.text("Legacy banner"))
            try await user.sees(.text("Value unknown, not a Flag"))
            try screen.close()
        }

        @Test func test0005_8() async throws {
            let store = FlagStore.isolated(
                arguments: FlagEncoding.arguments(ExampleFlags.gridColumns, 6))
            let (screen, user) = try render(store)
            let field = try await user.sees(.role(.textField, "Grid columns"))
            #expect(!field.isEnabled)
            try await user.sees(.text("Set by the launch argument, which beats this setting."))
            try screen.close()
        }
    }
}
