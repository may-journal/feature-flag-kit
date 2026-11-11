/// Where a flag's value came from, so a debug screen can say why it is on.
public struct FlagOrigin: Sendable, Hashable, CustomStringConvertible {
    /// A short name for the origin, such as "launch argument".
    public let description: String
    /// The parent's name when the parent being off is what turned the flag off, otherwise nil.
    public let parentName: String?

    public init(_ description: String) {
        self.init(description: description, parentName: nil)
    }

    private init(description: String, parentName: String?) {
        self.description = description
        self.parentName = parentName
    }

    /// The flag's parent, which is off, so the flag reads off whatever its own layers say.
    public static func parent(_ parent: Flag<Bool>) -> FlagOrigin {
        FlagOrigin(description: "\(parent.title) is off", parentName: parent.name)
    }

    /// A `-flag.<name> <value>` launch argument.
    public static let launchArgument = FlagOrigin("launch argument")
    /// A `FLAG_<NAME>` environment variable.
    public static let environment = FlagOrigin("environment")
    /// The person's own toggle in the app's settings.
    public static let user = FlagOrigin("user")
    /// The flag's compiled default.
    public static let compiledDefault = FlagOrigin("default")
}

/// A flag's value and the origin that supplied it.
public struct FlagResolution<Value: FlagValue>: Sendable, Equatable {
    public let value: Value
    public let origin: FlagOrigin
}
