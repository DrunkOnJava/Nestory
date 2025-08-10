// Layer: Foundation
// Module: Foundation/Utils
// Purpose: Date formatting and manipulation utilities

import Foundation

/// Date utility functions
public enum DateUtils {
    
    // MARK: - Formatters
    
    /// ISO 8601 date formatter
    nonisolated(unsafe) public static let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    /// Short date formatter (e.g., "Mar 15, 2024")
    public static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    /// Long date formatter (e.g., "March 15, 2024 at 3:30 PM")
    public static let longDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }()
    
    /// Relative date formatter (e.g., "2 days ago", "in 3 weeks")
    nonisolated(unsafe) public static let relativeDateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter
    }()
    
    /// Time-only formatter
    public static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    
    // MARK: - Formatting Methods
    
    /// Format date as ISO 8601 string
    public static func iso8601String(from date: Date) -> String {
        iso8601Formatter.string(from: date)
    }
    
    /// Parse ISO 8601 string to date
    public static func date(fromISO8601 string: String) -> Date? {
        iso8601Formatter.date(from: string)
    }
    
    /// Format date as short string
    public static func shortString(from date: Date) -> String {
        shortDateFormatter.string(from: date)
    }
    
    /// Format date as long string
    public static func longString(from date: Date) -> String {
        longDateFormatter.string(from: date)
    }
    
    /// Format date as relative string
    public static func relativeString(from date: Date, to referenceDate: Date = Date()) -> String {
        relativeDateFormatter.localizedString(for: date, relativeTo: referenceDate)
    }
    
    /// Format time only
    public static func timeString(from date: Date) -> String {
        timeFormatter.string(from: date)
    }
    
    // MARK: - Date Calculations
    
    /// Get start of day for a date
    public static func startOfDay(for date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }
    
    /// Get end of day for a date
    public static func endOfDay(for date: Date) -> Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay(for: date)) ?? date
    }
    
    /// Get start of week for a date
    public static func startOfWeek(for date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: components) ?? date
    }
    
    /// Get start of month for a date
    public static func startOfMonth(for date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components) ?? date
    }
    
    /// Get start of year for a date
    public static func startOfYear(for date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: date)
        return calendar.date(from: components) ?? date
    }
    
    /// Calculate days between two dates
    public static func daysBetween(_ startDate: Date, and endDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        return components.day ?? 0
    }
    
    /// Calculate months between two dates
    public static func monthsBetween(_ startDate: Date, and endDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: startDate, to: endDate)
        return components.month ?? 0
    }
    
    /// Calculate years between two dates
    public static func yearsBetween(_ startDate: Date, and endDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: startDate, to: endDate)
        return components.year ?? 0
    }
    
    /// Check if date is today
    public static func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }
    
    /// Check if date is yesterday
    public static func isYesterday(_ date: Date) -> Bool {
        Calendar.current.isDateInYesterday(date)
    }
    
    /// Check if date is tomorrow
    public static func isTomorrow(_ date: Date) -> Bool {
        Calendar.current.isDateInTomorrow(date)
    }
    
    /// Check if date is in the past
    public static func isPast(_ date: Date) -> Bool {
        date < Date()
    }
    
    /// Check if date is in the future
    public static func isFuture(_ date: Date) -> Bool {
        date > Date()
    }
    
    /// Check if date is within a range
    public static func isDate(_ date: Date, between startDate: Date, and endDate: Date) -> Bool {
        date >= startDate && date <= endDate
    }
    
    // MARK: - Date Generation
    
    /// Generate dates for a date range
    public static func dates(from startDate: Date, to endDate: Date, increment: Calendar.Component = .day, value: Int = 1) -> [Date] {
        var dates: [Date] = []
        var currentDate = startDate
        
        while currentDate <= endDate {
            dates.append(currentDate)
            currentDate = Calendar.current.date(byAdding: increment, value: value, to: currentDate) ?? endDate
        }
        
        return dates
    }
    
    /// Get date for next occurrence of weekday
    public static func nextDate(for weekday: Int, after date: Date = Date()) -> Date? {
        let calendar = Calendar.current
        let components = DateComponents(weekday: weekday)
        return calendar.nextDate(after: date, matching: components, matchingPolicy: .nextTime)
    }
}
