import FeatureFlagKit
import SwiftUI

/// Names the build's environment, then lists each flag it ships that the search keeps.
/// "Copy launch arguments" and "Reset all" follow over every flag, wherever the app opens it.
public struct FlagDebugView: View {
    private let catalog: FlagCatalog
    /// The environment's store, watched so any flag's change redraws the screen.
    private var watched = WatchedFlagStore()
    /// Whether "Reset all" is asking to be confirmed.
    @State private var confirmsReset: Bool
    /// What the search field holds, matched against each flag's title and name.
    @State private var query: String

    public init(catalog: FlagCatalog) {
        self.init(catalog: catalog, confirmsReset: false)
    }

    /// Opens on `catalog` with `query` searched, and the "Reset all" confirmation up when
    /// `confirmsReset` is true. A preview shows either.
    init(catalog: FlagCatalog, confirmsReset: Bool, query: String = "") {
        self.catalog = catalog
        _confirmsReset = State(initialValue: confirmsReset)
        _query = State(initialValue: query)
    }

    public var body: some View {
        let store = watched.store
        // Read each value and layer here, so the list's data changes and it redraws the row.
        // Each child follows its parent, indented, and a flag this build doesn't ship has no row.
        let kept = catalog.grouped(matching: query)
        let rows = kept.filter { store.isAvailable($0.flag) }.map { entry in
            let debuggable = entry.flag as? any DebuggableFlag
            return (
                flag: entry.flag, isChild: entry.isChild, shown: debuggable?.shown(in: store),
                own: debuggable?.ownOrigin(in: store)
            )
        }
        let rejected = store.rejectedOverrides(in: catalog)
        Form {
            Section {
                Text(FlagText.environment(of: store))
            }
            Section {
                ForEach(rows, id: \.flag.settingsKey) { row in
                    FlagDebugRow(
                        flag: row.flag, store: store, shown: row.shown, own: row.own,
                        isChild: row.isChild,
                        rejected: rejected.filter { $0.name == row.flag.name }.map(\.description))
                }
                if rows.isEmpty, !query.isEmpty {
                    ContentUnavailableView { Text(Self.noMatch) }
                }
            }
            Section {
                FlagCopyButton(catalog: catalog, store: store)
                // The confirmation hangs off the button, so it points at what was tapped.
                Button(Self.resetAll, role: .destructive) { confirmsReset = true }
                    .confirmationDialog(
                        "Clear every user setting?", isPresented: $confirmsReset,
                        titleVisibility: .visible
                    ) {
                        Button(Self.resetAll, role: .destructive) {
                            // A flag this build hides keeps its saved value.
                            for flag in catalog where store.isAvailable(flag) {
                                store.reset(flag)
                            }
                        }
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text(Self.resetMessage)
                    }
            }
        }
        .searchable(text: $query, prompt: Self.search)
        .navigationTitle("Feature flags")
    }

    private static let resetAll = "Reset all"
    private static let search = "Search"
    private static let noMatch = "No flags match"

    /// What "Reset all" clears, and what it leaves for an override to decide.
    private static let resetMessage = """
        Every flag in this list forgets the user's setting, wherever in the app it was made. \
        A flag set by a launch argument or environment variable keeps that value.
        """
}
