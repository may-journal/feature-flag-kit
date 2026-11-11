import Foundation

/// The calendar day a flag should be gone by. A flag counts as expired from
/// the start of that day, in UTC, so every machine agrees.
public struct FlagExpiry: Sendable, Hashable {
    public let year: Int
    public let month: Int
    public let day: Int
    /// Whether this is `never`, whose year, month and day are zero.
    public let isNever: Bool

    public init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
        isNever = false
    }

    /// No expiry day, for a permanent setting, which never counts as expired.
    public static let never = FlagExpiry()

    private init() {
        year = 0
        month = 0
        day = 0
        isNever = true
    }

    /// Whether `date` falls on or after the expiry day, which `never` has not. A day that does
    /// not exist, such as 30 February, counts as passed, so the expiry test names it.
    public func isPassed(asOf date: Date) -> Bool {
        if isNever { return false }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        let parts = DateComponents(year: year, month: month, day: day)
        // Compare only the day's fields, since `==` also compares calendar and time zone.
        guard let start = calendar.date(from: parts),
            case let found = calendar.dateComponents([.year, .month, .day], from: start),
            found.year == year, found.month == month, found.day == day
        else { return true }
        return date >= start
    }
}
