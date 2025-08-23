//
// Layer: Services
// Module: Services
// Purpose: TCA DependencyValues extensions for service access
//

import ComposableArchitecture

// MARK: - DependencyValues Extensions

extension DependencyValues {
    public var authService: any AuthService {
        get { self[AuthServiceKey.self] }
        set { self[AuthServiceKey.self] = newValue }
    }

    public var inventoryService: any InventoryService {
        get { self[InventoryServiceKey.self] }
        set { self[InventoryServiceKey.self] = newValue }
    }

    public var photoIntegrationService: any PhotoIntegrationService {
        get { self[PhotoIntegrationServiceKey.self] }
        set { self[PhotoIntegrationServiceKey.self] = newValue }
    }

    public var exportService: any ExportService {
        get { self[ExportServiceKey.self] }
        set { self[ExportServiceKey.self] = newValue }
    }

    public var syncService: any SyncService {
        get { self[SyncServiceKey.self] }
        set { self[SyncServiceKey.self] = newValue }
    }

    public var analyticsService: any AnalyticsService {
        get { self[AnalyticsServiceKey.self] }
        set { self[AnalyticsServiceKey.self] = newValue }
    }

    public var currencyService: any CurrencyService {
        get { self[CurrencyServiceKey.self] }
        set { self[CurrencyServiceKey.self] = newValue }
    }

    public var barcodeScannerService: any BarcodeScannerService {
        get { self[BarcodeScannerServiceKey.self] }
        set { self[BarcodeScannerServiceKey.self] = newValue }
    }

    public var notificationService: any NotificationService {
        get { self[NotificationServiceKey.self] }
        set { self[NotificationServiceKey.self] = newValue }
    }

    public var importExportService: any ImportExportService {
        get { self[ImportExportServiceKey.self] }
        set { self[ImportExportServiceKey.self] = newValue }
    }

    public var cloudBackupService: any CloudBackupService {
        get { self[CloudBackupServiceKey.self] }
        set { self[CloudBackupServiceKey.self] = newValue }
    }
    
    public var receiptOCRService: any ReceiptOCRService {
        get { self[ReceiptOCRServiceKey.self] }
        set { self[ReceiptOCRServiceKey.self] = newValue }
    }
    
    public var insuranceReportService: any InsuranceReportService {
        get { self[InsuranceReportServiceKey.self] }
        set { self[InsuranceReportServiceKey.self] = newValue }
    }
    
    public var insuranceClaimService: any InsuranceClaimService {
        get { self[InsuranceClaimServiceKey.self] }
        set { self[InsuranceClaimServiceKey.self] = newValue }
    }
    
    public var claimPackageAssemblerService: any ClaimPackageAssemblerService {
        get { self[ClaimPackageAssemblerServiceKey.self] }
        set { self[ClaimPackageAssemblerServiceKey.self] = newValue }
    }
    
    public var searchHistoryService: any SearchHistoryService {
        get { self[SearchHistoryServiceKey.self] }
        set { self[SearchHistoryServiceKey.self] = newValue }
    }
    
    public var warrantyTrackingService: any WarrantyTrackingService {
        get { self[WarrantyTrackingServiceKey.self] }
        set { self[WarrantyTrackingServiceKey.self] = newValue }
    }
}