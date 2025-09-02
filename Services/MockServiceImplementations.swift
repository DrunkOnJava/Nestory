//
// Layer: Services
// Module: Services
// Purpose: Lightweight mock implementations for all services used in TCA dependency testing
//

import Foundation
import UIKit

// MARK: - Mock Service Implementations

struct MockAuthService: AuthService, Sendable {
    var isAuthenticated: Bool { get async { false } }
    var currentUser: AuthUser? { get async { nil } }
    
    func signIn(email: String, password: String) async throws -> AuthUser {
        AuthUser(id: "mock", email: email, displayName: "Mock User", isEmailVerified: true, createdAt: Date(), lastSignInAt: Date(), subscriptionLevel: .free)
    }
    func signUp(email: String, password: String, displayName: String) async throws -> AuthUser {
        AuthUser(id: "mock", email: email, displayName: displayName, isEmailVerified: false, createdAt: Date(), lastSignInAt: nil, subscriptionLevel: .free)
    }
    func signOut() async throws {}
    func refreshToken() async throws -> AuthToken {
        AuthToken(accessToken: "mock", refreshToken: "mock", expiresAt: Date().addingTimeInterval(3600))
    }
    func hasPremiumAccess() async throws -> Bool { false }
    func verifyEmail() async throws {}
    func resetPassword(email: String) async throws {}
    func updateProfile(_ updates: UserProfileUpdate) async throws -> AuthUser {
        AuthUser(id: "mock", email: "updated@example.com", displayName: updates.displayName ?? "Updated", isEmailVerified: true, createdAt: Date().addingTimeInterval(-86400), lastSignInAt: Date(), subscriptionLevel: .free)
    }
}

struct MockInventoryService: InventoryService, Sendable {
    func fetchItems() async throws -> [Item] {
        try await Task.sleep(nanoseconds: 100_000_000) // Quick delay
        return createMockItems()
    }
    func fetchItem(id: UUID) async throws -> Item? {
        let items = try await fetchItems()
        return items.first { $0.id == id }
    }
    func saveItem(_: Item) async throws { try await Task.sleep(nanoseconds: 100_000_000) }
    func updateItem(_: Item) async throws { try await Task.sleep(nanoseconds: 100_000_000) }
    func deleteItem(id _: UUID) async throws { try await Task.sleep(nanoseconds: 100_000_000) }
    func searchItems(query: String) async throws -> [Item] {
        let items = try await fetchItems()
        return query.isEmpty ? items : items.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }
    func fetchCategories() async throws -> [Category] { createMockCategories() }
    func saveCategory(_: Category) async throws {}
    func assignItemToCategory(itemId _: UUID, categoryId _: UUID) async throws {}
    func fetchItemsByCategory(categoryId: UUID) async throws -> [Item] {
        let items = try await fetchItems()
        return items.filter { $0.category?.id == categoryId }
    }
    func fetchRooms() async throws -> [Room] { createMockRooms() }
    func bulkImport(items _: [Item]) async throws {}
    func bulkUpdate(items _: [Item]) async throws {}
    func bulkDelete(itemIds _: [UUID]) async throws {}
    func bulkSave(items _: [Item]) async throws {}
    func bulkAssignCategory(itemIds _: [UUID], categoryId _: UUID) async throws {}
    func exportInventory(format _: ExportFormat) async throws -> Data { Data() }
    
    private func createMockItems() -> [Item] {
        let categories = createMockCategories()
        let electronics = categories.first { $0.name == "Electronics" }
        
        let macbook = Item(name: "MacBook Pro 16-inch", itemDescription: "Space Gray", quantity: 1, category: electronics)
        macbook.brand = "Apple"
        macbook.purchasePrice = 2399
        macbook.purchaseDate = Date().addingTimeInterval(-365 * 24 * 60 * 60)
        macbook.room = "Home Office"
        
        let iphone = Item(name: "iPhone 15 Pro", itemDescription: "Natural Titanium", quantity: 1, category: electronics)
        iphone.brand = "Apple"
        iphone.purchasePrice = 1199
        iphone.purchaseDate = Date().addingTimeInterval(-90 * 24 * 60 * 60)
        iphone.room = "Bedroom"
        
        return [macbook, iphone]
    }
    
