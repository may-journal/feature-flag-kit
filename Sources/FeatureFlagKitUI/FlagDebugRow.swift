import FeatureFlagKit
import SwiftUI

/// A flag the debug screen can read and toggle without knowing its value type.
protocol DebuggableFlag: AnyFlag {
    /// The flag's value as the screen shows it, and the layer that set it.
    func shown(in store: FlagStore) -> (value: String, origin: FlagOrigin)
    /// A binding to the user's own toggle, for a flag that holds a `Bool`.
    func userToggle(in store: FlagStore) -> Binding<Bool>?
}

extension Flag: DebuggableFlag {
    func shown(in store: FlagStore) -> (value: String, origin: FlagOrigin) {
        let resolution = store.resolve(self)
        return (FlagText.value(resolution.value), resolution.origin)
    }

    func userToggle(in store: FlagStore) -> Binding<Bool>? {
        guard let flag = self as? Flag<Bool> else { return nil }
        return Binding(
            get: { store.userValue(for: flag) },
            set: { store.set($0, for: flag) }
        )
    }
}

/// The words the debug screen shows for a value, a layer and a day.
enum FlagText {
    /// What a row says for a flag of the app's own type, which no store can resolve.
    static let unknown = "Value unknown, not a Flag"

    static func value(_ value: some FlagValue) -> String {
        guard let bool = value as? Bool else { return String(describing: value) }
        return bool ? "On" : "Off"
    }

    /// The layer's name: launch argument, environment, user toggle or default.
    static func origin(_ origin: FlagOrigin) -> String {
        origin == .user ? "user toggle" : origin.description
    }

    static func expiry(_ expires: FlagExpiry) -> String {
        "Expires " + String(format: "%04d-%02d-%02d", expires.year, expires.month, expires.day)
    }

    /// Why the user's toggle is disabled: a layer above it sets the flag.
    static func overridden(by origin: FlagOrigin) -> String {
        "Set by the \(Self.origin(origin)), which beats this toggle."
    }
}

/// One flag's title, value, layer and expiry day, read by VoiceOver in that order.
/// A flag that holds a `Bool` also gets a toggle for the user's layer.
struct FlagDebugRow: View {
    let flag: any AnyFlag
    let store: FlagStore
    /// The value and layer, read by the screen so a change redraws this row. It is nil
    /// for a flag of the app's own type, which the store cannot resolve.
    let shown: (value: String, origin: FlagOrigin)?

    var body: some View {
        // Any layer other than the user's own or the default sits above the toggle.
        let overriding = shown.map { $0.origin != .user && $0.origin != .compiledDefault } ?? false
        VStack(alignment: .leading, spacing: 4) {
            if let toggle = (flag as? any DebuggableFlag)?.userToggle(in: store) {
                Toggle(flag.title, isOn: toggle)
                    .disabled(overriding)
            } else {
                Text(flag.title)
            }
            Text(
                shown.map { "\($0.value), from \(FlagText.origin($0.origin))" } ?? FlagText.unknown)
            Text(FlagText.expiry(flag.expires))
                .foregroundStyle(.secondary)
            if overriding, let shown {
                Text(FlagText.overridden(by: shown.origin))
                    .foregroundStyle(.secondary)
            }
        }
    }
}
