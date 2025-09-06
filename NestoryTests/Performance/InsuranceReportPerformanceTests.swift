//
// Layer: Tests
// Module: Performance
// Purpose: Performance testing for insurance PDF report generation
//

import XCTest
import SwiftData
import PDFKit
@testable import Nestory

/// Performance tests for insurance report generation
/// Ensures PDF generation meets SLA requirements for claim processing
@MainActor
final class XInsuranceReportPerformanceTests: XCTestCase { // DISABLED: Slow performance tests
    
    // MARK: - Test Infrastructure
    
    private var temporaryContainer: ModelContainer!
    private var insuranceReportService: LiveInsuranceReportService!
    private var mockDatasets: InsuranceReportTestDatasets!
    
    override func setUp() async throws {
        // Note: Not calling super.setUp() in async context due to Swift 6 concurrency
        
        // Create in-memory container for performance testing
        let schema = Schema([Item.self, Category.self, Warranty.self, Receipt.self])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        
        temporaryContainer = try ModelContainer(for: schema, configurations: [config])
        insuranceReportService = LiveInsuranceReportService()
        mockDatasets = InsuranceReportTestDatasets()
    }
    
    override func tearDown() async throws {
        temporaryContainer = nil
        insuranceReportService = nil
        mockDatasets = nil
        // Note: Not calling super.tearDown() in async context due to Swift 6 concurrency
    }
    
    // MARK: - PDF Generation Performance Tests
    
    func testSmallClaimReportGenerationPerformance() async throws {
        // Test performance for small insurance claims (10-50 items)
        let dataset = mockDatasets.createSmallInsuranceClaim()
        let options = ReportOptions(
            includePhotos: true,
            includeReceipts: true,
            template: .insuranceClaim
        )
        
        measure(metrics: [
            XCTClockMetric(),
            XCTCPUMetric(),
            XCTMemoryMetric()
        ]) {
            Task { @MainActor in
                do {
                    let pdfData = try await insuranceReportService.generateInsuranceReport(
                        items: dataset.items,
                        categories: dataset.categories,
                        options: options
                    )
                    
                    // Verify PDF was generated and has reasonable size
                    XCTAssertGreaterThan(pdfData.count, 1024, "PDF should be at least 1KB")
                    XCTAssertLessThan(pdfData.count, 10_000_000, "PDF should be under 10MB for small claims")
                    
                    // Verify PDF is valid
                    let pdfDocument = PDFDocument(data: pdfData)
                    XCTAssertNotNil(pdfDocument, "Generated data should be valid PDF")
                    XCTAssertGreaterThan(pdfDocument?.pageCount ?? 0, 0, "PDF should have pages")
                    
                } catch {
                    XCTFail("Small claim PDF generation failed: \\(error)")
                }
            }
        }
    }
    
    func testMediumClaimReportGenerationPerformance() async throws {
        // Test performance for medium insurance claims (100-500 items)
        let dataset = mockDatasets.createMediumInsuranceClaim()
        let options = ReportOptions(
            includePhotos: true,
            includeReceipts: true,
            groupByRoom: true,
            template: .detailed
        )
        
        measure(metrics: [
            XCTClockMetric(),
            XCTCPUMetric(),
            XCTMemoryMetric(),
            XCTStorageMetric()
        ]) {
            Task { @MainActor in
                do {
                    let pdfData = try await insuranceReportService.generateInsuranceReport(
                        items: dataset.items,
                        categories: dataset.categories,
                        options: options
                    )
                    
                    // Verify PDF generation metrics
                    XCTAssertGreaterThan(pdfData.count, 10_000, "PDF should be substantial for medium claims")
                    XCTAssertLessThan(pdfData.count, 50_000_000, "PDF should be under 50MB")
                    
                    // Verify PDF structure
                    let pdfDocument = PDFDocument(data: pdfData)
                    XCTAssertNotNil(pdfDocument, "Generated data should be valid PDF")
                    XCTAssertGreaterThan(pdfDocument?.pageCount ?? 0, 3, "Medium claims should have multiple pages")
                    
                } catch {
                    XCTFail("Medium claim PDF generation failed: \\(error)")
                }
            }
        }
    }
    
