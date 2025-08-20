// Layer: Tests
// Module: TestSupport
// Purpose: Service mocks for testing

import CloudKit
import ComposableArchitecture
import Foundation
import SwiftData
import UIKit

@testable import Nestory

public final class TestAuthService: AuthService {
    public var authenticateCalled = false
    public var authenticateResult: Result<AuthCredentials, Error>?

    public var validateBiometricCalled = false
    public var validateBiometricResult: Result<Bool, Error> = .success(true)

    public var signInCalled = false
    public var signInProvider: AuthProvider?
    public var signInResult: Result<AuthCredentials, Error>?

    public var signOutCalled = false
    public var signOutResult: Result<Void, Error> = .success(())

    public var refreshTokenCalled = false
    public var refreshTokenInput: String?
    public var refreshTokenResult: Result<AuthCredentials, Error>?

    public var currentUserCalled = false
    public var currentUserResult: AuthCredentials?

    public init() {}

    public func authenticate() async throws -> AuthCredentials {
        authenticateCalled = true
        if let result = authenticateResult {
            return try result.get()
        }
        return TestData.authCredentials
    }

    public func validateBiometric() async throws -> Bool {
        validateBiometricCalled = true
        return try validateBiometricResult.get()
    }

    public func signIn(with provider: AuthProvider) async throws -> AuthCredentials {
        signInCalled = true
        signInProvider = provider
        if let result = signInResult {
            return try result.get()
        }
        return TestData.authCredentials
    }

    public func signOut() async throws {
        signOutCalled = true
        try signOutResult.get()
    }

    public func refreshToken(_ token: String) async throws -> AuthCredentials {
        refreshTokenCalled = true
        refreshTokenInput = token
        if let result = refreshTokenResult {
            return try result.get()
        }
        return TestData.authCredentials
    }

    public func currentUser() async -> AuthCredentials? {
        currentUserCalled = true
        return currentUserResult
    }
}

public final class TestInventoryService: InventoryService {
    public var fetchItemsCalled = false
    public var fetchItemsResult: Result<[Item], Error> = .success([])

    public var fetchItemCalled = false
    public var fetchItemId: UUID?
    public var fetchItemResult: Item?

    public var saveItemCalled = false
    public var savedItem: Item?
    public var saveItemResult: Result<Void, Error> = .success(())

    public var updateItemCalled = false
    public var updatedItem: Item?
    public var updateItemResult: Result<Void, Error> = .success(())

    public var deleteItemCalled = false
    public var deletedItemId: UUID?
    public var deleteItemResult: Result<Void, Error> = .success(())

    public var searchItemsCalled = false
    public var searchQuery: String?
    public var searchItemsResult: Result<[Item], Error> = .success([])

    public init() {}

    public func fetchItems() async throws -> [Item] {
        fetchItemsCalled = true
        return try fetchItemsResult.get()
    }

    public func fetchItem(id: UUID) async throws -> Item? {
        fetchItemCalled = true
        fetchItemId = id
        return fetchItemResult
    }

    public func saveItem(_ item: Item) async throws {
        saveItemCalled = true
        savedItem = item
        try saveItemResult.get()
    }

    public func updateItem(_ item: Item) async throws {
        updateItemCalled = true
        updatedItem = item
        try updateItemResult.get()
    }

    public func deleteItem(id: UUID) async throws {
        deleteItemCalled = true
        deletedItemId = id
        try deleteItemResult.get()
    }

    public func searchItems(query: String) async throws -> [Item] {
        searchItemsCalled = true
        searchQuery = query
        return try searchItemsResult.get()
    }

    public func fetchCategories() async throws -> [Category] { [] }
    public func saveCategory(_: Category) async throws {}
    public func assignItemToCategory(itemId _: UUID, categoryId _: UUID) async throws {}
    public func fetchItemsByCategory(categoryId _: UUID) async throws -> [Item] { [] }
    public func bulkImport(items _: [Item]) async throws {}
    public func exportInventory(format _: ExportFormat) async throws -> Data { Data() }
}

