import FeatureFlagKit
import SwiftUI

/// The control a row shows for a flag that is neither a toggle nor a whole number.
enum FlagField {
    /// The type's cases, each spelled by its `flagText`, and the one the user chose.
    case choice([String], Binding<String>)
    /// A `Double` flag's own setting.
    case decimal(Binding<Double>)
    /// A `String` flag's own setting.
    case text(Binding<String>)
}

extension Flag {
    /// The user's own setting for a decimal, a text or a choice flag, or nil for any other.
    func userField(in store: FlagStore) -> FlagField? {
        if let flag = self as? Flag<Double> { return .decimal(store.userBinding(for: flag)) }
        if let flag = self as? Flag<String> { return .text(store.userBinding(for: flag)) }
        return choices(in: store)
    }

    /// The picker for a value type that lists its cases, found with no code per choice.
    private func choices(in store: FlagStore) -> FlagField? {
        guard let type = Value.self as? any CaseIterable.Type else { return nil }
        let cases = Self.cases(of: type).compactMap { $0 as? Value }
        guard !cases.isEmpty else { return nil }
        let selection = Binding<String>(
            get: { store.userValue(for: self).flagText },
            set: { text in
                guard let value = cases.first(where: { $0.flagText == text }) else { return }
                store.set(value, for: self)
            }
        )
        return .choice(cases.map(\.flagText), selection)
    }

    private static func cases<Cases: CaseIterable>(of type: Cases.Type) -> [Any] {
        Array(type.allCases)
    }
}

/// Text as typed, so a text field saves on Return or when focus leaves, as a number field does.
struct FlagTextFormat: ParseableFormatStyle, ParseStrategy {
    var parseStrategy: FlagTextFormat { self }

    func format(_ value: String) -> String { value }
    func parse(_ value: String) throws -> String { value }
}

/// A picker, a decimal field or a text field that writes the user's layer for one flag.
struct FlagFieldControl: View {
    let title: String
    let field: FlagField

    var body: some View {
        switch field {
        case .choice(let choices, let selection):
            LabeledContent(title) {
                // One button per choice, the chosen one tinted and marked as selected.
                HStack {
                    ForEach(choices, id: \.self) { choice in
                        let isChosen = choice == selection.wrappedValue
                        Button(choice) { selection.wrappedValue = choice }
                            .buttonStyle(.bordered)
                            .tint(isChosen ? Color.accentColor : Color.secondary)
                            .accessibilityAddTraits(isChosen ? .isSelected : [])
                    }
                }
            }
        case .decimal(let number):
            LabeledContent(title) {
                TextField(String(), value: number, format: .number).flagFieldStyle(title)
            }
        case .text(let text):
            LabeledContent(title) {
                TextField(String(), value: text, format: FlagTextFormat()).flagFieldStyle(title)
            }
        }
    }
}

extension View {
    /// The look every field in a row shares. The row's label shows the title, so the field
    /// names it only for VoiceOver.
    func flagFieldStyle(_ title: String) -> some View {
        accessibilityLabel(title)
            .multilineTextAlignment(.trailing)
            .textFieldStyle(.roundedBorder)
            .frame(maxWidth: 96)
    }
}
