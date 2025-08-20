//
// Layer: Services
// Module: ImportExportService
// Purpose: Protocol-first import/export service for bulk data operations
//

import Foundation
import SwiftData

/// Protocol defining import/export capabilities for inventory data
@MainActor
public protocol ImportExportService: AnyObject {
    // MARK: - CSV Operations

    func importCSV(from url: URL, modelContext: ModelContext) async throws -> ImportResult
    func exportToCSV(items: [Item]) -> Data?

    // MARK: - JSON Operations

    func importJSON(from url: URL, modelContext: ModelContext) async throws -> ImportResult
    func exportToJSON(items: [Item]) -> Data?
}
