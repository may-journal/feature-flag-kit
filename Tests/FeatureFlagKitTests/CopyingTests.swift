import FeatureFlagKit
import SwiftUI
import Testing
import UITestingLibrary

@testable import FeatureFlagKitUI

/// What the debug screen copied, in place of the system pasteboard.
@MainActor
private final class CopiedText {
    var text: String?
}

/// Requirement 0017: the debug screen copies the flags as launch arguments.
extension FeatureFlagKitTests {
    @MainActor
    @Suite struct Copying {
        /// Renders the debug screen on `store`, copying into `copied`.
        private func render(_ store: FlagStore, _ copied: CopiedText) throws -> (Screen, User) {
            let screen = try Screen.render {
                FlagDebugView(catalog: ExampleFlags.catalog)
                    .environment(\.flagStore, store)
                    .environment(\.flagPasteboard, FlagPasteboard { copied.text = $0 })
            }
            return (screen, User(screen))
        }

        @Test func test0017_1() {
            let store = FlagStore.isolated()
            store.set(true, for: ExampleFlags.onThisDay)
            store.set(5, for: ExampleFlags.gridColumns)
            let arguments = store.launchArguments(for: ExampleFlags.catalog)
            let launched = FlagStore.isolated(arguments: arguments)
            #expect(launched[ExampleFlags.onThisDay])
            #expect(launched[ExampleFlags.gridColumns] == 5)
            #expect(launched.resolve(ExampleFlags.gridColumns).origin == .launchArgument)
        }

        @Test func test0017_2() async throws {
            let store = FlagStore.isolated()
            store.set(5, for: ExampleFlags.gridColumns)
            let copied = CopiedText()
            let (screen, user) = try render(store, copied)
            try await user.taps(.button("Copy launch arguments"))
            try await user.sees(.button("Copied"))
            #expect(copied.text == "-flag.gridColumns 5")
            try screen.close()
        }

        @Test func test0017_3() async throws {
            let (screen, user) = try render(.isolated(), CopiedText())
            let button = try await user.sees(.button("Copy launch arguments"))
            #expect(!button.isEnabled)
            try screen.close()
        }

        @Test func test0017_4() {
            let store = FlagStore.isolated()
            store.set(false, for: ExampleFlags.daySuggestions)
            store.set(false, for: ExampleFlags.suggestions)
            let arguments = store.launchArguments(for: ExampleFlags.groupCatalog)
            let launched = FlagStore.isolated(
                arguments: arguments + FlagEncoding.arguments(ExampleFlags.suggestions, true))
            #expect(!launched[ExampleFlags.daySuggestions])
            #expect(launched.resolve(ExampleFlags.daySuggestions).origin == .launchArgument)
        }
    }
}
