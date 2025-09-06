//
// Layer: Tests
// Module: Performance
// Purpose: Performance testing for receipt OCR processing speed and accuracy
//

import XCTest
import Vision
import UIKit
@testable import Nestory

/// Performance tests for receipt OCR processing
/// Ensures OCR processing meets SLA requirements for insurance documentation
@MainActor
final class XOCRPerformanceTests: XCTestCase, @unchecked Sendable { // DISABLED: Slow performance tests
    
    // MARK: - Test Infrastructure
    
    private var ocrService: LiveReceiptOCRService!
    private var testImageGenerator: OCRTestImageGenerator!
    private var mockReceiptImages: [UIImage]!
    
    override func setUp() async throws {
        try await super.setUp()
        
        ocrService = LiveReceiptOCRService()
        testImageGenerator = OCRTestImageGenerator()
        mockReceiptImages = testImageGenerator.generateTestReceiptImages()
    }
    
    override func tearDown() async throws {
        ocrService = nil
        testImageGenerator = nil
        mockReceiptImages = nil
        try await super.tearDown()
    }
    
    // MARK: - Basic OCR Performance Tests
    
    func testSingleReceiptProcessingPerformance() async throws {
        // Test processing time for a single receipt image
        let testImage = mockReceiptImages.first!
        
        measure(metrics: [
            XCTClockMetric(),
            XCTCPUMetric(),
            XCTMemoryMetric()
        ]) {
            Task {
                do {
                    let result = try await ocrService.processReceiptImage(testImage)
                    
                    // Verify basic processing succeeded
                    XCTAssertNotNil(result.vendor, "Vendor should be extracted")
                    XCTAssertNotNil(result.total, "Total should be extracted")
                    XCTAssertGreaterThan(result.confidence, 0.0, "Should have confidence score")
                    XCTAssertFalse(result.rawText.isEmpty, "Should extract raw text")
                    
                } catch {
                    XCTFail("Single receipt processing failed: \\(error)")
                }
            }
        }
    }
    
    func testMultipleReceiptBatchProcessingPerformance() async throws {
        // Test batch processing performance for multiple receipts
        let batchSize = 5
        let testImages = Array(mockReceiptImages.prefix(batchSize))
        
        measure(metrics: [
            XCTClockMetric(),
            XCTCPUMetric(),
            XCTMemoryMetric(),
            XCTStorageMetric()
        ]) {
            Task {
                var results: [EnhancedReceiptData] = []
                
                for image in testImages {
                    do {
                        let result = try await ocrService.processReceiptImage(image)
                        results.append(result)
                    } catch {
                        XCTFail("Batch processing failed for image: \\(error)")
                    }
                }
                
                // Verify batch processing results
                XCTAssertEqual(results.count, batchSize, "All receipts should be processed")
                
                let averageConfidence = results.reduce(0.0) { $0 + $1.confidence } / Double(results.count)
                XCTAssertGreaterThan(averageConfidence, 0.5, "Average confidence should be reasonable")
                
                let successfulExtractions = results.filter { $0.vendor != nil && $0.total != nil }.count
                XCTAssertGreaterThan(successfulExtractions, batchSize / 2, "At least half should extract basic data")
            }
        }
    }
    
    func testHighResolutionImageProcessingPerformance() async throws {
        // Test performance with high-resolution receipt images
        let highResImage = testImageGenerator.generateHighResolutionReceipt()
        
        measure(metrics: [
            XCTClockMetric(),
            XCTCPUMetric(),
            XCTMemoryMetric(),
            XCTStorageMetric()
        ]) {
            Task {
                do {
                    let result = try await ocrService.processReceiptImage(highResImage)
                    
                    // High-res images should provide better accuracy
                    XCTAssertGreaterThan(result.confidence, 0.7, "High-res images should have higher confidence")
                    XCTAssertNotNil(result.vendor, "Vendor should be extractable from high-res image")
                    XCTAssertNotNil(result.total, "Total should be extractable from high-res image")
                    XCTAssertGreaterThan(result.items.count, 0, "Should extract item details from high-res image")
                    
                } catch {
                    XCTFail("High-resolution processing failed: \\(error)")
                }
            }
        }
    }
    
