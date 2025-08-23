//
// Layer: Services
// Module: WarrantyTrackingService/Operations/Status
// Purpose: Warranty status calculation and tracking logic
//

import Foundation

/// Handles warranty status calculations and expiration tracking
public struct WarrantyStatusManager {
    
    public init() {}
    
    // MARK: - Status Calculation
    
    public func getWarrantyStatus(for item: Item) async throws -> WarrantyStatus {
        guard let warranty = item.warranty else {
            return .noWarranty
        }

        let now = Date()
        let calendar = Calendar.current

        if now < warranty.startDate {
            let days = calendar.dateComponents([.day], from: now, to: warranty.startDate).day ?? 0
            return .notStarted(daysUntilStart: days)
        }

        if now >= warranty.expiresAt {
            let days = calendar.dateComponents([.day], from: warranty.expiresAt, to: now).day ?? 0
            return .expired(daysAgo: days)
        }

        let daysRemaining = calendar.dateComponents([.day], from: now, to: warranty.expiresAt).day ?? 0

        if daysRemaining <= 30 {
            return .expiringSoon(daysRemaining: daysRemaining)
        }

        return .active(daysRemaining: daysRemaining)
    }
    
    // MARK: - Expiration Queries
    
    public func getExpiringWarranties(within days: Int, from warranties: [Warranty]) -> [Warranty] {
        let now = Date()
        let targetDate = Calendar.current.date(byAdding: .day, value: days, to: now) ?? now
        
        return warranties.filter { warranty in
            warranty.expiresAt > now && warranty.expiresAt <= targetDate
        }
    }
    
    public func getExpiredWarranties(from warranties: [Warranty]) -> [Warranty] {
        let now = Date()
        return warranties.filter { warranty in
            warranty.expiresAt <= now
        }
    }
    
    public func getActiveWarranties(from warranties: [Warranty]) -> [Warranty] {
        let now = Date()
        return warranties.filter { warranty in
            warranty.startDate <= now && warranty.expiresAt > now
        }
    }
    
    // MARK: - Warranty Validation
    
    public func validateWarrantyDates(_ warranty: Warranty) -> [WarrantyValidationIssue] {
        var issues: [WarrantyValidationIssue] = []
        
        let now = Date()
        
        // Check if start date is in the future beyond reasonable limits
        if warranty.startDate > Calendar.current.date(byAdding: .year, value: 1, to: now) ?? now {
            issues.append(.startDateTooFarInFuture)
        }
        
        // Check if expiration date is before start date
        if warranty.expiresAt <= warranty.startDate {
            issues.append(.expirationBeforeStart)
        }
        
        // Check if warranty duration is unreasonably long
        let warrantyDurationInYears = Calendar.current.dateComponents([.year], from: warranty.startDate, to: warranty.expiresAt).year ?? 0
        if warrantyDurationInYears > 20 {
            issues.append(.durationTooLong)
        }
        
        // Check if warranty duration is too short
        let warrantyDurationInDays = Calendar.current.dateComponents([.day], from: warranty.startDate, to: warranty.expiresAt).day ?? 0
        if warrantyDurationInDays < 1 {
            issues.append(.durationTooShort)
        }
        
        return issues
    }
    
    // MARK: - Notification Timing
    
    public func calculateNotificationDates(for warranty: Warranty) -> [Date] {
        var notificationDates: [Date] = []
        let calendar = Calendar.current
        
        // 90 days before expiration
        if let date90Days = calendar.date(byAdding: .day, value: -90, to: warranty.expiresAt) {
            notificationDates.append(date90Days)
        }
        
        // 30 days before expiration
        if let date30Days = calendar.date(byAdding: .day, value: -30, to: warranty.expiresAt) {
            notificationDates.append(date30Days)
        }
        
        // 7 days before expiration
        if let date7Days = calendar.date(byAdding: .day, value: -7, to: warranty.expiresAt) {
            notificationDates.append(date7Days)
        }
        
        // 1 day before expiration
        if let date1Day = calendar.date(byAdding: .day, value: -1, to: warranty.expiresAt) {
            notificationDates.append(date1Day)
        }
        
        return notificationDates.filter { $0 > Date() } // Only future dates
    }
}

// MARK: - Supporting Types
// Note: WarrantyStatus, ValidationSeverity, and other shared types 
// are imported from Foundation/Models layer

public enum WarrantyValidationIssue: String, CaseIterable {
    case startDateTooFarInFuture = "Start date is too far in the future"
    case expirationBeforeStart = "Expiration date is before start date"
    case durationTooLong = "Warranty duration exceeds 20 years"
    case durationTooShort = "Warranty duration is less than 1 day"
    
    public var severity: ValidationSeverity {
        switch self {
        case .expirationBeforeStart, .durationTooShort:
            return .error
        case .startDateTooFarInFuture, .durationTooLong:
            return .warning
        }
    }
}

// ValidationSeverity is imported from Foundation/Core/ValidationIssue.swift