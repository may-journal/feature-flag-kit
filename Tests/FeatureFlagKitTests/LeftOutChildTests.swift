import FeatureFlagKit
import Testing

/// Requirement 0016: an off parent comes before the build when a child is left out.
extension FeatureFlagKitTests {
    @Suite struct LeftOutChild {
        /// A child that starts on and ships in debug builds only, under a parent in every build.
        private static let draftSuggestions = Flag(
            "draftSuggestions", default: true, title: "For drafts", availability: [.debug],
            parent: ExampleFlags.suggestions)

        @Test func test0016_1() {
            let store = FlagStore.isolated(in: .production)
            store.set(false, for: ExampleFlags.suggestions)
            let resolution = store.resolve(Self.draftSuggestions)
            #expect(!resolution.value)
            #expect(resolution.origin == .parent(ExampleFlags.suggestions))
        }

        @Test func test0016_2() {
            let store = FlagStore.isolated(in: .production)
            let resolution = store.resolve(Self.draftSuggestions)
            #expect(resolution.value)
            #expect(resolution.origin == .unavailable(in: .production))
        }
    }
}
