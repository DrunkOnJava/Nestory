//
// Layer: Services
// Module: Services
// Purpose: TCA dependency keys for all services
//

import ComposableArchitecture
import Foundation
import SwiftData
import os.log
import CloudKit

// MARK: - Service Dependency Keys

enum AuthServiceKey: @preconcurrency DependencyKey {
    @MainActor
    static var liveValue: any AuthService {
        return LiveAuthService()
    }
    @MainActor
    static let testValue: any AuthService = MockAuthService()
}

enum InventoryServiceKey: DependencyKey {
    static var liveValue: any InventoryService {
        do {
            // Create ModelContainer with explicit local-only configuration
            let config = ModelConfiguration(isStoredInMemoryOnly: false, allowsSave: true)
            let container = try ModelContainer(
                for: Item.self, Category.self, Receipt.self, Warranty.self,
                configurations: config
            )
            // Create a new context to avoid MainActor issues
            let context = ModelContext(container)
            let service = try LiveInventoryService(modelContext: context)
            
            // Record successful service creation
            Task { @MainActor in
                ServiceHealthManager.shared.recordSuccess(for: .inventory)
            }
            
            return service
        } catch {
            // Record service failure for health monitoring
            Task { @MainActor in
                ServiceHealthManager.shared.recordFailure(for: .inventory, error: error)
                ServiceHealthManager.shared.notifyDegradedMode(service: .inventory)
            }
            
            // Log error but don't crash in production
            Logger.service.error("Failed to create InventoryService: \(error.localizedDescription)")
            Logger.service.info("Falling back to MockInventoryService for graceful degradation")
            
            #if DEBUG
            Logger.service.debug("InventoryService creation debug info: \(error)")
            #endif
            
            // Return enhanced mock service with better reliability
            return ReliableMockInventoryService()
        }
    }

    static let testValue: any InventoryService = MockInventoryService()
}

enum PhotoIntegrationServiceKey: DependencyKey {
    static var liveValue: any PhotoIntegrationService {
        return LivePhotoIntegrationService()
    }
    static let testValue: any PhotoIntegrationService = MockPhotoIntegrationService()
}

enum ExportServiceKey: DependencyKey {
    static var liveValue: any ExportService {
        // Return mock service for now - live service implementation pending
        MockExportService()
    }

    static let testValue: any ExportService = MockExportService()
}

enum SyncServiceKey: DependencyKey {
    static var liveValue: any SyncService {
        // Return live service - no throwing constructor
        LiveSyncService()
    }
    static let testValue: any SyncService = MockSyncService()
}

enum AnalyticsServiceKey: DependencyKey {
    static var liveValue: any AnalyticsService {
        do {
            let currencyService = try LiveCurrencyService()
            let service = try LiveAnalyticsService(currencyService: currencyService)
            
            // Record successful service creation
            Task { @MainActor in
                ServiceHealthManager.shared.recordSuccess(for: .analytics)
            }
            
            return service
        } catch {
            // Record service failure for health monitoring
            Task { @MainActor in
                ServiceHealthManager.shared.recordFailure(for: .analytics, error: error)
                ServiceHealthManager.shared.notifyDegradedMode(service: .analytics)
            }
            
            Logger.service.error("Failed to create AnalyticsService: \(error)")
            Logger.service.info("Falling back to MockAnalyticsService for graceful degradation")
            return MockAnalyticsService()
        }
    }

    static let testValue: any AnalyticsService = MockAnalyticsService()
}

enum CurrencyServiceKey: DependencyKey {
    static var liveValue: any CurrencyService {
        do {
            let service = try LiveCurrencyService()
            
            // Record successful service creation
            Task { @MainActor in
                ServiceHealthManager.shared.recordSuccess(for: .currency)
            }
            
            return service
        } catch {
            // Record service failure for health monitoring
            Task { @MainActor in
                ServiceHealthManager.shared.recordFailure(for: .currency, error: error)
                ServiceHealthManager.shared.notifyDegradedMode(service: .currency)
            }
            
            Logger.service.error("Failed to create CurrencyService: \(error)")
            Logger.service.info("Falling back to MockCurrencyService for graceful degradation")
            return MockCurrencyService()
        }
    }

    static let testValue: any CurrencyService = MockCurrencyService()
}

enum BarcodeScannerServiceKey: @preconcurrency DependencyKey {
    @MainActor
    static var liveValue: any BarcodeScannerService {
        LiveBarcodeScannerService()
    }
    static let testValue: any BarcodeScannerService = MockBarcodeScannerService()
}

enum NotificationServiceKey: DependencyKey {
    static var liveValue: any NotificationService {
        // Return a minimal nonisolated default for TCA dependencies
        // The actual live service will be injected at app startup via withDependencies
        MockNotificationService()
    }

