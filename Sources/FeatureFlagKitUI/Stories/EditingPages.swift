#if DEBUG
import FeatureFlagKit
import SwiftUI

// One page per acceptance of requirement 0015, each named by the acceptance it shows.

extension FlagDebugStory {
    /// A decimal flag and a text flag, which the debug screen edits in a field.
    static let zoom = Flag("zoom", default: 1.0, title: "Zoom")
    static let greeting = Flag("greeting", default: "Hi", title: "Greeting")
    /// A list with a choice, a decimal and a text flag.
    static let editCatalog = FlagCatalog([sortOrder, zoom, greeting])
}

#Preview("0015.1 Debug screen: a choice picked") {
    FlagDebugStory.debug(
        .story { $0.set(.oldest, for: FlagDebugStory.sortOrder) },
        catalog: FlagDebugStory.editCatalog)
}

#Preview("0015.2 Debug screen: a decimal typed") {
    FlagDebugStory.debug(
        .story { $0.set(1.5, for: FlagDebugStory.zoom) }, catalog: FlagDebugStory.editCatalog)
}

#Preview("0015.3 Debug screen: text typed") {
    FlagDebugStory.debug(
        .story { $0.set("Hello", for: FlagDebugStory.greeting) },
        catalog: FlagDebugStory.editCatalog)
}

#Preview("0015.4 Debug screen: a decimal set by a launch argument") {
    FlagDebugStory.debug(
        .story(arguments: FlagEncoding.arguments(FlagDebugStory.zoom, 2.5)),
        catalog: FlagDebugStory.editCatalog)
}
#endif
