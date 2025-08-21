// Layer: Services
// Module: Services
// Purpose: TCA dependency keys for all services

import ComposableArchitecture
import Foundation
import SwiftData
import UIKit
import CloudKit

private enum AuthServiceKey: DependencyKey {
    static let liveValue: any AuthService = LiveAuthService()
    static let testValue: any AuthService = MockAuthService()
}

private enum InventoryServiceKey: @preconcurrency DependencyKey {
    @MainActor
    static var liveValue: any InventoryService {
        do {
            let container = try ModelContainer(for: Item.self, Category.self)
            return try LiveInventoryService(modelContext: container.mainContext)
        } catch {
            fatalError("Failed to create InventoryService: \(error)")
        }
    }

    static let testValue: any InventoryService = MockInventoryService()
}

private enum PhotoIntegrationServiceKey: DependencyKey {
    static let liveValue: any PhotoIntegrationService = LivePhotoIntegrationService()
    static let testValue: any PhotoIntegrationService = MockPhotoIntegrationService()
}

private enum ExportServiceKey: DependencyKey {
    static var liveValue: any ExportService {
        do {
            return try LiveExportService()
        } catch {
            fatalError("Failed to create ExportService: \(error)")
        }
    }

    static let testValue: any ExportService = MockExportService()
}

private enum SyncServiceKey: DependencyKey {
    static let liveValue: any SyncService = LiveSyncService()
    static let testValue: any SyncService = MockSyncService()
}

private enum AnalyticsServiceKey: DependencyKey {
    static var liveValue: any AnalyticsService {
        do {
            let currencyService = try LiveCurrencyService()
            return try LiveAnalyticsService(currencyService: currencyService)
        } catch {
            fatalError("Failed to create AnalyticsService: \(error)")
        }
    }

    static let testValue: any AnalyticsService = MockAnalyticsService()
}

private enum CurrencyServiceKey: DependencyKey {
    static var liveValue: any CurrencyService {
        do {
            return try LiveCurrencyService()
        } catch {
            fatalError("Failed to create CurrencyService: \(error)")
        }
    }

    static let testValue: any CurrencyService = MockCurrencyService()
}

private enum BarcodeScannerServiceKey: DependencyKey {
    static let liveValue: any BarcodeScannerService = LiveBarcodeScannerService()
    static let testValue: any BarcodeScannerService = MockBarcodeScannerService()
}

private enum NotificationServiceKey: DependencyKey {
    static var liveValue: any NotificationService {
        do {
            return try LiveNotificationService()
        } catch {
            fatalError("Failed to create NotificationService: \(error)")
        }
    }

    static let testValue: any NotificationService = MockNotificationService()
}

private enum ImportExportServiceKey: DependencyKey {
    static var liveValue: any ImportExportService {
        do {
            return try LiveImportExportService()
        } catch {
            fatalError("Failed to create ImportExportService: \(error)")
        }
    }

    static let testValue: any ImportExportService = MockImportExportService()
}

private enum CloudBackupServiceKey: DependencyKey {
    static var liveValue: any CloudBackupService {
        do {
            return try LiveCloudBackupService()
        } catch {
            fatalError("Failed to create CloudBackupService: \(error)")
        }
    }

    static let testValue: any CloudBackupService = MockCloudBackupService()
}

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
}

struct MockAuthService: AuthService, Sendable {
    func authenticate() async throws -> AuthCredentials {
        AuthCredentials(
            userId: "test-user",
            accessToken: "test-token",
            refreshToken: "test-refresh",
            expiresAt: Date().addingTimeInterval(3600),
            provider: .demo
        )
    }

    func validateBiometric() async throws -> Bool { true }

    func signIn(with provider: AuthProvider) async throws -> AuthCredentials {
        AuthCredentials(
            userId: "test-user",
            accessToken: "test-token",
            refreshToken: "test-refresh",
            expiresAt: Date().addingTimeInterval(3600),
            provider: provider
        )
    }

    func signOut() async throws {}

    func refreshToken(_: String) async throws -> AuthCredentials {
        AuthCredentials(
            userId: "test-user",
            accessToken: "new-token",
            refreshToken: "new-refresh",
            expiresAt: Date().addingTimeInterval(3600),
            provider: .demo
        )
    }

    func currentUser() async -> AuthCredentials? { nil }
}

