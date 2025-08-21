//
// Layer: App-Main
// Module: WarrantyViews/WarrantyTracking
// Purpose: Core state management and business logic for warranty tracking
//

import SwiftUI
import SwiftData

@MainActor
public final class WarrantyTrackingCore: ObservableObject {
    // MARK: - Published State
    
    @Published public var warrantyStatus: WarrantyStatus = .noWarranty
    @Published public var isLoading = false
    @Published public var showingAutoDetectSheet = false
    @Published public var showingWarrantyForm = false
    @Published public var detectionResult: WarrantyDetectionResult?
    @Published public var errorMessage: String?
    @Published public var showingNotificationSettings = false
    @Published public var showingExtensionOptions = false
    
    // MARK: - Dependencies
    
    private let warrantyTrackingService: LiveWarrantyTrackingService
    private let notificationService: LiveNotificationService
    private let item: Item
    
    // MARK: - Initialization
    
    public init(item: Item, modelContext: ModelContext) {
        self.item = item
        self.notificationService = LiveNotificationService()
        self.warrantyTrackingService = LiveWarrantyTrackingService(
            modelContext: modelContext,
            notificationService: notificationService
        )
        
        updateWarrantyStatus()
    }
    
    // MARK: - Computed Properties
    
    public var hasWarranty: Bool {
        item.warranty != nil
    }
    
    public var canAutoDetect: Bool {
        !item.brand.isNilOrEmpty || !item.modelNumber.isNilOrEmpty || !item.serialNumber.isNilOrEmpty
    }
    
    public var warrantyProgress: Double {
        guard let warranty = item.warranty else {
            return 0.0
        }
        
        let startDate = warranty.startDate
        let endDate = warranty.endDate
        
        let now = Date()
        let total = endDate.timeIntervalSince(startDate)
        let elapsed = now.timeIntervalSince(startDate)
        
        return max(0, min(1, elapsed / total))
    }
    
    public var daysRemaining: Int? {
        guard let warranty = item.warranty else {
            return nil
        }
        
        let days = Calendar.current.dateComponents([.day], from: Date(), to: warranty.expiresAt).day
        return max(0, days ?? 0)
    }
    
    // MARK: - Actions
    
    public func startAutoDetection() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let result = try await warrantyTrackingService.detectWarrantyInfo(
                    brand: item.brand,
                    model: item.modelNumber,
                    serialNumber: item.serialNumber,
                    purchaseDate: item.purchaseDate
                )
                
                await MainActor.run {
                    self.detectionResult = result
                    self.showingAutoDetectSheet = true
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    public func acceptDetectionResult() {
        guard let result = detectionResult else { return }
        
        let warranty = Warranty(
            provider: result.provider,
            type: result.type,
            startDate: result.startDate,
            expiresAt: result.endDate,
            item: item
        )
        
        item.warranty = warranty
        updateWarrantyStatus()
        showingAutoDetectSheet = false
        detectionResult = nil
        
        // Schedule notifications if enabled
        scheduleWarrantyNotifications()
    }
    
    public func rejectDetectionResult() {
        detectionResult = nil
        showingAutoDetectSheet = false
    }
    
    public func addManualWarranty() {
        showingWarrantyForm = true
    }
    
    public func removeWarranty() {
        item.warranty = nil
        updateWarrantyStatus()
        cancelWarrantyNotifications()
    }
    
    public func extendWarranty() {
        showingExtensionOptions = true
    }
    
    public func registerWarranty() {
        guard let warranty = item.warranty else { return }
        
        Task {
            do {
                try await warrantyTrackingService.registerWarranty(
                    warranty: warranty,
                    item: item
                )
                
                await MainActor.run {
                    // Note: isRegistered property not available in current Warranty model
                    updateWarrantyStatus()
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    public func configureNotifications() {
        showingNotificationSettings = true
    }
    
    // MARK: - Private Methods
    
    private func updateWarrantyStatus() {
        if let warranty = item.warranty {
            let endDate = warranty.expiresAt
            let now = Date()
            if endDate < now {
                warrantyStatus = .expired
            } else {
                let daysUntilExpiry = Calendar.current.dateComponents([.day], from: now, to: endDate).day ?? 0
                    if daysUntilExpiry <= 30 {
                        warrantyStatus = .expiringSoon
                    } else if daysUntilExpiry <= 90 {
                        warrantyStatus = .active
                    } else {
                        warrantyStatus = .active
                    }
                }
            } else {
                warrantyStatus = .active
            }
        } else {
            warrantyStatus = .noWarranty
        }
    }
    
    private func scheduleWarrantyNotifications() {
        guard let warranty = item.warranty else { return }
        let endDate = warranty.expiresAt
        
        Task {
            try await notificationService.scheduleWarrantyExpirationNotifications(for: item)
        }
    }
    
    private func cancelWarrantyNotifications() {
        Task {
            await notificationService.cancelWarrantyNotifications(for: item.id)
        }
    }
    
    // MARK: - Statistics
    
    public func getWarrantyStatistics() -> WarrantyProgressStatistics {
        guard let warranty = item.warranty else {
            return WarrantyProgressStatistics()
        }
        
        let startDate = warranty.startDate
        let endDate = warranty.endDate
        
        let totalDays = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
        let remainingDays = max(0, Calendar.current.dateComponents([.day], from: Date(), to: endDate).day ?? 0)
        let elapsedDays = totalDays - remainingDays
        
        return WarrantyProgressStatistics(
            totalDays: totalDays,
            elapsedDays: elapsedDays,
            remainingDays: remainingDays,
            progressPercentage: totalDays > 0 ? Double(elapsedDays) / Double(totalDays) : 0
        )
    }
}

// MARK: - Supporting Types

public struct WarrantyProgressStatistics {
    public let totalDays: Int
    public let elapsedDays: Int
    public let remainingDays: Int
    public let progressPercentage: Double
    
    public init(
        totalDays: Int = 0,
        elapsedDays: Int = 0,
        remainingDays: Int = 0,
        progressPercentage: Double = 0
    ) {
        self.totalDays = totalDays
        self.elapsedDays = elapsedDays
        self.remainingDays = remainingDays
        self.progressPercentage = progressPercentage
    }
}

// MARK: - String Extensions

private extension String {
    var isNilOrEmpty: Bool {
        return self.isEmpty
    }
}

private extension String? {
    var isNilOrEmpty: Bool {
        return self?.isEmpty ?? true
    }
}