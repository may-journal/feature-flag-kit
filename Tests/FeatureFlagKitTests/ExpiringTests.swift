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

    @Test func test0003_3() throws {
        var japanese = Calendar(identifier: .japanese)
        japanese.timeZone = try #require(TimeZone(identifier: "Asia/Tokyo"))
        // 07:00 on 16 January of the era year 9 (2027) in Tokyo is still 15 January in UTC.
        let era = japanese.component(.era, from: today)
        let tokyoMorning = try #require(
            japanese.date(from: DateComponents(era: era, year: 9, month: 1, day: 16, hour: 7)))
        let tomorrow = Flag(
            "mentions", default: false, title: "Mentions",
            expires: FlagExpiry(year: 2027, month: 1, day: 16))
        let catalog = FlagCatalog([ExampleFlags.onThisDay, tomorrow])
        #expect(catalog.expired(asOf: tokyoMorning).isEmpty)
    }

    @Test func test0003_4() {
        let catalog = FlagCatalog([ExampleFlags.sortOrder])
        #expect(catalog.expired(asOf: .distantFuture).isEmpty)
    }
}
