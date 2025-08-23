//
// Layer: Services
// Module: WarrantyTrackingService/Operations/Core
// Purpose: Core CRUD operations for warranty management
//

import Foundation
import SwiftData
import os.log

/// Core warranty operations handling basic CRUD functionality
public struct WarrantyCoreOperations {
    
    private let modelContext: ModelContext
    private let logger: Logger
    
    public init(modelContext: ModelContext, logger: Logger) {
        self.modelContext = modelContext
        self.logger = logger
    }
    
    // MARK: - Fetch Operations
    
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
    
    public func fetchWarranty(for itemId: UUID, cache: WarrantyCacheManager) async throws -> Warranty? {
        // Check cache first
        if let cachedWarranty = cache.getWarranty(for: itemId) {
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
                cache.setWarranty(warranty, for: itemId)
            }

            return warranty
        } catch {
            logger.error("Failed to fetch warranty for item \(itemId): \(error.localizedDescription)")
            throw WarrantyTrackingError.warrantyNotFound(itemId)
        }
    }
    
    // MARK: - Save Operations
    
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
            } else {
                // Create new warranty and associate with item
                warranty.item = item
                item.warranty = warranty
                modelContext.insert(warranty)
            }

            try modelContext.save()
            
            logger.info("Successfully saved warranty for item \(itemId)")
        } catch {
            logger.error("Failed to save warranty for item \(itemId): \(error.localizedDescription)")
            throw WarrantyTrackingError.saveFailed("Failed to save warranty: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Delete Operations
    
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
                try modelContext.save()
                
                logger.info("Successfully deleted warranty for item \(itemId)")
            }
        } catch {
            logger.error("Failed to delete warranty for item \(itemId): \(error.localizedDescription)")
            throw WarrantyTrackingError.deletionFailed("Failed to delete warranty: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Helper Methods
    
    public func fetchAllItems() async throws -> [Item] {
        let descriptor = FetchDescriptor<Item>()
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            logger.error("Failed to fetch all items: \(error.localizedDescription)")
            throw WarrantyTrackingError.calculationFailed("Failed to fetch items: \(error.localizedDescription)")
        }
    }
    
    public func calculateWarrantyExpiration(for item: Item) async throws -> Date? {
        guard let purchaseDate = item.purchaseDate else {
            return nil
        }
        
        let warrantyPeriodInMonths = getDefaultWarrantyPeriod(for: item)
        let calendar = Calendar.current
        
        return calendar.date(byAdding: .month, value: warrantyPeriodInMonths, to: purchaseDate)
    }
    
    private func getDefaultWarrantyPeriod(for item: Item) -> Int {
        let category = item.category
        let categoryName = category?.name
        let defaults = CategoryWarrantyDefaults.getDefaults(for: categoryName)
        return defaults.months
    }
}