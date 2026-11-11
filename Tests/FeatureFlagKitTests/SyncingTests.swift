import FeatureFlagKit
import FeatureFlagKitUI
import Foundation
import SwiftUI
import Testing
import UITestingLibrary

/// Requirement 0009: a sync hook that hears the user's changes and imports values back.
extension FeatureFlagKitTests {
    @MainActor
    @Suite struct Syncing {
        @Test func test0009_1() async throws {
            let store = FlagStore.isolated()
            var changes = store.userChanges(in: ExampleFlags.catalog).makeAsyncIterator()
            let screen = try Screen.render {
                BetaSettingsScreen().environment(\.flagStore, store)
            }
            try await User(screen).taps(.role(.toggle, "Show On This Day"))
            let change = await changes.next()
            #expect(
                change
                    == FlagChange(
                        name: "onThisDay", key: "beta.onThisDay", rawValue: .bool(true),
                        writer: .app))
            try screen.close()
        }

        @Test func test0009_2() async throws {
            let store = FlagStore.isolated()
            store.set(5, for: ExampleFlags.gridColumns)
            var changes = store.userChanges(in: ExampleFlags.catalog).makeAsyncIterator()
            let screen = try Screen.render {
                FlagDebugView(catalog: ExampleFlags.catalog).environment(\.flagStore, store)
            }
            let user = User(screen)
            try await user.taps(.button("Reset all"))
            try await user.taps(.button("Reset all"))
            let change = await changes.next()
            #expect(
                change
                    == FlagChange(
                        name: "gridColumns", key: "flag.gridColumns", rawValue: nil, writer: .app))
            try screen.close()
        }

        @Test func test0009_3() async throws {
            // The app's own defaults, whose change notice can arrive before the import returns.
            let suite = "FeatureFlagKitTests.\(UUID().uuidString)"
            let defaults = try #require(UserDefaults(suiteName: suite))
            defer { defaults.removePersistentDomain(forName: suite) }
            let store = FlagStore.live(defaults: defaults)
            var changes = store.userChanges(in: ExampleFlags.catalog).makeAsyncIterator()
            store.importUserValues(["beta.onThisDay": .bool(true), "flag.gridColumns": .int(5)])
            var heard: Set<FlagChange> = []
            for _ in 0..<2 {
                if let change = await changes.next() { heard.insert(change) }
            }
            #expect(
                heard == [
                    FlagChange(
                        name: "onThisDay", key: "beta.onThisDay", rawValue: .bool(true),
                        writer: .import),
                    FlagChange(
                        name: "gridColumns", key: "flag.gridColumns", rawValue: .int(5),
                        writer: .import),
                ])
        }

        @Test func test0009_4() async throws {
            let store = FlagStore.isolated()
            let screen = try Screen.render {
                WrappedMemoriesScreen().environment(\.flagStore, store)
            }
            let user = User(screen)
            try await user.sees(.text("Memories"))
            try await user.doesNotSee(.text("On This Day"))
            store.importUserValues(["beta.onThisDay": .bool(true)])
            try await user.sees(.text("On This Day"))
            try screen.close()
        }
    }
}