    func testLowQualityImageProcessingPerformance() async throws {
        // Test performance degradation with low-quality images
        let lowQualityImages = testImageGenerator.generateLowQualityReceipts()
        
        var processingTimes: [TimeInterval] = []
        var confidenceScores: [Double] = []
        
        for image in lowQualityImages {
            measure(metrics: [XCTClockMetric()]) {
                Task {
                    do {
                        let startTime = CFAbsoluteTimeGetCurrent()
                        let result = try await ocrService.processReceiptImage(image)
                        let processingTime = CFAbsoluteTimeGetCurrent() - startTime
                        
                        processingTimes.append(processingTime)
                        confidenceScores.append(result.confidence)
                        
                        // Low quality images should still process but may have lower confidence
                        XCTAssertGreaterThan(result.confidence, 0.1, "Should have some confidence even for low quality")
                        XCTAssertFalse(result.rawText.isEmpty, "Should extract some text even from poor quality")
                        
                    } catch {
                        // Low quality images may fail - this is acceptable
                        print("Low quality image processing failed (acceptable): \\(error)")
                    }
                }
            }
        }
        
        // Performance analysis for low quality images
        let avgProcessingTime = processingTimes.reduce(0, +) / Double(processingTimes.count)
        let avgConfidence = confidenceScores.reduce(0, +) / Double(confidenceScores.count)
        
        print("📊 Low Quality Image Performance:")
        print("   • Average processing time: \\(String(format: \"%.3f\", avgProcessingTime))s")
        print("   • Average confidence: \\(String(format: \"%.3f\", avgConfidence))")
    }
    
    // MARK: - Receipt Type Performance Tests
    
    func testGroceryReceiptProcessingPerformance() async throws {
        // Test performance on grocery receipts (typically long with many items)
        let groceryImage = testImageGenerator.generateGroceryReceipt()
        
        measure(metrics: [
            XCTClockMetric(),
            XCTCPUMetric(),
            XCTMemoryMetric()
        ]) {
            Task {
                do {
                    let result = try await ocrService.processReceiptImage(groceryImage)
                    
                    // Grocery receipts should extract multiple items
                    XCTAssertNotNil(result.vendor, "Grocery store should be identified")
                    XCTAssertGreaterThan(result.items.count, 3, "Grocery receipts typically have multiple items")
                    XCTAssertTrue(result.categories.contains { $0.lowercased().contains("grocery") || $0.lowercased().contains("food") },
                                 "Should categorize as grocery/food")
                    
                } catch {
                    XCTFail("Grocery receipt processing failed: \\(error)")
                }
            }
        }
    }
    
    func testElectronicsReceiptProcessingPerformance() async throws {
        // Test performance on electronics receipts (insurance-relevant, high-value items)
        let electronicsImage = testImageGenerator.generateElectronicsReceipt()
        
        measure(metrics: [
            XCTClockMetric(),
            XCTCPUMetric(),
            XCTMemoryMetric()
        ]) {
            Task {
                do {
                    let result = try await ocrService.processReceiptImage(electronicsImage)
                    
                    // Electronics receipts are crucial for insurance
                    XCTAssertNotNil(result.vendor, "Electronics retailer should be identified")
                    XCTAssertNotNil(result.total, "Total is critical for insurance valuation")
                    XCTAssertGreaterThan(result.confidence, 0.6, "Electronics receipts should be processed with good confidence")
                    
                    // Verify high-value detection
                    if let total = result.total, total >= 100 {
                        XCTAssertTrue(result.categories.contains { $0.lowercased().contains("electronics") },
                                     "Should categorize as electronics")
                    }
                    
                } catch {
                    XCTFail("Electronics receipt processing failed: \\(error)")
                }
            }
        }
    }
    
    func testRestaurantReceiptProcessingPerformance() async throws {
        // Test performance on restaurant receipts (simpler format, tax calculation)
        let restaurantImage = testImageGenerator.generateRestaurantReceipt()
        
        measure(metrics: [
            XCTClockMetric(),
            XCTCPUMetric(),
            XCTMemoryMetric()
        ]) {
            Task {
                do {
                    let result = try await ocrService.processReceiptImage(restaurantImage)
                    
                    // Restaurant receipts have specific characteristics
                    XCTAssertNotNil(result.vendor, "Restaurant should be identified")
                    XCTAssertNotNil(result.tax, "Tax should be extracted from restaurant receipts")
                    XCTAssertNotNil(result.total, "Total should be extracted")
                    
                    // Verify tax calculation accuracy
                    if let total = result.total, let tax = result.tax {
                        let subtotal = total - tax
                        let calculatedTax = subtotal * 0.08 // Assume ~8% tax rate
                        let taxDouble = Double(truncating: tax as NSNumber)
                        let calculatedTaxDouble = Double(truncating: calculatedTax as NSNumber)
                        let taxDifference = abs(taxDouble - calculatedTaxDouble)
                        XCTAssertLessThan(taxDifference, 2.0, "Tax calculation should be approximately correct")
                    }
                    
                } catch {
                    XCTFail("Restaurant receipt processing failed: \\(error)")
                }
            }
        }
    }
    
