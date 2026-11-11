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
            let changes = store.userChanges(in: ExampleFlags.catalog)
            let screen = try Screen.render {
                BetaSettingsScreen().environment(\.flagStore, store)
            }
            try await User(screen).taps(.role(.toggle, "Show On This Day"))
            #expect(
                await firstChanges(1, of: changes) == [
                    FlagChange(
                        name: "onThisDay", key: "beta.onThisDay", rawValue: .bool(true),
                        writer: .app)
                ])
            try screen.close()
        }

        @Test func test0009_2() async throws {
            let store = FlagStore.isolated()
            store.set(5, for: ExampleFlags.gridColumns)
            let changes = store.userChanges(in: ExampleFlags.catalog)
            let screen = try Screen.render {
                FlagDebugView(catalog: ExampleFlags.catalog).environment(\.flagStore, store)
            }
            let user = User(screen)
            try await user.taps(.button("Reset all"))
            try await user.taps(.button("Reset all"))
            #expect(
                await firstChanges(1, of: changes) == [
                    FlagChange(
                        name: "gridColumns", key: "flag.gridColumns", rawValue: nil, writer: .app)
                ])
            try screen.close()
        }

        @Test func test0009_3() async throws {
            // The app's own defaults, whose change notice can arrive before the import returns.
            let suite = "FeatureFlagKitTests.\(UUID().uuidString)"
            let defaults = try #require(UserDefaults(suiteName: suite))
            defer { defaults.removePersistentDomain(forName: suite) }
            let store = FlagStore.live(defaults: defaults)
            let changes = store.userChanges(in: ExampleFlags.catalog)
            store.importUserValues(["beta.onThisDay": .bool(true), "flag.gridColumns": .int(5)])
            #expect(
                Set(await firstChanges(2, of: changes)) == [
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

        @Test func test0009_5() {
            let store = FlagStore.isolated()
            _ = store.userChanges(in: ExampleFlags.catalog)
            store.set(true, for: ExampleFlags.onThisDay)
            store.importUserValues(["beta.onThisDay": .bool(false)])
            let nextRelease = Flag(
                "onThisDay", default: true, title: "On This Day",
                expires: ExampleFlags.onThisDay.expires, legacySettingsKey: "beta.onThisDay")
            #expect(store[nextRelease])
        }

        @Test func test0009_6() {
            let store = FlagStore.isolated()
            store.set(true, for: ExampleFlags.onThisDay)
            store.importUserValues(["beta.onThisDay": .string("maybe")])
            #expect(store[ExampleFlags.onThisDay])
        }

        /// The first `count` changes `stream` yields, or none once two seconds pass, so a missed
        /// change fails the test rather than hanging it.
        private func firstChanges(_ count: Int, of stream: AsyncStream<FlagChange>) async
            -> [FlagChange]
        {
            await withTaskGroup(of: [FlagChange]?.self) { group in
                group.addTask {
                    var heard: [FlagChange] = []
                    for await change in stream {
                        heard.append(change)
                        if heard.count == count { break }
                    }
                    return heard
                }
                group.addTask {
                    try? await Task.sleep(for: .seconds(2))
                    return nil
                }
                let first = await group.next().flatMap { $0 }
                group.cancelAll()
                return first ?? []
            }
        }
    }
}
