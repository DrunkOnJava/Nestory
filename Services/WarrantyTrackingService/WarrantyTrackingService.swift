//
// Layer: Services
// Module: WarrantyTrackingService
// Purpose: Smart warranty tracking with expiration detection and automatic defaults
//

import Foundation
import SwiftData
import os.log

/// Protocol defining warranty tracking capabilities with smart expiration detection
@MainActor
public protocol WarrantyTrackingService: AnyObject {
    // MARK: - Core Warranty Operations

    /// Fetch all warranties with optional filtering
    func fetchWarranties(includeExpired: Bool) async throws -> [Warranty]

    /// Fetch warranty for specific item
    func fetchWarranty(for itemId: UUID) async throws -> Warranty?

    /// Create or update warranty for an item
    func saveWarranty(_ warranty: Warranty, for itemId: UUID) async throws

    /// Delete warranty for specific item
    func deleteWarranty(for itemId: UUID) async throws

    // MARK: - Smart Detection & Defaults

    /// Calculate warranty expiration based on purchase date and category
    func calculateWarrantyExpiration(for item: Item) async throws -> Date?

    /// Get suggested warranty provider based on brand and category
    func suggestWarrantyProvider(for item: Item) async -> String?

    /// Get default warranty duration for category
    func defaultWarrantyDuration(for category: Category?) async -> Int

    /// Auto-detect warranty information from receipt data
    func detectWarrantyFromReceipt(item: Item, receiptText: String?) async throws -> WarrantyDetectionResult?

    // MARK: - Status Queries

    /// Get warranty status for an item
    func getWarrantyStatus(for item: Item) async throws -> WarrantyStatus

    /// Get items with warranties expiring within specified days
    func getItemsWithExpiringWarranties(within days: Int) async throws -> [Item]

    /// Get items missing warranty information
    func getItemsMissingWarrantyInfo() async throws -> [Item]

    /// Get warranty statistics
    func getWarrantyStatistics() async throws -> WarrantyStatistics

    // MARK: - Bulk Operations

    /// Bulk create warranties for items based on smart defaults
    func bulkCreateWarranties(for items: [Item]) async throws -> [Warranty]

    /// Refresh all warranty statuses and trigger notifications
    func refreshAllWarrantyStatuses() async throws

    /// Update warranties from receipt OCR results
    func updateWarrantiesFromReceipts() async throws -> Int
}

// MARK: - Supporting Data Types

/// Result of warranty detection from receipt
public struct WarrantyDetectionResult {
    public let suggestedDuration: Int // in months
    public let suggestedProvider: String
    public let confidence: Double // 0.0 to 1.0
    public let extractedText: String?

    public init(duration: Int, provider: String, confidence: Double, extractedText: String? = nil) {
        self.suggestedDuration = duration
        self.suggestedProvider = provider
        self.confidence = confidence
        self.extractedText = extractedText
    }
}

/// Warranty status for an item
public enum WarrantyStatus: Equatable {
    case noWarranty
    case active(daysRemaining: Int)
    case expiringSoon(daysRemaining: Int) // <= 30 days
    case expired(daysAgo: Int)
    case notStarted(daysUntilStart: Int)

    public var isActive: Bool {
        switch self {
        case .active, .expiringSoon:
            true
        default:
            false
        }
    }

    public var requiresAttention: Bool {
        switch self {
        case .expiringSoon, .expired, .noWarranty:
            true
        default:
            false
        }
    }

    public var displayText: String {
        switch self {
        case .noWarranty:
            "No warranty"
        case let .active(days):
            "Active (\(days) days remaining)"
        case let .expiringSoon(days):
            "Expiring soon (\(days) days)"
        case let .expired(days):
            "Expired (\(days) days ago)"
        case let .notStarted(days):
            "Starts in \(days) days"
        }
    }