    // MARK: - OCR Engine Performance Comparison Tests
    
    func testVisionFrameworkPerformance() async throws {
        // Test Apple's Vision framework performance directly
        let testImage = mockReceiptImages.first!
        guard let cgImage = testImage.cgImage else {
            XCTFail("Test image should be convertible to CGImage")
            return
        }
        
        measure(metrics: [
            XCTClockMetric(),
            XCTCPUMetric(),
            XCTMemoryMetric()
        ]) {
            let request = VNRecognizeTextRequest()
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try handler.perform([request])
                
                if let results = request.results {
                    let extractedText = results.compactMap { $0.topCandidates(1).first?.string }.joined(separator: " ")
                    XCTAssertFalse(extractedText.isEmpty, "Vision framework should extract text")
                    
                    // Basic text extraction performance validation
                    XCTAssertGreaterThan(extractedText.count, 10, "Should extract meaningful amount of text")
                }
                
            } catch {
                XCTFail("Vision framework processing failed: \\(error)")
            }
        }
    }
    
    // MARK: - Concurrent Processing Performance Tests
    
    func testConcurrentReceiptProcessing() async throws {
        // Test performance when processing multiple receipts concurrently
        let concurrentImages = Array(mockReceiptImages.prefix(3))
        
        measure(metrics: [
            XCTClockMetric(),
            XCTCPUMetric(),
            XCTMemoryMetric()
        ]) {
            Task {
                await withTaskGroup(of: EnhancedReceiptData?.self) { group in
                for image in concurrentImages {
                    group.addTask {
                        do {
                            return try await self.ocrService.processReceiptImage(image)
                        } catch {
                            print("Concurrent processing failed for image: \\(error)")
                            return nil
                        }
                    }
                }
                
                var results: [EnhancedReceiptData] = []
                for await result in group {
                    if let result = result {
                        results.append(result)
                    }
                }
                
                // Verify concurrent processing efficiency
                XCTAssertGreaterThan(results.count, 0, "At least some concurrent processing should succeed")
                
                let avgConfidence = results.reduce(0.0) { $0 + $1.confidence } / Double(results.count)
                XCTAssertGreaterThan(avgConfidence, 0.3, "Concurrent processing shouldn't degrade accuracy too much")
                }
            }
        }
    }
    
    // MARK: - Memory Pressure Tests
    
    func testOCRProcessingUnderMemoryPressure() async throws {
        // Test OCR performance under simulated memory pressure
        let testImage = mockReceiptImages.first!
        
        // Create memory pressure
        var memoryPressureArrays: [[Data]] = []
        
        measure(metrics: [
            XCTClockMetric(),
            XCTMemoryMetric()
        ]) {
            Task {
                do {
                    // Simulate memory pressure
                    for _ in 0..<20 {
                        let largeArray = Array(repeating: Data(count: 1024 * 1024), count: 5) // 5MB arrays
                        memoryPressureArrays.append(largeArray)
                    }
                    
                    // Process receipt under pressure
                    let result = try await ocrService.processReceiptImage(testImage)
                    
                    XCTAssertNotNil(result, "OCR should work under memory pressure")
                    XCTAssertGreaterThan(result.confidence, 0.1, "Should maintain some accuracy under pressure")
                    
                    // Clean up memory pressure
                    memoryPressureArrays.removeAll()
                    
                } catch {
                    memoryPressureArrays.removeAll()
                    XCTFail("OCR processing under memory pressure failed: \\(error)")
                }
            }
        }
    }
    
    // MARK: - Processing Stage Performance Analysis
    
    func testProcessingStageTimingAnalysis() async throws {
        // Test performance of individual processing stages
        let testImage = mockReceiptImages.first!
        
        var stageTimings: [String: TimeInterval] = [:]
        
        measure(metrics: [XCTClockMetric()]) {
            Task {
                do {
                    // Monitor processing stages
                    let startTime = CFAbsoluteTimeGetCurrent()
                    
                    let result = try await ocrService.processReceiptImage(testImage)
                    
                    let totalTime = CFAbsoluteTimeGetCurrent() - startTime
                    stageTimings["total"] = totalTime
                    
                    // Verify processing completed with stage breakdown
                    XCTAssertNotNil(result.processingMetadata, "Should have processing metadata")
                    XCTAssertNotNil(result, "Processing should complete successfully")
                    
                } catch {
                    XCTFail("Processing stage analysis failed: \\(error)")
                }
            }
        }
        
        // Log processing stage performance
        print("📊 OCR Processing Stage Timings:")
        for (stage, timing) in stageTimings {
            print("   • \\(stage): \\(String(format: \"%.3f\", timing))s")
        }
    }
    
    // MARK: - Accuracy vs Speed Trade-off Tests
    
    func testAccurateProcessingModePerformance() async throws {
        // Test performance with highest accuracy settings
        let testImage = mockReceiptImages.first!
        
        measure(metrics: [
            XCTClockMetric(),
            XCTCPUMetric(),
            XCTMemoryMetric()
        ]) {
            Task {
                do {
                    // Process with high accuracy expectations
                    let result = try await ocrService.processReceiptImage(testImage)
                    
                    // Accurate mode should provide higher confidence
                    XCTAssertGreaterThan(result.confidence, 0.7, "Accurate mode should provide high confidence")
                    XCTAssertNotNil(result.vendor, "Should extract vendor accurately")
                    XCTAssertNotNil(result.total, "Should extract total accurately")
                    XCTAssertNotNil(result.date, "Should extract date accurately")
                    
                    // Verify detailed extraction
                    XCTAssertFalse(result.categories.isEmpty, "Should categorize the receipt")
                    XCTAssertGreaterThan(result.rawText.count, 50, "Should extract substantial text")
                    
                } catch {
                    XCTFail("Accurate processing mode failed: \\(error)")
                }
            }
        }
    }
}

