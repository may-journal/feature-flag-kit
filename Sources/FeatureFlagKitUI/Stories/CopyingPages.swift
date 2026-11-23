#if DEBUG
import FeatureFlagKit
import SwiftUI

// One page per acceptance of requirement 0017, each named by the acceptance it shows.

/// The line "Copy launch arguments" would copy, then the debug screen a launch with it shows.
private struct CopiedLineStory: View {
    let store: FlagStore

    var body: some View {
        let arguments = store.launchArguments(for: FlagDebugStory.catalog)
        VStack(spacing: 0) {
            Text(FlagCopy.line(arguments)).monospaced().padding()
            FlagDebugStory.debug(.story(arguments: arguments))
        }
    }
}

#Preview("0017.1 Launch: started from the copied line") {
    CopiedLineStory(
        store: .story {
            $0.set(true, for: FlagDebugStory.replay)
            $0.set(5, for: FlagDebugStory.gridColumns)
        })
}

#Preview("0017.2 Debug screen: Copy launch arguments") {
    FlagDebugStory.debug(FlagDebugStory.edited)
        .environment(\.flagPasteboard, FlagPasteboard { _ in })
}

#Preview("0017.3 Debug screen: nothing to copy") {
    FlagDebugStory.debug(.story(in: .production))
}

#Preview("0017.4 Launch: a child kept off under its parent") {
    CopiedLineStory(store: FlagDebugStory.parentOff)
}
#endif
