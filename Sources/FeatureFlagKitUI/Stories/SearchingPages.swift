#if DEBUG
import FeatureFlagKit
import SwiftUI

// One page per acceptance of requirement 0019, each named by the acceptance it shows.

#Preview("0019.1 Debug screen: shows each match") {
    FlagDebugStory.debug(.story(), query: "day")
}

#Preview("0019.2 Debug screen: matches a name") {
    FlagDebugStory.debug(.story(), query: "SUGGESTIONS")
}

#Preview("0019.3 Debug screen: resets with no match") {
    FlagDebugStory.debug(FlagDebugStory.toggled, query: "zzz")
}

#Preview("0019.4 Debug screen: shows every row again") {
    FlagDebugStory.debug(.story())
}
#endif
