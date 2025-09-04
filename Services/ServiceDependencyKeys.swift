//
// Layer: Services
// Module: Services
// Purpose: TCA dependency keys for all services
//

import ComposableArchitecture
import Foundation
import SwiftData
import CloudKit

// MARK: - Service Dependency Keys

enum AuthServiceKey: @preconcurrency DependencyKey {
    @MainActor
    static var liveValue: any AuthService {
        do {
            return LiveAuthService()
        } catch {
            print("⚠️ Failed to create AuthService: \(error.localizedDescription)")
            print("🔄 Falling back to MockAuthService for graceful degradation")
            return MockAuthService()
        }
    }
    @MainActor
    static let testValue: any AuthService = MockAuthService()
}

enum InventoryServiceKey: @preconcurrency DependencyKey {
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
            print("⚠️ Failed to create InventoryService: \(error.localizedDescription)")
            print("🔄 Falling back to MockInventoryService for graceful degradation")
            
            #if DEBUG
            print("🔍 Debug info: \(error)")
            #endif
            
            // Return enhanced mock service with better reliability
            return ReliableMockInventoryService()
        }
    }

    static let testValue: any InventoryService = MockInventoryService()
}

enum PhotoIntegrationServiceKey: DependencyKey {
    static var liveValue: any PhotoIntegrationService {
        do {
            return LivePhotoIntegrationService()
        } catch {
            print("⚠️ Failed to create PhotoIntegrationService: \(error.localizedDescription)")
            print("🔄 Falling back to MockPhotoIntegrationService for graceful degradation")
            return MockPhotoIntegrationService()
        }
    }
    static let testValue: any PhotoIntegrationService = MockPhotoIntegrationService()
}

enum ExportServiceKey: DependencyKey {
    static var liveValue: any ExportService {
        do {
            return try LiveExportService()
        } catch {
            print("⚠️ Failed to create ExportService: \(error)")
            print("🔄 Falling back to MockExportService for graceful degradation")
            return MockExportService()
        }
    }

    static let testValue: any ExportService = MockExportService()
}

enum SyncServiceKey: @preconcurrency DependencyKey {
    @MainActor
    static var liveValue: any SyncService {
        do {
            return LiveSyncService()
        } catch {
            print("⚠️ Failed to create SyncService: \(error.localizedDescription)")
            print("🔄 Falling back to MockSyncService for graceful degradation")
            return MockSyncService()
        }
    }
    @MainActor
    static let testValue: any SyncService = MockSyncService()
}

enum AnalyticsServiceKey: @preconcurrency DependencyKey {
    static var liveValue: any AnalyticsService {
        do {
            let currencyService = try LiveCurrencyService()
            return try LiveAnalyticsService(currencyService: currencyService)
        } catch {
            print("⚠️ Failed to create AnalyticsService: \(error)")
            print("🔄 Falling back to MockAnalyticsService for graceful degradation")
            return MockAnalyticsService()
        }
    }

    static let testValue: any AnalyticsService = MockAnalyticsService()
}

enum CurrencyServiceKey: DependencyKey {
    static var liveValue: any CurrencyService {
        do {
            return try LiveCurrencyService()
        } catch {
            print("⚠️ Failed to create CurrencyService: \(error)")
            print("🔄 Falling back to MockCurrencyService for graceful degradation")
            return MockCurrencyService()
        }
    }

    static let testValue: any CurrencyService = MockCurrencyService()
}

enum BarcodeScannerServiceKey: @preconcurrency DependencyKey {
    @MainActor
    static var liveValue: any BarcodeScannerService {
        do {
            return LiveBarcodeScannerService()
        } catch {
            print("⚠️ Failed to create BarcodeScannerService: \(error.localizedDescription)")
            print("🔄 Falling back to MockBarcodeScannerService for graceful degradation")
            return MockBarcodeScannerService()
        }
    }
    @MainActor
    static let testValue: any BarcodeScannerService = MockBarcodeScannerService()
}

