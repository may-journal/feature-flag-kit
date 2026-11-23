#if DEBUG
import FeatureFlagKit
import SwiftUI

/// A screen that reads one flag with `@FlagState`, and names the layer that set it.
/// Its Settings toggle shows only when the build ships the flag.
struct FeatureStory: View {
    @FlagState private var isOn: Bool
    @Environment(\.flagStore) private var store
    private let flag: Flag<Bool>
    /// What the launch carried, listed above the screen, or nothing.
    private let launch: [String]

    init(_ flag: Flag<Bool>, launch: [String] = []) {
        self.flag = flag
        self.launch = launch
        _isOn = FlagState(flag)
    }

    var body: some View {
        Form {
            if !launch.isEmpty {
                Section("Launch") {
                    ForEach(launch, id: \.self) { Text($0).monospaced() }
                }
            }
            Section("Screen") {
                if isOn {
                    Label(flag.title, systemImage: "sparkles")
                } else {
                    Text("\(flag.title) is hidden").foregroundStyle(.secondary)
                }
                Text(
                    FlagText.shown(value: FlagText.value(isOn), origin: store.resolve(flag).origin))
            }
            if _isOn.isAvailable {
                Section("Settings") {
                    Toggle(flag.title, isOn: $isOn)
                }
            }
        }
    }
}

/// A Settings screen with a setting's list of choices, bound to the user's own choice.
struct ChoiceStory: View {
    @FlagState(FlagDebugStory.sortOrder) private var order
    @Environment(\.flagStore) private var store

    var body: some View {
        Form {
            Picker(FlagDebugStory.sortOrder.title, selection: $order) {
                ForEach(StorySortOrder.allCases, id: \.self) { choice in
                    Text(choice.rawValue).tag(choice)
                }
            }
            Text(
                FlagText.shown(
                    value: FlagText.value(order),
                    origin: store.resolve(FlagDebugStory.sortOrder).origin))
        }
    }
}

/// A parent toggle over a child that a screen reads with `@FlagState`.
struct GroupStory: View {
    @FlagState(FlagDebugStory.suggestions) private var suggestions
    @FlagState(FlagDebugStory.daySuggestions) private var daySuggestions

    var body: some View {
        Form {
            Section("Settings") {
                Toggle(FlagDebugStory.suggestions.title, isOn: $suggestions)
                Toggle(FlagDebugStory.daySuggestions.title, isOn: $daySuggestions)
                    .padding(.leading, 20)
            }
            Section("Screen") {
                Text(
                    "\(FlagDebugStory.daySuggestions.title) reads \(FlagText.value(daySuggestions))"
                )
            }
        }
    }
}

/// The flags an app's expiry test names on one day, given as seconds since 1970 in UTC.
struct ExpiryStory: View {
    let catalog: FlagCatalog
    let day: Date

    var body: some View {
        let expired = catalog.expired(asOf: day)
        Form {
            Section("Listed") {
                ForEach(catalog.flags, id: \.settingsKey) { flag in
                    Text(flag.expires.isNever ? flag.title : flag.title + ", " + expiry(flag))
                }
            }
            Section("Past their day on \(day.formatted(.iso8601))") {
                if expired.isEmpty { Text("None") }
                ForEach(expired, id: \.settingsKey) { Text("\($0.title) is past its day") }
            }
        }
    }

    private func expiry(_ flag: any AnyFlag) -> String {
        FlagText.expiry(flag.expires)
    }
}

/// Each change to the user's settings that a sync hook hears after the story's one write.
struct HeardStory: View {
    @Environment(\.flagStore) private var store
    @State private var heard: [String] = []
    /// What the user or the developer does once the listener is listening.
    let act: @Sendable (FlagStore) -> Void

    var body: some View {
        List {
            Section("The listener heard") {
                if heard.isEmpty { Text("Nothing yet") }
                ForEach(Array(heard.enumerated()), id: \.offset) { Text($0.element) }
            }
        }
        .task {
            let changes = store.userChanges(in: FlagDebugStory.catalog)
            act(store)
            for await change in changes {
                heard.append(Self.line(change))
            }
        }
    }

    /// The key, the new value and the writer, such as "flag.replay: true, written by the app".
    private static func line(_ change: FlagChange) -> String {
        let value = change.rawValue.map { String(describing: $0.propertyList) } ?? "no value"
        let writer = change.writer == .app ? "the app" : "an import"
        return "\(change.key): \(value), written by \(writer)"
    }
}

/// Cards that each read the flag with `@FlagState`, paged sideways.
struct CardsStory: View {
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(1..<4) { page in
                    FlagCard(page: page).containerRelativeFrame(.horizontal)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
    }
}

/// One card of `CardsStory`.
private struct FlagCard: View {
    @FlagState(FlagDebugStory.onThisDay) private var onThisDay
    let page: Int

    var body: some View {
        VStack(spacing: 8) {
            Text("Page \(page)").font(.title)
            Text("\(FlagDebugStory.onThisDay.title) reads \(FlagText.value(onThisDay))")
        }
    }
}

/// Words alone, for an acceptance no screen can show, such as one that stops the app.
struct NoteStory: View {
    let lines: [String]

    var body: some View {
        List(lines, id: \.self) { Text($0) }
    }
}
#endif
