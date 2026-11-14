import FeatureFlagKit
import SwiftUI

/// Names the build's environment, then lists each flag it ships with its value, layer and expiry
/// day, plus "Reset all". The app opens it however it likes, such as from a hidden gesture.
public struct FlagDebugView: View {
    private let catalog: FlagCatalog
    /// The environment's store, watched so any flag's change redraws the screen.
    private var watched = WatchedFlagStore()
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
        let store = watched.store
        // Read each value and layer here, so the list's data changes and it redraws the row.
        // Each child follows its parent, indented, and a flag this build doesn't ship has no row.
        let rows = catalog.grouped.filter { store.isAvailable($0.flag) }.map { entry in
            let debuggable = entry.flag as? any DebuggableFlag
            return (
                flag: entry.flag, isChild: entry.isChild, shown: debuggable?.shown(in: store),
                own: debuggable?.ownOrigin(in: store)
            )
        }
        Form {
            Section {
                Text(FlagText.environment(of: store))
            }
            Section {
                ForEach(rows, id: \.flag.settingsKey) { row in
                    FlagDebugRow(
                        flag: row.flag, store: store, shown: row.shown, own: row.own,
                        isChild: row.isChild)
                }
            }
            Section {
                // The confirmation hangs off the button, so it points at what was tapped.
                Button(Self.resetAll, role: .destructive) { confirmsReset = true }
                    .confirmationDialog(
                        "Clear every user setting?", isPresented: $confirmsReset,
                        titleVisibility: .visible
                    ) {
                        Button(Self.resetAll, role: .destructive) {
                            for flag in catalog {
                                store.reset(flag)
                            }
                        }
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text(Self.resetMessage)
                    }
            }
        }
        .navigationTitle("Feature flags")
    }

    private static let resetAll = "Reset all"

    /// What "Reset all" clears, and what it leaves for an override to decide.
    private static let resetMessage = """
        Every flag in this list forgets the user's setting, wherever in the app it was made. \
        A flag set by a launch argument or environment variable keeps that value.
        """
}