    private func createMockCategories() -> [Category] {
        [
            Category(name: "Electronics", icon: "laptopcomputer", colorHex: "#007AFF"),
            Category(name: "Furniture", icon: "chair.lounge", colorHex: "#34C759"),
            Category(name: "Kitchen", icon: "fork.knife", colorHex: "#FF9500")
        ]
    }
    
    private func createMockRooms() -> [Room] {
        [
            Room(name: "Home Office", icon: "desktopcomputer"),
            Room(name: "Living Room", icon: "sofa"),
            Room(name: "Kitchen", icon: "fork.knife"),
            Room(name: "Bedroom", icon: "bed.double")
        ]
    }
}

struct MockPhotoIntegrationService: PhotoIntegrationService, Sendable {
    func capturePhoto() async throws -> UIImage { UIImage() }
    func processPhoto(_ image: UIImage) async throws -> ProcessedPhoto {
        ProcessedPhoto(original: image, thumbnail: image, perceptualHash: 0, extractedText: [], detectedObjects: [],
                      metadata: ImageMetadata(width: 100, height: 100, captureDate: Date(), cameraModel: nil, lensMake: nil, latitude: nil, longitude: nil, orientation: .up))
    }
    func extractText(from _: UIImage) async throws -> [String] { [] }
    func detectObjects(in _: UIImage) async throws -> [DetectedObject] { [] }
    func generateThumbnail(from image: UIImage, size _: CGSize) async throws -> UIImage { image }
    func saveToPhotoLibrary(_: UIImage) async throws {}
    func loadFromPhotoLibrary(identifier _: String) async throws -> UIImage? { nil }
}

struct MockExportService: ExportService, Sendable {
    func exportToCSV<T: Encodable>(_ data: [T]) async throws -> Data { Data() }
    func exportToJSON<T: Encodable>(_ data: [T]) async throws -> Data { Data() }
    func exportToExcel<T: Encodable>(_ data: [T]) async throws -> Data { Data() }
    func exportToPDF<T: Encodable>(_ data: [T], template: PDFTemplate) async throws -> Data { Data() }
    func exportCompleteBackup() async throws -> InventoryBackup {
        InventoryBackup(items: [], categories: [], warranties: [], receipts: [],
                       metadata: BackupMetadata(forCloudBackup: Date(), itemCount: 0, deviceName: "Mock Device"))
    }
    func exportFiltered<T: Encodable>(_ data: [T], format: ExportFormat, fields: [String]) async throws -> Data { Data() }
    func getAvailableFormats<T>(for dataType: T.Type) -> [ExportFormat] { [.csv, .json, .pdf] }
    func validateExportData<T>(_ data: [T]) async throws -> ExportValidation {
        ExportValidation(isValid: true, issues: [], warnings: [], estimatedFileSize: data.count * 1024)
    }
}

struct MockSyncService: SyncService, Sendable {
    var syncStatus: SyncStatus { get async { .idle } }
    var lastSyncDate: Date? { get async { nil } }
    
