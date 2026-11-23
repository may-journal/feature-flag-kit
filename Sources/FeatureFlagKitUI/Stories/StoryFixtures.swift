#if DEBUG
import FeatureFlagKit
import Foundation
import SwiftUI

/// The choices of the stories' sort setting, a flag value with no code of its own.
enum StorySortOrder: String, FlagValue, CaseIterable {
    case newest
    case oldest
}

/// A flag of the app's own type rather than a `Flag`, which no store can resolve.
struct StoryCustomFlag: AnyFlag {
    let name = "legacyBanner"
    let title = "Legacy banner"
    let expires = FlagExpiry(year: 2027, month: 3, day: 1)
    let settingsKey = "flag.legacyBanner"
}

extension FlagDebugStory {
    /// A permanent setting with a list of choices, kept under an earlier release's key.
    static let sortOrder = Flag(
        "sortOrder", default: StorySortOrder.newest, title: "Sort order",
        legacySettingsKey: "browse.sortOrder")
    /// A setting in every build that starts on in internal and production builds.
    static let tips = Flag(
        "tips", default: false, title: "Tips",
        environmentDefaults: [.internal: true, .production: true])
    /// A parent that ships in debug builds only, over a child that ships in every build.
    static let labs = Flag("labs", default: true, title: "Labs", availability: [.debug])
    static let labsSearch = Flag("labsSearch", default: true, title: "Search", parent: labs)

    /// A list that names a child before its parent, with a flag between them.
    static let apartCatalog = FlagCatalog([daySuggestions, gridColumns, suggestions])
    /// A list with one flag of the app's own type.
    static let customCatalog = FlagCatalog([onThisDay, StoryCustomFlag()])
    /// A list with only a permanent setting, which has no expiry day.
    static let settingCatalog = FlagCatalog([suggestions])

    /// The launch arguments that force On This Day on, and off.
    static let on = FlagEncoding.arguments(onThisDay, true)
    static let off = FlagEncoding.arguments(onThisDay, false)
    /// The environment variable that forces On This Day on, and off.
    static let variableOn = FlagEncoding.environment(onThisDay, true)
    static let variableOff = FlagEncoding.environment(onThisDay, false)

    /// The expiry page at midnight UTC on 1 March 2027, Replay's day, or one second before.
    static func expiry(onReplaysDay: Bool) -> ExpiryStory {
        let midnight: TimeInterval = 1_803_859_200
        return ExpiryStory(
            catalog: catalog,
            day: Date(timeIntervalSince1970: onReplaysDay ? midnight : midnight - 1))
    }

    /// The settings every shared-settings story uses, emptied first, never the app's own.
    static func emptySuite() -> UserDefaults? {
        let suite = "FeatureFlagKitUI.stories"
        let defaults = UserDefaults(suiteName: suite)
        defaults?.removePersistentDomain(forName: suite)
        return defaults
    }

    /// Two stores over the same settings, as two screens of one app hold them.
    static func sharedStores() -> (FlagStore, FlagStore) {
        guard let defaults = emptySuite() else { return (.isolated(), .isolated()) }
        return (.live(defaults: defaults, in: .debug), .live(defaults: defaults, in: .debug))
    }

    /// A store over settings the developer wrote straight into, with no store between.
    static func writtenDirectly() -> FlagStore {
        guard let defaults = emptySuite() else { return .isolated() }
        defaults.set(true, forKey: onThisDay.settingsKey)
        return .live(defaults: defaults, in: .debug)
    }

    /// The live store of an app whose Info.plist holds `info`, in a bundle named by `label`.
    static func launched(
        _ label: String, info: [String: String], in environment: FlagEnvironment? = nil
    ) -> FlagStore {
        let url = FileManager.default.temporaryDirectory
            .appending(path: "FlagStory-\(label).bundle")
        #if os(macOS)
        let contents = url.appending(path: "Contents")
        #else
        let contents = url
        #endif
        let plist = ["CFBundleIdentifier": "example.story.\(label)"].merging(info) { $1 }
        try? FileManager.default.createDirectory(at: contents, withIntermediateDirectories: true)
        let data = try? PropertyListSerialization.data(
            fromPropertyList: plist, format: .xml, options: 0)
        try? data?.write(to: contents.appending(path: "Info.plist"))
        guard let bundle = Bundle(url: url), let defaults = emptySuite() else {
            return .isolated()
        }
        return .live(defaults: defaults, bundle: bundle, in: environment)
    }
}

extension FlagStore {
    /// A fresh store for one story, launched as given, then prepared as its acceptance says.
    static func story(
        arguments: [String] = [], variables: [String: String] = [:],
        in environment: FlagEnvironment = .debug, _ prepare: (FlagStore) -> Void = { _ in }
    ) -> FlagStore {
        let store = FlagStore.isolated(
            arguments: arguments, environment: variables, in: environment)
        prepare(store)
        return store
    }
}
#endif
