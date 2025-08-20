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
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory", category: "ImportExportService")
    let resilientExecutor = ResilientOperationExecutor()

    // Configuration constants
    let maxFileSize = 10 * 1024 * 1024 // 10MB
    let maxRowsPerImport = 10000

    public init() {}

    // All import/export operations have been moved to extension files:
    // - CSVOperations.swift - CSV import and export operations
    // - JSONOperations.swift - JSON import and export operations
    // - ImportExportModels.swift - Data models and error types
}

// MARK: - File Type Support

extension UTType {
    public static let csv = UTType(filenameExtension: "csv") ?? .commaSeparatedText
}
