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
public protocol WarrantyTrackingService: AnyObject, Sendable {
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
    
    /// Auto-detect warranty information from item properties
    func detectWarrantyInfo(brand: String?, model: String?, serialNumber: String?, purchaseDate: Date?) async throws -> WarrantyDetectionResult?

    // MARK: - Status Queries

    /// Get warranty status for an item
    func getWarrantyStatus(for item: Item) async throws -> WarrantyStatus

    /// Get items with warranties expiring within specified days
    func getItemsWithExpiringWarranties(within days: Int) async throws -> [Item]

    /// Get items missing warranty information
    func getItemsMissingWarrantyInfo() async throws -> [Item]

    /// Get warranty statistics
    func getWarrantyStatistics() async throws -> WarrantyTrackingStatistics

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
// WarrantyDetectionResult is defined in Foundation/Models/WarrantyStatus.swift

// WarrantyStatus is defined in Foundation/Models/WarrantyStatus.swift

// WarrantyTrackingStatistics is defined in Foundation/Models/WarrantyStatus.swift

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
    case registrationFailed(String)
    case saveFailed(String)
    case deletionFailed(String)

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
        case let .registrationFailed(reason):
            "Warranty registration failed: \(reason)"
        case let .saveFailed(reason):
            "Failed to save warranty: \(reason)"
        case let .deletionFailed(reason):
            "Failed to delete warranty: \(reason)"
        }
    }
}