    func startSync() async throws -> SyncResult {
        SyncResult(success: true, syncedItems: 0, conflicts: [], errors: [], duration: 0.5, syncDate: Date())
    }
    func enableAutoSync(interval: TimeInterval) async throws {}
    func disableAutoSync() async {}
    func syncDataType(_ dataType: SyncDataType) async throws -> SyncResult {
        SyncResult(success: true, syncedItems: 0, conflicts: [], errors: [], duration: 0.3, syncDate: Date())
    }
    func resolveConflicts(_ conflicts: [SyncConflict], resolution: ConflictResolution) async throws {}
    func getPendingSyncOperations() async -> [SyncOperation] { [] }
    func cancelSync() async {}
    func resetSyncState() async throws {}
    func getSyncStatistics() async -> SyncStatistics {
        SyncStatistics(totalSyncs: 0, successfulSyncs: 0, failedSyncs: 0, averageSyncDuration: 0, lastSuccessfulSync: nil, lastFailedSync: nil, totalDataSynced: 0, conflictsResolved: 0)
    }
}

struct MockCurrencyService: CurrencyService, Sendable {
    func convert(amount: Decimal, from _: String, to _: String) async throws -> Decimal { amount }
    func updateRates() async throws {}
    func getRate(from _: String, to _: String) async throws -> Decimal { 1 }
    func getSupportedCurrencies() async -> [Currency] { [] }
    func getHistoricalRate(from _: String, to _: String, date _: Date) async throws -> Decimal? { 1 }
}

@MainActor
struct MockReceiptOCRService: ReceiptOCRService, Sendable {
    func processReceiptImage(_ image: UIImage) async throws -> EnhancedReceiptData {
        EnhancedReceiptData(vendor: "Mock Store", total: 29.99, tax: 2.40, date: Date(), items: [], categories: ["electronics"], confidence: 0.85, rawText: "Mock receipt", boundingBoxes: [],
                           processingMetadata: ReceiptProcessingMetadata(documentCorrectionApplied: false, patternsMatched: [:], mlClassifierUsed: false))
    }
}

struct MockInsuranceReportService: InsuranceReportService, Sendable {
    func generateInsuranceReport(items: [Item], categories: [Category], options: ReportOptions) async throws -> Data { Data() }
    func exportReport(_ data: Data, filename: String) async throws -> URL { URL(fileURLWithPath: "/tmp/\(filename).pdf") }
    func shareReport(_ url: URL) async {}
}

struct MockInsuranceClaimService: InsuranceClaimService, Sendable {
    var isGenerating: Bool { false }
    
    func generateClaim(for request: ClaimRequest) async throws -> GeneratedClaim {
        GeneratedClaim(request: request, documentData: Data(), filename: "mock_claim.pdf", format: .pdf, checklistItems: [], submissionInstructions: "Mock instructions")
    }
    func getClaim(by id: UUID) async -> GeneratedClaim? { nil }
    func exportClaim(_ claim: GeneratedClaim, includePhotos: Bool) async throws -> URL { URL(fileURLWithPath: "/tmp/mock_claim.pdf") }
    func validateItemsForClaim(items: [Item]) -> [String] { [] }
    func estimateClaimValue(items: [Item]) -> Decimal { items.compactMap { $0.purchasePrice }.reduce(0, +) }
}

struct MockClaimPackageAssemblerService: ClaimPackageAssemblerService, Sendable {
    func assembleClaimPackage(items: [Item], claimInfo: ClaimInfo) async throws -> ClaimPackage {
        let summary = ClaimSummary(claimType: .multipleItems, incidentDate: Date(), totalItems: items.count, totalValue: 0, affectedRooms: [], description: "Mock")
        let coverLetter = ClaimCoverLetter(summary: summary, content: "Mock", generatedDate: Date(), policyHolder: "Mock", policyNumber: "MOCK-123")
        let validation = PackageValidation(isValid: true, issues: [], missingRequirements: [], totalItems: 0, documentedItems: 0, totalValue: 0, validationDate: Date())
        
        return ClaimPackage(id: UUID(), scenario: ClaimScenario(type: .multipleItems, incidentDate: Date(), description: "Mock"),
                           items: items, coverLetter: coverLetter, documentation: [], forms: [], attestations: [],
                           validation: validation, packageURL: URL(fileURLWithPath: "/tmp/mock.zip"), createdDate: Date(), options: ClaimPackageOptions())
    }
    
