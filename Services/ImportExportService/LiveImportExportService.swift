//
// Layer: Services
// Module: ImportExportService
// Purpose: Live implementation of import/export service for bulk data operations
//

import Foundation
import os.log
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

@MainActor
public final class LiveImportExportService: ImportExportService, ObservableObject {
    // Error handling infrastructure
    let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory", category: "ImportExportService")
    let resilientExecutor = ResilientOperationExecutor()

    // Configuration constants
    let maxFileSize = 10 * 1024 * 1024 // 10MB
    let maxRowsPerImport = 10000

    public init() {}

    // All import/export operations have been moved to extension files:
    // - CSVOperations.swift - CSV import and export operations
    // - JSONOperations.swift - JSON import and export operations
    // - ImportExportModels.swift - Data models and error types

    // MARK: - Comprehensive Export Operations

    public func exportData(
        format: ExportFormat,
        includeImages: Bool,
        includeReceipts: Bool,
        progressCallback: @escaping (Double) -> Void
    ) async throws -> URL {
        self.logger.info("Starting comprehensive export with format: \(format.rawValue)")
        
        // Create temporary file URL
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileName = "nestory_export_\(Int(Date().timeIntervalSince1970))"
        let fileURL = tempDirectory.appendingPathComponent(fileName).appendingPathExtension(format.fileExtension)
        
        // Report initial progress
        progressCallback(0.0)
        
        do {
            // For now, delegate to existing methods based on format
            // TODO: Implement comprehensive export with images and receipts
            let data: Data?
            
            switch format {
            case .csv:
                // Fetch all items - this should be passed as parameter in real implementation
                let descriptor = FetchDescriptor<Item>()
                // TODO: Inject ModelContext properly instead of creating new one
                let config = ModelConfiguration(isStoredInMemoryOnly: false)
                let container = try ModelContainer(for: Item.self, configurations: config)
                let context = ModelContext(container)
                let items = try context.fetch(descriptor)
                progressCallback(0.5)
                data = exportToCSV(items: items)
                
            case .json:
                let descriptor = FetchDescriptor<Item>()
                // TODO: Inject ModelContext properly instead of creating new one
                let config = ModelConfiguration(isStoredInMemoryOnly: false)
                let container = try ModelContainer(for: Item.self, configurations: config)
                let context = ModelContext(container)
                let items = try context.fetch(descriptor)
                progressCallback(0.5)
                data = exportToJSON(items: items)
                
            default:
                throw ImportError.invalidFormat("Export format \(format) not supported")
            }
            
            guard let exportData = data else {
                throw ImportError.invalidFormat("Failed to generate export data")
            }
            
            // Write data to file
            try exportData.write(to: fileURL)
            progressCallback(1.0)
            
            self.logger.info("Export completed successfully: \(fileURL)")
            return fileURL
            
        } catch {
            self.logger.error("Export failed: \(error)")
            throw error
        }
    }
}

// MARK: - File Type Support

extension UTType {
    public static let csv = UTType(filenameExtension: "csv") ?? .commaSeparatedText
}
