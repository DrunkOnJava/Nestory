//
// Layer: Tests
// Module: Performance  
// Purpose: XCTestMetrics performance tests for rich Test tab data and Insights
//

import XCTest
import SwiftData
@testable import Nestory

final class PerformanceTests: XCTestCase {
    
    // MARK: - Test Infrastructure
    
    private var temporaryContainer: ModelContainer!
    private var mockInventoryService: MockInventoryService!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Create in-memory container for performance testing
        let schema = Schema([Item.self, Category.self, Room.self, Warranty.self])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        
        temporaryContainer = try ModelContainer(for: Item.self, Category.self, Room.self, Warranty.self, configurations: config)
        mockInventoryService = MockInventoryService()
    }
    
    override func tearDown() async throws {
        temporaryContainer = nil
        mockInventoryService = nil
        try await super.tearDown()
    }
    
    // MARK: - Large Dataset Insurance Performance Tests
    
    @MainActor func testLargeInventoryLoadingPerformance() throws {
        // Test loading performance with 5000+ insurance items
        let items = createLargeInsuranceDataset(count: 5000)
        let context = temporaryContainer.mainContext
        
        // Insert test data
        for item in items {
            context.insert(item)
        }
        try context.save()
        
        // Measure fetch performance
        measure(metrics: [
            XCTClockMetric(),
            XCTCPUMetric(), 
            XCTMemoryMetric(),
            XCTStorageMetric()
        ]) {
            do {
                let fetchDescriptor = FetchDescriptor<Item>()
                let fetchedItems = try context.fetch(fetchDescriptor)
                XCTAssertGreaterThanOrEqual(fetchedItems.count, 5000)
            } catch {
                XCTFail("Large dataset fetch failed: \(error)")
            }
        }
    }
    
    @MainActor func testInsuranceReportGenerationPerformance() throws {
        // Test PDF generation performance for large insurance claims
        let items = createHighValueInsuranceItems(count: 500)
        let context = temporaryContainer.mainContext
        
        for item in items {
            context.insert(item)
        }
        try context.save()
        
        measure(metrics: [
            XCTClockMetric(),
            XCTCPUMetric(),
            XCTMemoryMetric(),
            XCTStorageMetric()
        ]) {
            // Simulate insurance report generation data processing
            let totalValue = items.reduce(0) { $0 + ($1.purchasePrice ?? 0) }
            let averageValue = totalValue / Decimal(items.count)
            let highValueItems = items.filter { ($0.purchasePrice ?? 0) > averageValue }
            
            XCTAssertGreaterThan(totalValue, 0)
            XCTAssertGreaterThan(highValueItems.count, 0)
            
            // Simulate report data aggregation
            var categoryTotals: [String: Decimal] = [:]
            for item in items {
                let category = item.category?.name ?? "Uncategorized"
                categoryTotals[category] = (categoryTotals[category] ?? 0) + (item.purchasePrice ?? 0)
            }
            
            XCTAssertFalse(categoryTotals.isEmpty)
        }
    }
    
    @MainActor func testSearchPerformanceWithLargeDataset() throws {
        // Test search performance across 10,000 insurance items
        let items = createDiverseInsuranceDataset(count: 10000)
        let context = temporaryContainer.mainContext
        
        for item in items {
            context.insert(item)
        }
        try context.save()
        
        measure(metrics: [
            XCTClockMetric(),
            XCTCPUMetric(),
            XCTMemoryMetric(),
            XCTStorageMetric()
        ]) {
            do {
                // Test various search scenarios
                let searchTerms = ["Apple", "Samsung", "Jewelry", "High-Value", "Electronics"]
                
                for term in searchTerms {
                    let predicate = #Predicate<Item> { item in
                        item.name.localizedStandardContains(term) ||
                        (item.itemDescription ?? "").localizedStandardContains(term)
                    }
                    let descriptor = FetchDescriptor<Item>(predicate: predicate)
                    let results = try context.fetch(descriptor)
                    
                    // Verify search returns reasonable results
                    if term == "Apple" || term == "Samsung" {
                        XCTAssertGreaterThan(results.count, 0, "Should find \(term) items")
                    }
                }
                
                // Test value-based search
                let highValuePredicate = #Predicate<Item> { item in
                    item.purchasePrice ?? 0 > 1000
                }
                let highValueDescriptor = FetchDescriptor<Item>(predicate: highValuePredicate)
                let highValueResults = try context.fetch(highValueDescriptor)
                
                XCTAssertGreaterThan(highValueResults.count, 0)
                
            } catch {
                XCTFail("Search performance test failed: \(error)")
            }
        }
    }
    
    @MainActor func testInsuranceAnalyticsPerformance() throws {
        // Test analytics calculations for large insurance portfolios
        let items = createComprehensiveInsurancePortfolio(count: 2000)
        let context = temporaryContainer.mainContext
        
        for item in items {
            context.insert(item)
        }
        try context.save()
        
        measure(metrics: [
            XCTClockMetric(),
            XCTCPUMetric(),
            XCTMemoryMetric()
        ]) {
            do {
                let allItems = try context.fetch(FetchDescriptor<Item>())
                
                // Comprehensive insurance analytics calculations
                let totalValue = allItems.reduce(0) { $0 + ($1.purchasePrice ?? 0) }
                let averageValue = totalValue / Decimal(allItems.count)
                
                // Category breakdown
                var categoryBreakdown: [String: (count: Int, value: Decimal)] = [:]
                for item in allItems {
                    let category = item.category?.name ?? "Uncategorized"
                    let existing = categoryBreakdown[category] ?? (count: 0, value: 0)
                    categoryBreakdown[category] = (
                        count: existing.count + 1,
                        value: existing.value + (item.purchasePrice ?? 0)
                    )
                }
                
                // Room-based analysis
                var roomAnalysis: [String: (count: Int, value: Decimal)] = [:]
                for item in allItems {
                    let room = item.room ?? "Unknown Location"
                    let existing = roomAnalysis[room] ?? (count: 0, value: 0)
                    roomAnalysis[room] = (
                        count: existing.count + 1,
                        value: existing.value + (item.purchasePrice ?? 0)
                    )
                }
                
                // Warranty expiration analysis
                let currentDate = Date()
                let expiringItems = allItems.filter { item in
                    guard let warranty = item.warranty else { return false }
                    let daysUntilExpiration = Calendar.current.dateComponents(
                        [.day], from: currentDate, to: warranty.expiresAt
                    ).day ?? 0
                    return daysUntilExpiration <= 90 && daysUntilExpiration > 0
                }
                
                // Purchase date analysis
                let recentPurchases = allItems.filter { item in
                    guard let purchaseDate = item.purchaseDate else { return false }
                    let monthsAgo = Calendar.current.dateComponents(
                        [.month], from: purchaseDate, to: currentDate
                    ).month ?? 0
                    return monthsAgo <= 12
                }
                
                // Verify calculations completed
                XCTAssertGreaterThan(totalValue, 0)
                XCTAssertGreaterThan(averageValue, 0)
                XCTAssertFalse(categoryBreakdown.isEmpty)
                XCTAssertFalse(roomAnalysis.isEmpty)
                XCTAssertGreaterThanOrEqual(expiringItems.count, 0)
                XCTAssertGreaterThan(recentPurchases.count, 0)
                
            } catch {
                XCTFail("Analytics performance test failed: \(error)")
            }
        }
    }
    
    @MainActor func testBulkDataOperationsPerformance() throws {
        // Test bulk operations for insurance data management
        measure(metrics: [
            XCTClockMetric(),
            XCTCPUMetric(),
            XCTMemoryMetric(),
            XCTStorageMetric()
        ]) {
            do {
                let context = temporaryContainer.mainContext
                
                // Bulk insert performance
                let items = createLargeInsuranceDataset(count: 1000)
                for item in items {
                    context.insert(item)
                }
                try context.save()
                
                // Bulk update performance 
                let fetchDescriptor = FetchDescriptor<Item>()
                let fetchedItems = try context.fetch(fetchDescriptor)
                
                // Update all items (simulate insurance value adjustment)
                for item in fetchedItems {
                    if let currentPrice = item.purchasePrice {
                        item.purchasePrice = currentPrice * 1.03 // 3% inflation adjustment
                    }
                }
                try context.save()
                
                // Bulk delete performance (simulate cleanup)
                let oldItems = fetchedItems.filter { item in
                    guard let purchaseDate = item.purchaseDate else { return false }
                    let yearsAgo = Calendar.current.dateComponents(
                        [.year], from: purchaseDate, to: Date()
                    ).year ?? 0
                    return yearsAgo > 20 // Remove very old items
                }
                
                for item in oldItems {
                    context.delete(item)
                }
                try context.save()
                
                XCTAssertGreaterThanOrEqual(fetchedItems.count, oldItems.count)
                
            } catch {
                XCTFail("Bulk operations performance test failed: \(error)")
            }
        }
    }
    
    // MARK: - Test Data Generation
    
    private func createLargeInsuranceDataset(count: Int) -> [Item] {
        var items: [Item] = []
        
        let categories = ["Electronics", "Jewelry", "Furniture", "Appliances", "Art", "Tools"]
        let rooms = ["Living Room", "Bedroom", "Kitchen", "Office", "Garage", "Basement"]
        
        for i in 0..<count {
            let item = Item(name: "Insurance Item \(i)")
            item.purchasePrice = Decimal(Double.random(in: 50...5000))
            item.itemDescription = "High-quality item for insurance documentation \(i)"
            item.serialNumber = "INS\(String(format: "%06d", i))"
            
            // Assign random category and room
            if i % 10 < categories.count {
                let category = Category(name: categories[i % categories.count], icon: "folder", colorHex: "#007AFF")
                item.category = category
            }
            
            items.append(item)
        }
        
        return items
    }
    
    private func createHighValueInsuranceItems(count: Int) -> [Item] {
        var items: [Item] = []
        
        let highValueItems = [
            ("Rolex Submariner", 8500),
            ("MacBook Pro M3", 3500),
            ("Diamond Ring", 12000),
            ("Steinway Piano", 75000),
            ("Original Artwork", 25000)
        ]
        
        for i in 0..<count {
            let template = highValueItems[i % highValueItems.count]
            let item = Item(name: "\(template.0) \(i)")
            item.purchasePrice = Decimal(template.1 + Int.random(in: -500...500))
            item.itemDescription = "High-value item requiring special insurance coverage"
            items.append(item)
        }
        
        return items
    }
    
    private func createDiverseInsuranceDataset(count: Int) -> [Item] {
        var items: [Item] = []
        
        let brands = ["Apple", "Samsung", "Sony", "LG", "Canon", "Nikon", "Dell", "HP"]
        let itemTypes = ["Laptop", "Phone", "Camera", "Watch", "Tablet", "TV", "Speaker"]
        
        for i in 0..<count {
            let brand = brands[i % brands.count]
            let type = itemTypes[i % itemTypes.count]
            
            let item = Item(name: "\(brand) \(type) Model \(i)")
            item.purchasePrice = Decimal(Double.random(in: 100...3000))
            item.itemDescription = "\(brand) \(type) with premium features and warranty"
            
            // Add some jewelry and high-value items
            if i % 50 == 0 {
                item.name = "Diamond Jewelry Piece \(i)"
                item.purchasePrice = Decimal(Double.random(in: 2000...15000))
                item.itemDescription = "High-Value jewelry requiring appraisal documentation"
            }
            
            items.append(item)
        }
        
        return items
    }
    
    private func createComprehensiveInsurancePortfolio(count: Int) -> [Item] {
        var items: [Item] = []
        
        // Create realistic insurance portfolio distribution
        let electronics = count * 40 / 100  // 40% electronics
        let jewelry = count * 15 / 100      // 15% jewelry
        let furniture = count * 20 / 100    // 20% furniture
        let appliances = count * 15 / 100   // 15% appliances
        let other = count - electronics - jewelry - furniture - appliances
        
        // Electronics
        for i in 0..<electronics {
            let item = Item(name: "Electronics Item \(i)")
            item.purchasePrice = Decimal(Double.random(in: 200...4000))
            let category = Category(name: "Electronics", icon: "desktopcomputer", colorHex: "#007AFF")
            item.category = category
            items.append(item)
        }
        
        // Jewelry
        for i in 0..<jewelry {
            let item = Item(name: "Jewelry Item \(i)")
            item.purchasePrice = Decimal(Double.random(in: 1000...20000))
            let category = Category(name: "Jewelry", icon: "sparkles", colorHex: "#FFD700")
            item.category = category
            items.append(item)
        }
        
        // Furniture
        for i in 0..<furniture {
            let item = Item(name: "Furniture Item \(i)")
            item.purchasePrice = Decimal(Double.random(in: 300...8000))
            let category = Category(name: "Furniture", icon: "bed.double", colorHex: "#8B4513")
            item.category = category
            items.append(item)
        }
        
        // Appliances
        for i in 0..<appliances {
            let item = Item(name: "Appliance Item \(i)")
            item.purchasePrice = Decimal(Double.random(in: 500...12000))
            let category = Category(name: "Appliances", icon: "refrigerator", colorHex: "#808080")
            item.category = category
            items.append(item)
        }
        
        // Other items
        for i in 0..<other {
            let item = Item(name: "Other Item \(i)")
            item.purchasePrice = Decimal(Double.random(in: 50...2000))
            items.append(item)
        }
        
        return items
    }
}