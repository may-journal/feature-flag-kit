/// A type a flag can hold. Overrides carry it as text, and the user's
/// settings store it as a property-list value.
public protocol FlagValue: Sendable, Equatable {
    /// Reads a value from launch-argument or environment text, or nil when it does not parse.
    init?(flagText: String)
    /// Reads a value the user's settings stored, or nil when it has another type.
    init?(stored: Any)
    /// The property-list value the user's settings store.
    var stored: Any { get }
}

extension FlagValue {
    public init?(stored: Any) {
        if let value = stored as? Self {
            self = value
        } else if let text = stored as? String {
            self.init(flagText: text)
        } else {
            return nil
        }
    }

    public var stored: Any { self }
}

extension Bool: FlagValue {
    /// Accepts the spellings `UserDefaults` accepts for a Boolean argument.
    public init?(flagText: String) {
        switch flagText.lowercased() {
        case "yes", "true", "1": self = true
        case "no", "false", "0": self = false
        default: return nil
        }
    }
}

extension Int: FlagValue {
    public init?(flagText: String) {
        self.init(flagText, radix: 10)
    }
}

extension Double: FlagValue {
    public init?(flagText: String) {
        self.init(flagText)
    }
}

extension String: FlagValue {
    public init?(flagText: String) {
        self = flagText
    }
}
