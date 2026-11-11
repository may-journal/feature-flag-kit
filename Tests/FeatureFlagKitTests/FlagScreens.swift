import FeatureFlagKit
import FeatureFlagKitUI
import SwiftUI

/// The example Memories screen, reading its flag with `@FlagState` from the environment.
struct WrappedMemoriesScreen: View {
    @FlagState(ExampleFlags.onThisDay) private var onThisDay

    var body: some View {
        VStack {
            Text("Memories")
            if onThisDay {
                Text("On This Day")
            }
        }
    }
}

/// An example app's own Settings screen, whose toggle writes the flag through `$binding`.
struct BetaSettingsScreen: View {
    @FlagState(ExampleFlags.onThisDay) private var onThisDay

    var body: some View {
        Form {
            Toggle("Show On This Day", isOn: $onThisDay)
            if onThisDay {
                Text("On This Day")
            }
        }
    }
}

/// An example app's Settings screen for its sort setting, with a button that picks a choice.
struct SortSettingsScreen: View {
    @FlagState(ExampleFlags.sortOrder) private var sortOrder

    var body: some View {
        VStack {
            Text("Sorted by \(sortOrder.rawValue)")
            Button("Oldest first") { $sortOrder.wrappedValue = .oldest }
        }
    }
}
