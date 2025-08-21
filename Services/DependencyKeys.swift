// Layer: Services
// Module: Services
// Purpose: TCA dependency keys for all services

import ComposableArchitecture
import Foundation
import SwiftData
import UIKit
import CloudKit

private enum AuthServiceKey: @preconcurrency DependencyKey {
    @MainActor
    static let liveValue: any AuthService = LiveAuthService()
    @MainActor
    static let testValue: any AuthService = MockAuthService()
}

private enum InventoryServiceKey: @preconcurrency DependencyKey {
    @MainActor
    static var liveValue: any InventoryService {
        do {
            let container = try ModelContainer(for: Item.self, Category.self)
            return try LiveInventoryService(modelContext: container.mainContext)
        } catch {
            print("⚠️ Failed to create InventoryService: \(error)")
            print("🔄 Falling back to MockInventoryService for graceful degradation")
            return MockInventoryService()
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
            print("⚠️ Failed to create ExportService: \(error)")
            print("🔄 Falling back to MockExportService for graceful degradation")
            return MockExportService()
        }
    }

    static let testValue: any ExportService = MockExportService()
}

private enum SyncServiceKey: @preconcurrency DependencyKey {
    @MainActor
    static let liveValue: any SyncService = LiveSyncService()
    @MainActor
    static let testValue: any SyncService = MockSyncService()
}

private enum AnalyticsServiceKey: @preconcurrency DependencyKey {
    @MainActor
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

    @MainActor
    static let testValue: any AnalyticsService = MockAnalyticsService()
}

private enum CurrencyServiceKey: DependencyKey {
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

private enum BarcodeScannerServiceKey: @preconcurrency DependencyKey {
    @MainActor
    static let liveValue: any BarcodeScannerService = LiveBarcodeScannerService()
    @MainActor
    static let testValue: any BarcodeScannerService = MockBarcodeScannerService()
}

private enum NotificationServiceKey: @preconcurrency DependencyKey {
    @MainActor
    static var liveValue: any NotificationService {
        do {
            return try LiveNotificationService()
        } catch {
            print("⚠️ Failed to create NotificationService: \(error)")
            print("🔄 Falling back to MockNotificationService for graceful degradation")
            return MockNotificationService()
        }
    }

    @MainActor
    static let testValue: any NotificationService = MockNotificationService()
}

private enum ImportExportServiceKey: @preconcurrency DependencyKey {
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

private enum CloudBackupServiceKey: @preconcurrency DependencyKey {
    @MainActor
    static var liveValue: any CloudBackupService {
        LiveCloudBackupService()
    }

    @MainActor
    static let testValue: any CloudBackupService = MockCloudBackupService()
}

private enum ReceiptOCRServiceKey: @preconcurrency DependencyKey {
    static var liveValue: any ReceiptOCRService {
        LiveReceiptOCRService()
    }
    
    static let testValue: any ReceiptOCRService = MockReceiptOCRService()
}

private enum InsuranceReportServiceKey: DependencyKey {
    static var liveValue: any InsuranceReportService {
        do {
            return try LiveInsuranceReportService()
        } catch {
            print("⚠️ Failed to create InsuranceReportService: \(error)")
            print("🔄 Falling back to MockInsuranceReportService for graceful degradation")
            return MockInsuranceReportService()
        }
    }
    
    static let testValue: any InsuranceReportService = MockInsuranceReportService()
}

private enum InsuranceClaimServiceKey: @preconcurrency DependencyKey {
    @MainActor
    static let liveValue: any InsuranceClaimService = LiveInsuranceClaimService()
    @MainActor
    static let testValue: any InsuranceClaimService = MockInsuranceClaimService()
}

private enum ClaimPackageAssemblerServiceKey: @preconcurrency DependencyKey {
    @MainActor
    static let liveValue: any ClaimPackageAssemblerService = LiveClaimPackageAssemblerService()
    @MainActor
    static let testValue: any ClaimPackageAssemblerService = MockClaimPackageAssemblerService()
}

private enum SearchHistoryServiceKey: DependencyKey {
    static let liveValue: any SearchHistoryService = MockSearchHistoryService()
    static let testValue: any SearchHistoryService = MockSearchHistoryService()
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
}

struct MockAuthService: AuthService, Sendable {
    var isAuthenticated: Bool {
        get async { false }
    }
    
