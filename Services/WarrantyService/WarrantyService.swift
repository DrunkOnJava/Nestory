//
// Layer: Services
// Module: WarrantyService
// Purpose: Warranty data operations and insights service
//

import Foundation
import os.log
import SwiftData

public protocol WarrantyService: Sendable {
    func fetchWarranties() async throws -> [Warranty]
    func fetchWarranty(id: UUID) async throws -> Warranty?
    func fetchItemsExpiringWithin(days: Int) async throws -> [Item]
    func fetchExpiredItems() async throws -> [Item]
    func fetchItemsWithoutWarranty() async throws -> [Item]
    func getWarrantyInsights() async throws -> WarrantyInsights
    func getTotalWarrantyValue() async throws -> Decimal
    func getWarrantyCoverageByCategory() async throws -> [CategoryCoverage]
    func saveWarranty(_ warranty: Warranty) async throws
    func updateWarranty(_ warranty: Warranty) async throws
    func deleteWarranty(id: UUID) async throws
}

public struct LiveWarrantyService: WarrantyService, @unchecked Sendable {
    private let modelContext: ModelContext
    private let cache: Cache<UUID, Warranty>
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory", category: "WarrantyService")

    public init(modelContext: ModelContext) throws {
        self.modelContext = modelContext
        cache = try Cache(name: "warranty", maxMemoryCount: CacheConstants.Memory.defaultCountLimit)
    }

    public func fetchWarranties() async throws -> [Warranty] {
        let descriptor = FetchDescriptor<Warranty>(
            sortBy: [SortDescriptor(\.expiresAt)]
        )

        do {
            let warranties = try modelContext.fetch(descriptor)
            logger.debug("Fetched \(warranties.count) warranties")

            for warranty in warranties {
                await cache.set(warranty, for: warranty.id)
            }

            return warranties
        } catch {
            logger.error("Failed to fetch warranties: \(error.localizedDescription)")
            throw WarrantyError.fetchFailed(error.localizedDescription)
        }
    }

    public func fetchWarranty(id: UUID) async throws -> Warranty? {
        if let cached = await cache.get(for: id) {
            logger.debug("Retrieved warranty from cache: \(id)")
            return cached
        }

        let descriptor = FetchDescriptor<Warranty>(
            predicate: #Predicate { $0.id == id }
        )

        do {
            let warranties = try modelContext.fetch(descriptor)
            if let warranty = warranties.first {
                await cache.set(warranty, for: id)
                return warranty
            }
            return nil
        } catch {
            logger.error("Failed to fetch warranty \(id): \(error.localizedDescription)")
            throw WarrantyError.fetchFailed(error.localizedDescription)
        }
    }

    public func fetchItemsExpiringWithin(days: Int) async throws -> [Item] {
        let currentDate = Date()
        let futureDate = Calendar.current.date(byAdding: .day, value: days, to: currentDate) ?? currentDate

        // Fetch all items and filter in memory to avoid complex predicate
        let descriptor = FetchDescriptor<Item>()

        do {
            let allItems = try modelContext.fetch(descriptor)
            let items = allItems.filter { item in
                guard let expirationDate = item.warrantyExpirationDate else { return false }
                return expirationDate > currentDate && expirationDate <= futureDate
            }.sorted { $0.warrantyExpirationDate ?? Date.distantPast < $1.warrantyExpirationDate ?? Date.distantPast }
            
            logger.debug("Found \(items.count) items expiring within \(days) days")
            return items
        } catch {
            logger.error("Failed to fetch expiring items: \(error.localizedDescription)")
            throw WarrantyError.fetchFailed(error.localizedDescription)
        }
    }

    public func fetchExpiredItems() async throws -> [Item] {
        let currentDate = Date()
        
        // Fetch all items and filter in memory to avoid complex predicate
        let descriptor = FetchDescriptor<Item>()

        do {
            let allItems = try modelContext.fetch(descriptor)
            let items = allItems.filter { item in
                guard let expirationDate = item.warrantyExpirationDate else { return false }
                return expirationDate < currentDate
            }.sorted { $0.warrantyExpirationDate ?? Date.distantPast > $1.warrantyExpirationDate ?? Date.distantPast }
            
            logger.debug("Found \(items.count) items with expired warranties")
            return items
        } catch {
            logger.error("Failed to fetch expired items: \(error.localizedDescription)")
            throw WarrantyError.fetchFailed(error.localizedDescription)
        }
    }

    public func fetchItemsWithoutWarranty() async throws -> [Item] {
        let descriptor = FetchDescriptor<Item>(
            predicate: #Predicate { item in
                item.warrantyExpirationDate == nil && item.warranty == nil
            },
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )

