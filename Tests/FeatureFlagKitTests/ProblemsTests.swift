import FeatureFlagKit
import FeatureFlagKitUI
import SwiftUI
import Testing
import UITestingLibrary

/// Requirement 0021: the debug screen warns when the catalog's flags collide.
extension FeatureFlagKitTests {
    @MainActor
    @Suite struct Problems {
        /// A flag kept under Replay's settings key by an earlier release.
        private let rewind = Flag(
            "rewind", default: false, title: "Rewind", legacySettingsKey: "flag.replay")
        private let replay = Flag("replay", default: false, title: "Replay")

        /// Renders the debug screen for `catalog` on `store`.
        private func render(_ catalog: FlagCatalog, _ store: FlagStore = .isolated()) throws
            -> (Screen, User)
        {
            let screen = try Screen.render {
                FlagDebugView(catalog: catalog).environment(\.flagStore, store)
            }
            return (screen, User(screen))
        }

        @Test func test0021_1() async throws {
            let store = FlagStore.isolated()
            store.set(true, for: replay)
            let (screen, user) = try render(FlagCatalog([replay, rewind]), store)
            try await user.sees(.text("Catalog problems"))
            let warning = "Flags \"replay\" and \"rewind\" share the settings key flag.replay"
            try await user.sees(.text("Warning: " + warning))
            try await user.sees(.role(.toggle, "Rewind"))
            let spoken = await user.reads().map(\.spoken)
            #expect(spoken.filter { $0 == "On, from user setting" }.count == 2)
            // The warning sits above both rows.
            let line = try #require(spoken.firstIndex(of: "Warning: " + warning))
            let firstRow = try #require(spoken.firstIndex { $0.hasPrefix("Replay") })
            #expect(line < firstRow)
            try screen.close()
        }

        @Test func test0021_2() async throws {
            let catalog = FlagCatalog([
                replay, Flag("replay", default: 3, title: "Replay speed"),
                Flag("showHTMLView", default: false, title: "Show HTML view"),
                Flag("showHtmlView", default: false, title: "Show web view"),
                ExampleFlags.daySuggestions,
            ])
            let (screen, user) = try render(catalog)
            try await user.sees(.role(.textField, "Replay speed"))
            let warnings = await user.reads().map(\.spoken).filter { $0.hasPrefix("Warning: ") }
            // The words test0014 already expects of the catalog.
            #expect(
                warnings == [
                    "Warning: 2 flags share the name \"replay\"",
                    "Warning: Flags \"showHTMLView\" and \"showHtmlView\" share the environment "
                        + "variable FLAG_SHOW_HTML_VIEW",
                    "Warning: Flag \"daySuggestions\" sits under \"suggestions\", "
                        + "which the catalog does not list",
                ])
            try screen.close()
        }

        @Test func test0021_3() async throws {
            let (screen, user) = try render(ExampleFlags.catalog)
            try await user.sees(.role(.toggle, "On This Day"))
            try await user.doesNotSee(.text("Catalog problems"))
            try screen.close()
        }
    }
}
