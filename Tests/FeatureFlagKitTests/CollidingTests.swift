import FeatureFlagKit
import Testing

/// Requirement 0014: the catalog names the flags that collide.
extension FeatureFlagKitTests {
    @Suite struct Colliding {
        @Test func test0014_1() {
            let catalog = FlagCatalog([
                ExampleFlags.gridColumns, Flag("gridColumns", default: false, title: "Grid"),
            ])
            #expect(
                catalog.problems() == [
                    FlagCatalogProblem(
                        kind: .sharedName, subject: "gridColumns",
                        flags: ["gridColumns", "gridColumns"])
                ])
            #expect(
                catalog.problems().map(\.description) == [
                    "2 flags share the name \"gridColumns\""
                ])
        }

        @Test func test0014_2() {
            let rewind = Flag(
                "rewind", default: false, title: "Rewind", legacySettingsKey: "flag.gridColumns")
            let catalog = FlagCatalog([ExampleFlags.gridColumns, rewind])
            #expect(
                catalog.problems().map(\.description) == [
                    "Flags \"gridColumns\" and \"rewind\" share the settings key flag.gridColumns"
                ])
        }

        @Test func test0014_3() {
            let catalog = FlagCatalog([
                Flag("showHTMLView", default: false, title: "Show HTML view"),
                Flag("showHtmlView", default: false, title: "Show web view"),
            ])
            #expect(
                catalog.problems().map(\.description) == [
                    "Flags \"showHTMLView\" and \"showHtmlView\" share the environment variable "
                        + "FLAG_SHOW_HTML_VIEW"
                ])
        }

        @Test func test0014_4() {
            let catalog = FlagCatalog([ExampleFlags.gridColumns, ExampleFlags.daySuggestions])
            #expect(
                catalog.problems().map(\.description) == [
                    "Flag \"daySuggestions\" sits under \"suggestions\", "
                        + "which the catalog does not list"
                ])
        }

        @Test func test0014_5() {
            #expect(ExampleFlags.catalog.problems().isEmpty)
            #expect(ExampleFlags.groupCatalog.problems().isEmpty)
        }
    }
}