struct MockInventoryService: InventoryService, Sendable {
    func fetchItems() async throws -> [Item] { [] }
    func fetchItem(id _: UUID) async throws -> Item? { nil }
    func saveItem(_: Item) async throws {}
    func updateItem(_: Item) async throws {}
    func deleteItem(id _: UUID) async throws {}
    func searchItems(query _: String) async throws -> [Item] { [] }
    func fetchCategories() async throws -> [Category] { [] }
    func saveCategory(_: Category) async throws {}
    func assignItemToCategory(itemId _: UUID, categoryId _: UUID) async throws {}
    func fetchItemsByCategory(categoryId _: UUID) async throws -> [Item] { [] }
    func bulkImport(items _: [Item]) async throws {}
    func exportInventory(format _: ExportFormat) async throws -> Data { Data() }
}

struct MockPhotoIntegrationService: PhotoIntegrationService, Sendable {
    func capturePhoto() async throws -> UIImage { UIImage() }
    func processPhoto(_ image: UIImage) async throws -> ProcessedPhoto {
        ProcessedPhoto(
            original: image,
            thumbnail: image,
            perceptualHash: 0,
            extractedText: [],
            detectedObjects: [],
            metadata: ImageMetadata(
                width: 100,
                height: 100,
                captureDate: Date(),
                cameraModel: nil,
                lensMake: nil,
                latitude: nil,
                longitude: nil,
                orientation: .up
            )
        )
    }

    func extractText(from _: UIImage) async throws -> [String] { [] }
    func detectObjects(in _: UIImage) async throws -> [DetectedObject] { [] }
    func generateThumbnail(from image: UIImage, size _: CGSize) async throws -> UIImage { image }
    func saveToPhotoLibrary(_: UIImage) async throws {}
    func loadFromPhotoLibrary(identifier _: String) async throws -> UIImage? { nil }
}

struct MockExportService: ExportService, Sendable {
    func exportToCSV(_: [some Encodable]) async throws -> Data { Data() }
    func exportToJSON(_: [some Encodable]) async throws -> Data { Data() }
    func exportToPDF(_: ExportData) async throws -> Data { Data() }
    func createBackup(inventory _: [Item]) async throws -> BackupPackage {
        BackupPackage(
            metadata: BackupMetadata(
                version: "1.0",
                createdAt: Date(),
                deviceName: "Test",
                itemCount: 0,
                checksum: nil
            ),
            items: [],
            images: []
        )
    }

    func restoreBackup(from _: BackupPackage) async throws -> [Item] { [] }
}

struct MockSyncService: SyncService, Sendable {
    func setupCloudKit() async throws {}
    func syncInventory() async throws -> SyncResult {
        SyncResult(
            pushedCount: 0,
            pulledCount: 0,
            conflictsResolved: 0,
            timestamp: Date()
        )
    }

    func pushChanges(_: [SyncChange]) async throws {}
    func pullChanges(since _: Date?) async throws -> [SyncChange] { [] }
    func resolveConflicts(_: [SyncConflict]) async throws {}
    func createSubscription(for _: String) async throws {}
    func fetchUserRecordID() async throws -> CKRecord.ID {
        CKRecord.ID(recordName: "test-user")
    }
}

struct MockAnalyticsService: AnalyticsService, Sendable {
    func calculateTotalValue(for _: [Item]) async -> Decimal { 0 }
    func calculateCategoryBreakdown(for _: [Item]) async -> [CategoryBreakdown] { [] }
    func calculateValueTrends(for _: [Item], period _: TrendPeriod) async -> [TrendPoint] { [] }
    func calculateTopItems(from _: [Item], limit _: Int) async -> [Item] { [] }
    func calculateDepreciation(for _: [Item]) async -> [DepreciationReport] { [] }
    func generateDashboard(for _: [Item]) async -> DashboardData {
        DashboardData(
            totalItems: 0,
            totalValue: 0,
            categoryBreakdown: [],
            topValueItemIds: [],
            recentItemIds: [],
            valueTrends: [],
            totalDepreciation: 0,
            lastUpdated: Date()
        )
    }

    func trackEvent(_: AnalyticsEvent) async {}
}

