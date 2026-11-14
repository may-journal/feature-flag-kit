import FeatureFlagKit
import FeatureFlagKitUI
import Foundation
import SwiftUI
import Testing
import UITestingLibrary

/// Requirement 0011: the build says who it is for, and the debug screen shows it.
extension FeatureFlagKitTests {
    @MainActor
    @Suite struct Environments {
        private let key = FlagEnvironment.infoPlistKey

        @Test func test0011_1() throws {
            let app = try LaunchedApp(info: [key: "internal"])
            defer { app.remove() }
            #expect(app.store.environment == .internal)
        }

        // The suite runs as a Debug build, as `make requirements` builds it.
        @Test func test0011_2() throws {
            let app = try LaunchedApp(info: [:])
            defer { app.remove() }
            #expect(app.store.environment == .debug)
        }

        @Test func test0011_3() throws {
            let app = try LaunchedApp(info: [key: "internal"], in: .production)
            defer { app.remove() }
            #expect(app.store.environment == .production)
        }

        @Test func test0011_4() async throws {
            let app = try LaunchedApp(info: [key: "internal"])
            defer { app.remove() }
            let screen = try Screen.render {
                FlagDebugView(catalog: ExampleFlags.catalog).environment(\.flagStore, app.store)
            }
            try await User(screen).sees(.text("Environment: internal, from Info.plist"))
            try screen.close()
        }

        @Test func test0011_5() throws {
            // An unset build setting leaves the key empty.
            let app = try LaunchedApp(info: [key: ""])
            defer { app.remove() }
            #expect(app.store.environment == .production)
        }
    }
}

/// An app launched from a bundle on disk, as Xcode would build it, on settings of its own.
/// `remove()` deletes both, so a run leaves nothing behind.
private struct LaunchedApp {
    let store: FlagStore
    private let bundleURL: URL
    private let suiteName: String

    /// Builds a bundle whose Info.plist holds `info`, then makes the live store from it.
    init(info: [String: String], in environment: FlagEnvironment? = nil) throws {
        bundleURL = FileManager.default.temporaryDirectory
            .appending(path: "FlagEnvironment-\(UUID().uuidString).app")
        let contents = bundleURL.appending(path: "Contents")
        try FileManager.default.createDirectory(at: contents, withIntermediateDirectories: true)
        var plist = ["CFBundleIdentifier": "example.\(UUID().uuidString)"]
        plist.merge(info) { _, given in given }
        let data = try PropertyListSerialization.data(
            fromPropertyList: plist, format: .xml, options: 0)
        try data.write(to: contents.appending(path: "Info.plist"))
        let bundle = try #require(Bundle(url: bundleURL))
        suiteName = "flags.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        store = .live(defaults: defaults, bundle: bundle, in: environment)
    }

    func remove() {
        UserDefaults.standard.removePersistentDomain(forName: suiteName)
        try? FileManager.default.removeItem(at: bundleURL)
    }
}
