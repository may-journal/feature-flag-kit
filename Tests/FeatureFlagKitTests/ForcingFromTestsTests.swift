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
            #expect(app.launchArguments == ["-uiTesting", "YES", "-flag.onThisDay", "true"])
        }

        @Test func test0007_5() async throws {
            let app = UITestApp(launchArguments: ["-flag.onThisDay", "NO"])
            app.overrideFlags(.set(flag, true))
            try await expectOnThisDay(shown: true, on: .isolated(arguments: app.launchArguments))
        }

        @Test func test0007_6() {
            let launched = FlagStore.isolated(arguments: FlagLaunch.arguments(.set(layout, .list)))
            #expect(launched[layout] == .list)
        }

        @Test func test0007_7() {
            let app = UITestApp(launchEnvironment: ["UI_TESTING": "YES"])
            app.overrideFlagsInEnvironment(.set(flag, true))
            #expect(app.launchEnvironment == ["UI_TESTING": "YES", "FLAG_ON_THIS_DAY": "true"])
        }

        /// A flag of the app's own value type, whose description is a label, not launch text.
        private let layout = Flag(
            "layout", default: Layout.grid, title: "Layout",
            expires: FlagExpiry(year: 2099, month: 1, day: 1))
    }
}

/// An app's own flag value: launch text is the raw value, the description a label.
enum Layout: String, FlagValue, CustomStringConvertible {
    case grid, list

    var stored: Any { rawValue }
    var flagText: String { rawValue }
    var description: String { self == .grid ? "Grid layout" : "List layout" }

    init?(flagText: String) {
        self.init(rawValue: flagText)
    }
}

/// Stands in for `XCUIApplication`, which runs only in a UI test bundle.
@MainActor
final class UITestApp: FlagLaunching {
    var launchArguments: [String]
    var launchEnvironment: [String: String]

    init(launchArguments: [String] = [], launchEnvironment: [String: String] = [:]) {
        self.launchArguments = launchArguments
        self.launchEnvironment = launchEnvironment
    }
}
