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
        expires: FlagExpiry(year: 2027, month: 6, day: 1), legacySettingsKey: "beta.onThisDay")
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

    /// The debug screen on `store` in two labeled columns, light then dark, so one page shows both.
    /// It brings no navigation stack, since the storybook already pushes each story onto its own.
    @MainActor
    static func screen(_ store: FlagStore, confirmsReset: Bool = false) -> some View {
        HStack(spacing: 0) {
            ForEach([ColorScheme.light, .dark], id: \.self) { scheme in
                VStack(alignment: .leading, spacing: 0) {
                    Text(scheme == .light ? "Light" : "Dark")
                        .font(.caption.bold())
                        .padding(.horizontal)
                    FlagDebugView(
                        catalog: catalog, confirmsReset: confirmsReset && scheme == .light
                    )
                    .environment(\.flagStore, store)
                    .environment(\.colorScheme, scheme)
                }
            }
        }
    }

    /// The debug screen on `store` and `catalog`, in the system's scheme.
    @MainActor
    static func debug(
        _ store: FlagStore, catalog: FlagCatalog = catalog, confirmsReset: Bool = false
    ) -> some View {
        FlagDebugView(catalog: catalog, confirmsReset: confirmsReset)
            .environment(\.flagStore, store)
    }

    /// A screen that reads `flag` with `@FlagState` on `store`, under what the launch carried.
    @MainActor
    static func feature(
        _ store: FlagStore, _ flag: Flag<Bool> = onThisDay, launch: [String] = []
    ) -> some View {
        FeatureStory(flag, launch: launch).environment(\.flagStore, store)
    }
}

#Preview("0005.1 Debug screen: catalog") {
    FlagDebugStory.screen(.isolated())
}

#Preview("0005.2 Debug screen: forced by launch argument") {
    FlagDebugStory.screen(FlagDebugStory.forced)
}

#Preview("0005.3 Debug screen: toggled on by the user") {
    FlagDebugStory.screen(FlagDebugStory.toggled)
}

#Preview("0006.1 Debug screen: number edited") {
    FlagDebugStory.screen(FlagDebugStory.edited)
}

#Preview("0010.5 Debug screen: group with its parent off") {
    FlagDebugStory.screen(FlagDebugStory.parentOff)
}

#Preview("0012.6 Debug screen: production build") {
    FlagDebugStory.screen(FlagDebugStory.production)
}

#Preview("0006.2 Debug screen: Reset all confirmation") {
    FlagDebugStory.screen(FlagDebugStory.edited, confirmsReset: true)
}

#Preview("0013.4 Debug screen: light beside dark") {
    FlagDebugStory.screen(.isolated())
}
#endif
