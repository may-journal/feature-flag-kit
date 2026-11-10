import FeatureFlagKit
import SwiftUI

/// The flags an example app defines, the way an app keeps its own list.
enum ExampleFlags {
    /// Defaults off, and keeps the settings key an earlier release used.
    static let onThisDay = Flag(
        "onThisDay", default: false, title: "On This Day",
        expires: FlagExpiry(year: 2099, month: 1, day: 1), legacySettingsKey: "beta.onThisDay")
}

/// An example app screen that shows its On This Day row only when the flag is on.
struct MemoriesScreen: View {
    let store: FlagStore

    var body: some View {
        VStack {
            Text("Memories")
            if store[ExampleFlags.onThisDay] {
                Text("On This Day")
            }
        }
    }
}

/// The same screen, redrawn whenever the store says a toggle changed.
struct LiveMemoriesScreen: View {
    let store: FlagStore
    @State private var showsOnThisDay = false

    var body: some View {
        VStack {
            Text("Memories")
            if showsOnThisDay {
                Text("On This Day")
            }
        }
        .task {
            showsOnThisDay = store[ExampleFlags.onThisDay]
            for await _ in store.changes() {
                showsOnThisDay = store[ExampleFlags.onThisDay]
            }
        }
    }
}
