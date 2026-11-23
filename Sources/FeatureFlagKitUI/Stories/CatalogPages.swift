#if DEBUG
import FeatureFlagKit
import SwiftUI

// One page per acceptance of requirement 0014, each named by the acceptance it shows.

/// The collisions an app's catalog test names, or that it names none.
struct ProblemsStory: View {
    let catalog: FlagCatalog

    var body: some View {
        let problems = catalog.problems()
        Form {
            Section("Listed") {
                ForEach(Array(catalog.flags.enumerated()), id: \.offset) { entry in
                    Text("\(entry.element.name), under \(entry.element.settingsKey)")
                }
            }
            Section("Problems") {
                if problems.isEmpty { Text("None") }
                ForEach(problems, id: \.self) { Text($0.description) }
            }
        }
    }
}

#Preview("0014.1 Catalog: two flags with one name") {
    ProblemsStory(
        catalog: FlagCatalog([
            FlagDebugStory.replay, Flag("replay", default: 3, title: "Replay speed"),
        ]))
}

#Preview("0014.2 Catalog: a legacy key that is another flag's key") {
    ProblemsStory(
        catalog: FlagCatalog([
            FlagDebugStory.replay,
            Flag("rewind", default: false, title: "Rewind", legacySettingsKey: "flag.replay"),
        ]))
}

#Preview("0014.3 Catalog: two names that spell one variable") {
    ProblemsStory(
        catalog: FlagCatalog([
            Flag("showHTMLView", default: false, title: "Show HTML view"),
            Flag("showHtmlView", default: false, title: "Show web view"),
        ]))
}

#Preview("0014.4 Catalog: a child without its parent") {
    ProblemsStory(catalog: FlagCatalog([FlagDebugStory.replay, FlagDebugStory.daySuggestions]))
}

#Preview("0014.5 Catalog: no flags collide") {
    ProblemsStory(catalog: FlagDebugStory.catalog)
}
#endif
