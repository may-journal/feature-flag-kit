/// A launch argument or environment variable the store could not read as its flag's type,
/// so the next layer decided the flag.
public struct FlagRejectedOverride: Sendable, Hashable, CustomStringConvertible {
    /// The flag's name, as overrides spell it.
    public let name: String
    /// The layer the text came from: `.launchArgument` or `.environment`.
    public let origin: FlagOrigin
    /// The text as typed, such as "four" for a number flag.
    public let text: String

    public init(name: String, origin: FlagOrigin, text: String) {
        self.name = name
        self.origin = origin
        self.text = text
    }

    /// The override in words, such as `Launch argument "four" is no value for this flag`.
    public var description: String {
        let layer = origin == .launchArgument ? "Launch argument" : "Environment variable"
        return "\(layer) \"\(text)\" is no value for this flag, so it is ignored."
    }
}

/// A source that holds override text by flag name, before any flag reads it as a value.
protocol OverrideTextSource: FlagSource {
    /// The text this source holds for the flag `name`, or nil when it sets none.
    func text(for name: String) -> String?
}

extension LaunchArgumentSource: OverrideTextSource {
    func text(for name: String) -> String? {
        let argument = FlagEncoding.argument(for: name)
        guard let index = arguments.lastIndex(of: argument), index + 1 < arguments.count else {
            return nil
        }
        return arguments[index + 1]
    }
}

extension EnvironmentSource: OverrideTextSource {
    func text(for name: String) -> String? {
        environment[FlagEncoding.environmentVariable(for: name)]
    }
}

/// A flag that can say whether override text reads as its own value type.
protocol OverrideReadingFlag: AnyFlag {
    func reads(_ text: String) -> Bool
}

extension Flag: OverrideReadingFlag {
    func reads(_ text: String) -> Bool {
        Value(flagText: text) != nil
    }
}

extension FlagStore {
    /// Each override the store skipped for a shipped flag in `catalog`, in catalog order.
    /// One is named only above the override that decided, and production names none.
    public func rejectedOverrides(in catalog: FlagCatalog) -> [FlagRejectedOverride] {
        let overrides = sources.compactMap { $0 as? any OverrideTextSource }
        return catalog.filter { isAvailable($0) }.flatMap { flag -> [FlagRejectedOverride] in
            guard let reading = flag as? any OverrideReadingFlag else { return [] }
            var skipped: [FlagRejectedOverride] = []
            // Sources run in precedence order, so the first override that reads decides.
            for source in overrides {
                guard let text = source.text(for: flag.name) else { continue }
                if reading.reads(text) { break }
                skipped.append(
                    FlagRejectedOverride(name: flag.name, origin: source.origin, text: text))
            }
            return skipped
        }
    }
}
