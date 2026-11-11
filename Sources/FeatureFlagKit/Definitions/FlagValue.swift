/// A type a flag can hold. Overrides carry it as text, and the user's
/// settings store it as a property-list value.
public protocol FlagValue: Sendable, Equatable {
    /// Reads a value from launch-argument or environment text, or nil when it does not parse.
    init?(flagText: String)
    /// Reads a value the user's settings stored, or nil when it has another type.
    init?(stored: Any)
    /// The property-list value the user's settings store. A custom type must
    /// return a `String`, number, `Bool`, `Data` or `Date`, as `UserDefaults` requires.
    var stored: Any { get }
    /// The value as launch-argument or environment text, which `init?(flagText:)`
    /// reads back. A custom type whose description does not parse back sets its own.
    var flagText: String { get }
}

extension FlagValue {
    public var flagText: String { String(describing: self) }

    public init?(stored: Any) {
        if let value = stored as? Self {
            self = value
        } else if let text = stored as? String {
            self.init(flagText: text)
        } else {
            return nil
        }
    }
}

extension Bool: FlagValue {
    public var stored: Any { self }

    /// Accepts `YES`, `NO`, `true`, `false`, `1` and `0`, in any case.
    public init?(flagText: String) {
        switch flagText.lowercased() {
        case "yes", "true", "1": self = true
        case "no", "false", "0": self = false
        default: return nil
        }
    }
}

extension Int: FlagValue {
    public var stored: Any { self }

    public init?(flagText: String) {
        self.init(flagText, radix: 10)
    }
}

extension Double: FlagValue {
    public var stored: Any { self }

    public init?(flagText: String) {
        self.init(flagText)
    }
}

extension String: FlagValue {
    public var stored: Any { self }

    public init?(flagText: String) {
        self = flagText
    }
}

/// An enum with a `String` raw value becomes a flag value by declaring the conformance alone,
/// as `extension SortOrder: FlagValue {}`. Settings store the raw value, and overrides spell it.
extension FlagValue where Self: RawRepresentable, RawValue == String {
    public var stored: Any { rawValue }
    public var flagText: String { rawValue }

    public init?(flagText: String) {
        self.init(rawValue: flagText)
    }
}
