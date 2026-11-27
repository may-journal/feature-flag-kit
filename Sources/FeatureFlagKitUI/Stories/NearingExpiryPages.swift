#if DEBUG
import FeatureFlagKit
import SwiftUI

// One page per acceptance of requirement 0020, each named by the acceptance it shows.

/// The flags `expiring(within:asOf:)` names within `days` of `today`, under the catalog.
private struct ExpiringStory: View {
    let days: Int
    let today: Date

    var body: some View {
        let near = FlagDebugStory.catalog.expiring(within: days, asOf: today)
        Form {
            Section("Within \(days) days of \(today.formatted(.iso8601))") {
                if near.isEmpty { Text("None") }
                ForEach(near, id: \.settingsKey) { Text("\($0.title) is near its day") }
            }
        }
    }
}

#Preview("0020.1 Catalog: names a flag within the window") {
    ExpiringStory(days: 14, today: FlagDebugStory.before(replaysDay: 12))
}

#Preview("0020.2 Catalog: leaves out a flag past its day") {
    ExpiringStory(days: 14, today: FlagDebugStory.before(replaysDay: 0))
}

#Preview("0020.3 Catalog: counts days in UTC") {
    ExpiringStory(days: 2, today: FlagDebugStory.before(replaysDay: 2))
}

#Preview("0020.4 Debug screen: counts down 12 days") {
    FlagDebugStory.debug(.story(), today: FlagDebugStory.before(replaysDay: 12))
}

#Preview("0020.5 Debug screen: counts down 1 day") {
    FlagDebugStory.debug(.story(), today: FlagDebugStory.before(replaysDay: 1))
}

#Preview("0020.6 Debug screen: shows the day alone") {
    FlagDebugStory.debug(.story(), today: FlagDebugStory.before(replaysDay: 31))
}
#endif
