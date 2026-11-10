import Foundation

/// An app's list of flags. Each app keeps its own; the catalog answers
/// questions about the whole list, such as which flags are past their expiry.
public struct FlagCatalog: Sendable {
    public let flags: [any AnyFlag]

    public init(_ flags: [any AnyFlag]) {
        self.flags = flags
    }

    /// The flags whose expiry day has come by `date`, in catalog order. An app
    /// test can expect this to be empty, so it fails once a flag outstays its day.
    public func expired(asOf date: Date = .now) -> [any AnyFlag] {
        flags.filter { $0.expires.isPassed(asOf: date) }
    }
}
