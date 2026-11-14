import FeatureFlagKit
import FeatureFlagKitUI
import SwiftUI
import Testing
import UITestingLibrary

/// Requirement 0012: a flag ships in the environments it names, and overrides stay out of
/// production.
extension FeatureFlagKitTests {
    @MainActor
    @Suite struct Shipping {
        private let beta = ExampleFlags.mentions

        @Test func test0012_1() {
            let store = FlagStore.isolated(in: .production)
            store.set(true, for: beta)
            #expect(!store[beta])
        }

        @Test func test0012_2() {
            let store = FlagStore.isolated(in: .internal)
            #expect(store[beta])
        }

        @Test func test0012_3() {
            let flag = ExampleFlags.onThisDay
            let store = FlagStore.isolated(
                arguments: FlagEncoding.arguments(flag, true),
                environment: FlagEncoding.environment(flag, true), in: .production)
            #expect(!store[flag])
        }

        @Test func test0012_4() {
            let flag = ExampleFlags.onThisDay
            let store = FlagStore.isolated(
                arguments: FlagEncoding.arguments(flag, true), in: .internal)
            let resolution = store.resolve(flag)
            #expect(resolution.value && resolution.origin == .launchArgument)
        }

        @Test func test0012_5() {
            let store = FlagStore.isolated(in: .production)
            store.set(false, for: ExampleFlags.tips)
            #expect(!store[ExampleFlags.tips])
        }

        @Test func test0012_6() async throws {
            let store = FlagStore.isolated(in: .production)
            let screen = try Screen.render {
                FlagDebugView(catalog: FlagCatalog([ExampleFlags.onThisDay, beta]))
                    .environment(\.flagStore, store)
            }
            let user = User(screen)
            try await user.sees(.role(.toggle, "On This Day"))
            let spoken = await user.reads().map(\.spoken)
            #expect(!spoken.contains { $0.hasPrefix("Mentions") })
            try screen.close()
        }

        @Test func test0012_7() async throws {
            let store = FlagStore.isolated(in: .production)
            let screen = try Screen.render {
                BetaFeaturesScreen().environment(\.flagStore, store)
            }
            let user = User(screen)
            try await user.sees(.text("Beta features"))
            let spoken = await user.reads().map(\.spoken)
            #expect(!spoken.contains { $0.hasPrefix("Show Mentions") })
            try screen.close()
        }

        @Test func test0012_8() {
            let store = FlagStore.isolated(in: .production)
            #expect(!store[ExampleFlags.labsSearch])
        }
    }
}
