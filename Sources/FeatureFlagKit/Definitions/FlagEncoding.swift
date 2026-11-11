/// How a flag's name becomes a launch argument, an environment variable and a
/// settings key. Every target spells overrides through here, so the encoding
/// lives in one place.
public enum FlagEncoding {
    /// The launch argument that names a flag: `-flag.<name>`, followed by its value.
    public static func argument(for name: String) -> String {
        "-flag.\(name)"
    }

    /// The environment variable that sets a flag: `FLAG_` and the camel-case
    /// name in upper snake case, so `showHTMLView` becomes `FLAG_SHOW_HTML_VIEW`.
    public static func environmentVariable(for name: String) -> String {
        let characters = Array(name)
        var out = "FLAG_"
        for (index, character) in characters.enumerated() {
            if index > 0, startsWord(characters, at: index) {
                out.append("_")
            }
            out.append(character.isLetter || character.isNumber ? character : "_")
        }
        return out.uppercased()
    }

    /// Whether an uppercase letter starts a word. It does after a lowercase letter
    /// or digit, and as an acronym's last capital before a lowercase letter.
    private static func startsWord(_ characters: [Character], at index: Int) -> Bool {
        let character = characters[index]
        let previous = characters[index - 1]
        guard character.isUppercase else { return false }
        if previous.isLowercase || previous.isNumber { return true }
        let next = index + 1 < characters.count ? characters[index + 1] : nil
        return previous.isUppercase && next?.isLowercase == true
    }

    /// The settings key a flag's toggle lives under when it has no legacy key.
    public static func settingsKey(for name: String) -> String {
        "flag.\(name)"
    }

    /// The launch arguments that set `flag` to `value`, ready to append to a launch.
    public static func arguments<Value: FlagValue>(_ flag: Flag<Value>, _ value: Value) -> [String]
    {
        [argument(for: flag.name), value.flagText]
    }

    /// The environment variable that sets `flag` to `value`, ready to merge into a launch.
    public static func environment<Value: FlagValue>(
        _ flag: Flag<Value>, _ value: Value
    ) -> [String: String] {
        [environmentVariable(for: flag.name): value.flagText]
    }
}
