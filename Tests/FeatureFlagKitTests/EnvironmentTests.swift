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
        /// An app bundle on disk whose Info.plist holds `info`, as Xcode would build it.
        private func appBundle(_ info: [String: String]) throws -> Bundle {
            let root = FileManager.default.temporaryDirectory
                .appending(path: "FlagEnvironment-\(UUID().uuidString).app")
            let contents = root.appending(path: "Contents")
            try FileManager.default.createDirectory(at: contents, withIntermediateDirectories: true)
            var plist: [String: String] = ["CFBundleIdentifier": "example.\(UUID().uuidString)"]
            plist.merge(info) { _, given in given }
            let data = try PropertyListSerialization.data(
                fromPropertyList: plist, format: .xml, options: 0)
            try data.write(to: contents.appending(path: "Info.plist"))
            return try #require(Bundle(url: root))
        }

        /// The store the app makes at launch, on settings of its own, from `bundle`.
        private func launch(_ bundle: Bundle, in environment: FlagEnvironment? = nil) throws
            -> FlagStore
        {
            let defaults = try #require(UserDefaults(suiteName: "flags.\(UUID().uuidString)"))
            return .live(defaults: defaults, bundle: bundle, in: environment)
        }

        @Test func test0011_1() throws {
            let store = try launch(appBundle([FlagEnvironment.infoPlistKey: "internal"]))
            #expect(store.environment == .internal)
        }

        @Test func test0011_2() throws {
            let store = try launch(appBundle([:]))
            #expect(store.environment == .debug)
        }

        @Test func test0011_3() throws {
            let bundle = try appBundle([FlagEnvironment.infoPlistKey: "internal"])
            let store = try launch(bundle, in: .production)
            #expect(store.environment == .production)
        }

        @Test func test0011_4() async throws {
            let store = try launch(appBundle([FlagEnvironment.infoPlistKey: "internal"]))
            let screen = try Screen.render {
                FlagDebugView(catalog: ExampleFlags.catalog).environment(\.flagStore, store)
            }
            try await User(screen).sees(.text("Environment: internal, from Info.plist"))
            try screen.close()
        }
    }
}
