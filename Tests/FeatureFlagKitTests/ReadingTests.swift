import FeatureFlagKit
import Foundation
import Testing
import UITestingLibrary

/// Requirement 0001: reading a flag from its one definition and the user's toggle.
extension FeatureFlagKitTests {
    @MainActor
    @Suite struct Reading {
        @Test func test0001_1() async throws {
            try await expectOnThisDay(shown: false, on: .isolated())
        }

        @Test func test0001_2() async throws {
            let store = FlagStore.isolated()
            store.set(true, for: ExampleFlags.onThisDay)
            try await expectOnThisDay(shown: true, on: store)
        }

        @Test func test0001_3() async throws {
            try await withDefaults { defaults in
                defaults.set(true, forKey: "beta.onThisDay")
                try await expectOnThisDay(shown: true, on: .live(defaults: defaults))
            }
        }

        @Test func test0001_4() async throws {
            FlagStore.isolated().set(true, for: ExampleFlags.onThisDay)
            try await expectOnThisDay(shown: false, on: .isolated())
        }

        @Test func test0001_5() async throws {
            let store = FlagStore.isolated()
            try await expectLiveOnThisDay(on: store) {
                store.set(true, for: ExampleFlags.onThisDay)
            }
        }

        @Test func test0001_6() {
            let store = FlagStore.isolated()
            store.set(true, for: ExampleFlags.onThisDay)
            store.set(false, for: ExampleFlags.onThisDay)
            let nextRelease = Flag(
                "onThisDay", default: true, title: "On This Day",
                expires: ExampleFlags.onThisDay.expires, legacySettingsKey: "beta.onThisDay")
            #expect(store[nextRelease])
        }

        @Test func test0001_7() async throws {
            try await withDefaults { defaults in
                try await expectLiveOnThisDay(on: .live(defaults: defaults)) {
                    FlagStore.live(defaults: defaults).set(true, for: ExampleFlags.onThisDay)
                }
            }
        }

        @Test func test0001_8() async throws {
            try await withDefaults { defaults in
                try await expectLiveOnThisDay(on: .live(defaults: defaults)) {
                    defaults.set(true, forKey: "beta.onThisDay")
                }
            }
        }

        /// Runs `body` on a fresh defaults suite, removed afterwards.
        private func withDefaults(_ body: (UserDefaults) async throws -> Void) async throws {
            let suite = "FeatureFlagKitTests.\(UUID().uuidString)"
            let defaults = try #require(UserDefaults(suiteName: suite))
            defer { defaults.removePersistentDomain(forName: suite) }
            try await body(defaults)
        }

        /// Renders the watching screen on `store`, runs `flip`, and checks the row appears.
        private func expectLiveOnThisDay(on store: FlagStore, flip: () -> Void) async throws {
            let screen = try Screen.render { LiveMemoriesScreen(store: store) }
            let user = User(screen)
            try await user.sees(.text("Memories"))
            try await user.doesNotSee(.text("On This Day"))
            flip()
            try await user.sees(.text("On This Day"))
            try screen.close()
        }
    }
}