    func testLargeClaimReportGenerationPerformance() async throws {
        // Test performance for large insurance claims (1000+ items)
        let dataset = mockDatasets.createLargeInsuranceClaim()
        let options = ReportOptions(
            includePhotos: false,  // Disable photos for large reports to test data processing speed
            includeReceipts: true,
            includeDepreciation: true,
            groupByRoom: true,
            template: .insuranceClaim
        )
        
        measure(metrics: [
            XCTClockMetric(),
            XCTCPUMetric(),
            XCTMemoryMetric(),
            XCTStorageMetric()
        ]) {
            Task { @MainActor in
                do {
                    let pdfData = try await insuranceReportService.generateInsuranceReport(
                        items: dataset.items,
                        categories: dataset.categories,
                        options: options
                    )
                    
                    // Verify large claim PDF generation
                    XCTAssertGreaterThan(pdfData.count, 50_000, "Large claims should generate substantial PDFs")
                    XCTAssertLessThan(pdfData.count, 100_000_000, "PDF should be under 100MB even for large claims")
                    
                    // Verify PDF structure for large claims
                    let pdfDocument = PDFDocument(data: pdfData)
                    XCTAssertNotNil(pdfDocument, "Large claim PDF should be valid")
                    XCTAssertGreaterThan(pdfDocument?.pageCount ?? 0, 10, "Large claims should have many pages")
                    
                } catch {
                    XCTFail("Large claim PDF generation failed: \\(error)")
                }
            }
        }
    }
    
    func testHighValueClaimReportPerformance() async throws {
        // Test performance for high-value insurance claims with detailed documentation
        let dataset = mockDatasets.createHighValueInsuranceClaim()
        let options = ReportOptions(
            includePhotos: true,
            includeReceipts: true,
            includeDepreciation: true,
            includeSerialNumbers: true,
            includePurchaseInfo: true,
            template: .detailed
        )
        
        measure(metrics: [
            XCTClockMetric(),
            XCTCPUMetric(),
            XCTMemoryMetric(),
            XCTStorageMetric()
        ]) {
            Task { @MainActor in
                do {
                    let pdfData = try await insuranceReportService.generateInsuranceReport(
                        items: dataset.items,
                        categories: dataset.categories,
                        options: options
                    )
                    
                    // High-value claims require comprehensive documentation
                    XCTAssertGreaterThan(pdfData.count, 20_000, "High-value claims need detailed reports")
                    
                    let pdfDocument = PDFDocument(data: pdfData)
                    XCTAssertNotNil(pdfDocument, "High-value claim PDF should be valid")
                    XCTAssertGreaterThan(pdfDocument?.pageCount ?? 0, 5, "High-value claims need detailed pages")
                    
                } catch {
                    XCTFail("High-value claim PDF generation failed: \\(error)")
                }
            }
        }
    }
    
    // MARK: - Template-Specific Performance Tests
    
    func testStandardTemplatePerformance() async throws {
        // Test performance of standard template across different dataset sizes
        let datasets = [
            ("Small", mockDatasets.createSmallInsuranceClaim()),
            ("Medium", mockDatasets.createMediumInsuranceClaim()),
            ("Large", mockDatasets.createLargeInsuranceClaim())
        ]
        
        for (size, dataset) in datasets {
            let options = ReportOptions(template: .standard)
            
            measure(metrics: [XCTClockMetric()]) {
                Task { @MainActor in
                    do {
                        let pdfData = try await insuranceReportService.generateInsuranceReport(
                            items: dataset.items,
                            categories: dataset.categories,
                            options: options
                        )
                        
                        XCTAssertGreaterThan(pdfData.count, 0, "\\(size) standard template should generate PDF")
                        
                    } catch {
                        XCTFail("\\(size) standard template generation failed: \\(error)")
                    }
                }
            }
        }
    }
    
