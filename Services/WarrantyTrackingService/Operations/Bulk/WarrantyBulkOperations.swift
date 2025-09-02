//
// Layer: Services
// Module: WarrantyTrackingService/Operations/Bulk
// Purpose: Batch processing operations for warranty management
//

import Foundation
import os.log
import UserNotifications

/// Handles bulk warranty operations for efficient batch processing
public struct WarrantyBulkOperations {
    
    private let coreOperations: WarrantyCoreOperations
    private let detectionEngine: WarrantyDetectionEngine
    private let statusManager: WarrantyStatusManager
    private let notificationService: any NotificationService
    private let logger: Logger
    
    public init(
        coreOperations: WarrantyCoreOperations,
        detectionEngine: WarrantyDetectionEngine,
        statusManager: WarrantyStatusManager,
        notificationService: any NotificationService,
        logger: Logger
    ) {
        self.coreOperations = coreOperations
        self.detectionEngine = detectionEngine
        self.statusManager = statusManager
        self.notificationService = notificationService
        self.logger = logger
    }
    
    // MARK: - Bulk Creation
    
    public func bulkCreateWarranties(for items: [Item]) async throws -> [Warranty] {
        var createdWarranties: [Warranty] = []
        
        for item in items {
            // Skip items that already have warranties
            guard item.warranty == nil else { continue }
            
            // Calculate warranty expiration
            guard let expirationDate = try await coreOperations.calculateWarrantyExpiration(for: item) else {
                continue
            }
            
            let provider = await detectionEngine.suggestWarrantyProvider(for: item) ?? "Manufacturer"
            let startDate = item.purchaseDate ?? Date()
            
            let warranty = Warranty(
                provider: provider,
                type: .manufacturer,
                startDate: startDate,
                expiresAt: expirationDate,
                item: item
            )
            
            try await coreOperations.saveWarranty(warranty, for: item.id)
            createdWarranties.append(warranty)
        }
        
        logger.info("Bulk created \(createdWarranties.count) warranties")
        return createdWarranties
    }
    
    // MARK: - Status Refresh
    
    public func refreshAllWarrantyStatuses(cache: WarrantyCacheManager) async throws {
        let allItems = try await coreOperations.fetchAllItems()
        
        for item in allItems {
            guard let warranty = item.warranty else { continue }
            
            let status = try await statusManager.getWarrantyStatus(for: item)
            
            // Schedule notifications for warranties expiring soon
            if case .expiringSoon = status {
                try await scheduleWarrantyNotification(for: item, warranty: warranty)
            }
        }
        
        // Clear cache to force refresh
        cache.clearCache()
        
        logger.info("Refreshed warranty statuses for \(allItems.count) items")
    }
    
    // MARK: - Receipt-based Updates
    
    public func updateWarrantiesFromReceipts() async throws -> Int {
        let allItems = try await coreOperations.fetchAllItems()
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
            if let detectionResult = try await detectionEngine.detectWarrantyFromReceipt(item: item, receiptText: item.extractedReceiptText),
               detectionResult.confidence > 0.6
            {
                let startDate = item.purchaseDate ?? Date()
                let calendar = Calendar.current
                let duration = detectionResult.suggestedDuration ?? 12 // Default to 12 months
                let expirationDate = calendar.date(byAdding: .month, value: duration, to: startDate) ?? startDate
                
                let warranty = Warranty(
                    provider: detectionResult.suggestedProvider ?? "Unknown Provider",
                    type: .manufacturer,
                    startDate: startDate,
                    expiresAt: expirationDate,
                    item: item
                )
                
                try await coreOperations.saveWarranty(warranty, for: item.id)
                updatedCount += 1
            }
        }
        
        logger.info("Updated warranties from receipts for \(updatedCount) items")
        return updatedCount
    }
    
    // MARK: - Warranty Registration
    
    public func bulkRegisterWarranties(items: [Item]) async throws -> [WarrantyRegistrationResult] {
        var results: [WarrantyRegistrationResult] = []
        
        for item in items {
            guard let warranty = item.warranty else {
                results.append(WarrantyRegistrationResult(
                    itemId: item.id,
                    success: false,
                    error: "No warranty found for item"
                ))
                continue
            }
            
            do {
                try await registerWarranty(warranty: warranty, item: item)
                results.append(WarrantyRegistrationResult(
                    itemId: item.id,
                    success: true,
                    confirmationNumber: warranty.confirmationNumber
                ))
            } catch {
                results.append(WarrantyRegistrationResult(
                    itemId: item.id,
                    success: false,
                    error: error.localizedDescription
                ))
            }
        }
        
        let successCount = results.filter { $0.success }.count
        logger.info("Bulk registered \(successCount) warranties out of \(items.count) items")
        
        return results
    }
    
    // MARK: - Notification Management
    
    public func scheduleWarrantyNotifications(for warranties: [Warranty]) async throws {
        for warranty in warranties {
            guard let item = warranty.item else { continue }
            try await scheduleWarrantyNotification(for: item, warranty: warranty)
        }
        
        logger.info("Scheduled notifications for \(warranties.count) warranties")
    }
    
    // MARK: - Private Helper Methods
    
    private func scheduleWarrantyNotification(for item: Item, warranty: Warranty) async throws {
        let notificationDates = statusManager.calculateNotificationDates(for: warranty)
        
        for date in notificationDates {
            let content = UNMutableNotificationContent()
            content.title = "Warranty Expiring Soon"
            content.body = "\(item.name) warranty expires on \(DateFormatter.localizedString(from: warranty.expiresAt, dateStyle: .medium, timeStyle: .none))"
            content.userInfo = ["itemId": item.id.uuidString, "warrantyId": warranty.id.uuidString]
            
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date),
                repeats: false
            )
            
            try await notificationService.scheduleNotification(
                id: "warranty-\(warranty.id.uuidString)-\(date.timeIntervalSince1970)",
                content: content,
                trigger: trigger
            )
        }
    }
    
    private func registerWarranty(warranty: Warranty, item: Item) async throws {
        // Simulate warranty registration process
        logger.info("Registering warranty for item \(item.id) with provider \(warranty.provider)")
        
        // In a real implementation, this would:
        // 1. Connect to manufacturer API
        // 2. Submit registration with serial number, purchase date, etc.
        // 3. Receive confirmation number
        // 4. Update warranty with registration details
        
        // For now, we'll simulate a successful registration
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay to simulate API call
        
        // Update warranty registration status
        warranty.isRegistered = true
        warranty.registrationDate = Date()
        
        // Generate a mock confirmation number
        warranty.confirmationNumber = "REG-\(Int.random(in: 100000...999999))"
        
        // Save the updated warranty
        try await coreOperations.saveWarranty(warranty, for: item.id)
        
        logger.info("Successfully registered warranty for item \(item.id)")
    }
}

// MARK: - Supporting Types

public struct WarrantyRegistrationResult: Sendable {
    public let itemId: UUID
    public let success: Bool
    public let confirmationNumber: String?
    public let error: String?
    
    public init(itemId: UUID, success: Bool, confirmationNumber: String? = nil, error: String? = nil) {
        self.itemId = itemId
        self.success = success
        self.confirmationNumber = confirmationNumber
        self.error = error
    }
}