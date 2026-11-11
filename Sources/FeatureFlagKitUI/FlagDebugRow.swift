import FeatureFlagKit
import SwiftUI

/// A flag the debug screen can read and change without knowing its value type.
protocol DebuggableFlag: AnyFlag {
    /// The flag's value as the screen shows it, and the layer that set it.
    func shown(in store: FlagStore) -> (value: String, origin: FlagOrigin)
    /// A binding to the user's own setting, for a flag that holds a `Bool`.
    func userToggle(in store: FlagStore) -> Binding<Bool>?
    /// A binding to the user's own setting, for a flag that holds an `Int`.
    func userNumber(in store: FlagStore) -> Binding<Int>?
}

extension Flag: DebuggableFlag {
    func shown(in store: FlagStore) -> (value: String, origin: FlagOrigin) {
        let resolution = store.resolve(self)
        return (FlagText.value(resolution.value), resolution.origin)
    }

    func userToggle(in store: FlagStore) -> Binding<Bool>? {
        (self as? Flag<Bool>).map { store.userBinding(for: $0) }
    }

    func userNumber(in store: FlagStore) -> Binding<Int>? {
        (self as? Flag<Int>).map { store.userBinding(for: $0) }
    }
}

extension FlagStore {
    /// Reads and writes the user's own layer for `flag`, which an override still beats.
    func userBinding<Value: FlagValue>(for flag: Flag<Value>) -> Binding<Value> {
        Binding(
            get: { self.userValue(for: flag) },
            set: { self.set($0, for: flag) }
        )
    }
}

/// The words the debug screen shows for a value, a layer and a day.
enum FlagText {
    /// What a row says for a flag of the app's own type, which no store can resolve.
    static let unknown = "Value unknown, not a Flag"

    /// "On" or "Off" for a `Bool`, otherwise the value's `flagText`, such as a choice's raw value.
    static func value(_ value: some FlagValue) -> String {
        guard let bool = value as? Bool else { return value.flagText }
        return bool ? "On" : "Off"
    }

    /// The layer's name: launch argument, environment, user setting or default.
    static func origin(_ origin: FlagOrigin) -> String {
        origin == .user ? "user setting" : origin.description
    }

    /// The value and the layer that set it, such as "On, from user setting". A child its
    /// parent turned off says so: "Off, because Use suggestions is off".
    static func shown(value: String, origin: FlagOrigin) -> String {
        origin.parentName == nil
            ? "\(value), from \(Self.origin(origin))" : "\(value), because \(origin.description)"
    }

    static func expiry(_ expires: FlagExpiry) -> String {
        "Expires " + String(format: "%04d-%02d-%02d", expires.year, expires.month, expires.day)
    }

    /// Why the user's control is disabled: a layer above it sets the flag.
    static func overridden(by origin: FlagOrigin) -> String {
        "Set by the \(Self.origin(origin)), which beats this setting."
    }
}

/// One flag's title, value, layer and expiry day if it has one, read by VoiceOver in that order.
/// A `Bool` flag gets a toggle, an `Int` flag a number field, and a child sits under its parent.
struct FlagDebugRow: View {
    let flag: any AnyFlag
    let store: FlagStore
    /// The value and layer, read by the screen so a change redraws this row. It is nil
    /// for a flag of the app's own type, which the store cannot resolve.
    let shown: (value: String, origin: FlagOrigin)?
    /// Whether the row sits under its parent's row.
    var isChild = false

    var body: some View {
        // Any layer other than the user's own or the default sits above the control,
        // and so does a parent that is off.
        let overriding = shown.map { $0.origin != .user && $0.origin != .compiledDefault } ?? false
        let byParent = shown?.origin.parentName != nil
        VStack(alignment: .leading, spacing: 4) {
            control
                .disabled(overriding)
            Text(
                shown.map { FlagText.shown(value: $0.value, origin: $0.origin) }
                    ?? FlagText.unknown)
            // A permanent setting has no expiry day to show.
            if !flag.expires.isNever {
                Text(FlagText.expiry(flag.expires))
                    .foregroundStyle(.secondary)
            }
            // The value line already names an off parent as the reason.
            if overriding, !byParent, let shown {
                Text(FlagText.overridden(by: shown.origin))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.leading, isChild ? 20 : 0)
    }

    /// The control that writes the user's layer, or the bare title for a type it cannot edit.
    @ViewBuilder private var control: some View {
        let debuggable = flag as? any DebuggableFlag
        if let toggle = debuggable?.userToggle(in: store) {
            Toggle(flag.title, isOn: toggle)
        } else if let number = debuggable?.userNumber(in: store) {
            LabeledContent(flag.title) {
                // Saves on Return or when focus leaves, so a half-typed number is never saved.
                // The row's label shows the title, so the field names it only for VoiceOver.
                TextField(String(), value: number, format: .number)
                    .accessibilityLabel(flag.title)
                    .multilineTextAlignment(.trailing)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 96)
                    .numberKeyboard()
            }
        } else {
            Text(flag.title)
        }
    }
}

extension View {
    /// On iOS, a keyboard with digits, a minus sign and Return; the Mac types on its own keys.
    func numberKeyboard() -> some View {
        #if os(iOS)
        keyboardType(.numbersAndPunctuation)
        #else
        self
        #endif
    }
}
