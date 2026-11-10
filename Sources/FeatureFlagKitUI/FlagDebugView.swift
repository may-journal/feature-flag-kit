import FeatureFlagKit
import SwiftUI

/// Lists each flag in the app's catalog with its value, layer and expiry day, plus "Reset all".
/// The app opens it however it likes, such as from a hidden gesture.
public struct FlagDebugView: View {
    private let catalog: FlagCatalog
    @Environment(\.flagStore) private var store
    @State private var watcher = FlagWatcher()

    public init(catalog: FlagCatalog) {
        self.catalog = catalog
    }

    public var body: some View {
        let flags = watchedFlags()
        Form {
            Section {
                ForEach(flags.indices, id: \.self) { index in
                    let flag = flags[index]
                    FlagDebugRow(flag: flag, store: store, shown: flag.shown(in: store))
                }
            }
            Section {
                Button("Reset all", role: .destructive) {
                    for flag in catalog {
                        store.reset(flag)
                    }
                }
            }
        }
        .navigationTitle("Feature flags")
    }

    /// Returns the catalog's flags, and reads the watcher so any toggle change redraws the screen.
    private func watchedFlags() -> [any DebuggableFlag] {
        watcher.watch(store)
        _ = watcher.version
        return catalog.compactMap { $0 as? any DebuggableFlag }
    }
}
