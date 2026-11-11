import FeatureFlagKit
import FeatureFlagKitUI
import SwiftUI

/// The example Memories screen, reading its flag with `@FlagState` from the environment.
struct WrappedMemoriesScreen: View {
    @FlagState(ExampleFlags.onThisDay) private var onThisDay

    var body: some View {
        VStack {
            Text("Memories")
            if onThisDay {
                Text("On This Day")
            }
        }
    }
}

/// An example app's own Settings screen, whose toggle writes the flag through `$binding`.
struct BetaSettingsScreen: View {
    @FlagState(ExampleFlags.onThisDay) private var onThisDay

    var body: some View {
        Form {
            Toggle("Show On This Day", isOn: $onThisDay)
            if onThisDay {
                Text("On This Day")
            }
        }
    }
}

/// An example app's day screen, which offers a suggestion while its child flag reads on.
/// Its own Settings toggle writes the child's saved setting, whatever the parent says.
struct DaySuggestionsScreen: View {
    @FlagState(ExampleFlags.daySuggestions) private var daySuggestions

    var body: some View {
        Form {
            Text(daySuggestions ? "Day suggestion ready" : "No day suggestion")
            Toggle("Suggest for days", isOn: $daySuggestions)
        }
    }
}

/// An example app screen that reads the day child afresh each time the store names it changed.
struct DaySuggestionsListener: View {
    let store: FlagStore
    @State private var isOn = false

    var body: some View {
        Text(isOn ? "Day suggestion ready" : "No day suggestion")
            .task {
                let changes = store.changes()
                isOn = store[ExampleFlags.daySuggestions]
                for await name in changes where name == ExampleFlags.daySuggestions.name {
                    isOn = store[ExampleFlags.daySuggestions]
                }
            }
    }
}

/// An example app's Settings screen for its sort setting, with a button that picks a choice.
struct SortSettingsScreen: View {
    @FlagState(ExampleFlags.sortOrder) private var sortOrder

    var body: some View {
        VStack {
            Text("Sorted by \(sortOrder.rawValue)")
            Button("Oldest first") { $sortOrder.wrappedValue = .oldest }
        }
    }
}

/// An example app's pages of cards, each reading the flag and drawn anew as the finger moves.
/// A horizontal drag past half the page's width turns the page.
struct SwipedMemoriesScreen: View {
    @State private var page = 1
    @State private var offset: CGFloat = 0

    var body: some View {
        HStack {
            ForEach(0..<12) { card in
                FlaggedCard(page: page, isTitled: card == 0).id("\(card)-\(offset)")
            }
        }
        .frame(width: 400, height: 300)
        .offset(x: offset)
        .contentShape(Rectangle())
        .gesture(
            DragGesture()
                .onChanged { offset = $0.translation.width }
                .onEnded { drag in
                    if drag.translation.width < -200 { page += 1 }
                    offset = 0
                })
    }
}

/// One card, which reads the flag; the first names its page.
private struct FlaggedCard: View {
    let page: Int
    let isTitled: Bool
    @FlagState(ExampleFlags.onThisDay) private var onThisDay

    var body: some View {
        if isTitled {
            Text(onThisDay ? "On This Day, page \(page)" : "Page \(page)")
        } else {
            Color.clear.frame(width: 2)
        }
    }
}
