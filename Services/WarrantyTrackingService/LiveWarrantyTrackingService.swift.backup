//
// Layer: Services
// Module: WarrantyTrackingService
// Purpose: Live implementation of warranty tracking service with SwiftData integration
//

import Foundation
import SwiftData
import os.log

/// Live implementation of warranty tracking service using SwiftData
public final class LiveWarrantyTrackingService: WarrantyTrackingService {
    private let modelContext: ModelContext
    private let notificationService: NotificationService
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory", category: "WarrantyTracking")

    // Cache for performance
    private var warrantyCache: [UUID: Warranty] = [:]
    private var lastCacheUpdate: Date = .distantPast
    private let cacheExpiryInterval: TimeInterval = 300 // 5 minutes

    public init(modelContext: ModelContext, notificationService: NotificationService) {
        self.modelContext = modelContext
        self.notificationService = notificationService
    }

    // MARK: - Core Warranty Operations

    public func fetchWarranties(includeExpired: Bool = true) async throws -> [Warranty] {
        let descriptor = FetchDescriptor<Warranty>(
            sortBy: [SortDescriptor(\.expiresAt, order: .forward)]
        )

        do {
            let warranties = try modelContext.fetch(descriptor)

            if includeExpired {
                return warranties
            } else {
                return warranties.filter { !$0.isExpired }
            }
        } catch {
            logger.error("Failed to fetch warranties: \(error.localizedDescription)")
            throw WarrantyTrackingError.calculationFailed("Failed to fetch warranties: \(error.localizedDescription)")
        }
    }

    public func fetchWarranty(for itemId: UUID) async throws -> Warranty? {
        // Check cache first
        if Date().timeIntervalSince(lastCacheUpdate) < cacheExpiryInterval,
           let cachedWarranty = warrantyCache[itemId]
        {
            return cachedWarranty
        }

        // Fetch from database
        let itemDescriptor = FetchDescriptor<Item>(
            predicate: #Predicate<Item> { item in
                item.id == itemId
            }
        )

