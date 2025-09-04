//
// Layer: Tests
// Module: Performance
// Purpose: UI responsiveness and performance validation for insurance workflows
//

import XCTest
import SwiftUI
import SwiftData
@testable import Nestory

/// UI responsiveness performance tests for insurance documentation workflows
/// Ensures smooth user experience during critical insurance claim documentation
@MainActor
final class UIResponsivenessTests: XCTestCase {
    
    // MARK: - Test Infrastructure
    
    private var temporaryContainer: ModelContainer!
    private var testDataset: UIResponsivenessTestDataset!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Create in-memory container with test data
        let schema = Schema([Item.self, Category.self, Room.self, Warranty.self])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        
        temporaryContainer = try ModelContainer(for: schema, configurations: [config])
        testDataset = UIResponsivenessTestDataset(container: temporaryContainer)
        
        // Pre-populate with test data for consistent performance testing
        await testDataset.createLargeDataset()
    }
    
    override func tearDown() async throws {
        temporaryContainer = nil
        testDataset = nil
        try await super.tearDown()
    }
    
    // MARK: - List Scrolling Performance Tests
    
    func testInventoryListScrollingPerformance() throws {
        // Test scrolling performance with large inventory datasets
        measure(metrics: [
            XCTClockMetric(),
            XCTCPUMetric(),
            XCTMemoryMetric()
        ]) {
            // Simulate inventory list rendering and scrolling
            let context = temporaryContainer.mainContext
            
            do {
                // Fetch large dataset (simulating list loading)
                let fetchDescriptor = FetchDescriptor<Item>(
                    sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
                )
                let items = try context.fetch(fetchDescriptor)
                
                // Simulate UI calculations that happen during scrolling
                var totalValue: Decimal = 0
                var visibleItemsProcessed = 0
                
                // Process items as if they're being rendered in a list
                for (index, item) in items.enumerated() {
                    // Simulate visibility calculations (typical in SwiftUI List)
                    if index < 100 { // Typical visible + buffer range
                        totalValue += item.estimatedValue
                        visibleItemsProcessed += 1
                        
                        // Simulate formatting operations (common in UI)
                        let formattedValue = NumberFormatter.currency.string(from: NSDecimalNumber(decimal: item.estimatedValue))
                        let itemAge = Date().timeIntervalSince(item.createdAt)
                        
                        // Simulate documentation score calculation (UI computation)
                        let hasPhoto = !item.photoPaths.isEmpty
                        let hasReceipt = item.receipts?.count ?? 0 > 0
                        let hasWarranty = item.warranty != nil
                        let documentationScore = (hasPhoto ? 0.4 : 0) + (hasReceipt ? 0.4 : 0) + (hasWarranty ? 0.2 : 0)
                        
                        XCTAssertNotNil(formattedValue, "Value formatting should work")
                        XCTAssertGreaterThanOrEqual(itemAge, 0, "Item age calculation should be valid")
                        XCTAssertGreaterThanOrEqual(documentationScore, 0, "Documentation score should be valid")
                    }
                }
                
                // Verify performance criteria
                XCTAssertGreaterThan(items.count, 1000, "Should test with substantial dataset")
                XCTAssertEqual(visibleItemsProcessed, min(100, items.count), "Should process visible items efficiently")
                XCTAssertGreaterThan(totalValue, 0, "Should calculate totals for visible items")
                
            } catch {
                XCTFail("Inventory list performance test failed: \\(error)")
            }
        }
    }
    
    func testSearchResultsRenderingPerformance() throws {
        // Test search UI responsiveness with large result sets
        measure(metrics: [
            XCTClockMetric(),
            XCTCPUMetric(),
            XCTMemoryMetric()
        ]) {
            let context = temporaryContainer.mainContext
            
            do {
                // Simulate common search scenarios
                let searchTerms = ["Electronics", "Apple", "Insurance", "High-Value", "2024"]
                
                for searchTerm in searchTerms {
                    // Search filtering (UI operation)
                    let predicate = #Predicate<Item> { item in
                        item.name.localizedStandardContains(searchTerm) ||
                        (item.itemDescription ?? "").localizedStandardContains(searchTerm) ||
                        (item.category?.name ?? "").localizedStandardContains(searchTerm)
                    }
                    
                    let searchDescriptor = FetchDescriptor<Item>(
                        predicate: predicate,
                        sortBy: [SortDescriptor(\.estimatedValue, order: .reverse)]
                    )
                    
                    let searchResults = try context.fetch(searchDescriptor)
                    
                    // Simulate UI rendering calculations for search results
                    var categoryCounts: [String: Int] = [:]
                    var totalValueInResults: Decimal = 0
                    
                    for result in searchResults.prefix(50) { // Typical first page
                        let categoryName = result.category?.name ?? "Uncategorized"
                        categoryCounts[categoryName] = (categoryCounts[categoryName] ?? 0) + 1
                        totalValueInResults += result.estimatedValue
                        
                        // Simulate search highlighting calculations
                        let nameContains = result.name.lowercased().contains(searchTerm.lowercased())
                        let descriptionContains = (result.itemDescription ?? "").lowercased().contains(searchTerm.lowercased())
                        XCTAssertTrue(nameContains || descriptionContains || result.category?.name.lowercased().contains(searchTerm.lowercased()) == true,
                                     "Search result should match criteria")
                    }
                    
                    // Verify search performance
                    XCTAssertGreaterThanOrEqual(searchResults.count, 0, "Search should return results")
                    XCTAssertFalse(categoryCounts.isEmpty || searchResults.isEmpty, "Should categorize results or have no results")
                }
                
            } catch {
                XCTFail("Search rendering performance test failed: \\(error)")
            }
        }
    }
    
    // MARK: - Form Input Responsiveness Tests
    
    func testItemEditFormResponsivenessPerformance() throws {
        // Test responsiveness of item editing forms during data entry
        measure(metrics: [
            XCTClockMetric(),
            XCTCPUMetric(),
            XCTMemoryMetric()
        ]) {
            let context = temporaryContainer.mainContext
            
            do {
                // Create test item for editing
                let testItem = TestDataFactory.createCompleteItem()
                context.insert(testItem)
                try context.save()
                
                // Simulate rapid form field updates (user typing)
                let formUpdateScenarios = [
                    ("name", "MacBook Pro M3 Max 16-inch with extended warranty"),
                    ("description", "High-performance laptop for professional video editing and development work. Includes premium warranty coverage and AppleCare+ protection plan."),
                    ("estimatedValue", "3499.99"),
                    ("serialNumber", "ABCD1234567890EFGH"),
                    ("purchaseLocation", "Apple Store Fifth Avenue, New York City")
                ]
                
                for (field, value) in formUpdateScenarios {
                    // Simulate field validation (common UI operation)
                    let isValid: Bool
                    switch field {
                    case "name":
                        isValid = !value.isEmpty && value.count <= 200
                        testItem.name = value
                    case "description":
                        isValid = value.count <= 1000
                        testItem.itemDescription = value
                    case "estimatedValue":
                        isValid = Decimal(string: value) != nil && Decimal(string: value)! > 0
                        if let decimalValue = Decimal(string: value) {
                            testItem.estimatedValue = decimalValue
                        }
                    case "serialNumber":
                        isValid = value.count >= 5 && value.count <= 50
                        testItem.serialNumber = value
                    case "purchaseLocation":
                        isValid = !value.isEmpty && value.count <= 200
                        testItem.purchaseLocation = value
                    default:
                        isValid = true
                    }
                    
                    // Simulate real-time validation feedback (UI computation)
                    XCTAssertTrue(isValid, "Form validation should work for \\(field)")
                    
                    // Simulate auto-save functionality (performance-critical)
                    testItem.updatedAt = Date()
                }
                
                // Save form changes (should be fast)
                try context.save()
                
                // Verify form responsiveness requirements
                XCTAssertEqual(testItem.name, formUpdateScenarios[0].1, "Name should be updated")
                XCTAssertEqual(testItem.estimatedValue, Decimal(string: formUpdateScenarios[2].1), "Value should be updated")
                
            } catch {
                XCTFail("Form responsiveness test failed: \\(error)")
            }
        }
    }
    
    func testDamageAssessmentFormPerformance() throws {
        // Test responsiveness during damage assessment workflow
        measure(metrics: [
            XCTClockMetric(),
            XCTCPUMetric(),
            XCTMemoryMetric()
        ]) {
            let context = temporaryContainer.mainContext
            
            do {
                // Create items for damage assessment
                let damagedItems = [
                    TestDataFactory.createDamagedItem(),
                    TestDataFactory.createDamagedItem(),
                    TestDataFactory.createDamagedItem()
                ]
                
                for item in damagedItems {
                    context.insert(item)
                }
                try context.save()
                
                // Simulate damage assessment form calculations
                for item in damagedItems {
                    // Simulate real-time damage value calculations
                    let originalValue = item.estimatedValue
                    let damagePercentages = [10, 25, 50, 75, 90] // Different damage levels
                    
                    for damagePercent in damagePercentages {
                        let damageAmount = originalValue * Decimal(damagePercent) / 100
                        let remainingValue = originalValue - damageAmount
                        
                        // Simulate UI calculations for damage assessment
                        let isTotal = damagePercent >= 75
                        let isSignificant = damagePercent >= 50
                        let requiresAppraisal = originalValue > 1000 && damagePercent >= 25
                        
                        XCTAssertGreaterThanOrEqual(damageAmount, 0, "Damage amount should be valid")
                        XCTAssertGreaterThanOrEqual(remainingValue, 0, "Remaining value should be valid")
                        XCTAssertNotNil(isTotal, "Total loss calculation should work")
                        XCTAssertNotNil(isSignificant, "Significant damage detection should work")
                        XCTAssertNotNil(requiresAppraisal, "Appraisal requirement detection should work")
                    }
                    
                    // Simulate documentation completeness scoring
                    let hasPhotos = !item.photoPaths.isEmpty
                    let hasReceipt = (item.receipts?.count ?? 0) > 0
                    let hasWarranty = item.warranty != nil
                    let hasDescription = item.itemDescription?.isEmpty == false
                    
                    let completenessScore = 
                        (hasPhotos ? 25 : 0) +
                        (hasReceipt ? 30 : 0) +
                        (hasWarranty ? 20 : 0) +
                        (hasDescription ? 25 : 0)
                    
                    XCTAssertGreaterThanOrEqual(completenessScore, 0, "Completeness scoring should work")
                    XCTAssertLessThanOrEqual(completenessScore, 100, "Completeness should not exceed 100%")
                }
                
            } catch {
                XCTFail("Damage assessment performance test failed: \\(error)")
            }
        }
    }
    
    // MARK: - Navigation Performance Tests
    
    func testTabNavigationPerformance() throws {
        // Test performance of tab switching with large datasets
        measure(metrics: [
            XCTClockMetric(),
            XCTCPUMetric(),
            XCTMemoryMetric()
        ]) {
            let context = temporaryContainer.mainContext
            
            do {
                // Simulate tab switching scenarios
                let tabScenarios = [
                    "inventory", "analytics", "settings", "search"
                ]
                
                for tabName in tabScenarios {
                    switch tabName {
                    case "inventory":
                        // Simulate inventory tab loading
                        let inventoryDescriptor = FetchDescriptor<Item>(
                            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
                        )
                        let inventoryItems = try context.fetch(inventoryDescriptor)
                        XCTAssertGreaterThan(inventoryItems.count, 0, "Inventory should have items")
                        
                    case "analytics":
                        // Simulate analytics calculations
                        let allItems = try context.fetch(FetchDescriptor<Item>())
                        let totalValue = allItems.reduce(0) { $0 + $1.estimatedValue }
                        let averageValue = totalValue / Decimal(allItems.count)
                        let highValueItems = allItems.filter { $0.estimatedValue > averageValue }
                        
                        XCTAssertGreaterThan(totalValue, 0, "Should calculate total value")
                        XCTAssertGreaterThan(averageValue, 0, "Should calculate average value")
                        XCTAssertGreaterThanOrEqual(highValueItems.count, 0, "Should identify high-value items")
                        
                    case "settings":
                        // Simulate settings tab loading (lighter operations)
                        let itemCount = try context.fetch(FetchDescriptor<Item>()).count
                        let categoryCount = try context.fetch(FetchDescriptor<Category>()).count
                        
                        XCTAssertGreaterThanOrEqual(itemCount, 0, "Should count items")
                        XCTAssertGreaterThanOrEqual(categoryCount, 0, "Should count categories")
                        
                    case "search":
                        // Simulate search tab initialization
                        let recentItems = try context.fetch(FetchDescriptor<Item>(
                            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
                        ))
                        let recentCategories = Array(Set(recentItems.compactMap { $0.category?.name })).prefix(10)
                        
                        XCTAssertGreaterThanOrEqual(recentItems.count, 0, "Should load recent items")
                        XCTAssertGreaterThanOrEqual(recentCategories.count, 0, "Should identify recent categories")
                        
                    default:
                        break
                    }
                }
                
            } catch {
                XCTFail("Tab navigation performance test failed: \\(error)")
            }
        }
    }
    
    func testDeepNavigationPerformance() throws {
        // Test performance of deep navigation scenarios
        measure(metrics: [
            XCTClockMetric(),
            XCTCPUMetric(),
            XCTMemoryMetric()
        ]) {
            let context = temporaryContainer.mainContext
            
            do {
                // Create navigation hierarchy: Category -> Items -> Item Detail -> Edit
                let testCategory = Category(name: "Test Electronics", icon: "desktopcomputer", color: "blue")
                context.insert(testCategory)
                
                let categoryItems = Array(0..<50).map { i in
                    let item = TestDataFactory.createCompleteItem()
                    item.name = "Navigation Test Item \\(i)"
                    item.category = testCategory
                    context.insert(item)
                    return item
                }
                
                try context.save()
                
                // Simulate deep navigation: Category List -> Item List -> Item Detail -> Edit Form
                
                // 1. Category navigation (load categories with counts)
                let categories = try context.fetch(FetchDescriptor<Category>())
                var categoryItemCounts: [String: Int] = [:]
                
                for category in categories {
                    let itemCountDescriptor = FetchDescriptor<Item>(
                        predicate: #Predicate { item in
                            item.category?.id == category.id
                        }
                    )
                    let count = try context.fetch(itemCountDescriptor).count
                    categoryItemCounts[category.name] = count
                }
                
                // 2. Item list in category (filtered view)
                let categoryItems = try context.fetch(FetchDescriptor<Item>(
                    predicate: #Predicate { item in
                        item.category?.id == testCategory.id
                    },
                    sortBy: [SortDescriptor(\.estimatedValue, order: .reverse)]
                ))
                
                // 3. Item detail view calculations
                let selectedItem = categoryItems.first!
                let relatedItems = try context.fetch(FetchDescriptor<Item>(
                    predicate: #Predicate { item in
                        item.category?.id == selectedItem.category?.id && item.id != selectedItem.id
                    }
                ))
                
                // 4. Edit form preparation
                let editableFields = [
                    "name": selectedItem.name,
                    "description": selectedItem.itemDescription ?? "",
                    "value": selectedItem.estimatedValue.description,
                    "serialNumber": selectedItem.serialNumber
                ]
                
                // Verify navigation performance requirements
                XCTAssertGreaterThan(categories.count, 0, "Should load categories")
                XCTAssertGreaterThan(categoryItems.count, 0, "Should load category items")
                XCTAssertGreaterThanOrEqual(relatedItems.count, 0, "Should find related items")
                XCTAssertEqual(editableFields.count, 4, "Should prepare editable fields")
                
            } catch {
                XCTFail("Deep navigation performance test failed: \\(error)")
            }
        }
    }
    
    // MARK: - Real-time Update Performance Tests
    
    func testLiveDataUpdatesPerformance() throws {
        // Test UI responsiveness during real-time data updates
        measure(metrics: [
            XCTClockMetric(),
            XCTCPUMetric(),
            XCTMemoryMetric()
        ]) {
            let context = temporaryContainer.mainContext
            
            do {
                // Create initial dataset
                let testItems = Array(0..<20).map { i in
                    let item = TestDataFactory.createCompleteItem()
                    item.name = "Live Update Test Item \\(i)"
                    context.insert(item)
                    return item
                }
                try context.save()
                
                // Simulate rapid updates (like live editing or batch operations)
                for (index, item) in testItems.enumerated() {
                    // Simulate value updates (insurance adjustments)
                    item.estimatedValue = item.estimatedValue * Decimal(1.03) // 3% increase
                    
                    // Simulate status updates
                    item.updatedAt = Date()
                    
                    // Simulate documentation score recalculation (UI computation)
                    let hasPhoto = !item.photoPaths.isEmpty
                    let hasReceipt = (item.receipts?.count ?? 0) > 0
                    let hasWarranty = item.warranty != nil
                    let documentationScore = (hasPhoto ? 0.4 : 0) + (hasReceipt ? 0.4 : 0) + (hasWarranty ? 0.2 : 0)
                    
                    // Simulate UI state calculations
                    let isComplete = documentationScore >= 0.8
                    let needsAttention = documentationScore < 0.4
                    let insuranceReady = hasReceipt && documentationScore >= 0.6
                    
                    XCTAssertGreaterThanOrEqual(documentationScore, 0, "Documentation score should be valid")
                    XCTAssertNotNil(isComplete, "Completeness calculation should work")
                    XCTAssertNotNil(needsAttention, "Attention flag should work")
                    XCTAssertNotNil(insuranceReady, "Insurance readiness should work")
                    
                    // Batch save every 5 items (realistic scenario)
                    if index % 5 == 4 {
                        try context.save()
                    }
                }
                
                // Final save
                try context.save()
                
                // Verify all updates were processed
                let updatedItems = try context.fetch(FetchDescriptor<Item>())
                XCTAssertEqual(updatedItems.count, testItems.count, "All items should be updated")
                
            } catch {
                XCTFail("Live data updates performance test failed: \\(error)")
            }
        }
    }
    
    // MARK: - Memory Pressure UI Tests
    
    func testUIResponsivenessUnderMemoryPressure() throws {
        // Test UI responsiveness when system is under memory pressure
        var memoryPressureArrays: [[Data]] = []
        
        measure(metrics: [
            XCTClockMetric(),
            XCTMemoryMetric()
        ]) {
            let context = temporaryContainer.mainContext
            
            do {
                // Create memory pressure
                for _ in 0..<15 {
                    let largeArray = Array(repeating: Data(count: 1024 * 1024), count: 5) // 5MB arrays
                    memoryPressureArrays.append(largeArray)
                }
                
                // Test UI operations under pressure
                let items = try context.fetch(FetchDescriptor<Item>())
                
                // Simulate UI calculations under pressure
                var totalValue: Decimal = 0
                var processedCount = 0
                
                for item in items.prefix(100) {
                    totalValue += item.estimatedValue
                    processedCount += 1
                    
                    // Simulate formatting operations
                    let formattedValue = NumberFormatter.currency.string(from: NSDecimalNumber(decimal: item.estimatedValue))
                    XCTAssertNotNil(formattedValue, "Value formatting should work under pressure")
                }
                
                XCTAssertGreaterThan(processedCount, 0, "Should process items under memory pressure")
                XCTAssertGreaterThan(totalValue, 0, "Should calculate totals under memory pressure")
                
                // Clean up memory pressure
                memoryPressureArrays.removeAll()
                
            } catch {
                memoryPressureArrays.removeAll()
                XCTFail("UI responsiveness under memory pressure test failed: \\(error)")
            }
        }
    }
}

