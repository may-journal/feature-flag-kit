#if DEBUG
import FeatureFlagKit
import SwiftUI

// One page per acceptance of requirement 0018, each named by the acceptance it shows.

#Preview("0018.1 Debug screen: a launch argument that is no number") {
    FlagDebugStory.debug(.story(arguments: ["-flag.gridColumns", "four"]))
}

#Preview("0018.2 Debug screen: a variable that is no number") {
    FlagDebugStory.debug(.story(variables: ["FLAG_GRID_COLUMNS": "four"]))
}

#Preview("0018.3 Debug screen: the row says the argument is ignored") {
    FlagDebugStory.debug(
        .story(arguments: ["-flag.gridColumns", "four"]) {
            $0.set(5, for: FlagDebugStory.gridColumns)
        })
}

#Preview("0018.4 Debug screen: production names no override") {
    FlagDebugStory.debug(.story(arguments: ["-flag.gridColumns", "four"], in: .production))
}
#endif