    func assemblePackage(request: ClaimPackageRequest) async throws -> ClaimPackage {
        let info = ClaimInfo(type: "MultipleItems", insuranceCompany: "Mock Insurance", incidentDate: Date(), incidentDescription: "Mock")
        return try await assembleClaimPackage(items: [], claimInfo: info)
    }
    func validatePackageCompleteness(_ package: ClaimPackage) async throws -> ValidationResult {
        ValidationResult(isComplete: true, missingItems: [], totalValue: 0)
    }
    func exportAsZIP(package: ClaimPackage) async throws -> URL { URL(fileURLWithPath: "/tmp/mock.zip") }
    func exportAsPDF(package: ClaimPackage) async throws -> URL { URL(fileURLWithPath: "/tmp/mock.pdf") }
    func prepareForEmail(package: ClaimPackage) async throws -> EmailPackage {
        EmailPackage(summaryPDF: URL(fileURLWithPath: "/tmp/mock.pdf"), compressedPhotos: [], attachmentSize: 1024, recipientEmails: [], subject: "Mock", body: "Mock")
    }
}

// MARK: - SearchHistoryService Protocol and Mock

public protocol SearchHistoryService: Sendable {
    func loadHistory() async -> [SearchHistoryItem]
    func addToHistory(_ query: String, _ filters: SearchFilters) async
    func removeFromHistory(_ id: UUID) async
    func clearHistory() async
    func loadSavedSearches() async -> [SavedSearch]
    func saveFavoriteSearch(_ savedSearch: SavedSearch) async
    func deleteSavedSearch(_ id: UUID) async
    func saveSearch(name: String, query: String, filters: SearchFilters) async
}

struct MockSearchHistoryService: SearchHistoryService, Sendable {
    func loadHistory() async -> [SearchHistoryItem] { [] }
    func addToHistory(_ query: String, _ filters: SearchFilters) async {}
    func removeFromHistory(_ id: UUID) async {}
    func clearHistory() async {}
    func loadSavedSearches() async -> [SavedSearch] { [] }
    func saveFavoriteSearch(_ savedSearch: SavedSearch) async {}
    func deleteSavedSearch(_ id: UUID) async {}
    func saveSearch(name: String, query: String, filters: SearchFilters) async {}
}

@MainActor
class MockWarrantyTrackingService: WarrantyTrackingService, Sendable {
    func fetchWarranties(includeExpired: Bool) async throws -> [Warranty] { [] }
    func fetchWarranty(for itemId: UUID) async throws -> Warranty? { nil }
    func saveWarranty(_ warranty: Warranty, for itemId: UUID) async throws {}
    func deleteWarranty(for itemId: UUID) async throws {}
    func calculateWarrantyExpiration(for item: Item) async throws -> Date? { nil }
    func suggestWarrantyProvider(for item: Item) async -> String? { "Manufacturer" }
    func defaultWarrantyDuration(for category: Category?) async -> Int { 12 }
    func detectWarrantyFromReceipt(item: Item, receiptText: String?) async throws -> WarrantyDetectionResult? { nil }
    func detectWarrantyInfo(brand: String?, model: String?, serialNumber: String?, purchaseDate: Date?) async throws -> WarrantyDetectionResult? { 
        WarrantyDetectionResult.detected(duration: 12, provider: "Manufacturer", confidence: 0.5, extractedText: "Mock detection")
    }
    func getWarrantyStatus(for item: Item) async throws -> WarrantyStatus { .noWarranty }
    func getItemsWithExpiringWarranties(within days: Int) async throws -> [Item] { [] }
    func getItemsMissingWarrantyInfo() async throws -> [Item] { [] }
    func getWarrantyStatistics() async throws -> WarrantyTrackingStatistics { 
        WarrantyTrackingStatistics(
            totalWarranties: 0, activeWarranties: 0, expiredWarranties: 0, 
            expiringSoonCount: 0, noWarrantyCount: 0, averageDurationDays: 365.0, 
            totalCoverageValue: 0.0, totalItems: 0, itemsWithWarranty: 0,
            missingWarrantyInfo: 0, averageWarrantyDuration: 1.0, mostCommonProvider: nil
        ) 
    }
    func bulkCreateWarranties(for items: [Item]) async throws -> [Warranty] { [] }
    func refreshAllWarrantyStatuses() async throws {}
    func updateWarrantiesFromReceipts() async throws -> Int { 0 }
}