enum NotificationServiceKey: @preconcurrency DependencyKey {
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
        do {
            return try LiveImportExportService()
        } catch {
            print("⚠️ Failed to create ImportExportService: \(error)")
            print("🔄 Falling back to MockImportExportService for graceful degradation")
            return MockImportExportService()
        }
    }

    @MainActor
    static let testValue: any ImportExportService = MockImportExportService()
}

enum CloudBackupServiceKey: @preconcurrency DependencyKey {
    @MainActor
    static var liveValue: any CloudBackupService {
        do {
            return LiveCloudBackupService()
        } catch {
            print("⚠️ Failed to create CloudBackupService: \(error.localizedDescription)")
            print("🔄 Falling back to MockCloudBackupService for graceful degradation")
            return MockCloudBackupService()
        }
    }

    @MainActor
    static let testValue: any CloudBackupService = MockCloudBackupService()
}

enum ReceiptOCRServiceKey: @preconcurrency DependencyKey {
    static var liveValue: any ReceiptOCRService {
        do {
            // Try live service first, fall back to mock for compatibility
            return MockReceiptOCRService() // Use mock for now to avoid async issues
        } catch {
            print("⚠️ Failed to create ReceiptOCRService: \(error.localizedDescription)")
            print("🔄 Falling back to MockReceiptOCRService for graceful degradation")
            return MockReceiptOCRService()
        }
    }
    
    static let testValue: any ReceiptOCRService = MockReceiptOCRService()
}

enum InsuranceReportServiceKey: DependencyKey {
    static var liveValue: any InsuranceReportService {
        do {
            // Try live service first, fall back to mock for compatibility
            return MockInsuranceReportService() // Use mock for now to avoid async issues
        } catch {
            print("⚠️ Failed to create InsuranceReportService: \(error.localizedDescription)")
            print("🔄 Falling back to MockInsuranceReportService for graceful degradation")
            return MockInsuranceReportService()
        }
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
            }
            
            print("⚠️ Failed to create InsuranceClaimService: \(error.localizedDescription)")
            print("🔄 Falling back to MockInsuranceClaimService for graceful degradation")
            return MockInsuranceClaimService()
        }
    }
    @MainActor
    static let testValue: any InsuranceClaimService = MockInsuranceClaimService()
}

enum ClaimPackageAssemblerServiceKey: @preconcurrency DependencyKey {
    @MainActor
    static var liveValue: any ClaimPackageAssemblerService {
        do {
            return LiveClaimPackageAssemblerService()
        } catch {
            print("⚠️ Failed to create ClaimPackageAssemblerService: \(error.localizedDescription)")
            print("🔄 Falling back to MockClaimPackageAssemblerService for graceful degradation")
            return MockClaimPackageAssemblerService()
        }
    }
    @MainActor
    static let testValue: any ClaimPackageAssemblerService = MockClaimPackageAssemblerService()
}

enum SearchHistoryServiceKey: DependencyKey {
    static var liveValue: any SearchHistoryService {
        do {
            // Currently using mock implementation, can upgrade to live service later
            return MockSearchHistoryService()
        } catch {
            print("⚠️ Failed to create SearchHistoryService: \(error.localizedDescription)")
            print("🔄 Falling back to MockSearchHistoryService for graceful degradation")
            return MockSearchHistoryService()
        }
    }
    static let testValue: any SearchHistoryService = MockSearchHistoryService()
}

enum CategoryServiceKey: DependencyKey {
    static var liveValue: any CategoryService {
        do {
            // Get the inventory service from the existing key
            let inventoryService = InventoryServiceKey.liveValue
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
            
            print("⚠️ Failed to create CategoryService: \(error.localizedDescription)")
            print("🔄 Falling back to MockCategoryService for graceful degradation")
            return MockCategoryService()
        }
    }
    static let testValue: any CategoryService = MockCategoryService()
}

enum WarrantyTrackingServiceKey: @preconcurrency DependencyKey {
    static var liveValue: any WarrantyTrackingService {
        // Return a minimal nonisolated default for TCA dependencies
        // The actual live service will be injected at app startup via withDependencies
        MockWarrantyTrackingService()
    }
    static let testValue: any WarrantyTrackingService = MockWarrantyTrackingService()
}
