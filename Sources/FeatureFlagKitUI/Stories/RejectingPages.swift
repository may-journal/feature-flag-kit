#if DEBUG
import FeatureFlagKit
import SwiftUI

// One page per acceptance of requirement 0018, each named by the acceptance it shows.

#Preview("0018.1 Debug screen: names a launch argument") {
    FlagDebugStory.debug(.story(arguments: ["-flag.gridColumns", "four"]))
}

#Preview("0018.2 Debug screen: names an environment variable") {
    FlagDebugStory.debug(.story(variables: ["FLAG_GRID_COLUMNS": "four"]))
}

#Preview("0018.3 Debug screen: says the argument is ignored") {
    FlagDebugStory.debug(
        .story(arguments: ["-flag.gridColumns", "four"]) {
            $0.set(5, for: FlagDebugStory.gridColumns)
        })
}

#Preview("0018.4 Debug screen: names nothing in production") {
    FlagDebugStory.debug(.story(arguments: ["-flag.gridColumns", "four"], in: .production))
}
#endif
