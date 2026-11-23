#if DEBUG
import FeatureFlagKit
import SwiftUI

// One page per acceptance of requirements 0004 to 0008, each named by the acceptance it shows.
// The debug screen's light and dark pairs are in FlagDebugView+Previews.swift.

#Preview("0004.1 FlagState: the feature shows") {
    FlagDebugStory.feature(.story { $0.set(true, for: FlagDebugStory.onThisDay) })
}

#Preview("0004.2 FlagState: flipped on another screen") {
    let (settings, other) = FlagDebugStory.sharedStores()
    VStack(spacing: 0) {
        FlagDebugStory.feature(other)
        FlagDebugStory.feature(settings)
    }
}

#Preview("0004.3 FlagState: the binding writes the user's toggle") {
    FlagDebugStory.feature(.story { $0.set(true, for: FlagDebugStory.onThisDay) })
}

#Preview("0004.4 FlagState: the binding shows the user's own choice") {
    FlagDebugStory.feature(.story(arguments: FlagDebugStory.on), launch: FlagDebugStory.on)
}

#Preview("0004.5 FlagState: cards that page") {
    CardsStory().environment(\.flagStore, .story())
}

#Preview("0004.6 FlagState: a child hears its parent") {
    GroupStory().environment(\.flagStore, .story())
}

#Preview("0005.4 Debug screen: toggle disabled with its reason") {
    FlagDebugStory.debug(FlagDebugStory.forced)
}

#Preview("0005.6 Debug screen: a row in VoiceOver's order") {
    FlagDebugStory.debug(.story())
}

#Preview("0005.7 Debug screen: a flag of the app's own type") {
    FlagDebugStory.debug(.story(), catalog: FlagDebugStory.customCatalog)
}

#Preview("0005.8 Debug screen: number field disabled with its reason") {
    FlagDebugStory.debug(.story(arguments: FlagEncoding.arguments(FlagDebugStory.gridColumns, 5)))
}

#Preview("0005.9 Debug screen: a setting with no expiry day") {
    FlagDebugStory.debug(.story(), catalog: FlagDebugStory.settingCatalog)
}

#Preview("0006.3 Debug screen: Reset all over two settings") {
    FlagDebugStory.debug(
        .story {
            $0.set(true, for: FlagDebugStory.replay)
            $0.set(5, for: FlagDebugStory.gridColumns)
        }, confirmsReset: true)
}

#Preview("0006.4 Debug screen: Reset all over a launch argument") {
    FlagDebugStory.debug(FlagDebugStory.forced, confirmsReset: true)
}

#Preview("0006.5 Debug screen: Reset all in a production build") {
    // Mentions has no row here, and its saved setting stays.
    FlagDebugStory.debug(
        .story(in: .production) { $0.set(true, for: FlagDebugStory.mentions) }, confirmsReset: true)
}

#Preview("0007.1 Launch: built arguments turn the flag off") {
    FlagDebugStory.feature(
        .story(arguments: FlagDebugStory.off) { $0.set(true, for: FlagDebugStory.onThisDay) },
        launch: FlagDebugStory.off)
}

#Preview("0007.2 Launch: built environment turns the flag on") {
    FlagDebugStory.feature(
        .story(variables: FlagDebugStory.variableOn), launch: ["FLAG_ON_THIS_DAY=YES"])
}

#Preview("0007.3 Launch: two flags forced at once") {
    FlagDebugStory.debug(
        .story(arguments: FlagDebugStory.on + FlagEncoding.arguments(FlagDebugStory.gridColumns, 4))
    )
}

#Preview("0007.4 Launch: earlier arguments stay") {
    let arguments = ["-uiTesting"] + FlagDebugStory.on
    FlagDebugStory.feature(.story(arguments: arguments), launch: arguments)
}

#Preview("0007.5 Launch: the forced value comes last and wins") {
    let arguments = FlagDebugStory.off + FlagDebugStory.on
    FlagDebugStory.feature(.story(arguments: arguments), launch: arguments)
}

#Preview("0007.6 Launch: a value of the app's own type") {
    let arguments = FlagEncoding.arguments(FlagDebugStory.sortOrder, StorySortOrder.oldest)
    ChoiceStory().environment(\.flagStore, .story(arguments: arguments))
}

#Preview("0007.7 Launch: earlier variables stay") {
    FlagDebugStory.feature(
        .story(variables: ["UI_TESTING": "1"].merging(FlagDebugStory.variableOn) { $1 }),
        launch: ["UI_TESTING=1", "FLAG_ON_THIS_DAY=YES"])
}

#Preview("0008.1 Choice: picked from the list") {
    ChoiceStory().environment(\.flagStore, .story())
}

#Preview("0008.2 Choice: picked under its old key") {
    ChoiceStory().environment(
        \.flagStore, .story { $0.settings.set("oldest", forKey: "browse.sortOrder") })
}

#Preview("0008.3 Choice: set by a launch argument") {
    ChoiceStory().environment(\.flagStore, .story(arguments: ["-flag.sortOrder", "oldest"]))
}
#endif
