import FeatureFlagKit
import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension EnvironmentValues {
    /// Where "Copy launch arguments" puts its line: the system pasteboard, unless a test or
    /// a preview swaps in its own.
    @Entry var flagPasteboard = FlagPasteboard.system
}

/// A place a copied line goes, held in a type so the environment can carry it.
struct FlagPasteboard: Sendable {
    let put: @MainActor @Sendable (String) -> Void

    /// Puts the line on the system pasteboard.
    static let system = FlagPasteboard(put: FlagCopy.toPasteboard)
}

/// Spells and copies the line a tester hands to a developer.
enum FlagCopy {
    /// The arguments as one line for a scheme or a shell. Single quotes wrap any argument
    /// that is empty or holds a character a shell reads, such as a space, `;` or `$`.
    static func line(_ arguments: [String]) -> String {
        arguments.map { argument in
            let isPlain = !argument.isEmpty && argument.unicodeScalars.allSatisfy(plain.contains)
            return isPlain ? argument : "'" + argument.replacing("'", with: "'\\''") + "'"
        }
        .joined(separator: " ")
    }

    /// The characters no shell reads specially, which need no quotes.
    private static let plain = CharacterSet.alphanumerics.union(
        CharacterSet(charactersIn: "-_.,:/=+@%"))

    /// Puts `text` on the system pasteboard.
    @MainActor
    static func toPasteboard(_ text: String) {
        #if canImport(UIKit)
        UIPasteboard.general.string = text
        #elseif canImport(AppKit)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #endif
    }
}

/// Copies the store's flags as launch arguments, then says so for two seconds. It is
/// disabled while every flag reads its compiled default.
struct FlagCopyButton: View {
    let catalog: FlagCatalog
    let store: FlagStore
    @Environment(\.flagPasteboard) private var pasteboard
    @State private var copied = false

    var body: some View {
        let arguments = store.launchArguments(for: catalog)
        Button(copied ? Self.done : Self.title) {
            pasteboard.put(FlagCopy.line(arguments))
            copied = true
        }
        .disabled(arguments.isEmpty)
        .task(id: copied) {
            guard copied else { return }
            try? await Task.sleep(for: .seconds(2))
            copied = false
        }
    }

    static let title = "Copy launch arguments"
    static let done = "Copied"
}
