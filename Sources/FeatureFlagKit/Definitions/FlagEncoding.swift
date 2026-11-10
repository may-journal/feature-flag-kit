/// How a flag's name becomes a launch argument, an environment variable and a
/// settings key. Every target spells overrides through here, so the encoding
/// lives in one place.
public enum FlagEncoding {
    /// The launch argument that names a flag: `-flag.<name>`, followed by its value.
    public static func argument(for name: String) -> String {
        "-flag.\(name)"
    }

    /// The environment variable that sets a flag: `FLAG_` and the name in
    /// upper snake case, so `onThisDay` becomes `FLAG_ON_THIS_DAY`.
    public static func environmentVariable(for name: String) -> String {
        var out = "FLAG_"
        var previous: Character?
        for character in name {
            if character.isUppercase, let previous, previous.isLowercase || previous.isNumber {
                out.append("_")
            }
            out.append(character.isLetter || character.isNumber ? character : "_")
            previous = character
        }
        return out.uppercased()
    }

    /// The settings key a flag's toggle lives under when it has no legacy key.
    public static func settingsKey(for name: String) -> String {
        "flag.\(name)"
    }

    /// The launch arguments that set `flag` to `value`, ready to append to a launch.
    public static func arguments<Value: FlagValue>(
        _ flag: Flag<Value>, _ value: Value
    ) -> [String] where Value: CustomStringConvertible {
        [argument(for: flag.name), value.description]
    }
}
