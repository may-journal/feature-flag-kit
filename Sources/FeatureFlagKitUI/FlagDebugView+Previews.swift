#if DEBUG
import FeatureFlagKit
import SwiftUI

/// The debug screen's stories in light and dark, shown by Xcode and by Examples/FlagDebugDemo.
/// They compile only in Debug builds, so an app's release build carries none of them.
enum FlagDebugStory {
    static let replay = Flag(
        "replay", default: false, title: "Replay",
        expires: FlagExpiry(year: 2027, month: 3, day: 1))
    /// A beta that ships in debug and internal builds only, and starts on in debug.
    static let mentions = Flag(
        "mentions", default: false, title: "Mentions",
        expires: FlagExpiry(year: 2027, month: 5, day: 15), availability: [.debug, .internal],
        environmentDefaults: [.debug: true])
    static let onThisDay = Flag(
        "onThisDay", default: false, title: "On This Day",
        expires: FlagExpiry(year: 2027, month: 6, day: 1))
    static let gridColumns = Flag(
        "gridColumns", default: 3, title: "Grid columns",
        expires: FlagExpiry(year: 2027, month: 9, day: 30))

    static let suggestions = Flag("suggestions", default: true, title: "Use suggestions")
    static let daySuggestions = Flag(
        "daySuggestions", default: true, title: "For days", parent: suggestions)
    static let photoSuggestions = Flag(
        "photoSuggestions", default: true, title: "For photos", parent: suggestions)

    static let catalog = FlagCatalog([
        replay, mentions, onThisDay, gridColumns, suggestions, daySuggestions, photoSuggestions,
    ])

    /// A store where the user turned Use suggestions off, after turning For photos off.
    static var parentOff: FlagStore {
        let store = FlagStore.isolated()
        store.set(false, for: photoSuggestions)
        store.set(false, for: suggestions)
        return store
    }

    /// A store launched with `-flag.onThisDay YES`, so On This Day's row is locked.
    static var forced: FlagStore {
        .isolated(arguments: FlagEncoding.arguments(onThisDay, true))
    }

    /// A production store, where Mentions has no row.
    static var production: FlagStore {
        .isolated(in: .production)
    }

    /// A store where the user turned Replay on.
    static var toggled: FlagStore {
        let store = FlagStore.isolated()
        store.set(true, for: replay)
        return store
    }

    /// A store where the user typed 5 for Grid columns, whose default is 3.
    static var edited: FlagStore {
        let store = FlagStore.isolated()
        store.set(5, for: gridColumns)
        return store
    }

    /// The debug screen on `store`, in `scheme`. It brings no navigation stack, since the
    /// storybook already pushes each story onto its own.
    @MainActor
    static func screen(
        _ store: FlagStore, _ scheme: ColorScheme, confirmsReset: Bool = false
    ) -> some View {
        FlagDebugView(catalog: catalog, confirmsReset: confirmsReset)
            .environment(\.flagStore, store)
            .preferredColorScheme(scheme)
    }
}

#Preview("FlagDebugView: catalog") {
    FlagDebugStory.screen(.isolated(), .light)
}

#Preview("FlagDebugView: catalog, dark") {
    FlagDebugStory.screen(.isolated(), .dark)
}

#Preview("FlagDebugView: forced by launch argument") {
    FlagDebugStory.screen(FlagDebugStory.forced, .light)
}

#Preview("FlagDebugView: forced by launch argument, dark") {
    FlagDebugStory.screen(FlagDebugStory.forced, .dark)
}

#Preview("FlagDebugView: toggled on by the user") {
    FlagDebugStory.screen(FlagDebugStory.toggled, .light)
}

#Preview("FlagDebugView: toggled on by the user, dark") {
    FlagDebugStory.screen(FlagDebugStory.toggled, .dark)
}

#Preview("FlagDebugView: number edited") {
    FlagDebugStory.screen(FlagDebugStory.edited, .light)
}

#Preview("FlagDebugView: number edited, dark") {
    FlagDebugStory.screen(FlagDebugStory.edited, .dark)
}

#Preview("FlagDebugView: group with its parent off") {
    FlagDebugStory.screen(FlagDebugStory.parentOff, .light)
}

#Preview("FlagDebugView: group with its parent off, dark") {
    FlagDebugStory.screen(FlagDebugStory.parentOff, .dark)
}

#Preview("FlagDebugView: production build") {
    FlagDebugStory.screen(FlagDebugStory.production, .light)
}

#Preview("FlagDebugView: production build, dark") {
    FlagDebugStory.screen(FlagDebugStory.production, .dark)
}

#Preview("FlagDebugView: Reset all confirmation") {
    FlagDebugStory.screen(FlagDebugStory.edited, .light, confirmsReset: true)
}

#Preview("FlagDebugView: Reset all confirmation, dark") {
    FlagDebugStory.screen(FlagDebugStory.edited, .dark, confirmsReset: true)
}
#endif
