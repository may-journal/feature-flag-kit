import FeatureFlagKit
import SwiftUI
import Testing
import UITestingLibrary

@testable import FeatureFlagKitUI

/// Requirement 0013: the storybook's pages show their acceptance on real views.
extension FeatureFlagKitTests {
    @MainActor
    @Suite struct Stories {
        @Test func test0013_1() async throws {
            let screen = try Screen.render { FlagDebugStory.feature(.story()) }
            let user = User(screen)
            try await user.sees(.text("On This Day is hidden"))
            try await user.taps(.role(.toggle, "On This Day"))
            try await user.sees(.text("On, from user setting"))
            try screen.close()
        }

        @Test func test0013_2() async throws {
            let screen = try Screen.render {
                HeardStory { $0.set(true, for: FlagDebugStory.replay) }
                    .environment(\.flagStore, .story())
            }
            try await User(screen).sees(.text("flag.replay: true, written by the app"))
            try screen.close()
        }

        @Test func test0013_3() async throws {
            let screen = try Screen.render { FlagDebugStory.expiry(onReplaysDay: true) }
            try await User(screen).sees(.text("Replay is past its day"))
            try screen.close()
        }
    }
}
