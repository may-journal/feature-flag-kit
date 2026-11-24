import FeatureFlagKit
import FeatureFlagKitUI
import SwiftUI
import Testing
import UITestingLibrary

/// A choice with eight cases, more than a phone's row holds side by side.
private enum Weekday: String, FlagValue, CaseIterable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday, holiday
}

/// Requirement 0015: the debug screen edits a choice, a decimal and a text flag.
extension FeatureFlagKitTests {
    @MainActor
    @Suite struct Editing {
        private static let zoom = Flag("zoom", default: 1.0, title: "Zoom")
        private static let greeting = Flag("greeting", default: "Hi", title: "Greeting")
        private static let catalog = FlagCatalog([ExampleFlags.sortOrder, zoom, greeting])

        /// Renders the debug screen for a choice, a decimal and a text flag on `store`.
        private func render(_ store: FlagStore) throws -> (Screen, User) {
            let screen = try Screen.render {
                FlagDebugView(catalog: Self.catalog).environment(\.flagStore, store)
            }
            return (screen, User(screen))
        }

        @Test func test0015_1() async throws {
            let (screen, user) = try render(.isolated())
            try await user.sees(.text("newest, from default"))
            try await user.taps(.button("oldest"))
            try await user.sees(.text("oldest, from user setting"))
            try screen.close()
        }

        @Test func test0015_2() async throws {
            let (screen, user) = try render(.isolated())
            try await user.clears(.role(.textField, "Zoom"))
            try await user.types("1.5")
            try await user.presses(.enter)
            try await user.sees(.text("1.5, from user setting"))
            try screen.close()
        }

        @Test func test0015_3() async throws {
            let (screen, user) = try render(.isolated())
            try await user.clears(.role(.textField, "Greeting"))
            try await user.types("Hello")
            try await user.presses(.enter)
            try await user.sees(.text("Hello, from user setting"))
            try screen.close()
        }

        @Test func test0015_5() async throws {
            let weekday = Flag("weekStart", default: Weekday.monday, title: "Week starts")
            let screen = try Screen.render {
                FlagDebugView(catalog: FlagCatalog([weekday]))
                    .environment(\.flagStore, .isolated())
            }
            let user = User(screen)
            try await user.taps(.button("holiday"))
            try await user.sees(.text("holiday, from user setting"))
            try screen.close()
        }

        @Test func test0015_4() async throws {
            let store = FlagStore.isolated(arguments: FlagEncoding.arguments(Self.zoom, 2.5))
            let (screen, user) = try render(store)
            let field = try await user.sees(.role(.textField, "Zoom"))
            #expect(!field.isEnabled)
            try await user.sees(.text("2.5, from launch argument"))
            try await user.sees(.text("Set by the launch argument, which beats this setting."))
            try screen.close()
        }
    }
}
