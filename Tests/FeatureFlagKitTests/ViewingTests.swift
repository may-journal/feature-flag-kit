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
            let defaults = UserDefaults.standard
            defaults.set(true, forKey: ExampleFlags.onThisDay.settingsKey)
            defer { defaults.removeObject(forKey: ExampleFlags.onThisDay.settingsKey) }
            let screen = try Screen.render { WrappedMemoriesScreen() }
            try await User(screen).sees(.text("On This Day"))
            try screen.close()
        }

        @Test func test0004_2() async throws {
            let store = FlagStore.isolated()
            let screen = try Screen.render {
                WrappedMemoriesScreen().environment(\.flagStore, store)
            }
            let user = User(screen)
            try await user.sees(.text("Memories"))
            try await user.doesNotSee(.text("On This Day"))
            store.set(true, for: ExampleFlags.onThisDay)
            try await user.sees(.text("On This Day"))
            try screen.close()
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
    }
}