        do {
            let items = try modelContext.fetch(descriptor)
            logger.debug("Found \(items.count) items without warranty information")
            return items
        } catch {
            logger.error("Failed to fetch items without warranty: \(error.localizedDescription)")
            throw WarrantyError.fetchFailed(error.localizedDescription)
        }
    }

    public func getWarrantyInsights() async throws -> WarrantyInsights {
        let allItemsDescriptor = FetchDescriptor<Item>()
        let allItems = try modelContext.fetch(allItemsDescriptor)

        let expiringSoon = try await fetchItemsExpiringWithin(days: 30)
        let expired = try await fetchExpiredItems()
        let withoutWarranty = try await fetchItemsWithoutWarranty()

        let totalValue = allItems.compactMap(\.purchasePrice).reduce(0, +)
        let protectedValue = allItems.filter { item in
            guard let expirationDate = item.warrantyExpirationDate else { return false }
            return expirationDate > Date()
        }.compactMap(\.purchasePrice).reduce(0, +)

        let coveragePercentage = totalValue > 0 ? (protectedValue / totalValue) * 100 : 0

        return WarrantyInsights(
            totalItems: allItems.count,
            itemsWithWarranty: allItems.count - withoutWarranty.count,
            expiringSoon: expiringSoon.count,
            expired: expired.count,
            withoutWarranty: withoutWarranty.count,
            totalValue: totalValue,
            protectedValue: protectedValue,
            coveragePercentage: coveragePercentage
        )
    }

    public func getTotalWarrantyValue() async throws -> Decimal {
        let currentDate = Date()
        // Fetch all items and filter in memory due to complex predicate
        let descriptor = FetchDescriptor<Item>()

        do {
            let allItems = try modelContext.fetch(descriptor)
            // Filter items with active warranties
            let items = allItems.filter { item in
                if let expirationDate = item.warrantyExpirationDate, expirationDate > currentDate {
                    return true
                }
                if let warranty = item.warranty, warranty.expiresAt > currentDate {
                    return true
                }
                return false
            }
            return items.compactMap(\.purchasePrice).reduce(0, +)
        } catch {
            logger.error("Failed to calculate warranty value: \(error.localizedDescription)")
            throw WarrantyError.calculationFailed(error.localizedDescription)
        }
    }

    public func getWarrantyCoverageByCategory() async throws -> [CategoryCoverage] {
        let categoriesDescriptor = FetchDescriptor<Category>()
        let categories = try modelContext.fetch(categoriesDescriptor)

        var coverage: [CategoryCoverage] = []

        for category in categories {
            // Fetch all items and filter by category in memory
            let itemsDescriptor = FetchDescriptor<Item>()
            let allItems = try modelContext.fetch(itemsDescriptor)
            let items = allItems.filter { item in
                item.category?.id == category.id
            }

            let totalItems = items.count
            let totalValue = items.compactMap(\.purchasePrice).reduce(0, +)

            let withWarranty = items.filter { item in
                if let expirationDate = item.warrantyExpirationDate {
                    return expirationDate > Date()
                }
                if let warranty = item.warranty {
                    return warranty.expiresAt > Date()
                }
                return false
            }

            let protectedValue = withWarranty.compactMap(\.purchasePrice).reduce(0, +)
            let coveragePercent = totalValue > 0 ? (protectedValue / totalValue) * 100 : 0

            coverage.append(CategoryCoverage(
                category: category,
                totalItems: totalItems,
                itemsWithWarranty: withWarranty.count,
                totalValue: totalValue,
                protectedValue: protectedValue,
                coveragePercentage: coveragePercent
            ))
        }

        return coverage.sorted { $0.totalValue > $1.totalValue }
    }

    public func saveWarranty(_ warranty: Warranty) async throws {
        modelContext.insert(warranty)

        do {
            try modelContext.save()
            await cache.set(warranty, for: warranty.id)
            logger.info("Saved warranty: \(warranty.provider)")
        } catch {
            logger.error("Failed to save warranty: \(error.localizedDescription)")
            throw WarrantyError.saveFailed(error.localizedDescription)
        }
    }

    public func updateWarranty(_ warranty: Warranty) async throws {
        warranty.updatedAt = Date()

        do {
            try modelContext.save()
            await cache.set(warranty, for: warranty.id)
            logger.info("Updated warranty: \(warranty.provider)")
        } catch {
            logger.error("Failed to update warranty: \(error.localizedDescription)")
            throw WarrantyError.updateFailed(error.localizedDescription)
        }
    }

    public func deleteWarranty(id: UUID) async throws {
        let descriptor = FetchDescriptor<Warranty>(
            predicate: #Predicate { $0.id == id }
        )

        do {
            let warranties = try modelContext.fetch(descriptor)
            if let warranty = warranties.first {
                modelContext.delete(warranty)
                try modelContext.save()
                await cache.remove(for: id)
                logger.info("Deleted warranty: \(id)")
            }
        } catch {
            logger.error("Failed to delete warranty \(id): \(error.localizedDescription)")
            throw WarrantyError.deleteFailed(error.localizedDescription)
        }
    }
}

// MARK: - Data Models

public struct WarrantyInsights: Sendable {
    public let totalItems: Int
    public let itemsWithWarranty: Int
    public let expiringSoon: Int
    public let expired: Int
    public let withoutWarranty: Int
    public let totalValue: Decimal
    public let protectedValue: Decimal
    public let coveragePercentage: Decimal
}

public struct CategoryCoverage: Sendable {
    public let category: Category
    public let totalItems: Int
    public let itemsWithWarranty: Int
    public let totalValue: Decimal
    public let protectedValue: Decimal
    public let coveragePercentage: Decimal
}

// MARK: - Error Types

public enum WarrantyError: Error, LocalizedError, Sendable {
    case fetchFailed(String)
    case saveFailed(String)
    case updateFailed(String)
    case deleteFailed(String)
    case calculationFailed(String)
    case notFound

    public var errorDescription: String? {
        switch self {
        case let .fetchFailed(reason):
            "Failed to fetch warranty data: \(reason)"
        case let .saveFailed(reason):
            "Failed to save warranty: \(reason)"
        case let .updateFailed(reason):
            "Failed to update warranty: \(reason)"
        case let .deleteFailed(reason):
            "Failed to delete warranty: \(reason)"
        case let .calculationFailed(reason):
            "Failed to calculate warranty data: \(reason)"
        case .notFound:
            "Warranty not found"
        }
    }
}