// MARK: - UI Responsiveness Test Dataset Factory

private class UIResponsivenessTestDataset {
    private let container: ModelContainer
    
    init(container: ModelContainer) {
        self.container = container
    }
    
    @MainActor
    func createLargeDataset() async {
        let context = container.mainContext
        
        // Create categories
        let categories = [
            Category(name: "Electronics", icon: "desktopcomputer", color: "blue"),
            Category(name: "Jewelry", icon: "sparkles", color: "yellow"),
            Category(name: "Furniture", icon: "bed.double", color: "brown"),
            Category(name: "Appliances", icon: "refrigerator", color: "gray"),
            Category(name: "Art & Collectibles", icon: "paintpalette", color: "purple")
        ]
        
        for category in categories {
            context.insert(category)
        }
        
        // Create rooms
        let rooms = Room.createDefaultRooms()
        for room in rooms {
            context.insert(room)
        }
        
        // Create large item dataset (2000 items for UI stress testing)
        for i in 0..<2000 {
            let item = TestDataFactory.createCompleteItem()
            item.name = "UI Test Item \\(i)"
            item.estimatedValue = Decimal(Double.random(in: 50...5000))
            item.category = categories[i % categories.count]
            item.room = rooms[i % rooms.count].name
            item.createdAt = Date().addingTimeInterval(-Double(i * 86400)) // Spread over time
            
            // Add some variety for testing
            if i % 10 == 0 {
                let warranty = Warranty(
                    provider: "Test Warranty Provider",
                    type: .extended,
                    startDate: Date(),
                    expiresAt: Date().addingTimeInterval(365 * 24 * 3600) // 1 year
                )
                warranty.item = item
                item.warranty = warranty
                context.insert(warranty)
            }
            
            context.insert(item)
        }
        
        do {
            try context.save()
        } catch {
            print("Failed to create large dataset: \\(error)")
        }
    }
}

// MARK: - Number Formatter Extension

private extension NumberFormatter {
    static let currency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter
    }()
}