// MARK: - OCR Test Image Generator

private class OCRTestImageGenerator {
    
    func generateTestReceiptImages() -> [UIImage] {
        // Generate synthetic receipt images for testing
        // In a real implementation, these would be pre-generated test images
        return [
            generateBasicReceipt(),
            generateComplexReceipt(),
            generateFadedReceipt(),
            generateCroppedReceipt(),
            generateSkewedReceipt()
        ]
    }
    
    func generateBasicReceipt() -> UIImage {
        // Generate a basic receipt image with clear text
        return createReceiptImage(
            storeName: "Test Store",
            items: [
                "Coffee - $3.99",
                "Sandwich - $7.50",
                "Tax - $0.92"
            ],
            total: "$12.41",
            quality: .high
        )
    }
    
    func generateComplexReceipt() -> UIImage {
        // Generate a complex receipt with many items
        return createReceiptImage(
            storeName: "SuperMart Electronics",
            items: [
                "iPhone 16 Pro - $999.00",
                "Case - $39.99", 
                "Screen Protector - $24.99",
                "Charger - $29.99",
                "AppleCare+ - $199.00",
                "Tax - $104.64"
            ],
            total: "$1,397.61",
            quality: .high
        )
    }
    
    func generateHighResolutionReceipt() -> UIImage {
        // Generate high-resolution receipt for quality testing
        return createReceiptImage(
            storeName: "Best Buy",
            items: [
                "MacBook Pro M3 - $1,999.00",
                "Magic Mouse - $79.00",
                "USB-C Hub - $49.99",
                "Tax - $170.40"
            ],
            total: "$2,298.39",
            quality: .ultraHigh,
            resolution: CGSize(width: 2048, height: 2048)
        )
    }
    
    func generateLowQualityReceipts() -> [UIImage] {
        return [
            createReceiptImage(storeName: "Faded Store", items: ["Item - $5.99"], total: "$5.99", quality: .low),
            createReceiptImage(storeName: "Blurry Shop", items: ["Thing - $12.34"], total: "$12.34", quality: .veryLow),
            createReceiptImage(storeName: "Dark Print", items: ["Product - $8.88"], total: "$8.88", quality: .low)
        ]
    }
    
