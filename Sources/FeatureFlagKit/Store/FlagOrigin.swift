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

    /// The flag doesn't ship in this environment, so it reads its compiled default.
    public static func unavailable(in environment: FlagEnvironment) -> FlagOrigin {
        FlagOrigin("not available in \(environment)")
    }

    /// The flag's default for this environment, set by `environmentDefaults`.
    public static func environmentDefault(_ environment: FlagEnvironment) -> FlagOrigin {
        FlagOrigin("\(environment) default")
    }

    /// A `-flag.<name> <value>` launch argument.
    public static let launchArgument = FlagOrigin("launch argument")
    /// A `FLAG_<NAME>` environment variable.
    public static let environment = FlagOrigin("environment")
    /// The person's own toggle in the app's settings.
    public static let user = FlagOrigin("user")
    /// The flag's compiled default.
    public static let compiledDefault = FlagOrigin("default")

    /// Whether a launch argument or environment variable set the flag, over the user's setting.
    public var isOverride: Bool {
        self == .launchArgument || self == .environment
    }
}

/// A flag's value and the origin that supplied it.
public struct FlagResolution<Value: FlagValue>: Sendable, Equatable {
    public let value: Value
    public let origin: FlagOrigin
}