    var currentUser: AuthUser? {
        get async { nil }
    }
    
    func signIn(email: String, password: String) async throws -> AuthUser {
        AuthUser(
            id: "mock-user-id",
            email: email,
            displayName: "Mock User",
            isEmailVerified: true,
            createdAt: Date(),
            lastSignInAt: Date(),
            subscriptionLevel: .free
        )
    }
    
    func signUp(email: String, password: String, displayName: String) async throws -> AuthUser {
        AuthUser(
            id: "mock-new-user-id",
            email: email,
            displayName: displayName,
            isEmailVerified: false,
            createdAt: Date(),
            lastSignInAt: nil,
            subscriptionLevel: .free
        )
    }
    
    func signOut() async throws {
        // Mock implementation
    }
    
    func refreshToken() async throws -> AuthToken {
        AuthToken(
            accessToken: "mock-refreshed-token",
            refreshToken: "mock-refresh-token",
            expiresAt: Date().addingTimeInterval(3600),
            tokenType: "Bearer"
        )
    }
    
    func hasPremiumAccess() async throws -> Bool {
        false
    }
    
    func verifyEmail() async throws {
        // Mock implementation
    }
    
    func resetPassword(email: String) async throws {
        // Mock implementation
    }
    
    func updateProfile(_ updates: UserProfileUpdate) async throws -> AuthUser {
        AuthUser(
            id: "mock-user-id",
            email: "updated@example.com",
            displayName: updates.displayName ?? "Updated User",
            isEmailVerified: true,
            createdAt: Date().addingTimeInterval(-86400),
            lastSignInAt: Date(),
            subscriptionLevel: .free
        )
    }
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
    func bulkUpdate(items _: [Item]) async throws {}
    func bulkDelete(itemIds _: [UUID]) async throws {}
    func bulkSave(items _: [Item]) async throws {}
    func bulkAssignCategory(itemIds _: [UUID], categoryId _: UUID) async throws {}
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
    func exportToCSV<T: Encodable>(_ data: [T]) async throws -> Data {
        Data()
    }
    
    func exportToJSON<T: Encodable>(_ data: [T]) async throws -> Data {
        Data()
    }
    
    func exportToExcel<T: Encodable>(_ data: [T]) async throws -> Data {
        Data()
    }
    
    func exportToPDF<T: Encodable>(_ data: [T], template: PDFTemplate) async throws -> Data {
        Data()
    }
    
    func exportCompleteBackup() async throws -> InventoryBackup {
        InventoryBackup(
            items: [],
            categories: [],
            warranties: [],
            receipts: [],
            metadata: BackupMetadata(
                forCloudBackup: Date(),
                itemCount: 0,
                deviceName: "Mock Device"
            )
        )
    }
    
    func exportFiltered<T: Encodable>(_ data: [T], format: ExportFormat, fields: [String]) async throws -> Data {
        Data()
    }
    
    func getAvailableFormats<T>(for dataType: T.Type) -> [ExportFormat] {
        [.csv, .json, .pdf]
    }
    
    func validateExportData<T>(_ data: [T]) async throws -> ExportValidation {
        ExportValidation(
            isValid: true,
            issues: [],
            warnings: [],
            estimatedFileSize: data.count * 1024 // Rough estimate
        )
    }
}

struct MockSyncService: SyncService, Sendable {
    var syncStatus: SyncStatus {
        get async { .idle }
    }
    
    var lastSyncDate: Date? {
        get async { nil }
    }
    
    func startSync() async throws -> SyncResult {
        SyncResult(
            success: true,
            syncedItems: 0,
            conflicts: [],
            errors: [],
            duration: 0.5,
            syncDate: Date()
        )
    }
    
    func enableAutoSync(interval: TimeInterval) async throws {
        // Mock implementation
    }
    
    func disableAutoSync() async {
        // Mock implementation
    }
    
