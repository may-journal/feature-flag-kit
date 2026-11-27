#if DEBUG
import FeatureFlagKit
import SwiftUI

// One page per acceptance of requirement 0016, each named by the acceptance it shows.

extension FlagDebugStory {
    /// A child that starts on and ships in debug builds only, under a parent in every build.
    static let draftSuggestions = Flag(
        "draftSuggestions", default: true, title: "For drafts", availability: [.debug],
        parent: suggestions)
}

#Preview("0016.1 Feature: reads off under an off parent") {
    FlagDebugStory.feature(
        .story(in: .production) { $0.set(false, for: FlagDebugStory.suggestions) },
        FlagDebugStory.draftSuggestions)
}

#Preview("0016.2 Feature: reads its default under an on parent") {
    FlagDebugStory.feature(.story(in: .production), FlagDebugStory.draftSuggestions)
}
#endif
