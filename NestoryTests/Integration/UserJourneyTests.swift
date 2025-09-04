//
// Layer: Tests
// Module: Integration
// Purpose: End-to-end user journey testing for complete insurance workflows
//

import XCTest
import SwiftData
import ComposableArchitecture
@testable import Nestory

/// Complete user journey testing for insurance documentation workflows
/// Tests real user scenarios from item capture through insurance claim preparation
@MainActor
final class UserJourneyTests: XCTestCase {
    
    // MARK: - Test Infrastructure
    
    private var temporaryContainer: ModelContainer!
    private var testStore: TestStore<RootFeature.State, RootFeature.Action>!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Create in-memory container for user journey testing
        let schema = Schema([Item.self, NestoryCategory.self, Room.self, Warranty.self, Receipt.self])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        
        temporaryContainer = try ModelContainer(for: schema, configurations: [config])
        
        // Create test store for TCA integration testing
        testStore = TestStore(initialState: RootFeature.State()) {
            RootFeature()
        }
    }
    
    override func tearDown() async throws {
        temporaryContainer = nil
        await testStore?.finish()
        testStore = nil
        try await super.tearDown()
    }
    
    // MARK: - Complete Insurance Documentation Journey
    
    func testCompleteInsuranceDocumentationJourney() async throws {
        // Journey: New user documents a high-value item for insurance
        // Flow: Add Item -> Add Photos -> Add Receipt -> Add Warranty -> Generate Report
        
        let context = temporaryContainer.mainContext
        
        // Step 1: User adds a new high-value item
        let macbook = Item()
        macbook.name = "MacBook Pro M3 Max 16\""
        macbook.brand = "Apple"
        macbook.modelNumber = "MBP16-M3MAX-2024"
        macbook.serialNumber = "C02ABC123456DEF"
        macbook.purchasePrice = Decimal(3499)
        macbook.currency = "USD"
        macbook.purchaseDate = Date()
        macbook.itemDescription = "16-inch MacBook Pro with M3 Max chip, 36GB RAM, 1TB SSD for professional video editing"
        
        // Step 2: Categorize the item
        let electronics = NestoryCategory(name: "Electronics", icon: "laptopcomputer", colorHex: "#007AFF")
        context.insert(electronics)
        macbook.category = electronics
        
        // Step 3: Set location
        macbook.room = "Home Office"
        macbook.specificLocation = "Desk"
        
        // Step 4: Add condition information
        macbook.itemCondition = .excellent
        macbook.conditionNotes = "Brand new, perfect condition with original packaging"
        macbook.lastConditionUpdate = Date()
        
        context.insert(macbook)
        try context.save()
        
        // Verify item creation
        let savedItems = try context.fetch(FetchDescriptor<Item>())
        XCTAssertEqual(savedItems.count, 1, "Item should be saved")
        XCTAssertEqual(savedItems.first?.name, "MacBook Pro M3 Max 16\"", "Item name should be preserved")
        XCTAssertEqual(savedItems.first?.purchasePrice, Decimal(3499), "Purchase price should be preserved")
        
        // Step 5: Add warranty information
        let appleCare = Warranty(
            provider: "Apple Inc.",
            type: .extended,
            startDate: Date(),
            expiresAt: Calendar.current.date(byAdding: .year, value: 3, to: Date()) ?? Date()
        )
        appleCare.policyNumber = "AC123456789"
        appleCare.claimPhone = "1-800-APL-CARE"
        appleCare.claimWebsite = "https://support.apple.com"
        appleCare.item = macbook
        macbook.warranty = appleCare
        
        context.insert(appleCare)
        try context.save()
        
        // Verify warranty relationship
        let itemWithWarranty = try context.fetch(FetchDescriptor<Item>()).first!
        XCTAssertNotNil(itemWithWarranty.warranty, "Item should have warranty")
        XCTAssertEqual(itemWithWarranty.warranty?.provider, "Apple Inc.", "Warranty provider should be correct")
        XCTAssertTrue(itemWithWarranty.warranty?.isActive ?? false, "Warranty should be active")
        
        // Step 6: Calculate documentation completeness score
        let hasBasicInfo = !macbook.name.isEmpty && macbook.purchasePrice > 0
        let hasDetailedInfo = macbook.serialNumber != nil && macbook.itemDescription != nil
        let hasWarranty = macbook.warranty != nil
        let hasLocation = macbook.room != nil
        let hasCondition = !macbook.condition.isEmpty
        
        let completenessScore = 
            (hasBasicInfo ? 20 : 0) +
            (hasDetailedInfo ? 30 : 0) +
            (hasWarranty ? 25 : 0) +
            (hasLocation ? 15 : 0) +
            (hasCondition ? 10 : 0)
        
        XCTAssertEqual(completenessScore, 100, "High-value item should have complete documentation")
        
        // Step 7: Verify insurance readiness
        let insuranceReady = completenessScore >= 80 && macbook.purchasePrice > 1000
        XCTAssertTrue(insuranceReady, "Item should be ready for insurance documentation")
        
        print("✅ Complete Insurance Documentation Journey:")
        print("   • Item: \\(macbook.name)")
        print("   • Value: $\\(macbook.purchasePrice)")
        print("   • Documentation Score: \\(completenessScore)%")
        print("   • Insurance Ready: \\(insuranceReady ? "Yes" : "No")")
    }
    
    func testMultiItemClaimPreparationJourney() async throws {
        // Journey: User prepares for home insurance claim after theft
        // Flow: Multiple Items -> Categorize -> Assess Value -> Generate Report
        
        let context = temporaryContainer.mainContext
        
        // Create categories first
        let electronics = NestoryCategory(name: "Electronics", icon: "desktopcomputer", colorHex: "#007AFF")
        let jewelry = NestoryCategory(name: "Jewelry", icon: "sparkles", colorHex: "#FFD700")
        let furniture = NestoryCategory(name: "Furniture", icon: "bed.double", colorHex: "#8B4513")
        
        context.insert(electronics)
        context.insert(jewelry)
        context.insert(furniture)
        
        // Step 1: User documents multiple stolen items
        let stolenItems = [
            // Electronics
            createStolenItem(name: "iPad Pro 12.9\"", value: 1099, category: electronics, room: "Living Room"),
            createStolenItem(name: "iPhone 15 Pro", value: 999, category: electronics, room: "Bedroom"),
            createStolenItem(name: "AirPods Pro", value: 249, category: electronics, room: "Home Office"),
            
            // Jewelry
            createStolenItem(name: "Diamond Wedding Ring", value: 3500, category: jewelry, room: "Bedroom"),
            createStolenItem(name: "Gold Watch", value: 2200, category: jewelry, room: "Bedroom"),
            
            // Furniture
            createStolenItem(name: "Leather Sofa Set", value: 4500, category: furniture, room: "Living Room")
        ]
        
        for item in stolenItems {
            context.insert(item)
        }
        try context.save()
        
        // Step 2: Calculate total claim value
        let totalClaimValue = stolenItems.reduce(0) { $0 + ($1.purchasePrice ?? 0) }
        XCTAssertEqual(totalClaimValue, Decimal(12547), "Total claim value should be calculated correctly")
        
        // Step 3: Categorize claim by value and room
        var roomBreakdown: [String: (count: Int, value: Decimal)] = [:]
        var categoryBreakdown: [String: (count: Int, value: Decimal)] = [:]
        
        for item in stolenItems {
            let room = item.room ?? "Unknown"
            let category = item.category?.name ?? "Uncategorized"
            let value = item.purchasePrice ?? 0
            
            // Room breakdown
            let roomExisting = roomBreakdown[room] ?? (count: 0, value: 0)
            roomBreakdown[room] = (count: roomExisting.count + 1, value: roomExisting.value + value)
            
            // Category breakdown
            let categoryExisting = categoryBreakdown[category] ?? (count: 0, value: 0)
            categoryBreakdown[category] = (count: categoryExisting.count + 1, value: categoryExisting.value + value)
        }
        
        // Step 4: Verify claim analysis
        XCTAssertEqual(roomBreakdown.count, 3, "Should have items from 3 rooms")
        XCTAssertEqual(categoryBreakdown.count, 3, "Should have items from 3 categories")
        
        // Living Room should have highest value (iPad + Sofa = $5599)
        let livingRoomValue = roomBreakdown["Living Room"]?.value ?? 0
        XCTAssertEqual(livingRoomValue, Decimal(5599), "Living Room should have highest loss value")
        
        // Electronics should have most items (3)
        let electronicsCount = categoryBreakdown["Electronics"]?.count ?? 0
        XCTAssertEqual(electronicsCount, 3, "Electronics should have most items")
        
        // Step 5: Identify high-priority items for detailed documentation
        let highValueItems = stolenItems.filter { ($0.purchasePrice ?? 0) >= 1000 }
        XCTAssertEqual(highValueItems.count, 5, "Should identify 5 high-value items requiring detailed documentation")
        
        // Step 6: Calculate average documentation completeness
        var totalDocumentationScore = 0
        for item in stolenItems {
            let hasBasicInfo = !item.name.isEmpty && (item.purchasePrice ?? 0) > 0
            let hasCategory = item.category != nil
            let hasLocation = item.room != nil
            let hasDescription = item.itemDescription?.isEmpty == false
            
            let itemScore = 
                (hasBasicInfo ? 40 : 0) +
                (hasCategory ? 25 : 0) +
                (hasLocation ? 25 : 0) +
                (hasDescription ? 10 : 0)
            
            totalDocumentationScore += itemScore
        }
        
        let averageDocumentationScore = totalDocumentationScore / stolenItems.count
        XCTAssertGreaterThanOrEqual(averageDocumentationScore, 80, "Average documentation should be insurance-ready")
        
        print("🔍 Multi-Item Claim Preparation Journey:")
        print("   • Total Items: \\(stolenItems.count)")
        print("   • Total Value: $\\(totalClaimValue)")
        print("   • High-Value Items: \\(highValueItems.count)")
        print("   • Avg Documentation Score: \\(averageDocumentationScore)%")
        print("   • Room Breakdown: \\(roomBreakdown.keys.joined(separator: ", "))")
    }
    
    func testWarrantyExpirationWorkflowJourney() async throws {
        // Journey: User monitors warranty expiration for proactive insurance planning
        // Flow: Items with Warranties -> Check Expiration -> Plan Coverage -> Update Insurance
        
        let context = temporaryContainer.mainContext
        
        // Step 1: Create items with various warranty statuses
        let warrantiedItems = createWarrantyTestScenarios(context: context)
        
        // Step 2: Analyze warranty status across all items
        let currentDate = Date()
        var expiringWithin30Days: [Item] = []
        var expiringWithin90Days: [Item] = []
        var expiredWarranties: [Item] = []
        var activeWarranties: [Item] = []
        
        for item in warrantiedItems {
            guard let warranty = item.warranty else { continue }
            
            let daysUntilExpiration = Calendar.current.dateComponents(
                [.day], from: currentDate, to: warranty.expiresAt
            ).day ?? 0
            
            if daysUntilExpiration < 0 {
                expiredWarranties.append(item)
            } else if daysUntilExpiration <= 30 {
                expiringWithin30Days.append(item)
            } else if daysUntilExpiration <= 90 {
                expiringWithin90Days.append(item)
            } else {
                activeWarranties.append(item)
            }
        }
        
        // Step 3: Prioritize items by value and warranty status
        let urgentItems = expiringWithin30Days.sorted { ($0.purchasePrice ?? 0) > ($1.purchasePrice ?? 0) }
        let planningItems = expiringWithin90Days.sorted { ($0.purchasePrice ?? 0) > ($1.purchasePrice ?? 0) }
        
        // Step 4: Calculate insurance coverage gap
        let expiredValue = expiredWarranties.reduce(0) { $0 + ($1.purchasePrice ?? 0) }
        let expiringValue = expiringWithin90Days.reduce(0) { $0 + ($1.purchasePrice ?? 0) }
        let totalExposure = expiredValue + expiringValue
        
        // Step 5: Verify warranty management effectiveness
        XCTAssertGreaterThan(warrantiedItems.count, 0, "Should have items with warranties")
        XCTAssertGreaterThanOrEqual(activeWarranties.count, 0, "Should track active warranties")
        
        if !urgentItems.isEmpty {
            XCTAssertGreaterThan(urgentItems.first?.purchasePrice ?? 0, 0, "Urgent items should have value")
        }
        
        // Step 6: Generate warranty action plan
        var actionPlan: [String] = []
        
        if !urgentItems.isEmpty {
            actionPlan.append("Renew \\(urgentItems.count) warranty(ies) expiring within 30 days")
        }
        
        if !planningItems.isEmpty {
            actionPlan.append("Plan renewal for \\(planningItems.count) warranty(ies) expiring within 90 days")
        }
        
        if totalExposure > 1000 {
            actionPlan.append("Review insurance coverage for $\\(totalExposure) in warranty gaps")
        }
        
        print("📅 Warranty Expiration Workflow Journey:")
        print("   • Total Warrantied Items: \\(warrantiedItems.count)")
        print("   • Active Warranties: \\(activeWarranties.count)")
        print("   • Expiring Soon (30d): \\(expiringWithin30Days.count)")
        print("   • Expiring Later (90d): \\(expiringWithin90Days.count)")
        print("   • Expired: \\(expiredWarranties.count)")
        print("   • Total Coverage Gap: $\\(totalExposure)")
        print("   • Action Items: \\(actionPlan.count)")
        
        XCTAssertFalse(actionPlan.isEmpty || warrantiedItems.isEmpty, "Should generate actionable warranty insights")
    }
    
    func testDamageAssessmentToClaimJourney() async throws {
        // Journey: User documents damage after incident and prepares claim
        // Flow: Document Damage -> Assess Value -> Compare Original -> Generate Claim
        
        let context = temporaryContainer.mainContext
        
        // Step 1: Create original items before damage
        let originalItems = createOriginalItemsForDamage(context: context)
        
        // Step 2: Document damage to items
        let damagedItems = simulateDamageIncident(items: originalItems)
        
        // Step 3: Calculate damage assessment
        var totalOriginalValue: Decimal = 0
        var totalDamageValue: Decimal = 0
        var totalRemainingValue: Decimal = 0
        
        for item in damagedItems {
            let originalValue = item.purchasePrice ?? 0
            // Simulate damage percentage based on condition
            let damagePercentage: Decimal
            
            switch item.itemCondition {
            case .destroyed:
                damagePercentage = 100
            case .poor:
                damagePercentage = 80
            case .fair:
                damagePercentage = 50
            case .good:
                damagePercentage = 25
            case .excellent:
                damagePercentage = 0
            }
            
            let damageValue = originalValue * damagePercentage / 100
            let remainingValue = originalValue - damageValue
            
            totalOriginalValue += originalValue
            totalDamageValue += damageValue
            totalRemainingValue += remainingValue
        }
        
        // Step 4: Categorize damage by severity
        let totalLoss = damagedItems.filter { $0.itemCondition == .destroyed }
        let majorDamage = damagedItems.filter { $0.itemCondition == .poor }
        let moderateDamage = damagedItems.filter { $0.itemCondition == .fair }
        let minorDamage = damagedItems.filter { $0.itemCondition == .good }
        
        // Step 5: Calculate claim priority
        let highValueDamaged = damagedItems.filter { 
            ($0.purchasePrice ?? 0) >= 1000 && $0.itemCondition != .excellent 
        }
        
        // Step 6: Verify damage assessment accuracy
        XCTAssertGreaterThan(totalOriginalValue, 0, "Should have original value")
        XCTAssertGreaterThan(totalDamageValue, 0, "Should have calculated damage")
        XCTAssertEqual(totalOriginalValue, totalDamageValue + totalRemainingValue, "Value calculation should be accurate")
        
        // Step 7: Generate damage report insights
        let damagePercentage = (totalDamageValue / totalOriginalValue) * 100
        let claimRecommendation: String
        
        if damagePercentage >= 75 {
            claimRecommendation = "Major claim - Total loss scenario"
        } else if damagePercentage >= 50 {
            claimRecommendation = "Significant claim - Detailed documentation required"
        } else if damagePercentage >= 25 {
            claimRecommendation = "Moderate claim - Item-by-item assessment needed"
        } else {
            claimRecommendation = "Minor claim - Focus on high-value items"
        }
        
        print("💥 Damage Assessment to Claim Journey:")
        print("   • Items Assessed: \\(damagedItems.count)")
        print("   • Original Value: $\\(totalOriginalValue)")
        print("   • Damage Value: $\\(totalDamageValue)")
        print("   • Remaining Value: $\\(totalRemainingValue)")
        print("   • Damage Percentage: \\(damagePercentage)%")
        print("   • Total Loss: \\(totalLoss.count) items")
        print("   • Major Damage: \\(majorDamage.count) items")
        print("   • High-Value Affected: \\(highValueDamaged.count) items")
        print("   • Recommendation: \\(claimRecommendation)")
        
        XCTAssertGreaterThan(damagePercentage, 0, "Should detect damage in assessment")
        XCTAssertFalse(claimRecommendation.isEmpty, "Should provide claim recommendation")
    }
    
    // MARK: - Helper Methods for User Journey Testing
    
    private func createStolenItem(
        name: String,
        value: Int,
        category: NestoryCategory,
        room: String
    ) -> Item {
        let item = Item()
        item.name = name
        item.purchasePrice = Decimal(value)
        item.purchaseDate = Date().addingTimeInterval(-Double.random(in: 86400...31536000)) // 1 day to 1 year ago
        item.category = category
        item.room = room
        item.itemCondition = .excellent // Assume good condition before theft
        item.itemDescription = "High-quality \\(name.lowercased()) stolen in home break-in incident"
        return item
    }
    
    private func createWarrantyTestScenarios(context: ModelContext) -> [Item] {
        let items: [Item] = []
        let currentDate = Date()
        
        // Create items with different warranty scenarios
        let warrantyScenarios: [(String, Int, TimeInterval)] = [
            ("MacBook Pro", 2499, -86400 * 30),     // Expired 30 days ago
            ("iPhone 15", 999, 86400 * 15),         // Expires in 15 days
            ("iPad Air", 599, 86400 * 45),          // Expires in 45 days  
            ("Apple Watch", 399, 86400 * 180),      // Expires in 6 months
            ("AirPods Pro", 249, 86400 * 365),      // Expires in 1 year
        ]
        
        var resultItems: [Item] = []
        
        for (name, value, timeOffset) in warrantyScenarios {
            let item = Item()
            item.name = name
            item.purchasePrice = Decimal(value)
            item.purchaseDate = currentDate.addingTimeInterval(-86400 * 30) // Purchased 30 days ago
            
            let warranty = Warranty(
                provider: "Apple Inc.",
                type: .manufacturer,
                startDate: item.purchaseDate ?? currentDate,
                expiresAt: currentDate.addingTimeInterval(timeOffset)
            )
            warranty.item = item
            item.warranty = warranty
            
            context.insert(item)
            context.insert(warranty)
            resultItems.append(item)
        }
        
        do {
            try context.save()
        } catch {
            XCTFail("Failed to save warranty test scenarios: \\(error)")
        }
        
        return resultItems
    }
    
    private func createOriginalItemsForDamage(context: ModelContext) -> [Item] {
        let items = [
            createItemForDamageTest(name: "Living Room TV", value: 2500, room: "Living Room"),
            createItemForDamageTest(name: "Kitchen Appliances", value: 3500, room: "Kitchen"),
            createItemForDamageTest(name: "Bedroom Furniture", value: 1800, room: "Master Bedroom"),
            createItemForDamageTest(name: "Home Office Setup", value: 4200, room: "Home Office"),
            createItemForDamageTest(name: "Jewelry Collection", value: 5500, room: "Master Bedroom")
        ]
        
        for item in items {
            context.insert(item)
        }
        
        do {
            try context.save()
        } catch {
            XCTFail("Failed to save original items for damage test: \\(error)")
        }
        
        return items
    }
    
    private func createItemForDamageTest(name: String, value: Int, room: String) -> Item {
        let item = Item()
        item.name = name
        item.purchasePrice = Decimal(value)
        item.purchaseDate = Date().addingTimeInterval(-86400 * 180) // 6 months ago
        item.room = room
        item.itemCondition = .excellent // Original condition before damage
        item.itemDescription = "\\(name) in excellent condition before incident"
        return item
    }
    
    private func simulateDamageIncident(items: [Item]) -> [Item] {
        // Simulate water damage incident with varying severity
        let damageScenarios: [ItemCondition] = [.destroyed, .poor, .fair, .good, .excellent]
        
        for (index, item) in items.enumerated() {
            // Apply damage based on room/location exposure
            switch item.room {
            case "Kitchen":
                item.itemCondition = .destroyed // Worst damage from water source
                item.conditionNotes = "Severe water damage from pipe burst - total loss"
            case "Living Room":
                item.itemCondition = .poor // Major damage from flooding
                item.conditionNotes = "Extensive water damage - electronics non-functional"
            case "Master Bedroom":
                item.itemCondition = .fair // Moderate damage
                item.conditionNotes = "Water damage to base/legs, some functionality affected"
            case "Home Office":
                item.itemCondition = .good // Minor damage
                item.conditionNotes = "Minor water exposure - mostly cosmetic damage"
            default:
                item.itemCondition = .excellent // No damage
            }
            
            item.lastConditionUpdate = Date()
        }
        
        return items
    }
}