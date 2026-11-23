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

#Preview("0016.1 Feature: left out of the build, parent off") {
    FlagDebugStory.feature(
        .story(in: .production) { $0.set(false, for: FlagDebugStory.suggestions) },
        FlagDebugStory.draftSuggestions)
}

#Preview("0016.2 Feature: left out of the build, parent on") {
    FlagDebugStory.feature(.story(in: .production), FlagDebugStory.draftSuggestions)
}
#endif
