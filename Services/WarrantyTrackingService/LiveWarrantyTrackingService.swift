//
// Layer: Services
// Module: WarrantyTrackingService
// Purpose: Live implementation of warranty tracking service - Modularized Architecture
//

import Foundation
import SwiftData
import os.log

/// Modularized warranty tracking service orchestrating specialized operations
@MainActor
public final class LiveWarrantyTrackingService: WarrantyTrackingService {
    
    // MARK: - Modular Components
    
    private nonisolated(unsafe) let coreOperations: WarrantyCoreOperations
    private nonisolated(unsafe) let detectionEngine: WarrantyDetectionEngine
    private nonisolated(unsafe) let statusManager: WarrantyStatusManager
    private nonisolated(unsafe) let analyticsEngine: WarrantyAnalyticsEngine
    private nonisolated(unsafe) let bulkOperations: WarrantyBulkOperations
    private nonisolated(unsafe) let cacheManager: WarrantyCacheManager
    
    // MARK: - Dependencies
    
    private let modelContext: ModelContext
    private let notificationService: NotificationService
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory", category: "WarrantyTracking")

    // MARK: - Initialization
    
    public init(modelContext: ModelContext, notificationService: NotificationService) {
        self.modelContext = modelContext
        self.notificationService = notificationService
        
        // Initialize modular components
        self.cacheManager = WarrantyCacheManager()
        self.coreOperations = WarrantyCoreOperations(modelContext: modelContext, logger: logger)
        self.detectionEngine = WarrantyDetectionEngine(logger: logger)
        self.statusManager = WarrantyStatusManager()
        self.analyticsEngine = WarrantyAnalyticsEngine(statusManager: statusManager)
        self.bulkOperations = WarrantyBulkOperations(
            coreOperations: coreOperations,
            detectionEngine: detectionEngine,
            statusManager: statusManager,
            notificationService: notificationService,
            logger: logger
        )
    }

    // MARK: - Core Warranty Operations (Delegated)

    public func fetchWarranties(includeExpired: Bool = true) async throws -> [Warranty] {
        try await coreOperations.fetchWarranties(includeExpired: includeExpired)
    }

    public func fetchWarranty(for itemId: UUID) async throws -> Warranty? {
        try await coreOperations.fetchWarranty(for: itemId, cache: cacheManager)
    }

    public func saveWarranty(_ warranty: Warranty, for itemId: UUID) async throws {
        try await coreOperations.saveWarranty(warranty, for: itemId)
    }

    public func deleteWarranty(for itemId: UUID) async throws {
        try await coreOperations.deleteWarranty(for: itemId)
        cacheManager.removeWarranty(for: itemId)
    }

    // MARK: - Smart Detection & Defaults (Protocol Required)

    public func calculateWarrantyExpiration(for item: Item) async throws -> Date? {
        try await coreOperations.calculateWarrantyExpiration(for: item)
    }

    public func suggestWarrantyProvider(for item: Item) async -> String? {
        await detectionEngine.suggestWarrantyProvider(for: item)
    }

    public func defaultWarrantyDuration(for category: Category?) async -> Int {
        let categoryName = category?.name
        let defaults = CategoryWarrantyDefaults.getDefaults(for: categoryName)
        return defaults.months
    }

    // MARK: - Detection Operations (Delegated)

    public func detectWarrantyFromReceipt(item: Item, receiptText: String?) async throws -> WarrantyDetectionResult? {
        try await detectionEngine.detectWarrantyFromReceipt(item: item, receiptText: receiptText)
    }

    public func detectWarrantyInfo(brand: String?, model: String?, serialNumber: String?, purchaseDate: Date?) async throws -> WarrantyDetectionResult? {
        try await detectionEngine.detectWarrantyFromProduct(
            brand: brand,
            model: model,
            serialNumber: serialNumber,
            purchaseDate: purchaseDate
        )
    }