public final class TestSyncService: SyncService {
    public var setupCloudKitCalled = false
    public var setupCloudKitResult: Result<Void, Error> = .success(())

    public var syncInventoryCalled = false
    public var syncInventoryResult: Result<SyncResult, Error> = .success(
        SyncResult(pushedCount: 0, pulledCount: 0, conflictsResolved: 0, timestamp: Date()),
    )

    public var pushChangesCalled = false
    public var pushedChanges: [SyncChange] = []

    public var pullChangesCalled = false
    public var pullChangesSince: Date?
    public var pullChangesResult: Result<[SyncChange], Error> = .success([])

    public init() {}

    public func setupCloudKit() async throws {
        setupCloudKitCalled = true
        try setupCloudKitResult.get()
    }

    public func syncInventory() async throws -> SyncResult {
        syncInventoryCalled = true
        return try syncInventoryResult.get()
    }

    public func pushChanges(_ changes: [SyncChange]) async throws {
        pushChangesCalled = true
        pushedChanges = changes
    }

    public func pullChanges(since date: Date?) async throws -> [SyncChange] {
        pullChangesCalled = true
        pullChangesSince = date
        return try pullChangesResult.get()
    }

    public func resolveConflicts(_: [SyncConflict]) async throws {}
    public func createSubscription(for _: String) async throws {}
    public func fetchUserRecordID() async throws -> CKRecord.ID {
        CKRecord.ID(recordName: "test-user")
    }
}

public final class TestAnalyticsService: AnalyticsService {
    public var calculateTotalValueCalled = false
    public var calculateTotalValueItems: [Item] = []
    public var calculateTotalValueResult: Decimal = 0

    public var trackEventCalled = false
    public var trackedEvents: [AnalyticsEvent] = []

    public init() {}

    public func calculateTotalValue(for items: [Item]) async -> Decimal {
        calculateTotalValueCalled = true
        calculateTotalValueItems = items
        return calculateTotalValueResult
    }

    public func calculateCategoryBreakdown(for _: [Item]) async -> [CategoryBreakdown] { [] }
    public func calculateValueTrends(for _: [Item], period _: TrendPeriod) async -> [TrendPoint] { [] }
    public func calculateTopItems(from _: [Item], limit _: Int) async -> [Item] { [] }
    public func calculateDepreciation(for _: [Item]) async -> [DepreciationReport] { [] }

    public func generateDashboard(for items: [Item]) async -> DashboardData {
        DashboardData(
            totalItems: items.count,
            totalValue: calculateTotalValueResult,
            categoryBreakdown: [],
            topValueItems: [],
            recentItems: [],
            valueTrends: [],
            totalDepreciation: 0,
            lastUpdated: Date(),
        )
    }

    public func trackEvent(_ event: AnalyticsEvent) async {
        trackEventCalled = true
        trackedEvents.append(event)
    }
}

public final class TestCurrencyService: CurrencyService {
    public var convertCalled = false
    public var convertAmount: Decimal?
    public var convertFrom: String?
    public var convertTo: String?
    public var convertResult: Result<Decimal, Error> = .success(100)

    public var updateRatesCalled = false
    public var updateRatesResult: Result<Void, Error> = .success(())

    public init() {}

    public func convert(amount: Decimal, from: String, to: String) async throws -> Decimal {
        convertCalled = true
        convertAmount = amount
        convertFrom = from
        convertTo = to
        return try convertResult.get()
    }

    public func updateRates() async throws {
        updateRatesCalled = true
        try updateRatesResult.get()
    }

    public func getRate(from _: String, to _: String) async throws -> Decimal { 1.0 }
    public func getSupportedCurrencies() async -> [Currency] { [] }
    public func getHistoricalRate(from _: String, to _: String, date _: Date) async throws -> Decimal? { 1.0 }
}

// MARK: - UI Service Mocks

public final class TestCloudBackupService: ObservableObject {
    @Published public var isBackupEnabled = false
    @Published public var lastBackupDate: Date?
    @Published public var backupStatus: BackupStatus = .idle

