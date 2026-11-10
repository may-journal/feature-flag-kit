import FeatureFlagKit
import Foundation
import Testing

/// Requirement 0003: a test that fails once a flag outstays its expiry day.
@Suite struct Expiring {
    /// 08:00 on 15 January 2027, in UTC.
    private let today = Date(timeIntervalSince1970: 1_800_000_000)

    @Test func test0003_1() {
        let stale = Flag(
            "replay", default: false, title: "Replay",
            expires: FlagExpiry(year: 2027, month: 1, day: 15))
        let catalog = FlagCatalog([ExampleFlags.onThisDay, stale])
        #expect(catalog.expired(asOf: today).map(\.name) == ["replay"])
    }

    @Test func test0003_2() {
        let fresh = Flag(
            "mentions", default: false, title: "Mentions",
            expires: FlagExpiry(year: 2027, month: 1, day: 16))
        let catalog = FlagCatalog([ExampleFlags.onThisDay, fresh])
        #expect(catalog.expired(asOf: today).isEmpty)
    }
}
