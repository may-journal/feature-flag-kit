import FeatureFlagKit
import FeatureFlagKitUI
import Foundation
import SwiftUI
import Testing
import UITestingLibrary

/// Requirement 0010: a parent toggle that turns its children off and keeps their settings.
extension FeatureFlagKitTests {
    @MainActor
    @Suite struct Grouping {
        private let parent = ExampleFlags.suggestions
        private let child = ExampleFlags.daySuggestions

        @Test func test0010_1() {
            let store = FlagStore.isolated()
            store.set(false, for: parent)
            #expect(!store[child])
        }

        @Test func test0010_2() {
            let store = FlagStore.isolated()
            store.set(false, for: child)
            store.set(false, for: parent)
            store.set(true, for: parent)
            #expect(!store[child])
        }

        @Test func test0010_3() {
            let store = FlagStore.isolated(arguments: FlagEncoding.arguments(child, false))
            #expect(store[parent])
            let resolution = store.resolve(child)
            #expect(!resolution.value && resolution.origin == .launchArgument)
        }

        @Test func test0010_4() async throws {
            let store = FlagStore.isolated()
            let screen = try Screen.render {
                DaySuggestionsScreen().environment(\.flagStore, store)
            }
            let user = User(screen)
            try await user.sees(.text("Day suggestion ready"))
            store.set(false, for: parent)
            try await user.sees(.text("No day suggestion"))
            try screen.close()
        }

        @Test func test0010_5() async throws {
            let store = FlagStore.isolated()
            store.set(false, for: parent)
            let screen = try Screen.render {
                FlagDebugView(catalog: FlagCatalog([parent, child]))
                    .environment(\.flagStore, store)
            }
            let user = User(screen)
            let toggle = try await user.sees(.role(.toggle, "For days"))
            #expect(!toggle.isEnabled)
            try await user.sees(.text("Off, because Use suggestions is off"))
            try screen.close()
        }

        @Test func test0010_6() async throws {
            let screen = try Screen.render {
                FlagDebugView(catalog: ExampleFlags.groupCatalog)
                    .environment(\.flagStore, .isolated())
            }
            let user = User(screen)
            try await user.sees(.role(.toggle, "For days"))
            let names = ["Grid columns", "Use suggestions", "For days"]
            // A number field reads its title twice, once as the label and once as the field.
            let titles = await user.reads().map(\.spoken).compactMap { spoken in
                names.first { spoken.hasPrefix($0) }
            }
            let rows = titles.enumerated().filter { row in
                row.offset == 0 || titles[row.offset - 1] != row.element
            }
            #expect(rows.map(\.element) == names)
            try screen.close()
        }

        @Test func test0010_8() async throws {
            let store = FlagStore.isolated()
            store.set(false, for: parent)
            let changes = store.userChanges(in: FlagCatalog([parent, child]))
            let screen = try Screen.render {
                DaySuggestionsScreen().environment(\.flagStore, store)
            }
            try await User(screen).taps(.role(.toggle, "Suggest for days"))
            let first = await firstChange(of: changes)
            #expect(
                first
                    == FlagChange(
                        name: "daySuggestions", key: "flag.daySuggestions",
                        rawValue: .bool(false), writer: .app))
            try screen.close()
        }

        /// The first change `stream` yields, or nil once two seconds pass.
        private func firstChange(of stream: AsyncStream<FlagChange>) async -> FlagChange? {
            await withTaskGroup(of: FlagChange?.self) { group in
                group.addTask {
                    for await change in stream { return change }
                    return nil
                }
                group.addTask {
                    try? await Task.sleep(for: .seconds(2))
                    return nil
                }
                let first = await group.next().flatMap { $0 }
                group.cancelAll()
                return first
            }
        }
    }
}

/// Requirement 0010.7, apart from the main-actor suite since it runs in a child process.
@Test func test0010_7() async {
    let result = await #expect(
        processExitsWith: .failure, observing: [\.standardErrorContent]
    ) {
        _ = Flag("nested", default: true, title: "Nested", parent: ExampleFlags.daySuggestions)
    }
    let message = String(bytes: result?.standardErrorContent ?? [], encoding: .utf8) ?? ""
    #expect(message.contains("a group is one level deep"))
}
