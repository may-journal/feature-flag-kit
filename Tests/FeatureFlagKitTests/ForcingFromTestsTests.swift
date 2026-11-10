import FeatureFlagKit
import FeatureFlagKitTesting
import Testing

/// Requirement 0007: forcing flags from a test with the testing helpers.
extension FeatureFlagKitTests {
    @MainActor
    @Suite struct ForcingFromTests {
        private let flag = ExampleFlags.onThisDay

        @Test func test0007_1() async throws {
            let launched = FlagStore.isolated(arguments: FlagLaunch.arguments(.set(flag, false)))
            launched.set(true, for: flag)
            try await expectOnThisDay(shown: false, on: launched)
        }

        @Test func test0007_2() async throws {
            let launched = FlagStore.isolated(environment: FlagLaunch.environment(.set(flag, true)))
            try await expectOnThisDay(shown: true, on: launched)
        }

        @Test func test0007_3() {
            let arguments = FlagLaunch.arguments(
                .set(flag, true), .set(ExampleFlags.gridColumns, 5))
            let launched = FlagStore.isolated(arguments: arguments)
            #expect(launched[flag] == true)
            #expect(launched[ExampleFlags.gridColumns] == 5)
        }

        @Test func test0007_4() {
            let app = UITestApp(launchArguments: ["-uiTesting", "YES"])
            app.overrideFlags(.set(flag, true))
            #expect(Array(app.launchArguments.prefix(2)) == ["-uiTesting", "YES"])
        }

        @Test func test0007_5() async throws {
            let app = UITestApp()
            app.overrideFlags(.set(flag, true))
            try await expectOnThisDay(shown: true, on: .isolated(arguments: app.launchArguments))
        }
    }
}

/// Stands in for `XCUIApplication`, which runs only in a UI test bundle.
@MainActor
final class UITestApp: FlagLaunching {
    var launchArguments: [String]

    init(launchArguments: [String] = []) {
        self.launchArguments = launchArguments
    }
}
