/// One collision in an app's catalog, such as two flags that share a settings key.
public struct FlagCatalogProblem: Sendable, Hashable, CustomStringConvertible {
    /// The kind of thing the flags share, or lack.
    public enum Kind: Sendable, Hashable {
        /// Two or more flags have one name, so one override forces them all.
        case sharedName
        /// Flags with different names keep the user's value under one settings key.
        case sharedSettingsKey
        /// Flags with different names read one environment variable.
        case sharedEnvironmentVariable
        /// A child's parent is missing from the catalog, so no screen lists it above the child.
        case unlistedParent
    }

    public let kind: Kind
    /// The shared name, settings key or environment variable, or the missing parent's name.
    public let subject: String
    /// The names of the flags involved, in catalog order.
    public let flags: [String]

    public init(kind: Kind, subject: String, flags: [String]) {
        self.kind = kind
        self.subject = subject
        self.flags = flags
    }

    /// The problem in words, such as `Flags "a" and "b" share the settings key flag.a`.
    public var description: String {
        let named = flags.map { "\"\($0)\"" }.joined(separator: " and ")
        switch kind {
        case .sharedName:
            return "\(flags.count) flags share the name \"\(subject)\""
        case .sharedSettingsKey:
            return "Flags \(named) share the settings key \(subject)"
        case .sharedEnvironmentVariable:
            return "Flags \(named) share the environment variable \(subject)"
        case .unlistedParent:
            return "Flag \(named) sits under \"\(subject)\", which the catalog does not list"
        }
    }
}

extension FlagCatalog {
    /// The collisions among the listed flags, by kind and then in catalog order. An app test
    /// can expect this to be empty, so it fails before two flags share a toggle.
    public func problems() -> [FlagCatalogProblem] {
        let keys = Set(map(\.settingsKey))
        let orphans = filter { flag in
            flag.parent.map { !keys.contains($0.settingsKey) } ?? false
        }
        return shared(.sharedName) { $0.name }
            + shared(.sharedSettingsKey) { $0.settingsKey }
            + shared(.sharedEnvironmentVariable) {
                FlagEncoding.environmentVariable(for: $0.name)
            }
            + orphans.map { flag in
                FlagCatalogProblem(
                    kind: .unlistedParent, subject: flag.parent?.name ?? "", flags: [flag.name])
            }
    }

    /// A problem for each value of `subject` that more than one flag has. Flags that share
    /// their name count only under `sharedName`, since one name spells one key and variable.
    private func shared(
        _ kind: FlagCatalogProblem.Kind, by subject: (any AnyFlag) -> String
    ) -> [FlagCatalogProblem] {
        var names: [String: [String]] = [:]
        var order: [String] = []
        for flag in flags {
            let value = subject(flag)
            if names[value] == nil { order.append(value) }
            names[value, default: []].append(flag.name)
        }
        return order.compactMap { value in
            let found = names[value] ?? []
            let distinct = Set(found).count
            let collides = kind == .sharedName ? found.count > 1 : distinct > 1
            return collides ? FlagCatalogProblem(kind: kind, subject: value, flags: found) : nil
        }
    }
}