    func testInsuranceClaimTemplatePerformance() async throws {
        // Test performance of insurance-specific template
        let dataset = mockDatasets.createComprehensiveInsuranceClaim()
        let options = ReportOptions(
            includePhotos: true,
            includeReceipts: true,
            includeDepreciation: true,
            groupByRoom: true,
            template: .insuranceClaim
        )
        
        measure(metrics: [
            XCTClockMetric(),
            XCTCPUMetric(),
            XCTMemoryMetric()
        ]) {
            Task { @MainActor in
                do {
                    let pdfData = try await insuranceReportService.generateInsuranceReport(
                        items: dataset.items,
                        categories: dataset.categories,
                        options: options
                    )
                    
                    // Insurance claim template should be comprehensive
                    XCTAssertGreaterThan(pdfData.count, 15_000, "Insurance claim template should be detailed")
                    
                    let pdfDocument = PDFDocument(data: pdfData)
                    XCTAssertNotNil(pdfDocument, "Insurance claim PDF should be valid")
                    
                } catch {
                    XCTFail("Insurance claim template generation failed: \\(error)")
                }
            }
        }
    }
    
    // MARK: - Photo Integration Performance Tests
    
    func testPhotoInclusionPerformance() async throws {
        // Test performance impact of including photos in reports
        let dataset = mockDatasets.createPhotoHeavyInsuranceClaim()
        
        // Test with photos
        let optionsWithPhotos = ReportOptions(
            includePhotos: true,
            includeReceipts: false,
            template: .detailed
        )
        
        // Test without photos
        let optionsWithoutPhotos = ReportOptions(
            includePhotos: false,
            includeReceipts: false,
            template: .detailed
        )
        
        var withPhotosTime: TimeInterval = 0
        var withoutPhotosTime: TimeInterval = 0
        var withPhotosSize = 0
        var withoutPhotosSize = 0
        
        // Measure with photos
        measure(metrics: [XCTClockMetric()]) {
            Task { @MainActor in
                do {
                    let startTime = CFAbsoluteTimeGetCurrent()
                    let pdfData = try await insuranceReportService.generateInsuranceReport(
                        items: dataset.items,
                        categories: dataset.categories,
                        options: optionsWithPhotos
                    )
                    withPhotosTime = CFAbsoluteTimeGetCurrent() - startTime
                    withPhotosSize = pdfData.count
                    
                    XCTAssertGreaterThan(pdfData.count, 0, "Photo-included PDF should be generated")
                    
                } catch {
                    XCTFail("Photo inclusion performance test failed: \\(error)")
                }
            }
        }
        
        // Measure without photos
        measure(metrics: [XCTClockMetric()]) {
            Task { @MainActor in
                do {
                    let startTime = CFAbsoluteTimeGetCurrent()
                    let pdfData = try await insuranceReportService.generateInsuranceReport(
                        items: dataset.items,
                        categories: dataset.categories,
                        options: optionsWithoutPhotos
                    )
                    withoutPhotosTime = CFAbsoluteTimeGetCurrent() - startTime
                    withoutPhotosSize = pdfData.count
                    
                    XCTAssertGreaterThan(pdfData.count, 0, "No-photo PDF should be generated")
                    
                } catch {
                    XCTFail("No-photo performance test failed: \\(error)")
                }
            }
        }
        
        // Verify photo inclusion impact
        XCTAssertGreaterThan(withPhotosSize, withoutPhotosSize, "PDF with photos should be larger")
        print("📊 Photo Inclusion Impact:")
        print("   • With photos: \\(String(format: \"%.3f\", withPhotosTime))s, \\(withPhotosSize) bytes")
        print("   • Without photos: \\(String(format: \"%.3f\", withoutPhotosTime))s, \\(withoutPhotosSize) bytes")
    }
    
