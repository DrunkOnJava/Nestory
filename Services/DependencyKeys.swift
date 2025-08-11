// Layer: Services
// Module: Services
// Purpose: TCA dependency keys for all services

import ComposableArchitecture
import Foundation
import SwiftData

private enum AuthServiceKey: DependencyKey {
    static let liveValue: AuthService = LiveAuthService()
    static let testValue: AuthService = MockAuthService()
}

private enum InventoryServiceKey: DependencyKey {
    static var liveValue: InventoryService {
        do {
            let container = try ModelContainer(for: Item.self, Category.self)
            return try LiveInventoryService(modelContext: container.mainContext)
        } catch {
            fatalError("Failed to create InventoryService: \(error)")
        }
    }

    static let testValue: InventoryService = MockInventoryService()
}

private enum PhotoIntegrationServiceKey: DependencyKey {
    static let liveValue: PhotoIntegrationService = LivePhotoIntegrationService()
    static let testValue: PhotoIntegrationService = MockPhotoIntegrationService()
}

private enum ExportServiceKey: DependencyKey {
    static var liveValue: ExportService {
        do {
            return try LiveExportService()
        } catch {
            fatalError("Failed to create ExportService: \(error)")
        }
    }

    static let testValue: ExportService = MockExportService()
}

private enum SyncServiceKey: DependencyKey {
    static let liveValue: SyncService = LiveSyncService()
    static let testValue: SyncService = MockSyncService()
}

private enum AnalyticsServiceKey: DependencyKey {
    static var liveValue: AnalyticsService {
        do {
            let currencyService = try LiveCurrencyService()
            return try LiveAnalyticsService(currencyService: currencyService)
        } catch {
            fatalError("Failed to create AnalyticsService: \(error)")
        }
    }

    static let testValue: AnalyticsService = MockAnalyticsService()
}

private enum CurrencyServiceKey: DependencyKey {
    static var liveValue: CurrencyService {
        do {
            return try LiveCurrencyService()
        } catch {
            fatalError("Failed to create CurrencyService: \(error)")
        }
    }

    static let testValue: CurrencyService = MockCurrencyService()
}

public extension DependencyValues {
    var authService: AuthService {
        get { self[AuthServiceKey.self] }
        set { self[AuthServiceKey.self] = newValue }
    }

    var inventoryService: InventoryService {
        get { self[InventoryServiceKey.self] }
        set { self[InventoryServiceKey.self] = newValue }
    }

    var photoIntegrationService: PhotoIntegrationService {
        get { self[PhotoIntegrationServiceKey.self] }
        set { self[PhotoIntegrationServiceKey.self] = newValue }
    }

    var exportService: ExportService {
        get { self[ExportServiceKey.self] }
        set { self[ExportServiceKey.self] = newValue }
    }

    var syncService: SyncService {
        get { self[SyncServiceKey.self] }
        set { self[SyncServiceKey.self] = newValue }
    }

    var analyticsService: AnalyticsService {
        get { self[AnalyticsServiceKey.self] }
        set { self[AnalyticsServiceKey.self] = newValue }
    }

    var currencyService: CurrencyService {
        get { self[CurrencyServiceKey.self] }
        set { self[CurrencyServiceKey.self] = newValue }
    }
}

struct MockAuthService: AuthService {
    func authenticate() async throws -> AuthCredentials {
        AuthCredentials(
            userId: "test-user",
            accessToken: "test-token",
            refreshToken: "test-refresh",
            expiresAt: Date().addingTimeInterval(3600),
            provider: .demo,
        )
    }

    func validateBiometric() async throws -> Bool { true }

    func signIn(with provider: AuthProvider) async throws -> AuthCredentials {
        AuthCredentials(
            userId: "test-user",
            accessToken: "test-token",
            refreshToken: "test-refresh",
            expiresAt: Date().addingTimeInterval(3600),
            provider: provider,
        )
    }

    func signOut() async throws {}

    func refreshToken(_: String) async throws -> AuthCredentials {
        AuthCredentials(
            userId: "test-user",
            accessToken: "new-token",
            refreshToken: "new-refresh",
            expiresAt: Date().addingTimeInterval(3600),
            provider: .demo,
        )
    }

    func currentUser() async -> AuthCredentials? { nil }
}

struct MockInventoryService: InventoryService {
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

struct MockPhotoIntegrationService: PhotoIntegrationService {
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
                orientation: .up,
            ),
        )
    }

    func extractText(from _: UIImage) async throws -> [String] { [] }
    func detectObjects(in _: UIImage) async throws -> [DetectedObject] { [] }
    func generateThumbnail(from image: UIImage, size _: CGSize) async throws -> UIImage { image }
    func saveToPhotoLibrary(_: UIImage) async throws {}
    func loadFromPhotoLibrary(identifier _: String) async throws -> UIImage? { nil }
}

struct MockExportService: ExportService {
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
                checksum: nil,
            ),
            items: [],
            images: [],
        )
    }

    func restoreBackup(from _: BackupPackage) async throws -> [Item] { [] }
}

struct MockSyncService: SyncService {
    func setupCloudKit() async throws {}
    func syncInventory() async throws -> SyncResult {
        SyncResult(
            pushedCount: 0,
            pulledCount: 0,
            conflictsResolved: 0,
            timestamp: Date(),
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

struct MockAnalyticsService: AnalyticsService {
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
            topValueItems: [],
            recentItems: [],
            valueTrends: [],
            totalDepreciation: 0,
            lastUpdated: Date(),
        )
    }

    func trackEvent(_: AnalyticsEvent) async {}
}

struct MockCurrencyService: CurrencyService {
    func convert(amount: Decimal, from _: String, to _: String) async throws -> Decimal { amount }
    func updateRates() async throws {}
    func getRate(from _: String, to _: String) async throws -> Decimal { 1 }
    func getSupportedCurrencies() async -> [Currency] { [] }
    func getHistoricalRate(from _: String, to _: String, date _: Date) async throws -> Decimal? { 1 }
}
