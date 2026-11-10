import FeatureFlagKit
import Testing
import UITestingLibrary

/// Requirement 0002: forcing a flag for a test or a manual run.
extension FeatureFlagKitTests {
    @MainActor
    @Suite struct Overriding {
        private let flag = ExampleFlags.onThisDay

        /// A store whose user turned the flag on, so only an override can hide the row.
        private func store(arguments: [String] = [], environment: [String: String] = [:])
            -> FlagStore
        {
            let store = FlagStore.isolated(arguments: arguments, environment: environment)
            store.set(true, for: flag)
            return store
        }

        @Test func test0002_1() async throws {
            let launched = store(arguments: FlagEncoding.arguments(flag, false))
            try await expectOnThisDay(shown: false, on: launched)
        }

        @Test func test0002_2() async throws {
            let launched = store(environment: ["FLAG_ON_THIS_DAY": "NO"])
            try await expectOnThisDay(shown: false, on: launched)
        }

        @Test func test0002_3() async throws {
            let launched = store(
                arguments: ["-flag.onThisDay", "NO"], environment: ["FLAG_ON_THIS_DAY": "YES"])
            try await expectOnThisDay(shown: false, on: launched)
        }

        @Test func test0002_4() {
            let launched = store(arguments: ["-flag.onThisDay", "YES"])
            #expect(launched.resolve(flag).origin == .launchArgument)
        }
    }
}
