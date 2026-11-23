#if DEBUG
import FeatureFlagKit
import SwiftUI

// One page per acceptance of requirements 0009 to 0013, each named by the acceptance it shows.

#Preview("0009.1 Listener: the user flips a toggle") {
    HeardStory { $0.set(true, for: FlagDebugStory.replay) }
        .environment(\.flagStore, .story())
}

#Preview("0009.2 Listener: Reset all clears a setting") {
    HeardStory { $0.reset(FlagDebugStory.replay) }
        .environment(\.flagStore, .story { $0.set(true, for: FlagDebugStory.replay) })
}

#Preview("0009.3 Listener: values imported from another device") {
    HeardStory { $0.importUserValues([FlagDebugStory.replay.settingsKey: .bool(true)]) }
        .environment(\.flagStore, .story())
}

#Preview("0009.4 Feature: imported on from another device") {
    let store = FlagStore.story()
    FlagDebugStory.feature(store)
        .task { store.importUserValues([FlagDebugStory.onThisDay.settingsKey: .bool(true)]) }
}

#Preview("0009.5 Feature: an imported default leaves no setting") {
    let store = FlagStore.story { $0.set(true, for: FlagDebugStory.onThisDay) }
    FlagDebugStory.feature(store)
        .task { store.importUserValues([FlagDebugStory.onThisDay.settingsKey: .bool(false)]) }
}

#Preview("0009.6 Feature: imported text that is no toggle") {
    let store = FlagStore.story { $0.set(true, for: FlagDebugStory.onThisDay) }
    FlagDebugStory.feature(store)
        .task { store.importUserValues([FlagDebugStory.onThisDay.settingsKey: .string("maybe")]) }
}

#Preview("0010.1 Group: the parent turned off") {
    GroupStory().environment(\.flagStore, .story { $0.set(false, for: FlagDebugStory.suggestions) })
}

#Preview("0010.2 Group: the child keeps its own setting") {
    GroupStory().environment(
        \.flagStore,
        .story {
            $0.set(false, for: FlagDebugStory.daySuggestions)
            $0.set(false, for: FlagDebugStory.suggestions)
            $0.set(true, for: FlagDebugStory.suggestions)
        })
}

#Preview("0010.3 Debug screen: a child forced off") {
    FlagDebugStory.debug(
        .story(arguments: FlagEncoding.arguments(FlagDebugStory.daySuggestions, false)))
}

#Preview("0010.4 Group: the screen follows the parent") {
    GroupStory().environment(\.flagStore, .story())
}

#Preview("0010.6 Debug screen: a child listed apart from its parent") {
    FlagDebugStory.debug(.story(), catalog: FlagDebugStory.apartCatalog)
}

#Preview("0010.7 Group: one level deep") {
    NoteStory(lines: [
        "A parent that sits under a parent of its own stops the app where it is defined.",
        "The message names both flags and says a group is one level deep.",
    ])
}

#Preview("0010.8 Listener: a child flipped under an off parent") {
    HeardStory { $0.set(false, for: FlagDebugStory.daySuggestions) }
        .environment(\.flagStore, .story { $0.set(false, for: FlagDebugStory.suggestions) })
}

#Preview("0011.1 Build: Info.plist says internal") {
    FlagDebugStory.debug(
        FlagDebugStory.launched("internal", info: [FlagEnvironment.infoPlistKey: "internal"]))
}

#Preview("0011.2 Build: no Info.plist key") {
    FlagDebugStory.debug(FlagDebugStory.launched("none", info: [:]))
}

#Preview("0011.3 Build: production passed in code") {
    FlagDebugStory.debug(
        FlagDebugStory.launched(
            "code", info: [FlagEnvironment.infoPlistKey: "internal"], in: .production))
}

#Preview("0011.4 Debug screen: the environment and its source") {
    FlagDebugStory.debug(
        FlagDebugStory.launched("shown", info: [FlagEnvironment.infoPlistKey: "internal"]))
}

#Preview("0011.5 Build: an unset build setting") {
    FlagDebugStory.debug(
        FlagDebugStory.launched(
            "unset", info: [FlagEnvironment.infoPlistKey: "$(FLAG_ENVIRONMENT)"]))
}

#Preview("0012.1 Feature: a saved value in a build without the flag") {
    FlagDebugStory.feature(
        .story(in: .production) { $0.set(true, for: FlagDebugStory.mentions) },
        FlagDebugStory.mentions)
}

#Preview("0012.2 Feature: starts on in internal builds") {
    FlagDebugStory.feature(.story(in: .internal), FlagDebugStory.tips)
}

#Preview("0012.3 Feature: production ignores overrides") {
    FlagDebugStory.feature(
        .story(arguments: FlagDebugStory.on, variables: FlagDebugStory.variableOn, in: .production),
        launch: FlagDebugStory.on + ["FLAG_ON_THIS_DAY=YES"])
}

#Preview("0012.4 Feature: internal takes the launch argument") {
    FlagDebugStory.feature(
        .story(arguments: FlagDebugStory.on, in: .internal), launch: FlagDebugStory.on)
}

#Preview("0012.5 Feature: turned off in production") {
    FlagDebugStory.feature(
        .story(in: .production) { $0.set(false, for: FlagDebugStory.tips) }, FlagDebugStory.tips)
}

#Preview("0012.7 Feature: the toggle hides in production") {
    FlagDebugStory.feature(.story(in: .production), FlagDebugStory.mentions)
}

#Preview("0012.8 Feature: a child under a debug-only parent") {
    FlagDebugStory.feature(.story(in: .production), FlagDebugStory.labsSearch)
}

#Preview("0013.1 Story: a feature page") {
    FlagDebugStory.feature(.story())
}

#Preview("0013.2 Story: a listener page") {
    HeardStory { $0.set(true, for: FlagDebugStory.replay) }
        .environment(\.flagStore, .story())
}

#Preview("0013.3 Story: an expiry page") {
    FlagDebugStory.expiry(onReplaysDay: true)
}
#endif