    // MARK: - Memory Pressure Tests
    
    func testReportGenerationUnderMemoryPressure() async throws {
        // Test PDF generation performance under simulated memory pressure
        let dataset = mockDatasets.createLargeInsuranceClaim()
        let options = ReportOptions(template: .insuranceClaim)
        
        // Simulate memory pressure by creating large temporary arrays
        var memoryPressureArrays: [[Data]] = []
        
        measure(metrics: [
            XCTClockMetric(),
            XCTMemoryMetric()
        ]) {
            Task { @MainActor in
                do {
                    // Create memory pressure
                    for _ in 0..<10 {
                        let largeArray = Array(repeating: Data(count: 1024 * 1024), count: 10) // 10MB arrays
                        memoryPressureArrays.append(largeArray)
                    }
                    
                    // Generate report under pressure
                    let pdfData = try await insuranceReportService.generateInsuranceReport(
                        items: dataset.items,
                        categories: dataset.categories,
                        options: options
                    )
                    
                    XCTAssertGreaterThan(pdfData.count, 0, "Report should generate under memory pressure")
                    
                    // Clean up memory pressure
                    memoryPressureArrays.removeAll()
                    
                } catch {
                    memoryPressureArrays.removeAll()
                    XCTFail("Report generation under memory pressure failed: \\(error)")
                }
            }
        }
    }
    
    // MARK: - Concurrent Generation Performance Tests
    
    func testConcurrentReportGenerationPerformance() async throws {
        // Test performance when generating multiple reports concurrently
        let datasets = [
            mockDatasets.createSmallInsuranceClaim(),
            mockDatasets.createMediumInsuranceClaim(),
            mockDatasets.createHighValueInsuranceClaim()
        ]
        
        let options = ReportOptions(template: .standard)
        
        measure(metrics: [
            XCTClockMetric(),
            XCTCPUMetric(),
            XCTMemoryMetric()
        ]) {
            Task { @MainActor in
                do {
                    // Generate multiple reports concurrently
                    let tasks = datasets.map { dataset in
                        Task {
                            return try await insuranceReportService.generateInsuranceReport(
                                items: dataset.items,
                                categories: dataset.categories,
                                options: options
                            )
                        }
                    }
                    
                    // Wait for all reports to complete
                    var allReportsData: [Data] = []
                    for task in tasks {
                        let reportData = try await task.value
                        allReportsData.append(reportData)
                    }
                    
                    // Verify all reports generated successfully
                    XCTAssertEqual(allReportsData.count, 3, "All concurrent reports should complete")
                    for reportData in allReportsData {
                        XCTAssertGreaterThan(reportData.count, 0, "Each report should have data")
                    }
                    
                } catch {
                    XCTFail("Concurrent report generation failed: \\(error)")
                }
            }
        }
    }
    
    // MARK: - Export Performance Tests
    
    func testReportExportPerformance() async throws {
        // Test performance of exporting generated reports to files
        let dataset = mockDatasets.createMediumInsuranceClaim()
        let options = ReportOptions(template: .insuranceClaim)
        
        measure(metrics: [
            XCTClockMetric(),
            XCTStorageMetric()
        ]) {
            Task { @MainActor in
                do {
                    // Generate report
                    let pdfData = try await insuranceReportService.generateInsuranceReport(
                        items: dataset.items,
                        categories: dataset.categories,
                        options: options
                    )
                    
                    // Export report to file
                    let filename = "PerformanceTest_\\(UUID().uuidString).pdf"
                    let exportURL = try await insuranceReportService.exportReport(
                        pdfData,
                        filename: filename
                    )
                    
                    // Verify export successful
                    XCTAssertTrue(FileManager.default.fileExists(atPath: exportURL.path), "Exported file should exist")
                    
                    let exportedData = try Data(contentsOf: exportURL)
                    XCTAssertEqual(exportedData.count, pdfData.count, "Exported data should match generated data")
                    
                    // Clean up exported file
                    try FileManager.default.removeItem(at: exportURL)
                    
                } catch {
                    XCTFail("Report export performance test failed: \\(error)")
                }
            }
        }
    }
}

