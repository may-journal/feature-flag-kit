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
    /// The day the rows count to each expiry day from, or nil for the moment each draw runs.
    private let today: Date?
    /// The catalog's collisions in words, found once since the catalog never changes.
    private let problems: [String]

    /// A row's identity for each of `kept`, which `all` holds in the same order. Flags may
    /// share a key or a name, so it counts the earlier rows of `all` with both.
    private static func identities(
        of kept: [(flag: FlagCatalog.Element, isChild: Bool)],
        in all: [(flag: FlagCatalog.Element, isChild: Bool)]
    ) -> [String] {
        func key(_ flag: FlagCatalog.Element) -> String { flag.name + " " + flag.settingsKey }
        var twins: [String: Int] = [:]
        let ids = all.map { entry in
            let twin = twins[key(entry.flag), default: 0]
            twins[key(entry.flag)] = twin + 1
            return "\(key(entry.flag)) \(twin)"
        }
        // Walk `all` once; each kept row takes the identity of the next entry like it.
        var next = all.startIndex
        return kept.map { entry in
            while next < all.count - 1,
                key(all[next].flag) != key(entry.flag) || all[next].flag.title != entry.flag.title
                    || all[next].isChild != entry.isChild
            {
                next += 1
            }
            defer { next += 1 }
            return ids[min(next, ids.count - 1)]
        }
    }

    public init(catalog: FlagCatalog) {
        self.init(catalog: catalog, confirmsReset: false)
    }

    /// Opens on `catalog` with `query` searched, and the "Reset all" confirmation up when
    /// `confirmsReset` is true. A preview or test shows either, and fixes `today`.
    init(catalog: FlagCatalog, confirmsReset: Bool, query: String = "", today: Date? = nil) {
        self.catalog = catalog
        self.today = today
        problems = catalog.problems().map(\.description)
        _confirmsReset = State(initialValue: confirmsReset)
        _query = State(initialValue: query)
    }

    public var body: some View {
        let store = watched.store
        // Read each value and layer here, so the list's data changes and it redraws the row.
        // Each child follows its parent, indented, and a flag this build doesn't ship has no row.
        let kept = catalog.grouped(matching: query)
        let rows = zip(kept, Self.identities(of: kept, in: catalog.grouped))
            .filter { store.isAvailable($0.0.flag) }
            .map { entry, id in
                let debuggable = entry.flag as? any DebuggableFlag
                return (
                    id: id, flag: entry.flag, isChild: entry.isChild,
                    shown: debuggable?.shown(in: store), own: debuggable?.ownOrigin(in: store)
                )
            }
        let rejected = store.rejectedOverrides(in: catalog)
        Form {
            Section {
                Text(FlagText.environment(of: store))
            }
            // A clean catalog shows no section, and the screen is as it was.
            if !problems.isEmpty {
                Section(Self.problemsTitle) {
                    // A catalog can list one problem twice, so each line is known by its place.
                    ForEach(Array(problems.enumerated()), id: \.offset) { _, problem in
                        Label(problem, systemImage: "exclamationmark.triangle.fill")
                            .symbolRenderingMode(.multicolor)
                            .accessibilityLabel("Warning: \(problem)")
                    }
                }
            }
            Section {
                ForEach(rows, id: \.id) { row in
                    FlagDebugRow(
                        flag: row.flag, store: store, shown: row.shown, own: row.own,
                        isChild: row.isChild,
                        rejected: rejected.filter { $0.name == row.flag.name }.map(\.description),
                        today: today ?? .now)
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
    private static let problemsTitle = "Catalog problems"

    /// What "Reset all" clears, and what it leaves for an override to decide.
    private static let resetMessage = """
        Every flag in this list forgets the user's setting, wherever in the app it was made. \
        A flag set by a launch argument or environment variable keeps that value.
        """
}