struct MockCurrencyService: CurrencyService, Sendable {
    func convert(amount: Decimal, from _: String, to _: String) async throws -> Decimal { amount }
    func updateRates() async throws {}
    func getRate(from _: String, to _: String) async throws -> Decimal { 1 }
    func getSupportedCurrencies() async -> [Currency] { [] }
    func getHistoricalRate(from _: String, to _: String, date _: Date) async throws -> Decimal? { 1 }
}

struct MockBarcodeScannerService: BarcodeScannerService, Sendable {
    func scanBarcode(from _: Data) async throws -> BarcodeResult {
        BarcodeResult(
            barcode: "123456789",
            format: .upca,
            detectedAt: Date(),
            confidence: 0.95
        )
    }

    func scanBarcode(using _: ScanMethod) async throws -> BarcodeResult {
        BarcodeResult(
            barcode: "123456789",
            format: .upca,
            detectedAt: Date(),
            confidence: 0.95
        )
    }

    func checkCameraPermission() async -> Bool { true }
    func requestCameraPermission() async -> Bool { true }
}

struct MockNotificationService: NotificationService {
    func scheduleNotification(_: PendingNotification) async throws {}
    func cancelNotification(withId _: String) async throws {}
    func cancelAllNotifications() async throws {}
    func getPendingNotifications() async throws -> [PendingNotification] { [] }
    func getDeliveredNotifications() async throws -> [DeliveredNotification] { [] }
    func requestPermissions() async throws -> Bool { true }
    func getNotificationSettings() async throws -> NotificationSettings {
        NotificationSettings(
            authorizationStatus: .authorized,
            soundSetting: .enabled,
            badgeSetting: .enabled,
            alertSetting: .enabled,
            notificationCenterSetting: .enabled,
            lockScreenSetting: .enabled,
            carPlaySetting: .notSupported,
            alertStyle: .banner,
            showPreviewsSetting: .always,
            criticalAlertSetting: .notSupported,
            providesAppNotificationSettings: false,
            announcementSetting: .notSupported,
            timeSensitiveSetting: .notSupported,
            scheduledDeliverySetting: .enabled
        )
    }
}

struct MockImportExportService: ImportExportService {
    func exportItems(_: [Item], format _: ExportFormat) async throws -> Data {
        Data()
    }

    func importItems(from _: Data, format _: ImportFormat) async throws -> ImportResult {
        ImportResult(
            importedItems: [],
            skippedItems: [],
            errors: [],
            summary: ImportSummary(
                totalProcessed: 0,
                successful: 0,
                skipped: 0,
                failed: 0
            )
        )
    }

    func validateImportData(_: Data, format _: ImportFormat) async throws -> ValidationResult {
        ValidationResult(
            isValid: true,
            itemCount: 0,
            warnings: [],
            errors: []
        )
    }

    func getSupportedExportFormats() -> [ExportFormat] {
        [.csv, .json, .pdf]
    }

    func getSupportedImportFormats() -> [ImportFormat] {
        [.csv, .json]
    }
}

struct MockCloudBackupService: CloudBackupService {
    func enableCloudBackup() async throws {
        // Mock implementation
    }

    func disableCloudBackup() async throws {
        // Mock implementation
    }

    func performManualBackup() async throws -> BackupResult {
        BackupResult(
            success: true,
            itemCount: 0,
            dataSize: 0,
            timestamp: Date(),
            backupId: "mock-backup-id"
        )
    }

    func restoreFromBackup(backupId: String) async throws -> RestoreResult {
        RestoreResult(
            success: true,
            restoredItemCount: 0,
            timestamp: Date(),
            backupId: backupId
        )
    }

    func getBackupStatus() async throws -> BackupStatus {
        BackupStatus(
            isEnabled: false,
            lastBackupDate: nil,
            backupSize: 0,
            nextScheduledBackup: nil,
            isInProgress: false
        )
    }

    func getAvailableBackups() async throws -> [CloudBackup] {
        []
    }

    func deleteBackup(backupId _: String) async throws {
        // Mock implementation
    }

    func getBackupSettings() async throws -> BackupSettings {
        BackupSettings(
            automaticBackupEnabled: false,
            backupFrequency: .weekly,
            includePhotos: true,
            includeReceipts: true,
            wifiOnlyBackup: true
        )
    }

    func updateBackupSettings(_: BackupSettings) async throws {
        // Mock implementation
    }
}