        do {
            let items = try modelContext.fetch(itemDescriptor)
            guard let item = items.first else {
                throw WarrantyTrackingError.itemNotFound(itemId)
            }

            let warranty = item.warranty

            // Update cache
            if let warranty {
                warrantyCache[itemId] = warranty
            }

            return warranty
        } catch {
            logger.error("Failed to fetch warranty for item \(itemId): \(error.localizedDescription)")
            throw WarrantyTrackingError.warrantyNotFound(itemId)
        }
    }

    public func saveWarranty(_ warranty: Warranty, for itemId: UUID) async throws {
        let itemDescriptor = FetchDescriptor<Item>(
            predicate: #Predicate<Item> { item in
                item.id == itemId
            }
        )

        do {
            let items = try modelContext.fetch(itemDescriptor)
            guard let item = items.first else {
                throw WarrantyTrackingError.itemNotFound(itemId)
            }

            // If item already has a warranty, update it
            if let existingWarranty = item.warranty {
                existingWarranty.update(
                    provider: warranty.provider,
                    type: warranty.type,
                    startDate: warranty.startDate,
                    expiresAt: warranty.expiresAt,
                    coverageNotes: warranty.coverageNotes,
                    policyNumber: warranty.policyNumber
                )
                existingWarranty.setClaimContact(
                    phone: warranty.claimPhone,
                    email: warranty.claimEmail,
                    website: warranty.claimWebsite
                )
            } else {
                // Create new warranty relationship
                item.warranty = warranty
                modelContext.insert(warranty)
            }

            // Update item's updatedAt timestamp
            item.updatedAt = Date()

            try modelContext.save()

            // Update cache
            warrantyCache[itemId] = warranty

            // Schedule notification for warranty expiration
            try await scheduleWarrantyNotification(for: item, warranty: warranty)

            logger.info("Saved warranty for item \(itemId)")
        } catch {
            logger.error("Failed to save warranty for item \(itemId): \(error.localizedDescription)")
            throw WarrantyTrackingError.invalidWarrantyData("Failed to save warranty: \(error.localizedDescription)")
        }
    }

    public func deleteWarranty(for itemId: UUID) async throws {
        let itemDescriptor = FetchDescriptor<Item>(
            predicate: #Predicate<Item> { item in
                item.id == itemId
            }
        )

        do {
            let items = try modelContext.fetch(itemDescriptor)
            guard let item = items.first else {
                throw WarrantyTrackingError.itemNotFound(itemId)
            }

            if let warranty = item.warranty {
                item.warranty = nil
                modelContext.delete(warranty)
                item.updatedAt = Date()

                try modelContext.save()

                // Remove from cache
                warrantyCache.removeValue(forKey: itemId)

                // Cancel warranty notifications
                await notificationService.cancelWarrantyNotifications(for: itemId)

                logger.info("Deleted warranty for item \(itemId)")
            }
        } catch {
            logger.error("Failed to delete warranty for item \(itemId): \(error.localizedDescription)")
            throw WarrantyTrackingError.warrantyNotFound(itemId)
        }
    }

    // MARK: - Smart Detection & Defaults

    public func calculateWarrantyExpiration(for item: Item) async throws -> Date? {
        guard let purchaseDate = item.purchaseDate else {
            return nil
        }

        let categoryName = item.category?.name
        let defaults = CategoryWarrantyDefaults.getDefaults(for: categoryName)

        guard defaults.months > 0 else {
            return nil // No warranty for this category
        }

        let calendar = Calendar.current
        return calendar.date(byAdding: .month, value: defaults.months, to: purchaseDate)
    }

    public func suggestWarrantyProvider(for item: Item) async -> String? {
        // First, try brand-specific providers
        if let brand = item.brand, !brand.isEmpty {
            return brand
        }

        // Then try category defaults
        let categoryName = item.category?.name
        let defaults = CategoryWarrantyDefaults.getDefaults(for: categoryName)
        return defaults.provider
    }

    public func defaultWarrantyDuration(for category: Category?) async -> Int {
        let categoryName = category?.name
        let defaults = CategoryWarrantyDefaults.getDefaults(for: categoryName)
        return defaults.months
    }

    public func detectWarrantyFromReceipt(item: Item, receiptText: String?) async throws -> WarrantyDetectionResult? {
        guard let receiptText, !receiptText.isEmpty else {
            return nil
        }

        var confidence = 0.5
        var detectedDuration = 0
        var detectedProvider = "Retailer"

        let text = receiptText.lowercased()

        // Look for explicit warranty mentions
        let warrantyPatterns = [
            "warranty",
            "guarantee",
            "coverage",
            "protection plan",
            "extended service",
        ]

        for pattern in warrantyPatterns {
            if text.contains(pattern) {
                confidence += 0.2
                break
            }
        }

        // Look for duration patterns
        let durationRegex = try NSRegularExpression(pattern: "(\\d+)\\s*(year|month|yr|mo)", options: .caseInsensitive)
        let matches = durationRegex.matches(in: receiptText, options: [], range: NSRange(location: 0, length: receiptText.count))

        if let match = matches.first,
           let numberRange = Range(match.range(at: 1), in: receiptText),
           let unitRange = Range(match.range(at: 2), in: receiptText),
           let number = Int(String(receiptText[numberRange]))
        {
            let unit = String(receiptText[unitRange]).lowercased()

            if unit.contains("year") || unit.contains("yr") {
                detectedDuration = number * 12
            } else if unit.contains("month") || unit.contains("mo") {
                detectedDuration = number
            }

            confidence += 0.3
        }

        // Look for brand/provider names
        if let brand = item.brand, !brand.isEmpty, text.contains(brand.lowercased()) {
            detectedProvider = brand
            confidence += 0.2
        }

        // If no explicit warranty info found, use category defaults
        if detectedDuration == 0 {
            let categoryDefaults = CategoryWarrantyDefaults.getDefaults(for: item.category?.name)
            detectedDuration = categoryDefaults.months
            detectedProvider = categoryDefaults.provider
            confidence = max(confidence, 0.3) // Minimum confidence for category defaults
        }

        guard confidence > 0.3 else {
            return nil // Too low confidence
        }

        return WarrantyDetectionResult(
            duration: detectedDuration,
            provider: detectedProvider,
            confidence: min(confidence, 1.0),
            extractedText: receiptText
        )
    }

    // MARK: - Status Queries

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

    public func getItemsWithExpiringWarranties(within days: Int) async throws -> [Item] {
        let allItems = try await fetchAllItems()
        var expiringItems: [Item] = []

        for item in allItems {
            let status = try await getWarrantyStatus(for: item)

            switch status {
            case let .expiringSoon(daysRemaining):
                if daysRemaining <= days {
                    expiringItems.append(item)
                }
            case let .active(daysRemaining):
                if daysRemaining <= days {
                    expiringItems.append(item)
                }
            default:
                break
            }
        }

        return expiringItems.sorted { item1, item2 in
            guard let warranty1 = item1.warranty, let warranty2 = item2.warranty else {
                return false
            }
            return warranty1.expiresAt < warranty2.expiresAt
        }
    }

    public func getItemsMissingWarrantyInfo() async throws -> [Item] {
        let allItems = try await fetchAllItems()

        return allItems.filter { item in
            // Item is missing warranty info if:
            // 1. No warranty object
            // 2. Has purchase date but no warranty (and category suggests it should have one)
            // 3. Has warranty but missing key fields

            if item.warranty == nil {
                // Check if category suggests it should have warranty
                let categoryDefaults = CategoryWarrantyDefaults.getDefaults(for: item.category?.name)
                return categoryDefaults.months > 0 && item.purchaseDate != nil
            }

            guard let warranty = item.warranty else { return false }

            // Check for missing key warranty fields
            return warranty.provider.isEmpty ||
                warranty.policyNumber?.isEmpty == true
        }
    }

    public func getWarrantyStatistics() async throws -> WarrantyTrackingStatistics {
        let allItems = try await fetchAllItems()
        let totalItems = allItems.count

        var itemsWithWarranty = 0
        var activeWarranties = 0
        var expiringSoon = 0
        var expired = 0
        var missingWarrantyInfo = 0
        var warrantyDurations: [Double] = []
        var providerCounts: [String: Int] = [:]

        for item in allItems {
            let status = try await getWarrantyStatus(for: item)

            switch status {
            case .noWarranty:
                missingWarrantyInfo += 1
            case .active:
                itemsWithWarranty += 1
                activeWarranties += 1
            case .expiringSoon:
                itemsWithWarranty += 1
                activeWarranties += 1
                expiringSoon += 1
            case .expired:
                itemsWithWarranty += 1
                expired += 1
            case .notStarted:
                itemsWithWarranty += 1
            }

            if let warranty = item.warranty {
                // Calculate duration
                let duration = Double(warranty.durationInMonths)
                warrantyDurations.append(duration)

                // Count providers
                let provider = warranty.provider
                providerCounts[provider] = (providerCounts[provider] ?? 0) + 1
            }
        }

        let averageWarrantyDuration = warrantyDurations.isEmpty ? 0.0 : warrantyDurations.reduce(0, +) / Double(warrantyDurations.count)
        let mostCommonProvider = providerCounts.max(by: { $0.value < $1.value })?.key

        return WarrantyTrackingStatistics(
            totalItems: totalItems,
            itemsWithWarranty: itemsWithWarranty,
            activeWarranties: activeWarranties,
            expiringSoon: expiringSoon,
            expired: expired,
            missingWarrantyInfo: missingWarrantyInfo,
            averageWarrantyDuration: averageWarrantyDuration,
            mostCommonProvider: mostCommonProvider
        )
    }

    // MARK: - Bulk Operations

    public func bulkCreateWarranties(for items: [Item]) async throws -> [Warranty] {
        var createdWarranties: [Warranty] = []

        for item in items {
            // Skip items that already have warranties
            guard item.warranty == nil else { continue }

            // Calculate warranty expiration
            guard let expirationDate = try await calculateWarrantyExpiration(for: item) else {
                continue
            }

            let provider = await suggestWarrantyProvider(for: item) ?? "Manufacturer"
            let startDate = item.purchaseDate ?? Date()

            let warranty = Warranty(
                provider: provider,
                type: .manufacturer,
                startDate: startDate,
                expiresAt: expirationDate,
                item: item
            )

            try await saveWarranty(warranty, for: item.id)
            createdWarranties.append(warranty)
        }

        logger.info("Bulk created \(createdWarranties.count) warranties")
        return createdWarranties
    }

    public func refreshAllWarrantyStatuses() async throws {
        let allItems = try await fetchAllItems()

        for item in allItems {
            guard let warranty = item.warranty else { continue }

            let status = try await getWarrantyStatus(for: item)

            // Schedule notifications for warranties expiring soon
            if case .expiringSoon = status {
                try await scheduleWarrantyNotification(for: item, warranty: warranty)
            }
        }

        // Clear cache to force refresh
        warrantyCache.removeAll()
        lastCacheUpdate = .distantPast

        logger.info("Refreshed warranty statuses for \(allItems.count) items")
    }

    public func updateWarrantiesFromReceipts() async throws -> Int {
        let allItems = try await fetchAllItems()
        var updatedCount = 0

        for item in allItems {
            // Skip items that already have detailed warranty info
            if let warranty = item.warranty,
               !warranty.provider.isEmpty,
               warranty.policyNumber?.isEmpty == false
            {
                continue
            }

            // Try to detect warranty from receipt text
            if let detectionResult = try await detectWarrantyFromReceipt(item: item, receiptText: item.extractedReceiptText),
               detectionResult.confidence > 0.6
            {
                let startDate = item.purchaseDate ?? Date()
                let calendar = Calendar.current
                let expirationDate = calendar.date(byAdding: .month, value: detectionResult.suggestedDuration, to: startDate) ?? startDate

                let warranty = Warranty(
                    provider: detectionResult.suggestedProvider,
                    type: .manufacturer,
                    startDate: startDate,
                    expiresAt: expirationDate,
                    item: item
                )

                try await saveWarranty(warranty, for: item.id)
                updatedCount += 1
            }
        }

        logger.info("Updated warranties from receipts for \(updatedCount) items")
        return updatedCount
    }

    // MARK: - Private Helpers

    private func fetchAllItems() async throws -> [Item] {
        let descriptor = FetchDescriptor<Item>()
        return try modelContext.fetch(descriptor)
    }

    private func scheduleWarrantyNotification(for item: Item, warranty _: Warranty) async throws {
        do {
            try await notificationService.scheduleWarrantyExpirationNotifications(for: item)
        } catch {
            logger.error("Failed to schedule warranty notification for item \(item.id): \(error.localizedDescription)")
            throw WarrantyTrackingError.notificationFailed(error.localizedDescription)
        }
    }

    // MARK: - Additional Methods for UI Integration

    /// Detect warranty information from item metadata (brand, model, serial number)
    public func detectWarrantyInfo(
        brand: String?,
        model: String?,
        serialNumber: String?,
        purchaseDate: Date?
    ) async throws -> WarrantyDetectionResult {
        var confidence = 0.3 // Base confidence
        var detectedDuration = 12 // Default 1 year
        var detectedProvider = "Manufacturer"

        // Improve confidence and detection based on available information
        if let brand = brand, !brand.isEmpty {
            detectedProvider = brand
            confidence += 0.2

            // Brand-specific warranty defaults
            switch brand.lowercased() {
            case "apple":
                detectedDuration = 12
                detectedProvider = "Apple Inc."
                confidence += 0.3
            case "samsung":
                detectedDuration = 24
                detectedProvider = "Samsung"
                confidence += 0.3
            case "sony":
                detectedDuration = 12
                detectedProvider = "Sony"
                confidence += 0.2
            case "lg":
                detectedDuration = 24
                detectedProvider = "LG Electronics"
                confidence += 0.2
            case "whirlpool", "kitchenaid":
                detectedDuration = 12
                detectedProvider = brand
                confidence += 0.2
            default:
                confidence += 0.1
            }
        }

        if let model = model, !model.isEmpty {
            confidence += 0.1

            // Model-specific adjustments
            let modelLower = model.lowercased()
            if modelLower.contains("pro") || modelLower.contains("premium") {
                detectedDuration += 6 // Premium products often have longer warranties
                confidence += 0.1
            }
        }

        if let serialNumber = serialNumber, !serialNumber.isEmpty {
            confidence += 0.1
        }

        if let purchaseDate = purchaseDate {
            confidence += 0.1

            // Adjust based on age - older items might have expired manufacturer warranties
            let ageInMonths = Calendar.current.dateComponents([.month], from: purchaseDate, to: Date()).month ?? 0
            if ageInMonths > 12 {
                // Item is older, might have expired warranty
                confidence -= 0.1
            }
        }

        // Cap confidence at 1.0
        confidence = min(confidence, 1.0)

        guard confidence > 0.4 else {
            throw WarrantyTrackingError.detectionFailed("Insufficient information to detect warranty details")
        }

        return WarrantyDetectionResult(
            duration: detectedDuration,
            provider: detectedProvider,
            confidence: confidence,
            extractedText: "Auto-detected from brand: \(brand ?? "Unknown"), model: \(model ?? "Unknown")"
        )
    }

    /// Register warranty with manufacturer or provider
    public func registerWarranty(warranty: Warranty, item: Item) async throws {
        // Simulate warranty registration process
        logger.info("Registering warranty for item \(item.id) with provider \(warranty.provider)")

        // In a real implementation, this would:
        // 1. Connect to manufacturer API
        // 2. Submit registration with serial number, purchase date, etc.
        // 3. Receive confirmation number
        // 4. Update warranty with registration details

        // For now, we'll simulate a successful registration
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay to simulate API call

        // Update warranty registration status
        warranty.isRegistered = true
        warranty.registrationDate = Date()
        
        // Generate a mock confirmation number
        warranty.confirmationNumber = "REG-\(Int.random(in: 100000...999999))"

        // Save the updated warranty
        try await saveWarranty(warranty, for: item.id)

        logger.info("Successfully registered warranty for item \(item.id)")
    }
}