    public func detectWarrantyFromProduct(
        brand: String?,
        model: String?,
        serialNumber: String?,
        purchaseDate: Date?
    ) async throws -> WarrantyDetectionResult {
        try await detectionEngine.detectWarrantyFromProduct(
            brand: brand,
            model: model,
            serialNumber: serialNumber,
            purchaseDate: purchaseDate
        )
    }

    // MARK: - Status Operations (Delegated)

    public func getWarrantyStatus(for item: Item) async throws -> WarrantyStatus {
        try await statusManager.getWarrantyStatus(for: item)
    }

    public func getExpiringWarranties(within days: Int = 30) async throws -> [Warranty] {
        let allWarranties = try await fetchWarranties()
        return statusManager.getExpiringWarranties(within: days, from: allWarranties)
    }

    // MARK: - Status Queries (Protocol Required)

    public func getItemsWithExpiringWarranties(within days: Int) async throws -> [Item] {
        let allItems = try await coreOperations.fetchAllItems()
        let now = Date()
        let targetDate = Calendar.current.date(byAdding: .day, value: days, to: now) ?? now
        
        return allItems.filter { item in
            guard let warranty = item.warranty else { return false }
            return warranty.expiresAt > now && warranty.expiresAt <= targetDate
        }
    }

    public func getItemsMissingWarrantyInfo() async throws -> [Item] {
        let allItems = try await coreOperations.fetchAllItems()
        
        return allItems.filter { item in
            item.warranty == nil || 
            (item.warranty?.provider.isEmpty ?? true) ||
            (item.warranty != nil && item.warranty!.expiresAt <= item.warranty!.startDate)
        }
    }

    public func getWarrantyStatistics() async throws -> WarrantyTrackingStatistics {
        try await getWarrantyTrackingStatistics()
    }

    // MARK: - Analytics Operations (Delegated)

    public func getWarrantyTrackingStatistics() async throws -> WarrantyTrackingStatistics {
        let allItems = try await coreOperations.fetchAllItems()
        return try await analyticsEngine.generateStatistics(from: allItems)
    }

    // MARK: - Bulk Operations (Delegated)

    public func bulkCreateWarranties(for items: [Item]) async throws -> [Warranty] {
        try await bulkOperations.bulkCreateWarranties(for: items)
    }

    public func refreshAllWarrantyStatuses() async throws {
        try await bulkOperations.refreshAllWarrantyStatuses(cache: cacheManager)
    }

    public func updateWarrantiesFromReceipts() async throws -> Int {
        try await bulkOperations.updateWarrantiesFromReceipts()
    }

    // MARK: - Registration Operations (Delegated)

    public func registerWarranty(warranty: Warranty, item: Item) async throws {
        let results = try await bulkOperations.bulkRegisterWarranties(items: [item])
        guard let result = results.first, result.success else {
            throw WarrantyTrackingError.registrationFailed(results.first?.error ?? "Registration failed")
        }
    }

    // MARK: - Cache Management

    public func getCacheStatistics() -> CacheStatistics {
        cacheManager.getCacheStatistics()
    }

    public func clearCache() {
        cacheManager.clearCache()
    }
}

// MARK: - Architecture Documentation

//
// 🏗️ MODULAR ARCHITECTURE: Specialized operations organized by responsibility
// - CoreOperations: Basic CRUD functionality with SwiftData integration
// - DetectionEngine: AI-powered warranty detection from receipts and product info
// - StatusManager: Warranty status calculation and expiration tracking  
// - AnalyticsEngine: Statistical analysis and reporting capabilities
// - BulkOperations: Efficient batch processing for multiple items
// - CacheManager: Performance optimization through intelligent caching
//
// 🎯 BENEFITS ACHIEVED:
// - Single Responsibility: Each module handles one specific aspect
// - Testability: Individual components can be unit tested in isolation
// - Maintainability: Changes to one component don't affect others
// - Performance: Optimized caching and batch operations
// - Extensibility: New functionality can be added without modifying existing modules
//