    public var startBackupCalled = false
    public var restoreFromBackupCalled = false
    public var enableBackupCalled = false
    public var disableBackupCalled = false

    public init() {}

    public func startBackup() async {
        startBackupCalled = true
        backupStatus = .inProgress
        // Simulate backup process
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        backupStatus = .completed
        lastBackupDate = Date()
    }

    public func restoreFromBackup() async {
        restoreFromBackupCalled = true
        backupStatus = .inProgress
        try? await Task.sleep(nanoseconds: 100_000_000)
        backupStatus = .completed
    }

    public func enableBackup() {
        enableBackupCalled = true
        isBackupEnabled = true
    }

    public func disableBackup() {
        disableBackupCalled = true
        isBackupEnabled = false
    }
}

public final class TestNotificationService: ObservableObject {
    @Published public var areNotificationsEnabled = false
    @Published public var warrantyNotificationsEnabled = true
    @Published public var maintenanceNotificationsEnabled = true

    public var requestPermissionCalled = false
    public var scheduleWarrantyNotificationCalled = false
    public var cancelNotificationCalled = false

    public init() {}

    public func requestPermission() async {
        requestPermissionCalled = true
        areNotificationsEnabled = true
    }

    public func scheduleWarrantyNotification(for _: Item) {
        scheduleWarrantyNotificationCalled = true
    }

    public func cancelNotification(for _: UUID) {
        cancelNotificationCalled = true
    }
}

public final class TestReceiptOCRService: ObservableObject {
    @Published public var isProcessing = false

    public var extractTextCalled = false
    public var extractedText = "Mock receipt text\nTotal: $99.99\nDate: 2024-01-15"

    public init() {}

    public func extractText(from _: Data) async throws -> String {
        extractTextCalled = true
        isProcessing = true

        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

        isProcessing = false
        return extractedText
    }
}

public final class TestBarcodeScannerService: ObservableObject {
    @Published public var isScanning = false
    @Published public var scannedCode: String?

    public var startScanningSampledCalled = false
    public var stopScanningCalled = false
    public var mockScanResult = "1234567890123"

    public init() {}

    public func startScanning() {
        startScanningSampledCalled = true
        isScanning = true

        // Simulate finding a barcode after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.scannedCode = self.mockScanResult
            self.isScanning = false
        }
    }

    public func stopScanning() {
        stopScanningCalled = true
        isScanning = false
    }
}

public final class TestInsuranceReportService: ObservableObject {
    @Published public var isGenerating = false

    public var generatePDFCalled = false
    public var generateHTMLCalled = false
    public var exportFormatCalled = false

    public init() {}

    public func generatePDF(for _: [Item]) async throws -> Data {
        generatePDFCalled = true
        isGenerating = true

        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

        isGenerating = false
        return Data("Mock PDF data".utf8)
    }

    public func generateHTML(for _: [Item]) async throws -> String {
        generateHTMLCalled = true
        isGenerating = true

        try? await Task.sleep(nanoseconds: 500_000_000)

        isGenerating = false
        return "<html><body><h1>Insurance Report</h1></body></html>"
    }

    public func exportToFormat(_ format: ExportFormat, items: [Item]) async throws -> Data {
        exportFormatCalled = true

        switch format {
        case .pdf:
            return try await generatePDF(for: items)
        case .html:
            return try await Data(generateHTML(for: items).utf8)
        case .json:
            return Data("{}".utf8)
        case .csv:
            return Data("Name,Price,Quantity\nTest Item,99.99,1".utf8)
        }
    }
}

public final class TestImportExportService: ObservableObject {
    @Published public var isImporting = false
    @Published public var isExporting = false

    public var importDataCalled = false
    public var exportDataCalled = false
    public var exportFormat: ExportFormat?

    public init() {}

    public func importData(from _: Data, format _: ImportFormat) async throws -> ImportResult {
        importDataCalled = true
        isImporting = true

        try? await Task.sleep(nanoseconds: 500_000_000)

        isImporting = false
        return ImportResult(
            itemsImported: 5,
            categoriesImported: 2,
            errors: [],
            warnings: [],
        )
    }

