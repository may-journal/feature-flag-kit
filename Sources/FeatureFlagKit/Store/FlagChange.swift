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
    case array([FlagRawValue])
    case dictionary([String: FlagRawValue])

    /// Reads a property-list value, as the user's settings or another store hand it back,
    /// or nil for a type settings cannot hold.
    public init?(propertyList: Any) {
        guard let value = Self.scalar(propertyList) ?? Self.collection(propertyList) else {
            return nil
        }
        self = value
    }

    /// A string, data, date or number, or nil for anything else.
    private static func scalar(_ propertyList: Any) -> FlagRawValue? {
        switch propertyList {
        case let text as String: .string(text)
        case let data as Data: .data(data)
        case let date as Date: .date(date)
        case let number as NSNumber: Self.number(number)
        default: nil
        }
    }

    /// An array or dictionary whose every element reads, or nil for anything else.
    private static func collection(_ propertyList: Any) -> FlagRawValue? {
        if let array = propertyList as? [Any] {
            let values = array.compactMap(FlagRawValue.init(propertyList:))
            return values.count == array.count ? .array(values) : nil
        }
        if let dictionary = propertyList as? [String: Any] {
            let values = dictionary.compactMapValues(FlagRawValue.init(propertyList:))
            return values.count == dictionary.count ? .dictionary(values) : nil
        }
        return nil
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
        case .array(let values): values.map(\.propertyList)
        case .dictionary(let values): values.mapValues(\.propertyList)
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

/// What an import does with a value for one flag.
enum FlagImport: Sendable {
    /// Store this value, which reads as the flag's type and differs from its default.
    case store(FlagRawValue)
    /// Remove the key, since the value is the default, so the flag follows a later release.
    case remove
    /// Leave the key, since the value does not read as the flag's type.
    case skip
}

/// A flag that can judge an imported value by its own type and default.
protocol ImportableFlag: AnyFlag {
    /// What an import does with `raw` for this flag.
    var importing: @Sendable (FlagRawValue) -> FlagImport { get }
}

extension Flag: ImportableFlag {
    var importing: @Sendable (FlagRawValue) -> FlagImport {
        let defaultValue = defaultValue
        return { raw in
            guard let value = Value(stored: raw.propertyList) else { return .skip }
            guard value != defaultValue else { return .remove }
            return FlagRawValue(propertyList: value.stored).map { .store($0) } ?? .skip
        }
    }
}
