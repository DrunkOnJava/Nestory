//
// Layer: Tests
// Module: Services
// Purpose: Unit tests for InsuranceClaimService functionality
//

import XCTest
import SwiftData
@testable import Nestory

@MainActor
final class InsuranceClaimServiceTests: XCTestCase {
    var claimService: any InsuranceClaimService!
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    var testItems: [Item]!

    override func setUp() async throws {
        super.setUp()

        // Create in-memory model container for testing
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(
            for: Item.self, Category.self,
            configurations: config
        )
        modelContext = ModelContext(modelContainer)

        claimService = InsuranceClaimService()

        // Create test items
        testItems = [
            createTestItem(name: "MacBook Pro", price: 2499.00, brand: "Apple"),
            createTestItem(name: "iPhone 15", price: 999.00, brand: "Apple"),
            createTestItem(name: "Samsung TV", price: 1200.00, brand: "Samsung"),
        ]

        // Save test items to context
        for item in testItems {
            modelContext.insert(item)
        }
        try modelContext.save()
    }

    override func tearDown() {
        claimService = nil
        testItems = nil
        modelContext = nil
        modelContainer = nil
        super.tearDown()
    }

    // MARK: - Test Helpers

    private func createTestItem(name: String, price: Decimal, brand: String) -> Item {
        let item = Item(name: name, itemDescription: "Test item", quantity: 1)
        item.purchasePrice = price
        item.purchaseDate = Date()
        item.brand = brand
        item.serialNumber = "TEST123"
        item.itemCondition = .excellent

        // Add mock image data
        item.imageData = "mock_image_data".data(using: .utf8)

        return item
    }

    private func createTestContactInfo() -> ClaimContactInfo {
        ClaimContactInfo(
            name: "John Doe",
            phone: "555-0123",
            email: "john@example.com",
            address: "123 Main St, Anytown, ST 12345"
        )
    }

    // MARK: - Basic Functionality Tests

    func testClaimServiceInitialization() {
        XCTAssertNotNil(claimService)
        XCTAssertFalse(claimService.isGenerating)
        XCTAssertTrue(claimService.generatedClaims.isEmpty)
    }

    func testEstimateClaimValue() {
        let totalValue = claimService.estimateClaimValue(items: testItems)
        XCTAssertEqual(totalValue, 4698.00) // 2499 + 999 + 1200
    }

    func testValidateItemsForClaim() {
        // Test with complete items
        let issues = claimService.validateItemsForClaim(items: testItems)
        XCTAssertEqual(issues.count, 0, "Complete items should have no validation issues")

        // Test with incomplete item
        let incompleteItem = Item(name: "Incomplete Item")
        let incompleteIssues = claimService.validateItemsForClaim(items: [incompleteItem])
        XCTAssertGreaterThan(incompleteIssues.count, 0, "Incomplete items should have validation issues")
    }

    func testSupportedCompanies() {
        let companies = claimService.getSupportedCompanies(for: .fire)
        XCTAssertEqual(companies.count, InsuranceClaimService.InsuranceCompany.allCases.count)
        XCTAssertTrue(companies.contains(.stateFarm))
        XCTAssertTrue(companies.contains(.allstate))
    }

    func testRequiredDocumentation() {
        let theftDocs = claimService.getRequiredDocumentation(for: .theft)
        XCTAssertTrue(theftDocs.contains("Police report"))
        XCTAssertTrue(theftDocs.contains("Photos of scene"))

        let fireDocs = claimService.getRequiredDocumentation(for: .fire)
        XCTAssertTrue(fireDocs.contains("Fire department report"))
        XCTAssertTrue(fireDocs.contains("Photos of damage"))
    }

    // MARK: - Claim Generation Tests

    func testGeneratePDFClaim() async throws {
        let request = InsuranceClaimService.ClaimRequest(
            claimType: .fire,
            insuranceCompany: .stateFarm,
            items: testItems,
            incidentDate: Date(),
            incidentDescription: "House fire caused damage to electronics",
            policyNumber: "SF-123456789",
            contactInfo: createTestContactInfo()
        )

        let claim = try await claimService.generateClaim(for: request)

        XCTAssertNotNil(claim)
        XCTAssertEqual(claim.format, .pdf)
        XCTAssertTrue(claim.filename.contains("Fire"))
        XCTAssertTrue(claim.filename.contains("StateFarm"))
        XCTAssertGreaterThan(claim.documentData.count, 0)
        XCTAssertFalse(claim.checklistItems.isEmpty)
        XCTAssertFalse(claim.submissionInstructions.isEmpty)
    }

    func testGenerateJSONClaim() async throws {
        let request = InsuranceClaimService.ClaimRequest(
            claimType: .theft,
            insuranceCompany: .geico,
            items: testItems,
            incidentDate: Date(),
            incidentDescription: "Electronics stolen from home",
            contactInfo: createTestContactInfo(),
            format: .structuredJSON
        )

        let claim = try await claimService.generateClaim(for: request)

        XCTAssertEqual(claim.format, .structuredJSON)
        XCTAssertTrue(claim.filename.hasSuffix(".json"))

        // Verify JSON structure
        let jsonObject = try JSONSerialization.jsonObject(with: claim.documentData)
        XCTAssertNotNil(jsonObject as? [String: Any])
    }

