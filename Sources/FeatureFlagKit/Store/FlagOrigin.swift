/// Where a flag's value came from, so a debug screen can say why it is on.
public struct FlagOrigin: Sendable, Hashable, CustomStringConvertible {
    /// A short name for the origin, such as "launch argument".
    public let description: String

    public init(_ description: String) {
        self.description = description
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
