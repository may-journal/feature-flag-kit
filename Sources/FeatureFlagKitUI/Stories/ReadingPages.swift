#if DEBUG
import FeatureFlagKit
import SwiftUI

// One page per acceptance of requirements 0001 to 0003, each named by the acceptance it shows.

#Preview("0001.1 Feature: hidden by default") {
    FlagDebugStory.feature(.story())
}

#Preview("0001.2 Feature: turned on in Settings") {
    FlagDebugStory.feature(.story { $0.set(true, for: FlagDebugStory.onThisDay) })
}

#Preview("0001.3 Feature: turned on under its old key") {
    FlagDebugStory.feature(.story { $0.settings.set(true, forKey: "beta.onThisDay") })
}

#Preview("0001.4 Feature: a fresh store reads the default") {
    // An earlier store was turned on; the fresh one shares nothing with it.
    FlagStore.story().set(true, for: FlagDebugStory.onThisDay)
    return FlagDebugStory.feature(.story())
}

#Preview("0001.5 Feature: the toggle updates the screen") {
    FlagDebugStory.feature(.story())
}

#Preview("0001.6 Feature: set back to its default") {
    FlagDebugStory.feature(
        .story {
            $0.set(true, for: FlagDebugStory.onThisDay)
            $0.set(false, for: FlagDebugStory.onThisDay)
        })
}

#Preview("0001.7 Feature: two screens over one settings") {
    let (settings, other) = FlagDebugStory.sharedStores()
    VStack(spacing: 0) {
        FlagDebugStory.feature(settings)
        FlagDebugStory.feature(other)
    }
}

#Preview("0001.8 Feature: written straight into settings") {
    FlagDebugStory.feature(FlagDebugStory.writtenDirectly())
}

#Preview("0002.1 Feature: launch argument off beats the toggle") {
    FlagDebugStory.feature(
        .story(arguments: FlagDebugStory.off) { $0.set(true, for: FlagDebugStory.onThisDay) },
        launch: FlagDebugStory.off)
}

#Preview("0002.2 Feature: environment variable off beats the toggle") {
    FlagDebugStory.feature(
        .story(variables: FlagDebugStory.variableOff) {
            $0.set(true, for: FlagDebugStory.onThisDay)
        },
        launch: ["FLAG_ON_THIS_DAY=NO"])
}

#Preview("0002.3 Feature: launch argument beats the variable") {
    FlagDebugStory.feature(
        .story(arguments: FlagDebugStory.off, variables: FlagDebugStory.variableOn),
        launch: FlagDebugStory.off + ["FLAG_ON_THIS_DAY=YES"])
}

#Preview("0002.4 Feature: value from the launch argument") {
    FlagDebugStory.feature(.story(arguments: FlagDebugStory.on), launch: FlagDebugStory.on)
}

#Preview("0002.5 Feature: mistyped argument, variable decides") {
    FlagDebugStory.feature(
        .story(arguments: ["-flag.onThisDay", "maybe"], variables: FlagDebugStory.variableOff) {
            $0.set(true, for: FlagDebugStory.onThisDay)
        }, launch: ["-flag.onThisDay", "maybe", "FLAG_ON_THIS_DAY=NO"])
}

#Preview("0002.6 Feature: mistyped variable, toggle decides") {
    FlagDebugStory.feature(
        .story(variables: ["FLAG_ON_THIS_DAY": "maybe"]) {
            $0.set(true, for: FlagDebugStory.onThisDay)
        },
        launch: ["FLAG_ON_THIS_DAY=maybe"])
}

#Preview("0002.7 Debug screen: forced child under an off parent") {
    FlagDebugStory.debug(
        .story(arguments: FlagEncoding.arguments(FlagDebugStory.daySuggestions, false)) {
            $0.set(false, for: FlagDebugStory.suggestions)
        })
}

#Preview("0003.1 Expiry: a flag whose day has come") {
    FlagDebugStory.expiry(onReplaysDay: true)
}

#Preview("0003.2 Expiry: every flag expires later") {
    // 1 January 2026 at midnight UTC.
    ExpiryStory(catalog: FlagDebugStory.catalog, day: Date(timeIntervalSince1970: 1_767_225_600))
}

#Preview("0003.3 Expiry: the day before, in UTC") {
    // One second before the day in UTC, which is already that morning in Tokyo.
    FlagDebugStory.expiry(onReplaysDay: false)
}

#Preview("0003.4 Expiry: a setting with no day") {
    // 1 January 2100 at midnight UTC.
    ExpiryStory(
        catalog: FlagDebugStory.settingCatalog, day: Date(timeIntervalSince1970: 4_102_444_800))
}
#endif