@MainActor
struct MockDamageAssessmentService: DamageAssessmentServiceProtocol, Sendable {
    var isLoading: Bool { false }
    
    func createAssessment(for item: Item, damageType: DamageType, incidentDescription: String) async throws -> DamageAssessmentWorkflow {
        let assessment = DamageAssessment(
            itemId: item.id,
            damageType: damageType,
            severity: .moderate,
            incidentDescription: incidentDescription
        )
        
        return DamageAssessmentWorkflow(
            damageType: damageType,
            assessment: assessment
        )
    }
    
    func updateAssessment(_ assessment: DamageAssessment) async throws {
        // Mock implementation - no-op
    }
    
    func completeWorkflowStep(_ workflow: inout DamageAssessmentWorkflow, step: DamageAssessmentStep) async throws {
        workflow.completedSteps.insert(step)
        workflow.updatedAt = Date()
        workflow.currentStep = step
    }
    
    func addPhoto(_ photo: DamagePhoto, to assessment: inout DamageAssessment) async throws {
        // Add photo data to the appropriate category based on type
        switch photo.photoType {
        case .before:
            assessment.beforePhotos.append(photo.imageData)
        case .after:
            assessment.afterPhotos.append(photo.imageData)
        case .detail, .overview, .comparison:
            assessment.detailPhotos.append(photo.imageData)
        }
        assessment.photoDescriptions.append(photo.description)
    }
    
    func calculateDamageValue(for item: Item, severity: DamageSeverity) async throws -> Decimal {
        // Mock calculation based on severity
        let baseValue = item.purchasePrice ?? 0
        switch severity {
        case .minor:
            return baseValue * 0.1
        case .moderate:
            return baseValue * 0.3
        case .major:
            return baseValue * 0.6
        case .severe:
            return baseValue * 0.9
        case .total:
            return baseValue
        }
    }
    
    func generateAssessmentReport(_ workflow: DamageAssessmentWorkflow) async throws -> Data {
        // Mock PDF generation
        let reportContent = "Mock Damage Assessment Report\nWorkflow ID: \(workflow.id)\nDamage Type: \(workflow.damageType.rawValue)"
        return reportContent.data(using: String.Encoding.utf8) ?? Data()
    }
    
    func getAssessmentTemplate(for damageType: DamageType) async throws -> AssessmentTemplate {
        AssessmentTemplate(
            damageType: damageType,
            checklistItems: [
                AssessmentTemplate.ChecklistItem(
                    description: "Document damage location",
                    category: "Initial Assessment",
                    isRequired: true
                ),
                AssessmentTemplate.ChecklistItem(
                    description: "Take photos from multiple angles",
                    category: "Photo Documentation",
                    isRequired: true
                )
            ],
            photoRequirements: [
                AssessmentTemplate.PhotoRequirement(
                    description: "Clear front view of the damage",
                    photoType: .overview,
                    isRequired: true
                ),
                AssessmentTemplate.PhotoRequirement(
                    description: "Detailed close-up of damage area",
                    photoType: .detail,
                    isRequired: true
                )
            ],
            recommendedMeasurements: ["Length of damage", "Width of damage", "Depth if applicable"]
        )
    }
    
    func getActiveAssessments(for item: Item) async throws -> [DamageAssessmentWorkflow] {
        // Return empty array for mock
        []
    }
}
