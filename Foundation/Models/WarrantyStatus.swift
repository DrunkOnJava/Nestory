//
// Layer: Foundation
// Module: Models
// Purpose: Warranty status enumeration for status tracking across the app
//

import Foundation

/// Represents the current status of a warranty
public enum WarrantyStatus: Equatable, Sendable {
    case noWarranty
    case notStarted(daysUntilStart: Int)
    case active(daysRemaining: Int)
    case expiringSoon(daysRemaining: Int)
    case expired(daysAgo: Int)
    
    public var displayText: String {
        switch self {
        case .noWarranty:
            return "No warranty information"
        case .notStarted(let days):
            return "Warranty starts in \(days) day\(days == 1 ? "" : "s")"
        case .active(let days):
            return "Active - \(days) day\(days == 1 ? "" : "s") remaining"
        case .expiringSoon(let days):
            return "Expires in \(days) day\(days == 1 ? "" : "s")"
        case .expired(let days):
            return "Expired \(days) day\(days == 1 ? "" : "s") ago"
        }
    }
    
    public var isActive: Bool {
        switch self {
        case .active, .expiringSoon:
            return true
        default:
            return false
        }
    }
    
    public var requiresAttention: Bool {
        switch self {
        case .expiringSoon, .expired:
            return true
        default:
            return false
        }
    }
    
    public var systemImageName: String {
        switch self {
        case .noWarranty:
            return "questionmark.circle"
        case .notStarted:
            return "clock.circle"
        case .active:
            return "checkmark.shield"
        case .expiringSoon:
            return "exclamationmark.shield"
        case .expired:
            return "xmark.shield"
        }
    }
    
    /// Icon name for backwards compatibility
    public var icon: String {
        return systemImageName
    }
    
    /// Color string for UI theming
    public var color: String {
        switch self {
        case .noWarranty, .expired:
            return "#FF3B30" // Red
        case .expiringSoon:
            return "#FF9500" // Orange
        case .active:
            return "#34C759" // Green
        case .notStarted:
            return "#007AFF" // Blue
        }
    }
}

/// Represents the detection result from warranty scanning
public enum WarrantyDetectionResult: Equatable, Sendable {
    case detected(provider: String, duration: Int, confidence: Double)
    case partial(provider: String?, duration: Int?, confidence: Double)
    case notDetected
    
    public var hasProvider: Bool {
        switch self {
        case .detected: return true
        case .partial(let provider, _, _): return provider != nil
        case .notDetected: return false
        }
    }
    
    public var hasDuration: Bool {
        switch self {
        case .detected: return true
        case .partial(_, let duration, _): return duration != nil
        case .notDetected: return false
        }
    }
    
    /// Suggested provider from detection (for backwards compatibility)
    public var suggestedProvider: String? {
        switch self {
        case .detected(let provider, _, _): return provider
        case .partial(let provider, _, _): return provider
        case .notDetected: return nil
        }
    }
    
    /// Suggested duration in months (for backwards compatibility)
    public var suggestedDuration: Int? {
        switch self {
        case .detected(_, let duration, _): return duration
        case .partial(_, let duration, _): return duration
        case .notDetected: return nil
        }
    }
    
    /// Detection confidence (for backwards compatibility)
    public var confidence: Double {
        switch self {
        case .detected(_, _, let confidence): return confidence
        case .partial(_, _, let confidence): return confidence
        case .notDetected: return 0.0
        }
    }
    
    /// Extracted text placeholder (for backwards compatibility)
    public var extractedText: String? {
        // This was part of the old struct but not the enum design
        // Return nil for now - this could be added as associated data if needed
        return nil
    }
    
    /// Initializer for backwards compatibility with struct-like usage
    public static func detected(duration: Int, provider: String, confidence: Double, extractedText: String? = nil) -> WarrantyDetectionResult {
        return .detected(provider: provider, duration: duration, confidence: confidence)
    }
}

/// Statistics for warranty tracking across the inventory
public struct WarrantyTrackingStatistics: Equatable, Sendable {
    public let totalWarranties: Int
    public let activeWarranties: Int
    public let expiredWarranties: Int
    public let expiringSoonCount: Int
    public let noWarrantyCount: Int
    public let averageDurationDays: Double
    public let totalCoverageValue: Double
    
    // Additional properties for comprehensive analytics
    public let totalItems: Int
    public let itemsWithWarranty: Int
    public let missingWarrantyInfo: Int
    public let averageWarrantyDuration: Double // in years
    public let mostCommonProvider: String?
    
    public init(
        totalWarranties: Int,
        activeWarranties: Int,
        expiredWarranties: Int,
        expiringSoonCount: Int,
        noWarrantyCount: Int,
        averageDurationDays: Double,
        totalCoverageValue: Double,
        totalItems: Int = 0,
        itemsWithWarranty: Int = 0,
        missingWarrantyInfo: Int = 0,
        averageWarrantyDuration: Double = 0.0,
        mostCommonProvider: String? = nil
    ) {
        self.totalWarranties = totalWarranties
        self.activeWarranties = activeWarranties
        self.expiredWarranties = expiredWarranties
        self.expiringSoonCount = expiringSoonCount
        self.noWarrantyCount = noWarrantyCount
        self.averageDurationDays = averageDurationDays
        self.totalCoverageValue = totalCoverageValue
        self.totalItems = totalItems
        self.itemsWithWarranty = itemsWithWarranty
        self.missingWarrantyInfo = missingWarrantyInfo
        self.averageWarrantyDuration = averageWarrantyDuration
        self.mostCommonProvider = mostCommonProvider
    }
    
    public var coveragePercentage: Double {
        guard totalWarranties > 0 else { return 0.0 }
        return (Double(totalWarranties - noWarrantyCount) / Double(totalWarranties)) * 100.0
    }
}