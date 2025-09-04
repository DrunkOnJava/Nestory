//
// Layer: Unit/Models
// Module: WarrantyModelTests
// Purpose: Comprehensive tests for Warranty model, tracking logic, and insurance integration
//

import XCTest
import SwiftData
@testable import Nestory

/// Comprehensive test suite for Warranty model covering lifecycle, expiration logic, and insurance documentation
final class WarrantyModelTests: XCTestCase {
    
    // MARK: - Test Infrastructure
    
    private var modelContext: ModelContext!
    private var container: ModelContainer!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Create in-memory model context for testing
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Warranty.self, Item.self, configurations: configuration)
        modelContext = ModelContext(container)
    }
    
    override func tearDown() async throws {
        modelContext = nil
        container = nil
        try await super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testBasicInitialization() {
        let startDate = Date()
        let expiresAt = Calendar.current.date(byAdding: .year, value: 1, to: startDate)!
        
        let warranty = Warranty(
            provider: "Apple Inc.",
            type: .manufacturer,
            startDate: startDate,
            expiresAt: expiresAt
        )
        
        XCTAssertEqual(warranty.provider, "Apple Inc.")
        XCTAssertEqual(warranty.type, .manufacturer)
        XCTAssertEqual(warranty.startDate, startDate)
        XCTAssertEqual(warranty.expiresAt, expiresAt)
        XCTAssertNotNil(warranty.id)
        XCTAssertNotNil(warranty.createdAt)
        XCTAssertNotNil(warranty.updatedAt)
        
        // Test default values
        XCTAssertFalse(warranty.isRegistered)
        XCTAssertNil(warranty.registrationDate)
        XCTAssertNil(warranty.confirmationNumber)
    }
    
    func testInitializationWithItem() {
        let item = Item(name: "iPhone 15 Pro")
        let startDate = Date()
        let expiresAt = Calendar.current.date(byAdding: .month, value: 12, to: startDate)!
        
        let warranty = Warranty(
            provider: "Apple",
            type: .manufacturer,
            startDate: startDate,
            expiresAt: expiresAt,
            item: item
        )
        
        XCTAssertEqual(warranty.item?.name, "iPhone 15 Pro")
        XCTAssertEqual(item.warranty?.provider, "Apple")
    }
    
    func testUniqueIdentifiers() {
        let startDate = Date()
        let expiresAt = Calendar.current.date(byAdding: .year, value: 1, to: startDate)!
        
        let warranty1 = Warranty(provider: "Provider 1", startDate: startDate, expiresAt: expiresAt)
        let warranty2 = Warranty(provider: "Provider 2", startDate: startDate, expiresAt: expiresAt)
        
        XCTAssertNotEqual(warranty1.id, warranty2.id)
    }
    
    // MARK: - Warranty Type Tests
    
    func testWarrantyTypeEnum() {
        let allTypes: [WarrantyType] = [
            .manufacturer, .extended, .dealer, .thirdParty, .insurance, .service, .store
        ]
        
        for type in allTypes {
            let warranty = Warranty(
                provider: "Test Provider",
                type: type,
                startDate: Date(),
                expiresAt: Date(timeIntervalSinceNow: 365 * 24 * 60 * 60)
            )
            
            XCTAssertEqual(warranty.type, type)
            XCTAssertEqual(warranty.warrantyType, type.rawValue)
            XCTAssertFalse(type.displayName.isEmpty)
            XCTAssertFalse(type.icon.isEmpty)
        }
    }
    
    func testWarrantyTypeStringConversion() {
        let warranty = Warranty(
            provider: "Test",
            startDate: Date(),
            expiresAt: Date(timeIntervalSinceNow: 86400)
        )
        
        // Test setting via enum
        warranty.type = .extended
        XCTAssertEqual(warranty.warrantyType, "extended")
        
        // Test setting via string
        warranty.warrantyType = "dealer"
        XCTAssertEqual(warranty.type, .dealer)
        
        // Test invalid string defaults to manufacturer
        warranty.warrantyType = "invalid_type"
        XCTAssertEqual(warranty.type, .manufacturer)
    }
    
    func testWarrantyTypeDisplayProperties() {
        let typeDisplayTests = [
            (WarrantyType.manufacturer, "Manufacturer Warranty", "checkmark.shield.fill"),
            (WarrantyType.extended, "Extended Warranty", "shield.lefthalf.filled"),
            (WarrantyType.dealer, "Dealer Warranty", "building.2.fill"),
            (WarrantyType.thirdParty, "Third-Party Warranty", "person.3.fill"),
            (WarrantyType.insurance, "Insurance Coverage", "umbrella.fill"),
            (WarrantyType.service, "Service Contract", "wrench.and.screwdriver.fill"),
            (WarrantyType.store, "Store Warranty", "storefront.fill")
        ]
        
        for (type, expectedDisplay, expectedIcon) in typeDisplayTests {
            XCTAssertEqual(type.displayName, expectedDisplay)
            XCTAssertEqual(type.icon, expectedIcon)
        }
    }
    
    // MARK: - Duration Calculation Tests
    
    func testDurationCalculations() {
        let startDate = Date()
        let oneYearLater = Calendar.current.date(byAdding: .year, value: 1, to: startDate)!
        
        let warranty = Warranty(
            provider: "Test Provider",
            startDate: startDate,
            expiresAt: oneYearLater
        )
        
        // Test duration in months (approximately 12)
        XCTAssertGreaterThanOrEqual(warranty.durationInMonths, 11)
        XCTAssertLessThanOrEqual(warranty.durationInMonths, 13)
        
        // Test duration in days (approximately 365)
        XCTAssertGreaterThanOrEqual(warranty.durationInDays, 364)
        XCTAssertLessThanOrEqual(warranty.durationInDays, 366)
    }
    
    func testShortDurationCalculations() {
        let startDate = Date()
        let twoMonthsLater = Calendar.current.date(byAdding: .month, value: 2, to: startDate)!
        
        let warranty = Warranty(
            provider: "Short Warranty",
            startDate: startDate,
            expiresAt: twoMonthsLater
        )
        
        XCTAssertEqual(warranty.durationInMonths, 2)
        XCTAssertGreaterThanOrEqual(warranty.durationInDays, 59) // Minimum for 2 months
        XCTAssertLessThanOrEqual(warranty.durationInDays, 62) // Maximum for 2 months
    }
    
    func testFormattedDuration() {
        let startDate = Date()
        
        // Test 6 months
        let sixMonths = Calendar.current.date(byAdding: .month, value: 6, to: startDate)!
        let sixMonthWarranty = Warranty(provider: "Test", startDate: startDate, expiresAt: sixMonths)
        XCTAssertEqual(sixMonthWarranty.formattedDuration, "6 months")
        
        // Test 1 month
        let oneMonth = Calendar.current.date(byAdding: .month, value: 1, to: startDate)!
        let oneMonthWarranty = Warranty(provider: "Test", startDate: startDate, expiresAt: oneMonth)
        XCTAssertEqual(oneMonthWarranty.formattedDuration, "1 month")
        
        // Test 1 year
        let oneYear = Calendar.current.date(byAdding: .year, value: 1, to: startDate)!
        let oneYearWarranty = Warranty(provider: "Test", startDate: startDate, expiresAt: oneYear)
        XCTAssertEqual(oneYearWarranty.formattedDuration, "1 year")
        
        // Test 2 years
        let twoYears = Calendar.current.date(byAdding: .year, value: 2, to: startDate)!
        let twoYearWarranty = Warranty(provider: "Test", startDate: startDate, expiresAt: twoYears)
        XCTAssertEqual(twoYearWarranty.formattedDuration, "2 years")
        
        // Test 1 year 3 months
        let oneYearThreeMonths = Calendar.current.date(byAdding: .month, value: 15, to: startDate)!
        let complexWarranty = Warranty(provider: "Test", startDate: startDate, expiresAt: oneYearThreeMonths)
        XCTAssertEqual(complexWarranty.formattedDuration, "1 year, 3 months")
    }
    
    // MARK: - Status and Expiration Tests
    
    func testActiveWarranty() {
        let startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())! // Started 1 month ago
        let expiresAt = Calendar.current.date(byAdding: .month, value: 11, to: Date())! // Expires in 11 months
        
        let warranty = Warranty(
            provider: "Active Provider",
            startDate: startDate,
            expiresAt: expiresAt
        )
        
        XCTAssertTrue(warranty.isActive)
        XCTAssertFalse(warranty.isExpired)
        XCTAssertEqual(warranty.status, "Active")
        XCTAssertGreaterThan(warranty.daysUntilExpiration, 300) // Should be around 330 days
    }
    
    func testExpiredWarranty() {
        let startDate = Calendar.current.date(byAdding: .year, value: -2, to: Date())! // Started 2 years ago
        let expiresAt = Calendar.current.date(byAdding: .month, value: -1, to: Date())! // Expired 1 month ago
        
        let warranty = Warranty(
            provider: "Expired Provider",
            startDate: startDate,
            expiresAt: expiresAt
        )
        
        XCTAssertFalse(warranty.isActive)
        XCTAssertTrue(warranty.isExpired)
        XCTAssertEqual(warranty.status, "Expired")
        XCTAssertLessThan(warranty.daysUntilExpiration, 0) // Negative for expired
    }
    
    func testFutureWarranty() {
        let startDate = Calendar.current.date(byAdding: .month, value: 1, to: Date())! // Starts in 1 month
        let expiresAt = Calendar.current.date(byAdding: .year, value: 1, to: startDate)!
        
        let warranty = Warranty(
            provider: "Future Provider",
            startDate: startDate,
            expiresAt: expiresAt
        )
        
        XCTAssertFalse(warranty.isActive)
        XCTAssertFalse(warranty.isExpired)
        XCTAssertEqual(warranty.status, "Not yet started")
    }
    
    func testExpiringSoonWarranty() {
        let startDate = Calendar.current.date(byAdding: .year, value: -1, to: Date())! // Started 1 year ago
        let expiresAt = Calendar.current.date(byAdding: .day, value: 15, to: Date())! // Expires in 15 days
        
        let warranty = Warranty(
            provider: "Expiring Provider",
            startDate: startDate,
            expiresAt: expiresAt
        )
        
        XCTAssertTrue(warranty.isActive)
        XCTAssertFalse(warranty.isExpired)
        XCTAssertEqual(warranty.status, "Expiring soon (15 days)")
        XCTAssertEqual(warranty.daysUntilExpiration, 15)
    }
    
    func testExpiringSoonSingularDay() {
        let startDate = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
        let expiresAt = Calendar.current.date(byAdding: .day, value: 1, to: Date())! // Expires tomorrow
        
        let warranty = Warranty(
            provider: "Tomorrow Provider",
            startDate: startDate,
            expiresAt: expiresAt
        )
        
        XCTAssertEqual(warranty.status, "Expiring soon (1 day)")
    }
    
    // MARK: - Document and Contact Information Tests
    
    func testDocumentAttachment() {
        let warranty = Warranty(
            provider: "Document Test",
            startDate: Date(),
            expiresAt: Date(timeIntervalSinceNow: 86400)
        )
        
        // Initially no document
        XCTAssertFalse(warranty.hasDocument)
        XCTAssertNil(warranty.documentFileName)
        
        // Attach document
        warranty.attachDocument(fileName: "warranty_certificate.pdf")
        XCTAssertTrue(warranty.hasDocument)
        XCTAssertEqual(warranty.documentFileName, "warranty_certificate.pdf")
    }
    
    func testClaimContactInformation() {
        let warranty = Warranty(
            provider: "Contact Test",
            startDate: Date(),
            expiresAt: Date(timeIntervalSinceNow: 86400)
        )
        
        // Set contact information
        warranty.setClaimContact(
            phone: "1-800-APL-CARE",
            email: "warranty@apple.com",
            website: "https://support.apple.com"
        )
        
        XCTAssertEqual(warranty.claimPhone, "1-800-APL-CARE")
        XCTAssertEqual(warranty.claimEmail, "warranty@apple.com")
        XCTAssertEqual(warranty.claimWebsite, "https://support.apple.com")
    }
    
    func testPartialContactUpdate() {
        let warranty = Warranty(
            provider: "Partial Update Test",
            startDate: Date(),
            expiresAt: Date(timeIntervalSinceNow: 86400)
        )
        
        // Set only phone initially
        warranty.setClaimContact(phone: "555-1234")
        XCTAssertEqual(warranty.claimPhone, "555-1234")
        XCTAssertNil(warranty.claimEmail)
        XCTAssertNil(warranty.claimWebsite)
        
        // Update only email
        warranty.setClaimContact(email: "support@company.com")
        XCTAssertEqual(warranty.claimPhone, "555-1234") // Should remain unchanged
        XCTAssertEqual(warranty.claimEmail, "support@company.com")
        XCTAssertNil(warranty.claimWebsite)
    }
    
    // MARK: - Registration Tracking Tests
    
    func testWarrantyRegistration() {
        let warranty = Warranty(
            provider: "Registration Test",
            startDate: Date(),
            expiresAt: Date(timeIntervalSinceNow: 86400)
        )
        
        // Initially not registered
        XCTAssertFalse(warranty.isRegistered)
        XCTAssertNil(warranty.registrationDate)
        XCTAssertNil(warranty.confirmationNumber)
        
        // Register warranty
        let registrationDate = Date()
        warranty.isRegistered = true
        warranty.registrationDate = registrationDate
        warranty.confirmationNumber = "REG123456"
        
        XCTAssertTrue(warranty.isRegistered)
        XCTAssertEqual(warranty.registrationDate, registrationDate)
        XCTAssertEqual(warranty.confirmationNumber, "REG123456")
    }
    
    // MARK: - Update Methods Tests
    
    func testWarrantyUpdate() {
        let originalDate = Date()
        let warranty = Warranty(
            provider: "Original Provider",
            type: .manufacturer,
            startDate: originalDate,
            expiresAt: Date(timeIntervalSinceNow: 86400)
        )
        
        let originalUpdatedAt = warranty.updatedAt
        
        // Wait a tiny bit to ensure timestamp difference
        Thread.sleep(forTimeInterval: 0.001)
        
        // Update warranty
        let newStartDate = Calendar.current.date(byAdding: .day, value: 1, to: originalDate)!
        let newExpiresAt = Calendar.current.date(byAdding: .year, value: 2, to: newStartDate)!
        
        warranty.update(
            provider: "Updated Provider",
            type: .extended,
            startDate: newStartDate,
            expiresAt: newExpiresAt,
            coverageNotes: "Extended coverage with accidental damage",
            policyNumber: "POL123456"
        )
        
        XCTAssertEqual(warranty.provider, "Updated Provider")
        XCTAssertEqual(warranty.type, .extended)
        XCTAssertEqual(warranty.startDate, newStartDate)
        XCTAssertEqual(warranty.expiresAt, newExpiresAt)
        XCTAssertEqual(warranty.coverageNotes, "Extended coverage with accidental damage")
        XCTAssertEqual(warranty.policyNumber, "POL123456")
        XCTAssertGreaterThan(warranty.updatedAt, originalUpdatedAt)
    }
    
    func testPartialWarrantyUpdate() {
        let warranty = Warranty(
            provider: "Original Provider",
            startDate: Date(),
            expiresAt: Date(timeIntervalSinceNow: 86400)
        )
        
        // Update only provider
        warranty.update(provider: "New Provider")
        XCTAssertEqual(warranty.provider, "New Provider")
        XCTAssertEqual(warranty.type, .manufacturer) // Should remain unchanged
        
        // Update only coverage notes
        warranty.update(coverageNotes: "Comprehensive coverage")
        XCTAssertEqual(warranty.coverageNotes, "Comprehensive coverage")
        XCTAssertEqual(warranty.provider, "New Provider") // Should remain unchanged
    }
    
    // MARK: - Relationship Tests
    
    func testItemWarrantyRelationship() throws {
        let item = Item(name: "MacBook Pro")
        let warranty = Warranty(
            provider: "Apple Inc.",
            type: .manufacturer,
            startDate: Date(),
            expiresAt: Date(timeIntervalSinceNow: 365 * 24 * 60 * 60),
            item: item
        )
        
        modelContext.insert(item)
        modelContext.insert(warranty)
        try modelContext.save()
        
        // Test bidirectional relationship
        XCTAssertEqual(item.warranty?.provider, "Apple Inc.")
        XCTAssertEqual(warranty.item?.name, "MacBook Pro")
    }
    
    func testOrphanedWarranty() {
        let warranty = Warranty(
            provider: "Orphaned Warranty",
            startDate: Date(),
            expiresAt: Date(timeIntervalSinceNow: 86400)
        )
        
        XCTAssertNil(warranty.item)
    }
    
    // MARK: - Backward Compatibility Tests
    
    func testEndDateCompatibility() {
        let expirationDate = Date(timeIntervalSinceNow: 86400)
        let warranty = Warranty(
            provider: "Compatibility Test",
            startDate: Date(),
            expiresAt: expirationDate
        )
        
        // Test backward compatibility property
        XCTAssertEqual(warranty.endDate, expirationDate)
        XCTAssertEqual(warranty.endDate, warranty.expiresAt)
        
        // Test setting via endDate
        let newEndDate = Date(timeIntervalSinceNow: 172800) // 2 days
        warranty.endDate = newEndDate
        XCTAssertEqual(warranty.expiresAt, newEndDate)
        XCTAssertEqual(warranty.endDate, newEndDate)
    }
    
    // MARK: - Equality Tests
    
    func testWarrantyEquality() {
        let startDate = Date()
        let expiresAt = Date(timeIntervalSinceNow: 86400)
        
        let warranty1 = Warranty(provider: "Test", startDate: startDate, expiresAt: expiresAt)
        let warranty2 = Warranty(provider: "Test", startDate: startDate, expiresAt: expiresAt)
        
        // Different warranties should not be equal (different IDs and updatedAt)
        XCTAssertNotEqual(warranty1, warranty2)
        
        // Same warranty should be equal to itself
        XCTAssertEqual(warranty1, warranty1)
        
        // Test with same ID and updatedAt
        warranty2.id = warranty1.id
        warranty2.updatedAt = warranty1.updatedAt
        XCTAssertEqual(warranty1, warranty2)
    }
    
    // MARK: - Insurance Documentation Tests
    
    func testAppleCareWarranty() {
        let startDate = Date()
        let expiresAt = Calendar.current.date(byAdding: .year, value: 3, to: startDate)!
        
        let appleCare = Warranty(
            provider: "Apple Inc.",
            type: .extended,
            startDate: startDate,
            expiresAt: expiresAt
        )
        
        appleCare.update(
            coverageNotes: "AppleCare+ with accidental damage protection",
            policyNumber: "AP123456789"
        )
        
        appleCare.setClaimContact(
            phone: "1-800-APL-CARE",
            email: "support@apple.com",
            website: "https://getsupport.apple.com"
        )
        
        XCTAssertEqual(appleCare.type, .extended)
        XCTAssertEqual(appleCare.formattedDuration, "3 years")
        XCTAssertNotNil(appleCare.coverageNotes)
        XCTAssertNotNil(appleCare.policyNumber)
        XCTAssertNotNil(appleCare.claimPhone)
        XCTAssertNotNil(appleCare.claimEmail)
        XCTAssertNotNil(appleCare.claimWebsite)
    }
    
    func testExtendedWarrantyForHighValueItem() {
        let highValueItem = TestDataFactory.createHighValueItem()
        let startDate = Date()
        let expiresAt = Calendar.current.date(byAdding: .year, value: 5, to: startDate)!
        
        let extendedWarranty = Warranty(
            provider: "Best Buy Geek Squad",
            type: .service,
            startDate: startDate,
            expiresAt: expiresAt,
            item: highValueItem
        )
        
        extendedWarranty.update(
            coverageNotes: "Complete protection plan including accidental damage, liquid spills, and power surges",
            policyNumber: "GS987654321"
        )
        
        extendedWarranty.attachDocument(fileName: "geek_squad_protection_plan.pdf")
        
        // High-value items should have comprehensive warranty documentation
        XCTAssertNotNil(extendedWarranty.item?.purchasePrice)
        XCTAssertTrue(extendedWarranty.hasDocument)
        XCTAssertEqual(extendedWarranty.formattedDuration, "5 years")
        XCTAssertEqual(extendedWarranty.type, .service)
        XCTAssertNotNil(extendedWarranty.coverageNotes)
    }
    
    func testInsuranceWarrantyIntegration() {
        let item = Item(name: "Diamond Ring")
        let startDate = Date()
        let expiresAt = Calendar.current.date(byAdding: .year, value: 10, to: startDate)!
        
        let insuranceWarranty = Warranty(
            provider: "State Farm Insurance",
            type: .insurance,
            startDate: startDate,
            expiresAt: expiresAt,
            item: item
        )
        
        insuranceWarranty.update(
            coverageNotes: "Jewelry floater policy with full replacement value",
            policyNumber: "SF123456789"
        )
        
        insuranceWarranty.setClaimContact(
            phone: "1-800-STATE-FARM",
            email: "claims@statefarm.com",
            website: "https://www.statefarm.com/claims"
        )
        
        // Insurance warranties should have long durations and comprehensive contact info
        XCTAssertEqual(insuranceWarranty.type, .insurance)
        XCTAssertEqual(insuranceWarranty.formattedDuration, "10 years")
        XCTAssertTrue(insuranceWarranty.coverageNotes?.contains("replacement value") == true)
        XCTAssertNotNil(insuranceWarranty.claimPhone)
        XCTAssertNotNil(insuranceWarranty.claimEmail)
        XCTAssertNotNil(insuranceWarranty.claimWebsite)
    }
    
    // MARK: - Performance Tests
    
    func testWarrantyCreationPerformance() {
        let startDate = Date()
        let expiresAt = Date(timeIntervalSinceNow: 365 * 24 * 60 * 60)
        
        measure {
            for i in 0..<1000 {
                let warranty = Warranty(
                    provider: "Provider \(i)",
                    type: .manufacturer,
                    startDate: startDate,
                    expiresAt: expiresAt
                )
                _ = warranty.isActive // Access computed property
                _ = warranty.formattedDuration // Access computed property
                _ = warranty.status // Access computed property
            }
        }
    }
    
    func testDurationCalculationPerformance() {
        let warranties = (0..<100).map { i in
            let startDate = Calendar.current.date(byAdding: .month, value: -i, to: Date())!
            let expiresAt = Calendar.current.date(byAdding: .month, value: 12 - i, to: Date())!
            return Warranty(provider: "Provider \(i)", startDate: startDate, expiresAt: expiresAt)
        }
        
        measure {
            for warranty in warranties {
                _ = warranty.durationInDays
                _ = warranty.durationInMonths
                _ = warranty.formattedDuration
                _ = warranty.daysUntilExpiration
                _ = warranty.isActive
                _ = warranty.status
            }
        }
    }
    
    // MARK: - Edge Cases
    
    func testZeroDurationWarranty() {
        let date = Date()
        let warranty = Warranty(
            provider: "Zero Duration",
            startDate: date,
            expiresAt: date
        )
        
        XCTAssertEqual(warranty.durationInDays, 0)
        XCTAssertEqual(warranty.durationInMonths, 0)
        XCTAssertEqual(warranty.formattedDuration, "0 months")
        XCTAssertEqual(warranty.daysUntilExpiration, 0)
    }
    
    func testNegativeDurationWarranty() {
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: -1, to: startDate)! // End before start
        
        let warranty = Warranty(
            provider: "Negative Duration",
            startDate: startDate,
            expiresAt: endDate
        )
        
        XCTAssertLessThan(warranty.durationInDays, 0)
        XCTAssertTrue(warranty.isExpired)
        XCTAssertFalse(warranty.isActive)
    }
    
    func testVeryLongWarranty() {
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .year, value: 50, to: startDate)!
        
        let warranty = Warranty(
            provider: "Lifetime Warranty",
            startDate: startDate,
            expiresAt: endDate
        )
        
        XCTAssertGreaterThan(warranty.durationInDays, 18000) // Approximately 50 years
        XCTAssertGreaterThan(warranty.durationInMonths, 600) // Approximately 50 years
        XCTAssertEqual(warranty.formattedDuration, "50 years")
    }
    
    func testEmptyStringProperties() {
        let warranty = Warranty(
            provider: "",
            startDate: Date(),
            expiresAt: Date(timeIntervalSinceNow: 86400)
        )
        
        XCTAssertEqual(warranty.provider, "")
        
        warranty.coverageNotes = ""
        warranty.policyNumber = ""
        warranty.claimPhone = ""
        warranty.claimEmail = ""
        warranty.claimWebsite = ""
        warranty.confirmationNumber = ""
        
        XCTAssertEqual(warranty.coverageNotes, "")
        XCTAssertEqual(warranty.policyNumber, "")
        XCTAssertEqual(warranty.claimPhone, "")
        XCTAssertEqual(warranty.claimEmail, "")
        XCTAssertEqual(warranty.claimWebsite, "")
        XCTAssertEqual(warranty.confirmationNumber, "")
    }
    
    func testVeryLongStringProperties() {
        let longString = String(repeating: "A", count: 1000)
        let warranty = Warranty(
            provider: longString,
            startDate: Date(),
            expiresAt: Date(timeIntervalSinceNow: 86400)
        )
        
        warranty.coverageNotes = longString
        warranty.policyNumber = longString
        
        XCTAssertEqual(warranty.provider.count, 1000)
        XCTAssertEqual(warranty.coverageNotes?.count, 1000)
        XCTAssertEqual(warranty.policyNumber?.count, 1000)
    }
}