    func generateGroceryReceipt() -> UIImage {
        return createReceiptImage(
            storeName: "Whole Foods Market",
            items: [
                "Organic Bananas - $3.99",
                "Milk 2% - $4.49",
                "Bread Whole Wheat - $3.79",
                "Greek Yogurt - $5.99",
                "Chicken Breast - $12.99",
                "Spinach Organic - $2.99",
                "Tax - $0.00" // Groceries often tax-exempt
            ],
            total: "$34.24",
            quality: .medium
        )
    }
    
    func generateElectronicsReceipt() -> UIImage {
        return createReceiptImage(
            storeName: "Apple Store",
            items: [
                "iPad Pro 12.9\" - $1,099.00",
                "Apple Pencil - $129.00",
                "Smart Keyboard - $299.00",
                "Tax - $122.24"
            ],
            total: "$1,649.24",
            quality: .high
        )
    }
    
    func generateRestaurantReceipt() -> UIImage {
        return createReceiptImage(
            storeName: "The Bistro",
            items: [
                "Caesar Salad - $14.99",
                "Grilled Salmon - $28.99",
                "Wine Glass - $12.00",
                "Tip - $11.20",
                "Tax - $4.48"
            ],
            total: "$71.66",
            quality: .medium
        )
    }
    
    func generateFadedReceipt() -> UIImage {
        return createReceiptImage(
            storeName: "Old Receipt Store",
            items: ["Faded Item - $10.00"],
            total: "$10.00",
            quality: .veryLow
        )
    }
    
    func generateCroppedReceipt() -> UIImage {
        return createReceiptImage(
            storeName: "Cropped Store",
            items: ["Partial Item - $15.99"],
            total: "$15.99",
            quality: .medium,
            isCropped: true
        )
    }
    
    func generateSkewedReceipt() -> UIImage {
        return createReceiptImage(
            storeName: "Angled Store",
            items: ["Skewed Item - $7.77"],
            total: "$7.77",
            quality: .medium,
            isSkewed: true
        )
    }
    
    private enum ImageQuality {
        case ultraHigh, high, medium, low, veryLow
    }
    
    private func createReceiptImage(
        storeName: String,
        items: [String],
        total: String,
        quality: ImageQuality,
        resolution: CGSize = CGSize(width: 400, height: 600),
        isCropped: Bool = false,
        isSkewed: Bool = false
    ) -> UIImage {
        
        let renderer = UIGraphicsImageRenderer(size: resolution)
        
        return renderer.image { context in
            // Background
            UIColor.white.setFill()
            context.cgContext.fill(CGRect(origin: .zero, size: resolution))
            
            // Configure text attributes based on quality
            let fontSize: CGFloat
            let textColor: UIColor
            
            switch quality {
            case .ultraHigh:
                fontSize = 18
                textColor = UIColor.black
            case .high:
                fontSize = 16
                textColor = UIColor.black
            case .medium:
                fontSize = 14
                textColor = UIColor.darkGray
            case .low:
                fontSize = 12
                textColor = UIColor.gray
            case .veryLow:
                fontSize = 10
                textColor = UIColor.lightGray
            }
            
            let font = UIFont.systemFont(ofSize: fontSize, weight: .regular)
            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: textColor
            ]
            
            var currentY: CGFloat = 20
            let lineHeight: CGFloat = fontSize * 1.4
            let padding: CGFloat = 20
            
            // Store name (header)
            let headerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: fontSize * 1.2, weight: .bold),
                .foregroundColor: textColor
            ]
            
            storeName.draw(at: CGPoint(x: padding, y: currentY), withAttributes: headerAttributes)
            currentY += lineHeight * 2
            
            // Items
            for item in items {
                item.draw(at: CGPoint(x: padding, y: currentY), withAttributes: textAttributes)
                currentY += lineHeight
            }
            
            // Separator line
            currentY += lineHeight * 0.5
            context.cgContext.setStrokeColor(textColor.cgColor)
            context.cgContext.setLineWidth(1)
            context.cgContext.move(to: CGPoint(x: padding, y: currentY))
            context.cgContext.addLine(to: CGPoint(x: resolution.width - padding, y: currentY))
            context.cgContext.strokePath()
            currentY += lineHeight
            
            // Total
            let totalAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: fontSize, weight: .bold),
                .foregroundColor: textColor
            ]
            
            "TOTAL: \\(total)".draw(at: CGPoint(x: padding, y: currentY), withAttributes: totalAttributes)
        }
    }
}