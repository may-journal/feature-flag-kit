import CoreFoundation
import Foundation

/// A value the user's settings hold, in a form that crosses threads and compares equal. It is
/// what a sync hook copies to another store, such as iCloud key-value storage, and back.
public enum FlagRawValue: Sendable, Hashable {
    case bool(Bool)
    case int(Int)
    case double(Double)
    case string(String)
    case data(Data)
    case date(Date)

    /// Reads a property-list value, as the user's settings or another store hand it back,
    /// or nil for a type settings cannot hold.
    public init?(propertyList: Any) {
        switch propertyList {
        case let text as String: self = .string(text)
        case let data as Data: self = .data(data)
        case let date as Date: self = .date(date)
        case let number as NSNumber: self = Self.number(number)
        default: return nil
        }
    }

    /// The property-list value to write to the user's settings or another store.
    public var propertyList: Any {
        switch self {
        case .bool(let value): value
        case .int(let value): value
        case .double(let value): value
        case .string(let value): value
        case .data(let value): value
        case .date(let value): value
        }
    }

    /// A Boolean, whole or fractional number, since settings hand each back as a number.
    private static func number(_ number: NSNumber) -> FlagRawValue {
        if CFGetTypeID(number) == CFBooleanGetTypeID() { return .bool(number.boolValue) }
        if CFNumberIsFloatType(number) { return .double(number.doubleValue) }
        return .int(number.intValue)
    }
}

/// Who wrote a change to the user's settings.
public enum FlagWriter: Sendable, Hashable {
    /// The app: a toggle, a reset or a direct write to the settings.
    case app
    /// `FlagStore.importUserValues(_:)`, such as values synced from another device.
    case `import`
}

/// One change to the user's own layer: the flag, its key, its new value and who wrote it.
public struct FlagChange: Sendable, Hashable {
    /// The flag's name, as overrides spell it.
    public let name: String
    /// The settings key that holds the user's value.
    public let key: String
    /// The new stored value, or nil when the user's value was cleared.
    public let rawValue: FlagRawValue?
    /// Whether the app or an import wrote it, so a sync hook sends back only the app's writes.
    public let writer: FlagWriter

    public init(name: String, key: String, rawValue: FlagRawValue?, writer: FlagWriter) {
        self.name = name
        self.key = key
        self.rawValue = rawValue
        self.writer = writer
    }
}
