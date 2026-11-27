import FeatureFlagKit
import SwiftUI
import Testing
import UITestingLibrary

@testable import FeatureFlagKitUI

/// Requirement 0019: the debug screen's search narrows its rows.
extension FeatureFlagKitTests {
    @MainActor
    @Suite struct Searching {
        /// A list with a group, so a matching child can keep its parent.
        private let catalog = FlagCatalog([
            ExampleFlags.onThisDay, ExampleFlags.gridColumns, ExampleFlags.suggestions,
            ExampleFlags.daySuggestions, ExampleFlags.photoSuggestions,
        ])

        /// Renders the debug screen on `store` in a navigation stack, as an app opens it, with
        /// `query` already in the search field. The testing library cannot focus a Mac's
        /// toolbar search field, so the field opens holding what the user typed.
        private func render(_ store: FlagStore, query: String) throws -> (Screen, User) {
            let screen = try Screen.render {
                NavigationStack {
                    FlagDebugView(catalog: catalog, confirmsReset: false, query: query)
                }
                .environment(\.flagStore, store)
            }
            return (screen, User(screen))
        }

        /// The titles of the rows the screen shows, in order.
        private func titles(_ user: User) async -> [String] {
            let shown = ["On This Day", "Grid columns", "Use suggestions", "For days", "For photos"]
            return await user.reads().map(\.spoken).compactMap { spoken in
                shown.first { spoken.hasPrefix($0) }
            }
        }

        @Test func test0019_1() async throws {
            let (screen, user) = try render(.isolated(), query: "day ")
            try await user.sees(.role(.toggle, "For days"))
            try await user.doesNotSee(.role(.toggle, "For photos"))
            #expect(await titles(user) == ["On This Day", "Use suggestions", "For days"])
            try screen.close()
        }

        @Test func test0019_2() async throws {
            // "For days" and "For photos" hold it only in their names.
            let (screen, user) = try render(.isolated(), query: "SUGGESTIONS")
            try await user.sees(.role(.toggle, "For photos"))
            #expect(await titles(user) == ["Use suggestions", "For days", "For photos"])
            try screen.close()
        }

        @Test func test0019_3() async throws {
            let store = FlagStore.isolated()
            store.set(true, for: ExampleFlags.onThisDay)
            let (screen, user) = try render(store, query: "zzz")
            try await user.sees(.text("No flags match"))
            try await user.taps(.button("Reset all"))
            try await user.taps(.button("Reset all"))
            #expect(store.resolve(ExampleFlags.onThisDay).origin == .compiledDefault)
            try screen.close()
        }

        @Test func test0019_4() {
            #expect(catalog.grouped(matching: "zzz").isEmpty)
            let every = catalog.grouped.map(\.flag.name)
            #expect(catalog.grouped(matching: "").map(\.flag.name) == every)
        }
    }
}
