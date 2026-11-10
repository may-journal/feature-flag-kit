import Foundation

/// The calendar day a flag should be gone by. A flag counts as expired from
/// the start of that day, in UTC, so every machine agrees.
public struct FlagExpiry: Sendable, Hashable {
    public let year: Int
    public let month: Int
    public let day: Int

    public init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }

    /// Whether `date` falls on or after the expiry day.
    public func isPassed(asOf date: Date) -> Bool {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        let parts = DateComponents(year: year, month: month, day: day)
        guard let start = calendar.date(from: parts) else { return true }
        return date >= start
    }
}