    func syncDataType(_ dataType: SyncDataType) async throws -> SyncResult {
        SyncResult(
            success: true,
            syncedItems: 0,
            conflicts: [],
            errors: [],
            duration: 0.3,
            syncDate: Date()
        )
    }
    
    func resolveConflicts(_ conflicts: [SyncConflict], resolution: ConflictResolution) async throws {
        // Mock implementation
    }
    
    func getPendingSyncOperations() async -> [SyncOperation] {
        []
    }
    
    func cancelSync() async {
        // Mock implementation
    }
    
    func resetSyncState() async throws {
        // Mock implementation
    }
    
    func getSyncStatistics() async -> SyncStatistics {
        SyncStatistics(
            totalSyncs: 0,
            successfulSyncs: 0,
            failedSyncs: 0,
            averageSyncDuration: 0,
            lastSuccessfulSync: nil,
            lastFailedSync: nil,
            totalDataSynced: 0,
            conflictsResolved: 0
        )
    }
}

// Note: MockAnalyticsService is defined in Services/AnalyticsService/MockAnalyticsService.swift

struct MockCurrencyService: CurrencyService, Sendable {
    func convert(amount: Decimal, from _: String, to _: String) async throws -> Decimal { amount }
    func updateRates() async throws {}
    func getRate(from _: String, to _: String) async throws -> Decimal { 1 }
    func getSupportedCurrencies() async -> [Currency] { [] }
    func getHistoricalRate(from _: String, to _: String, date _: Date) async throws -> Decimal? { 1 }
}

// Note: MockBarcodeScannerService is defined in Services/BarcodeScannerService/MockBarcodeScannerService.swift

// MockNotificationService: Use canonical implementation in Services/NotificationService/MockNotificationService.swift

// MockImportExportService is defined in Services/ImportExportService/MockImportExportService.swift

// MockCloudBackupService is defined in Services/CloudBackupService/MockCloudBackupService.swift

@MainActor
struct MockReceiptOCRService: ReceiptOCRService, Sendable {
    func processReceiptImage(_ image: UIImage) async throws -> EnhancedReceiptData {
        EnhancedReceiptData(
            vendor: "Mock Store",
            total: 29.99,
            tax: 2.40,
            date: Date(),
            categories: ["electronics"],
            items: [],
            confidence: 0.85,
            rawText: "Mock receipt text",
            boundingBoxes: [],
            processingMetadata: ReceiptProcessingMetadata(
                documentCorrectionApplied: false,
                patternsMatched: [:],
                mlClassifierUsed: false
            )
        )
    }
}

struct MockInsuranceReportService: InsuranceReportService, Sendable {
    func generateInsuranceReport(
        items: [Item],
        categories: [Category],
        options: ReportOptions
    ) async throws -> InsuranceReportData {
        return InsuranceReportData(
            summary: "Mock insurance report summary for \(items.count) items",
            content: "Mock Insurance Report PDF Data for \(items.count) items",
            generatedDate: Date(),
            policyHolder: "Mock Policy Holder",
            policyNumber: "MOCK-12345"
        )
    }
    
    func exportReport(
        _ data: InsuranceReportData,
        filename: String
    ) async throws -> URL {
        let tempURL = URL(fileURLWithPath: "/tmp/\(filename).pdf")
        return tempURL
    }
    
    func shareReport(_ url: URL) async {
        // Mock sharing - would typically present share sheet
        print("Mock sharing report at: \(url)")
    }
}

struct MockInsuranceClaimService: InsuranceClaimService, Sendable {
    var isGenerating: Bool { false }
    
    func generateClaim(for request: ClaimRequest) async throws -> GeneratedClaim {
        GeneratedClaim(
            request: request,
            documentData: Data(),
            filename: "mock_claim.pdf",
            format: .pdf,
            checklistItems: [],
            submissionInstructions: "Mock submission instructions"
        )
    }
    
    func getClaim(by id: UUID) async -> GeneratedClaim? {
        nil
    }
    
    func exportClaim(_ claim: GeneratedClaim, includePhotos: Bool) async throws -> URL {
        URL(fileURLWithPath: "/tmp/mock_claim_\(claim.id).pdf")
    }
    
