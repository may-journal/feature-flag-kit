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
        guard let start else { return true }
        return date >= start
    }

    /// The whole UTC days from `date` to the expiry day: 1 the day before, 0 or less after.
    /// It is nil for `never`, and 0 for a day that does not exist.
    public func daysLeft(asOf date: Date) -> Int? {
        if isNever { return nil }
        guard let start else { return 0 }
        let today = Self.calendar.startOfDay(for: date)
        return Self.calendar.dateComponents([.day], from: today, to: start).day
    }

    /// The days left when the expiry day comes within `days` days of `date`, from 1 the day
    /// before. It is nil once the day has come, past `days`, or for `never`.
    public func daysLeft(within days: Int, asOf date: Date) -> Int? {
        daysLeft(asOf: date).flatMap { $0 >= 1 && $0 <= days ? $0 : nil }
    }

    /// The Gregorian calendar in UTC, where every machine agrees on the day.
    private static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        return calendar
    }()

    /// Midnight UTC at the start of the expiry day, or nil for a day that does not exist.
    private var start: Date? {
        let parts = DateComponents(year: year, month: month, day: day)
        // Compare only the day's fields, since `==` also compares calendar and time zone.
        guard let start = Self.calendar.date(from: parts),
            case let found = Self.calendar.dateComponents([.year, .month, .day], from: start),
            found.year == year, found.month == month, found.day == day
        else { return nil }
        return start
    }
}