// MARK: - Insurance Report Test Data Factory

private class InsuranceReportTestDatasets {
    
    @MainActor
    func createSmallInsuranceClaim() -> (items: [Item], categories: [Nestory.Category]) {
        let electronics = Category(name: "Electronics", icon: "desktopcomputer", colorHex: "#007AFF")
        let jewelry = Category(name: "Jewelry", icon: "sparkles", colorHex: "#FFD700")
        
        var items: [Item] = []
        
        // Electronics items (20 items)
        for i in 0..<20 {
            let item = TestDataFactory.createCompleteItem()
            item.name = "Electronics Item \\(i)"
            item.purchasePrice = Decimal(Double.random(in: 200...2000))
            item.category = electronics
            items.append(item)
        }
        
        // Jewelry items (10 items)
        for i in 0..<10 {
            let item = TestDataFactory.createHighValueItem()
            item.name = "Jewelry Item \\(i)"
            item.purchasePrice = Decimal(Double.random(in: 1000...5000))
            item.category = jewelry
            items.append(item)
        }
        
        return (items: items, categories: [electronics, jewelry])
    }
    
    @MainActor
    func createMediumInsuranceClaim() -> (items: [Item], categories: [Nestory.Category]) {
        let categories = createInsuranceCategories()
        var items: [Item] = []
        
        // Distribute 200 items across categories
        let itemsPerCategory = 200 / categories.count
        
        for (index, category) in categories.enumerated() {
            for i in 0..<itemsPerCategory {
                let item = TestDataFactory.createCompleteItem()
                item.name = "\\(category.name) Item \\(i)"
                item.purchasePrice = Decimal(Double.random(in: 100...3000))
                item.category = category
                item.serialNumber = "MED\\(String(format: \"%03d%03d\", index, i))"
                items.append(item)
            }
        }
        
        return (items: items, categories: categories)
    }
    
    @MainActor
    func createLargeInsuranceClaim() -> (items: [Item], categories: [Nestory.Category]) {
        let categories = createInsuranceCategories()
        var items: [Item] = []
        
        // Create 1000 items for large claim testing
        let itemsPerCategory = 1000 / categories.count
        
        for (index, category) in categories.enumerated() {
            for i in 0..<itemsPerCategory {
                let item = TestDataFactory.createCompleteItem()
                item.name = "\\(category.name) Large Claim Item \\(i)"
                item.purchasePrice = Decimal(Double.random(in: 50...5000))
                item.category = category
                item.serialNumber = "LRG\\(String(format: \"%03d%04d\", index, i))"
                items.append(item)
            }
        }
        
        return (items: items, categories: categories)
    }
    
