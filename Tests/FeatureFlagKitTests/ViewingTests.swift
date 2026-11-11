import FeatureFlagKit
import FeatureFlagKitUI
import Foundation
import SwiftUI
import Testing
import UITestingLibrary

/// Requirement 0004: reading a flag in a SwiftUI view with `@FlagState`.
extension FeatureFlagKitTests {
    @MainActor
    @Suite struct Viewing {
        @Test func test0004_1() async throws {
            try await withStandardDefaults {
                UserDefaults.standard.set(true, forKey: ExampleFlags.onThisDay.settingsKey)
                let screen = try Screen.render { WrappedMemoriesScreen() }
                try await User(screen).sees(.text("On This Day"))
                try screen.close()
            }
        }

        @Test func test0004_2() async throws {
            try await withStandardDefaults {
                let screen = try Screen.render { WrappedMemoriesScreen() }
                let user = User(screen)
                try await user.sees(.text("Memories"))
                try await user.doesNotSee(.text("On This Day"))
                FlagStore.live().set(true, for: ExampleFlags.onThisDay)
                try await user.sees(.text("On This Day"))
                try screen.close()
            }
        }

        @Test func test0004_3() async throws {
            let store = FlagStore.isolated()
            let screen = try Screen.render {
                BetaSettingsScreen().environment(\.flagStore, store)
            }
            let user = User(screen)
            try await user.taps(.role(.toggle, "Show On This Day"))
            try await user.sees(.text("On This Day"))
            let resolution = store.resolve(ExampleFlags.onThisDay)
            #expect(resolution.value && resolution.origin == .user)
            try screen.close()
        }

        @Test func test0004_4() async throws {
            let launched = FlagStore.isolated(
                arguments: FlagEncoding.arguments(ExampleFlags.onThisDay, true))
            let screen = try Screen.render {
                BetaSettingsScreen().environment(\.flagStore, launched)
            }
            let user = User(screen)
            try await user.sees(.text("On This Day"))
            let toggle = try await user.sees(.role(.toggle, "Show On This Day"))
            #expect(toggle.value == "0")
            try screen.close()
        }

        @Test func test0004_5() async throws {
            let screen = try Screen.render {
                SwipedMemoriesScreen().environment(\.flagStore, .isolated())
            }
            let user = User(screen)
            try await user.drags(.text("Page 1"), by: CGVector(dx: -220, dy: 0), speed: .slow)
            try await user.sees(.text("Page 2"))
            try screen.close()
        }

        /// Runs `body` with the flag's key cleared from the standard defaults the live
        /// store reads, before and after. The serialized parent suite keeps this one at a time.
        private func withStandardDefaults(_ body: () async throws -> Void) async throws {
            let key = ExampleFlags.onThisDay.settingsKey
            UserDefaults.standard.removeObject(forKey: key)
            defer { UserDefaults.standard.removeObject(forKey: key) }
            try await body()
        }
    }
}
