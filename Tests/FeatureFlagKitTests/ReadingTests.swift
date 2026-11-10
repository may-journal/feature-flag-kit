import FeatureFlagKit
import Foundation
import Testing
import UITestingLibrary

/// Requirement 0001: reading a flag from its one definition and the user's toggle.
extension FeatureFlagKitTests {
    @MainActor
    @Suite struct Reading {
        @Test func test0001_1() async throws {
            let screen = try Screen.render { MemoriesScreen(store: .isolated()) }
            let user = User(screen)
            try await user.sees(.text("Memories"))
            try await user.doesNotSee(.text("On This Day"))
            try screen.close()
        }

        @Test func test0001_2() async throws {
            let store = FlagStore.isolated()
            store.set(true, for: ExampleFlags.onThisDay)
            let screen = try Screen.render { MemoriesScreen(store: store) }
            try await User(screen).sees(.text("On This Day"))
            try screen.close()
        }

        @Test func test0001_3() async throws {
            let suite = "FeatureFlagKitTests.\(UUID().uuidString)"
            let defaults = try #require(UserDefaults(suiteName: suite))
            defer { defaults.removePersistentDomain(forName: suite) }
            defaults.set(true, forKey: "beta.onThisDay")
            let screen = try Screen.render { MemoriesScreen(store: .live(defaults: defaults)) }
            try await User(screen).sees(.text("On This Day"))
            try screen.close()
        }

        @Test func test0001_4() async throws {
            FlagStore.isolated().set(true, for: ExampleFlags.onThisDay)
            let screen = try Screen.render { MemoriesScreen(store: .isolated()) }
            let user = User(screen)
            try await user.sees(.text("Memories"))
            try await user.doesNotSee(.text("On This Day"))
            try screen.close()
        }
    }
}
