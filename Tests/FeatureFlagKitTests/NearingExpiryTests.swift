import FeatureFlagKit
import Foundation
import SwiftUI
import Testing
import UITestingLibrary

@testable import FeatureFlagKitUI

/// Requirement 0020: a flag near its expiry day is named ahead of time.
extension FeatureFlagKitTests {
    @MainActor
    @Suite struct NearingExpiry {
        /// A beta that should be gone by 1 March 2027.
        private let replay = Flag(
            "replay", default: false, title: "Replay",
            expires: FlagExpiry(year: 2027, month: 3, day: 1))

        /// Noon UTC `days` before Replay's day, as the stories count it.
        private func before(_ days: Int) -> Date {
            FlagDebugStory.before(replaysDay: days)
        }

        /// Renders the debug screen for Replay and On This Day, opened on `today`.
        private func render(on today: Date) throws -> (Screen, User) {
            let catalog = FlagCatalog([replay, ExampleFlags.onThisDay])
            let screen = try Screen.render {
                FlagDebugView(catalog: catalog, confirmsReset: false, today: today)
                    .environment(\.flagStore, .isolated())
            }
            return (screen, User(screen))
        }

        @Test func test0020_1() {
            let catalog = FlagCatalog([ExampleFlags.onThisDay, replay])
            #expect(catalog.expiring(within: 14, asOf: before(12)).map(\.name) == ["replay"])
            #expect(catalog.expiring(within: 7, asOf: before(12)).isEmpty)
            #expect(replay.expires.daysLeft(within: 14, asOf: before(12)) == 12)
        }

        @Test func test0020_2() {
            let catalog = FlagCatalog([replay, ExampleFlags.sortOrder])
            #expect(catalog.expiring(within: 14, asOf: before(0)).isEmpty)
            #expect(catalog.expiring(within: 14, asOf: before(-3)).isEmpty)
        }

        @Test func test0020_3() throws {
            // 07:00 on 28 February in Tokyo is still 27 February in UTC, two days before.
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = try #require(TimeZone(identifier: "Asia/Tokyo"))
            let tokyoMorning = try #require(
                calendar.date(from: DateComponents(year: 2027, month: 2, day: 28, hour: 7)))
            #expect(replay.expires.daysLeft(asOf: tokyoMorning) == 2)
            #expect(FlagCatalog([replay]).expiring(within: 1, asOf: tokyoMorning).isEmpty)
        }

        @Test func test0020_4() async throws {
            let (screen, user) = try render(on: before(12))
            try await user.sees(.text("Expires 2027-03-01, in 12 days"))
            try await user.sees(.text("Expires 2099-01-01"))
            try screen.close()
        }

        @Test func test0020_5() async throws {
            let (screen, user) = try render(on: before(1))
            try await user.sees(.text("Expires 2027-03-01, in 1 day"))
            try screen.close()
        }

        @Test func test0020_6() async throws {
            let (screen, user) = try render(on: before(31))
            try await user.sees(.text("Expires 2027-03-01"))
            try screen.close()
        }
    }
}
