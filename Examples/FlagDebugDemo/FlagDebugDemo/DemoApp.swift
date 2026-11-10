import StorybookKit
import SwiftUI

/// Opens the storybook of every `#Preview` it links, FeatureFlagKitUI's stories among them.
/// Launch with `--storybook "<story name>"` to open one story straight away.
@main
struct DemoApp: App {
    private let storybook =
        StorybookLaunchRequest(arguments: ProcessInfo.processInfo.arguments) ?? .catalog

    var body: some Scene {
        WindowGroup {
            Storybook(launchRequest: storybook)
        }
    }
}