    public var color: String {
        switch self {
        case .noWarranty, .expired:
            "#FF3B30" // Red
        case .expiringSoon:
            "#FF9500" // Orange
        case .active:
            "#34C759" // Green
        case .notStarted:
            "#007AFF" // Blue
        }
    }

    public var icon: String {
        switch self {
        case .noWarranty:
            "exclamationmark.shield"
        case .active:
            "checkmark.shield.fill"
        case .expiringSoon:
            "clock.badge.exclamationmark"
        case .expired:
            "xmark.shield"
        case .notStarted:
            "clock.arrow.circlepath"
        }
    }
}

/// Statistics about warranty coverage
public struct WarrantyStatistics {
    public let totalItems: Int
    public let itemsWithWarranty: Int
    public let activeWarranties: Int
    public let expiringSoon: Int // within 30 days
    public let expired: Int
    public let missingWarrantyInfo: Int
    public let averageWarrantyDuration: Double // in months
    public let mostCommonProvider: String?

    public var coveragePercentage: Double {
        guard totalItems > 0 else { return 0.0 }
        return Double(itemsWithWarranty) / Double(totalItems) * 100.0
    }

    public init(
        totalItems: Int,
        itemsWithWarranty: Int,
        activeWarranties: Int,
        expiringSoon: Int,
        expired: Int,
        missingWarrantyInfo: Int,
        averageWarrantyDuration: Double,
        mostCommonProvider: String?
    ) {
        self.totalItems = totalItems
        self.itemsWithWarranty = itemsWithWarranty
        self.activeWarranties = activeWarranties
        self.expiringSoon = expiringSoon
        self.expired = expired
        self.missingWarrantyInfo = missingWarrantyInfo
        self.averageWarrantyDuration = averageWarrantyDuration
        self.mostCommonProvider = mostCommonProvider
    }
}

/// Category-based warranty defaults
public enum CategoryWarrantyDefaults {
    public static let defaults: [String: (months: Int, provider: String)] = [
        "Electronics": (months: 12, provider: "Manufacturer"),
        "Appliances": (months: 24, provider: "Manufacturer"),
        "Furniture": (months: 60, provider: "Manufacturer"),
        "Tools": (months: 36, provider: "Manufacturer"),
        "Automotive": (months: 36, provider: "Manufacturer"),
        "Jewelry": (months: 12, provider: "Manufacturer"),
        "Watches": (months: 24, provider: "Manufacturer"),
        "Kitchen": (months: 12, provider: "Manufacturer"),
        "Sports": (months: 12, provider: "Manufacturer"),
        "Books": (months: 0, provider: "Publisher"),
        "Clothing": (months: 3, provider: "Retailer"),
        "Art": (months: 0, provider: "Gallery"),
        "Other": (months: 12, provider: "Retailer"),
    ]

    public static func getDefaults(for categoryName: String?) -> (months: Int, provider: String) {
        guard let categoryName else {
            return defaults["Other"] ?? (months: 12, provider: "Retailer")
        }
        return defaults[categoryName] ?? defaults["Other"] ?? (months: 12, provider: "Retailer")
    }
}

/// Errors that can occur during warranty tracking operations
public enum WarrantyTrackingError: Error, LocalizedError {
    case itemNotFound(UUID)
    case warrantyNotFound(UUID)
    case invalidWarrantyData(String)
    case calculationFailed(String)
    case detectionFailed(String)
    case notificationFailed(String)

    public var errorDescription: String? {
        switch self {
        case let .itemNotFound(id):
            "Item with ID \(id) not found"
        case let .warrantyNotFound(id):
            "Warranty for item \(id) not found"
        case let .invalidWarrantyData(reason):
            "Invalid warranty data: \(reason)"
        case let .calculationFailed(reason):
            "Warranty calculation failed: \(reason)"
        case let .detectionFailed(reason):
            "Warranty detection failed: \(reason)"
        case let .notificationFailed(reason):
            "Warranty notification failed: \(reason)"
        }
    }
}
