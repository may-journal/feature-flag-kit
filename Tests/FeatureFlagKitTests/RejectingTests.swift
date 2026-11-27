import FeatureFlagKit
import FeatureFlagKitUI
import SwiftUI
import Testing
import UITestingLibrary

/// Requirement 0018: the store names an override it cannot read.
extension FeatureFlagKitTests {
    @MainActor
    @Suite struct Rejecting {
        private let mistyped = ["-flag.gridColumns", "four"]

        @Test func test0018_1() {
            let store = FlagStore.isolated(arguments: mistyped)
            #expect(
                store.rejectedOverrides(in: ExampleFlags.catalog) == [
                    FlagRejectedOverride(
                        name: "gridColumns", origin: .launchArgument, text: "four")
                ])
            #expect(store.resolve(ExampleFlags.gridColumns).origin == .compiledDefault)
        }

        @Test func test0018_2() {
            let store = FlagStore.isolated(environment: ["FLAG_GRID_COLUMNS": "four"])
            #expect(
                store.rejectedOverrides(in: ExampleFlags.catalog) == [
                    FlagRejectedOverride(name: "gridColumns", origin: .environment, text: "four")
                ])
        }

        @Test func test0018_3() async throws {
            let store = FlagStore.isolated(arguments: mistyped)
            let screen = try Screen.render {
                FlagDebugView(catalog: ExampleFlags.catalog).environment(\.flagStore, store)
            }
            let user = User(screen)
            try await user.sees(.text("3, from default"))
            try await user.sees(
                .text("Launch argument \"four\" is no value for this flag, so it is ignored."))
            try screen.close()
        }

        @Test func test0018_4() {
            let store = FlagStore.isolated(arguments: mistyped, in: .production)
            #expect(store.rejectedOverrides(in: ExampleFlags.catalog).isEmpty)
        }

        @Test func test0018_5() {
            // Labs ships in debug builds only, and the launch argument decides Grid columns.
            let store = FlagStore.isolated(
                arguments: ["-flag.gridColumns", "5"],
                environment: ["FLAG_GRID_COLUMNS": "four", "FLAG_LABS": "maybe"], in: .internal)
            let catalog = FlagCatalog([ExampleFlags.gridColumns, ExampleFlags.labs])
            #expect(store[ExampleFlags.gridColumns] == 5)
            #expect(store.rejectedOverrides(in: catalog).isEmpty)
        }
    }
}
