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

    /// The flags whose expiry day has come by `date`, in catalog order. An app
    /// test can expect this to be empty, so it fails once a flag outstays its day.
    public func expired(asOf date: Date = .now) -> [any AnyFlag] {
        filter { $0.expires.isPassed(asOf: date) }
    }
}
