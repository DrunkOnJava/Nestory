//
// Layer: Services
// Module: ImportExportService
// Purpose: Mock implementation of import/export service for testing
//

import Foundation
import SwiftData

public final class MockImportExportService: ImportExportService {
    // Track operations for testing
    public var importCSVCalled = false
    public var exportCSVCalled = false
    public var importJSONCalled = false
    public var exportJSONCalled = false

    public var lastImportURL: URL?
    public var lastExportItems: [Item] = []

    // Mock responses
    public var shouldFailImport = false
    public var shouldFailExport = false
    public var mockImportResult: ImportResult
    public var mockCSVData: Data?
    public var mockJSONData: Data?

    public init() {
        // Set up default mock import result
        mockImportResult = ImportResult(
            itemsImported: 10,
            itemsSkipped: 0,
            errors: [],
            warnings: [],
            fileSize: 1024,
            processingTime: 1.5,
        )

        // Mock CSV data
        mockCSVData = """
        Name,Description,Category,Room,Purchase Price,Currency
        Mock Item 1,Test description,Electronics,Living Room,299.99,USD
        Mock Item 2,Another test,Furniture,Bedroom,599.99,USD
        """.data(using: .utf8)

        // Mock JSON data
        mockJSONData = """
        {
            "items": [
                {
                    "name": "Mock Item 1",
                    "description": "Test description",
                    "category": "Electronics",
                    "room": "Living Room",
                    "purchasePrice": 299.99,
                    "currency": "USD"
                }
            ]
        }
        """.data(using: .utf8)
    }

    // MARK: - CSV Operations

    public func importCSV(from url: URL, modelContext _: ModelContext) async throws -> ImportResult {
        importCSVCalled = true
        lastImportURL = url

        if shouldFailImport {
            throw ImportError.invalidFormat("Mock import failure")
        }

        // Simulate processing time
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        return mockImportResult
    }

    public func exportToCSV(items: [Item]) -> Data? {
        exportCSVCalled = true
        lastExportItems = items

        if shouldFailExport {
            return nil
        }

        return mockCSVData
    }

    // MARK: - JSON Operations

    public func importJSON(from url: URL, modelContext _: ModelContext) async throws -> ImportResult {
        importJSONCalled = true
        lastImportURL = url

        if shouldFailImport {
            throw ImportError.invalidFormat("Mock JSON import failure")
        }

        // Simulate processing time
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        return mockImportResult
    }

    public func exportToJSON(items: [Item]) -> Data? {
        exportJSONCalled = true
        lastExportItems = items

        if shouldFailExport {
            return nil
        }

        return mockJSONData
    }

    // MARK: - Comprehensive Export Operations

    public func exportData(
        format: ExportFormat,
        includeImages: Bool,
        includeReceipts: Bool,
        progressCallback: @escaping (Double) -> Void
    ) async throws -> URL {
        // Simulate progress
        progressCallback(0.0)
        
        // Simulate processing time
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        progressCallback(0.5)
        
        if shouldFailExport {
            throw ImportError.invalidFormat("Mock export failure")
        }
        
        // Create mock temporary file
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "mock_export_\(Int(Date().timeIntervalSince1970))"
        let fileURL: URL
        
        switch format {
        case .csv:
            fileURL = tempDir.appendingPathComponent(fileName).appendingPathExtension("csv")
            try mockCSVData?.write(to: fileURL)
        case .json:
            fileURL = tempDir.appendingPathComponent(fileName).appendingPathExtension("json")
            try mockJSONData?.write(to: fileURL)
        default:
            fileURL = tempDir.appendingPathComponent(fileName).appendingPathExtension("txt")
            try "Mock export data".data(using: .utf8)?.write(to: fileURL)
        }
        
        progressCallback(1.0)
        return fileURL
    }
}

// MARK: - Test Helpers

extension MockImportExportService {
    /// Reset all call tracking flags
    public func resetCallTracking() {
        importCSVCalled = false
        exportCSVCalled = false
        importJSONCalled = false
        exportJSONCalled = false
        lastImportURL = nil
        lastExportItems = []
    }

    /// Configure mock to simulate import errors
    public func configureForFailure() {
        shouldFailImport = true
        shouldFailExport = true
    }

    /// Configure mock with successful responses
    public func configureForSuccess() {
        shouldFailImport = false
        shouldFailExport = false
    }
}
