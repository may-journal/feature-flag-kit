import FeatureFlagKit
import SwiftUI

/// Lists each flag in the app's catalog with its value, layer and expiry day, plus "Reset all".
/// The app opens it however it likes, such as from a hidden gesture.
public struct FlagDebugView: View {
    private let catalog: FlagCatalog
    @Environment(\.flagStore) private var store
    @State private var watcher = FlagWatcher()
    /// Whether "Reset all" is asking to be confirmed.
    @State private var confirmsReset: Bool

    public init(catalog: FlagCatalog) {
        self.init(catalog: catalog, confirmsReset: false)
    }

    /// Opens on `catalog`, with the "Reset all" confirmation up when `confirmsReset` is true,
    /// so a preview can show it.
    init(catalog: FlagCatalog, confirmsReset: Bool) {
        self.catalog = catalog
        _confirmsReset = State(initialValue: confirmsReset)
    }

    public var body: some View {
        let flags = watchedFlags()
        Form {
            Section {
                ForEach(flags, id: \.settingsKey) { flag in
                    let shown = (flag as? any DebuggableFlag)?.shown(in: store)
                    FlagDebugRow(flag: flag, store: store, shown: shown)
                }
            }
            Section {
                // The confirmation hangs off the button, so it points at what was tapped.
                Button(Self.resetAll, role: .destructive) { confirmsReset = true }
                    .confirmationDialog(
                        "Reset every flag to its default?", isPresented: $confirmsReset,
                        titleVisibility: .visible
                    ) {
                        Button(Self.resetAll, role: .destructive) {
                            for flag in catalog {
                                store.reset(flag)
                            }
                        }
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("This clears every setting the user made on this screen.")
                    }
            }
        }
        .navigationTitle("Feature flags")
    }

    private static let resetAll = "Reset all"

    /// Returns the catalog's flags, and reads the watcher so any change redraws the screen.
    private func watchedFlags() -> [any AnyFlag] {
        watcher.watch(store)
        _ = watcher.version
        return catalog.flags
    }
}