    func testGenerateClaimWithoutItems() async {
        let request = InsuranceClaimService.ClaimRequest(
            claimType: .theft,
            insuranceCompany: .stateFarm,
            items: [],
            incidentDate: Date(),
            incidentDescription: "Test",
            contactInfo: createTestContactInfo()
        )

        do {
            _ = try await claimService.generateClaim(for: request)
            XCTFail("Should throw error for empty items")
        } catch InsuranceClaimService.ClaimError.noItemsSelected {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - Bulk Claim Tests

    func testGenerateBulkClaim() async throws {
        let claims = try await claimService.generateBulkClaim(
            items: testItems,
            claimType: .water,
            insuranceCompany: .allstate,
            incidentDate: Date(),
            incidentDescription: "Basement flooding",
            contactInfo: createTestContactInfo(),
            policyNumber: "AL-987654321"
        )

        XCTAssertEqual(claims.count, 1, "Small item count should result in single claim")
        XCTAssertEqual(claims.first?.request.items.count, testItems.count)
    }

    func testGenerateBulkClaimWithManyItems() async throws {
        // Create many items to test chunking
        var manyItems: [Item] = []
        for i in 0 ..< 250 {
            let item = createTestItem(name: "Item \(i)", price: 100.00, brand: "Test")
            manyItems.append(item)
        }

        let claims = try await claimService.generateBulkClaim(
            items: manyItems,
            claimType: .fire,
            insuranceCompany: .usaa,
            incidentDate: Date(),
            incidentDescription: "Large fire loss",
            contactInfo: createTestContactInfo()
        )

        XCTAssertEqual(claims.count, 1, "250 items should fit in one claim")

        // Test with items over the limit
        for i in 250 ..< 1100 {
            let item = createTestItem(name: "Item \(i)", price: 100.00, brand: "Test")
            manyItems.append(item)
        }

        let manyClaims = try await claimService.generateBulkClaim(
            items: manyItems,
            claimType: .fire,
            insuranceCompany: .usaa,
            incidentDate: Date(),
            incidentDescription: "Very large fire loss",
            contactInfo: createTestContactInfo()
        )

        XCTAssertGreaterThan(manyClaims.count, 1, "1100 items should be split into multiple claims")
    }

    // MARK: - Export Tests

    func testExportClaim() async throws {
        let request = InsuranceClaimService.ClaimRequest(
            claimType: .vandalism,
            insuranceCompany: .progressive,
            items: [testItems[0]],
            incidentDate: Date(),
            incidentDescription: "Vandalism damage",
            contactInfo: createTestContactInfo()
        )

        let claim = try await claimService.generateClaim(for: request)
        let exportURL = try await claimService.exportClaim(claim)

        XCTAssertTrue(FileManager.default.fileExists(atPath: exportURL.path))
        XCTAssertTrue(exportURL.lastPathComponent.contains("Vandalism"))

        // Cleanup
        try? FileManager.default.removeItem(at: exportURL)
    }

    func testShareClaim() async throws {
        let request = InsuranceClaimService.ClaimRequest(
            claimType: .generalLoss,
            insuranceCompany: .generic,
            items: [testItems[0]],
            incidentDate: Date(),
            incidentDescription: "General loss",
            contactInfo: createTestContactInfo()
        )

        let claim = try await claimService.generateClaim(for: request)
        let shareURL = try await claimService.shareClaim(claim)

        XCTAssertTrue(FileManager.default.fileExists(atPath: shareURL.path))

        // Cleanup
        try? FileManager.default.removeItem(at: shareURL)
    }

    // MARK: - Filename Generation Tests

    func testFilenameGeneration() async throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayString = dateFormatter.string(from: Date())

        let request = InsuranceClaimService.ClaimRequest(
            claimType: .fire,
            insuranceCompany: .stateFarm,
            items: [testItems[0]],
            incidentDate: Date(),
            incidentDescription: "Test",
            contactInfo: createTestContactInfo()
        )

        let claim = try await claimService.generateClaim(for: request)

        XCTAssertTrue(claim.filename.contains("Fire"))
        XCTAssertTrue(claim.filename.contains("State_Farm"))
        XCTAssertTrue(claim.filename.contains(todayString))
        XCTAssertTrue(claim.filename.hasSuffix(".pdf"))
    }

    // MARK: - Error Handling Tests

    func testInvalidClaimRequest() async {
        let invalidContactInfo = ClaimContactInfo(
            name: "",
            phone: "",
            email: "",
            address: ""
        )

        let request = ClaimRequest(
            claimType: .theft,
            insuranceCompany: .stateFarm,
            items: testItems,
            incidentDate: Date(),
            incidentDescription: "",
            contactInfo: invalidContactInfo
        )

        do {
            _ = try await claimService.generateClaim(for: request)
            XCTFail("Should throw error for invalid request")
        } catch InsuranceClaimService.ClaimError.missingRequiredFields {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - Performance Tests

    func testClaimGenerationPerformance() throws {
        measure {
            Task {
                let request = InsuranceClaimService.ClaimRequest(
                    claimType: .fire,
                    insuranceCompany: .stateFarm,
                    items: testItems,
                    incidentDate: Date(),
                    incidentDescription: "Performance test",
                    contactInfo: createTestContactInfo()
                )

                do {
                    _ = try await claimService.generateClaim(for: request)
                } catch {
                    XCTFail("Performance test failed: \(error)")
                }
            }
        }
    }
}

// MARK: - Mock Data Extensions

extension InsuranceClaimServiceTests {
    func testMockDataConsistency() {
        XCTAssertEqual(testItems.count, 3)
        XCTAssertEqual(testItems[0].name, "MacBook Pro")
        XCTAssertEqual(testItems[1].name, "iPhone 15")
        XCTAssertEqual(testItems[2].name, "Samsung TV")

        for item in testItems {
            XCTAssertNotNil(item.purchasePrice)
            XCTAssertNotNil(item.purchaseDate)
            XCTAssertNotNil(item.brand)
            XCTAssertNotNil(item.imageData)
        }
    }
}