    static let testValue: any NotificationService = MockNotificationService()
}

enum ImportExportServiceKey: @preconcurrency DependencyKey {
    @MainActor
    static var liveValue: any ImportExportService {
        LiveImportExportService()
    }

    @MainActor
    static let testValue: any ImportExportService = MockImportExportService()
}

enum CloudBackupServiceKey: @preconcurrency DependencyKey {
    @MainActor
        static var liveValue: any CloudBackupService {
        LiveCloudBackupService()
    }

    @MainActor
        static let testValue: any CloudBackupService = MockCloudBackupService()
}

enum ReceiptOCRServiceKey: DependencyKey {
    static var liveValue: any ReceiptOCRService {
        // Use mock for now to avoid async issues
        MockReceiptOCRService()
    }
    
    static let testValue: any ReceiptOCRService = MockReceiptOCRService()
}

enum InsuranceReportServiceKey: DependencyKey {
    static var liveValue: any InsuranceReportService {
        // Use mock for now to avoid async issues  
        MockInsuranceReportService()
    }
    
    static let testValue: any InsuranceReportService = MockInsuranceReportService()
}

enum InsuranceClaimServiceKey: @preconcurrency DependencyKey {
    @MainActor
        static var liveValue: any InsuranceClaimService {
        do {
            // Create ModelContainer with explicit local-only configuration
            let config = ModelConfiguration(isStoredInMemoryOnly: false, allowsSave: true)
            let container = try ModelContainer(
                for: Item.self, Category.self, Receipt.self, Warranty.self, ClaimSubmission.self,
                configurations: config
            )
            // Create a new context to avoid MainActor issues
            let context = ModelContext(container)
            
            // Record successful service creation
            Task { @MainActor in
                ServiceHealthManager.shared.recordSuccess(for: .insuranceClaim)
            }
            
            return LiveInsuranceClaimService(modelContext: context)
        } catch {
            // Record service failure for health monitoring
            Task { @MainActor in
                ServiceHealthManager.shared.recordFailure(for: .insuranceClaim, error: error)
                ServiceHealthManager.shared.notifyDegradedMode(service: .insuranceClaim)
            }
            
            Logger.service.error("Failed to create InsuranceClaimService: \(error.localizedDescription)")
            Logger.service.info("Falling back to MockInsuranceClaimService for graceful degradation")
            return MockInsuranceClaimService()
        }
    }
        static let testValue: any InsuranceClaimService = MockInsuranceClaimService()
}

enum ClaimPackageAssemblerServiceKey: @preconcurrency DependencyKey {
    @MainActor
        static var liveValue: any ClaimPackageAssemblerService {
        LiveClaimPackageAssemblerService()
    }
        static let testValue: any ClaimPackageAssemblerService = MockClaimPackageAssemblerService()
}

enum SearchHistoryServiceKey: DependencyKey {
    static var liveValue: any SearchHistoryService {
        // Currently using mock implementation, can upgrade to live service later
        MockSearchHistoryService()
    }
    static let testValue: any SearchHistoryService = MockSearchHistoryService()
}

enum WarrantyTrackingServiceKey: DependencyKey {
    static var liveValue: any WarrantyTrackingService {
        // Return a minimal nonisolated default for TCA dependencies
        // The actual live service will be injected at app startup via withDependencies
        MockWarrantyTrackingService()
    }
    static let testValue: any WarrantyTrackingService = MockWarrantyTrackingService()
}

enum CategoryServiceKey: DependencyKey {
    static var liveValue: any CategoryService {
        do {
            // CategoryService depends on InventoryService - use the same approach
            let config = ModelConfiguration(isStoredInMemoryOnly: false, allowsSave: true)
            let container = try ModelContainer(
                for: Item.self, Category.self, Receipt.self, Warranty.self,
                configurations: config
            )
            let context = ModelContext(container)
            let inventoryService = try LiveInventoryService(modelContext: context)
            let service = LiveCategoryService(inventoryService: inventoryService)
            
            // Record successful service creation
            Task { @MainActor in
                ServiceHealthManager.shared.recordSuccess(for: .category)
            }
            
            return service
        } catch {
            // Record service failure for health monitoring
            Task { @MainActor in
                ServiceHealthManager.shared.recordFailure(for: .category, error: error)
                ServiceHealthManager.shared.notifyDegradedMode(service: .category)
            }
            
            Logger.service.error("Failed to create CategoryService: \(error.localizedDescription)")
            Logger.service.info("Falling back to MockCategoryService for graceful degradation")
            return MockCategoryService()
        }
    }
    static let testValue: any CategoryService = MockCategoryService()
}
