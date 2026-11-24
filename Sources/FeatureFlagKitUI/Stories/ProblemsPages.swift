#if DEBUG
import FeatureFlagKit
import SwiftUI

// One page per acceptance of requirement 0021, each named by the acceptance it shows.

extension FlagDebugStory {
    /// A flag kept under Replay's settings key by an earlier release.
    static let rewind = Flag(
        "rewind", default: false, title: "Rewind", legacySettingsKey: "flag.replay")
    /// Replay and Rewind, which share one settings key.
    static let sharedKeyCatalog = FlagCatalog([replay, rewind])
    /// A shared name, a shared environment variable and a child whose parent is not listed.
    static let problemsCatalog = FlagCatalog([
        replay, Flag("replay", default: 3, title: "Replay speed"),
        Flag("showHTMLView", default: false, title: "Show HTML view"),
        Flag("showHtmlView", default: false, title: "Show web view"), daySuggestions,
    ])
}

#Preview("0021.1 Debug screen: names a shared key") {
    FlagDebugStory.debug(
        .story { $0.set(true, for: FlagDebugStory.replay) },
        catalog: FlagDebugStory.sharedKeyCatalog)
}

#Preview("0021.2 Debug screen: warns of each problem") {
    FlagDebugStory.debug(.story(), catalog: FlagDebugStory.problemsCatalog)
}

#Preview("0021.3 Debug screen: shows no problems for a clean catalog") {
    FlagDebugStory.debug(.story())
}
#endif
