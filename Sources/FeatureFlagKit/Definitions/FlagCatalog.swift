import Foundation

/// An app's list of flags. Each app keeps its own; the catalog answers
/// questions about the whole list, such as which flags are past their expiry.
public struct FlagCatalog: Sendable, RandomAccessCollection {
    /// Every flag, in the order the app listed them, each with its own title.
    public let flags: [any AnyFlag]

    public var startIndex: Int { flags.startIndex }
    public var endIndex: Int { flags.endIndex }
    public subscript(position: Int) -> any AnyFlag { flags[position] }

    public init(_ flags: [any AnyFlag]) {
        self.flags = flags
    }

    /// The flags whose expiry day has come by `date`, in catalog order, never a setting without
    /// one. An app test can expect this to be empty, so it fails once a flag outstays its day.
    public func expired(asOf date: Date = .now) -> [any AnyFlag] {
        filter { $0.expires.isPassed(asOf: date) }
    }

    /// Every flag with each listed child moved right under its parent, as a debug screen shows
    /// them. A child whose parent the catalog doesn't list stays where the app put it.
    public var grouped: [(flag: any AnyFlag, isChild: Bool)] {
        // Parents are matched by settings key, the one thing no two listed flags share.
        let listed = Set(map(\.settingsKey))
        var children: [String: [any AnyFlag]] = [:]
        var tops: [any AnyFlag] = []
        for flag in flags {
            if let key = flag.parent?.settingsKey, listed.contains(key) {
                children[key, default: []].append(flag)
            } else {
                tops.append(flag)
            }
        }
        return tops.flatMap { flag in
            [(flag: flag, isChild: false)]
                + (children[flag.settingsKey] ?? []).map { (flag: $0, isChild: true) }
        }
    }

    /// The grouped flags whose title or name holds `query` in any case, each matching child
    /// still under its parent's row. Spaces around it are dropped, and a blank one keeps all.
    public func grouped(matching query: String) -> [(flag: any AnyFlag, isChild: Bool)] {
        let rows = grouped
        let query = query.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return rows }
        let matches = rows.map { row in
            [row.flag.title, row.flag.name].contains {
                $0.range(of: query, options: [.caseInsensitive, .diacriticInsensitive]) != nil
            }
        }
        // A parent stays for a matching child, which always follows it in `grouped`.
        var keeps = matches
        var parent: Int?
        for (index, row) in rows.enumerated() {
            if !row.isChild {
                parent = index
            } else if matches[index], let parent {
                keeps[parent] = true
            }
        }
        return rows.indices.filter { keeps[$0] }.map { rows[$0] }
    }
}