    func validateItemsForClaim(items: [Item]) -> [String] {
        []
    }
    
    func estimateClaimValue(items: [Item]) -> Decimal {
        items.compactMap { $0.purchasePrice }.reduce(0, +)
    }
}

struct MockClaimPackageAssemblerService: ClaimPackageAssemblerService, Sendable {
    func assembleClaimPackage(items: [Item], claimInfo: ClaimInfo) async throws -> ClaimPackage {
        ClaimPackage(
            id: UUID(),
            scenario: ClaimScenario(type: .multipleItems, incidentDate: Date(), description: "Mock claim"),
            items: items,
            coverLetter: ClaimCoverLetter(content: "Mock cover letter", generatedAt: Date()),
            documentation: [],
            forms: [],
            attestations: [],
            validation: PackageValidation(
                isValid: true,
                issues: [],
                missingRequirements: [],
                totalItems: items.count,
                documentedItems: items.count,
                totalValue: 0,
                validationDate: Date()
            ),
            packageURL: URL(fileURLWithPath: "/tmp/mock_package.zip"),
            createdDate: Date(),
            options: ClaimPackageOptions()
        )
    }
    
    func assemblePackage(request: ClaimPackageRequest) async throws -> ClaimPackage {
        ClaimPackage(
            id: UUID(),
            scenario: request.scenario,
            items: [],
            coverLetter: ClaimCoverLetter(content: "Mock cover letter", generatedAt: Date()),
            documentation: [],
            forms: [],
            attestations: [],
            validation: PackageValidation(
                isValid: true,
                issues: [],
                missingRequirements: [],
                totalItems: 0,
                documentedItems: 0,
                totalValue: 0,
                validationDate: Date()
            ),
            packageURL: URL(fileURLWithPath: "/tmp/mock_package.zip"),
            createdDate: Date(),
            options: request.options
        )
    }
    
    func validatePackageCompleteness(_ package: ClaimPackage) async throws -> ValidationResult {
        ValidationResult(isComplete: true, missingItems: [], totalValue: 0)
    }
    
    func exportAsZIP(package: ClaimPackage) async throws -> URL {
        URL(fileURLWithPath: "/tmp/mock_\(package.id).zip")
    }
    
    func exportAsPDF(package: ClaimPackage) async throws -> URL {
        URL(fileURLWithPath: "/tmp/mock_\(package.id).pdf")
    }
    
    func prepareForEmail(package: ClaimPackage) async throws -> EmailPackage {
        EmailPackage(
            summaryPDF: URL(fileURLWithPath: "/tmp/mock_summary.pdf"),
            compressedPhotos: [],
            attachmentSize: 1024,
            recipientEmails: ["claims@insurance.com"],
            subject: "Insurance Claim Package",
            body: "Please find attached the claim package."
        )
    }
}

// MARK: - SearchHistoryService Protocol and Mock

protocol SearchHistoryService: Sendable {
    func loadHistory() async -> [SearchHistoryItem]
    func addToHistory(_ query: String, _ filters: SearchFilters) async
    func removeFromHistory(_ id: UUID) async
    func clearHistory() async
    func loadSavedSearches() async -> [SavedSearch]
    func saveFavoriteSearch(_ savedSearch: SavedSearch) async
    func deleteSavedSearch(_ id: UUID) async
}

struct MockSearchHistoryService: SearchHistoryService, Sendable {
    func loadHistory() async -> [SearchHistoryItem] {
        []
    }
    
    func addToHistory(_ query: String, _ filters: SearchFilters) async {
        // Mock implementation
    }
    
    func removeFromHistory(_ id: UUID) async {
        // Mock implementation
    }
    
    func clearHistory() async {
        // Mock implementation
    }
    
    func loadSavedSearches() async -> [SavedSearch] {
        []
    }
    
    func saveFavoriteSearch(_ savedSearch: SavedSearch) async {
        // Mock implementation
    }
    
    func deleteSavedSearch(_ id: UUID) async {
        // Mock implementation
    }
}