    public func exportData(items _: [Item], format: ExportFormat) async throws -> Data {
        exportDataCalled = true
        exportFormat = format
        isExporting = true

        try? await Task.sleep(nanoseconds: 500_000_000)

        isExporting = false

        switch format {
        case .json:
            return Data("[]".utf8)
        case .csv:
            return Data("Name,Price,Quantity".utf8)
        case .pdf:
            return Data("PDF data".utf8)
        case .html:
            return Data("<html></html>".utf8)
        }
    }
}

// MARK: - Mock Data and Enums

public enum BackupStatus {
    case idle
    case inProgress
    case completed
    case failed
}

public enum ExportFormat {
    case json
    case csv
    case pdf
    case html
}

public enum ImportFormat {
    case json
    case csv
}

public struct ImportResult {
    public let itemsImported: Int
    public let categoriesImported: Int
    public let errors: [String]
    public let warnings: [String]

    public init(itemsImported: Int, categoriesImported: Int, errors: [String], warnings: [String]) {
        self.itemsImported = itemsImported
        self.categoriesImported = categoriesImported
        self.errors = errors
        self.warnings = warnings
    }
}

public enum TestData {
    public static let authCredentials = AuthCredentials(
        userId: "test-user-123",
        accessToken: "test-access-token",
        refreshToken: "test-refresh-token",
        expiresAt: Date().addingTimeInterval(3600),
        provider: .demo,
    )

    public static func makeItem(
        id _: UUID = UUID(),
        name: String = "Test Item",
        purchasePrice: Decimal? = 99.99,
        quantity: Int = 1,
    ) -> Item {
        let item = Item(name: name)
        item.purchasePrice = purchasePrice
        item.quantity = quantity
        return item
    }

    public static func makeCategory(name: String = "Test Category") -> Category {
        Category(name: name)
    }

    public static func makeCompleteItem(name: String = "Complete Test Item") -> Item {
        let category = Category(name: "Test Electronics")

        let item = Item(name: name)
        item.itemDescription = "A comprehensive test item with all fields populated"
        item.quantity = 1
        item.category = category
        item.brand = "Test Brand"
        item.modelNumber = "TEST-123"
        item.serialNumber = "ABC123456789"
        item.purchasePrice = Decimal(999.99)
        item.purchaseDate = Date(timeIntervalSinceReferenceDate: 694_224_000) // Fixed date
        item.condition = .excellent
        item.conditionNotes = "Perfect condition"
        item.notes = "Important test item"
        item.warrantyExpirationDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())
        item.room = "Test Room"
        item.specificLocation = "Test Location"

        // Mock binary data
        item.imageData = Data([0x89, 0x50, 0x4E, 0x47]) // PNG header
        item.receiptImageData = Data([0x89, 0x50, 0x4E, 0x47])
        item.extractedReceiptText = "Test Store\nTotal: $999.99"
        item.conditionPhotos = [Data([0x01, 0x02]), Data([0x03, 0x04])]
        item.documentNames = ["manual.pdf", "warranty.pdf"]

        return item
    }

    public static func makeSampleItems(count: Int = 5) -> [Item] {
        let categories = ["Electronics", "Furniture", "Clothing", "Books", "Kitchen"]
        let brands = ["Apple", "Samsung", "IKEA", "Herman Miller", "Patagonia"]
        let conditions: [ItemCondition] = [.excellent, .good, .fair, .poor]

        return (1 ... count).map { i in
            let item = Item(name: "Sample Item \(i)")
            item.itemDescription = "Description for sample item \(i)"
            item.quantity = i % 3 + 1
            item.brand = brands[i % brands.count]
            item.purchasePrice = Decimal(Double(i * 50) + 99.99)
            item.condition = conditions[i % conditions.count]
            item.notes = "Notes for item \(i)"

            // Create and assign category
            let category = Category(name: categories[i % categories.count])
            item.category = category

            return item
        }
    }
}