    @MainActor
    func createHighValueInsuranceClaim() -> (items: [Item], categories: [Nestory.Category]) {
        let luxury = Category(name: "Luxury Items", icon: "diamond", colorHex: "#8A2BE2")
        let art = Category(name: "Art & Collectibles", icon: "paintpalette", colorHex: "#FF8C00")
        
        var items: [Item] = []
        
        // High-value luxury items
        let luxuryItems = [
            ("Rolex Submariner", 12000),
            ("Tiffany Diamond Necklace", 25000),
            ("Hermès Birkin Bag", 18000),
            ("Cartier Wedding Set", 15000),
            ("Patek Philippe Watch", 45000)
        ]
        
        for (name, baseValue) in luxuryItems {
            for i in 0..<5 {  // 5 of each type
                let item = TestDataFactory.createHighValueItem()
                item.name = "\\(name) \\(i + 1)"
                item.purchasePrice = Decimal(baseValue + Int.random(in: -2000...2000))
                item.category = luxury
                item.itemDescription = "High-value luxury item requiring detailed appraisal"
                items.append(item)
            }
        }
        
        // Art and collectibles
        let artItems = [
            ("Original Oil Painting", 8000),
            ("Antique Sculpture", 12000),
            ("Rare Book Collection", 6000),
            ("Vintage Wine Collection", 15000)
        ]
        
        for (name, baseValue) in artItems {
            for i in 0..<3 {
                let item = TestDataFactory.createHighValueItem()
                item.name = "\\(name) \\(i + 1)"
                item.purchasePrice = Decimal(baseValue + Int.random(in: -1000...3000))
                item.category = art
                item.itemDescription = "Collectible item with provenance documentation"
                items.append(item)
            }
        }
        
        return (items: items, categories: [luxury, art])
    }
    
    @MainActor
    func createComprehensiveInsuranceClaim() -> (items: [Item], categories: [Nestory.Category]) {
        let categories = createInsuranceCategories()
        var items: [Item] = []
        
        // Create a balanced, comprehensive claim with 300 items
        let distributions = [40, 25, 20, 15] // Percentage distribution
        
        for (index, category) in categories.prefix(4).enumerated() {
            let itemCount = (300 * distributions[index]) / 100
            
            for i in 0..<itemCount {
                let item = TestDataFactory.createCompleteItem()
                item.name = "Comprehensive \\(category.name) Item \\(i)"
                item.purchasePrice = Decimal(Double.random(in: 200...4000))
                item.category = category
                
                // Add realistic details for comprehensive claims
                item.itemDescription = "Detailed item description for comprehensive insurance claim documentation"
                item.serialNumber = "COMP\\(String(format: \"%02d%03d\", index, i))"
                
                items.append(item)
            }
        }
        
        return (items: items, categories: categories)
    }
    
    @MainActor
    func createPhotoHeavyInsuranceClaim() -> (items: [Item], categories: [Nestory.Category]) {
        let categories = createInsuranceCategories()
        var items: [Item] = []
        
        // Create 100 items that would typically have multiple photos
        for i in 0..<100 {
            let item = TestDataFactory.createCompleteItem()
            item.name = "Photo-Heavy Item \\(i)"
            item.purchasePrice = Decimal(Double.random(in: 500...3000))
            item.category = categories[i % categories.count]
            item.itemDescription = "Item with multiple high-resolution photos for detailed documentation"
            
            // Simulate multiple photos by adding photo data
            let photoCount = Int.random(in: 2...6)
            for photoIndex in 0..<photoCount {
                let photoData = "photo_\(photoIndex)_data".data(using: .utf8)!
                if photoIndex == 0 {
                    item.imageData = photoData
                } else if photoIndex == 1 {
                    item.receiptImageData = photoData  
                } else {
                    item.conditionPhotos.append(photoData)
                }
            }
            
            items.append(item)
        }
        
        return (items: items, categories: categories)
    }
    
    private func createInsuranceCategories() -> [Nestory.Category] {
        return [
            Category(name: "Electronics", icon: "desktopcomputer", colorHex: "#007AFF"),
            Category(name: "Furniture", icon: "bed.double", colorHex: "#8B4513"),
            Category(name: "Jewelry", icon: "sparkles", colorHex: "#FFD700"),
            Category(name: "Appliances", icon: "refrigerator", colorHex: "#808080"),
            Category(name: "Clothing", icon: "tshirt", colorHex: "#32CD32"),
            Category(name: "Tools", icon: "hammer", colorHex: "#FF8C00"),
            Category(name: "Sports Equipment", icon: "sportscourt", colorHex: "#DC143C"),
            Category(name: "Books & Media", icon: "book", colorHex: "#8A2BE2")
        ]
    }
}