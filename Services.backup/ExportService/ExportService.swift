// Layer: Services
// Module: ExportService
// Purpose: Data export service for multiple formats

import Foundation
import os.log
import PDFKit
import UniformTypeIdentifiers

public protocol ExportService: Sendable {
    func exportToCSV(_ data: [some Encodable]) async throws -> Data
    func exportToJSON(_ data: [some Encodable]) async throws -> Data
    func exportToPDF(_ data: ExportData) async throws -> Data
    func createBackup(inventory: [Item]) async throws -> BackupPackage
    func restoreBackup(from package: BackupPackage) async throws -> [Item]
}

public struct LiveExportService: ExportService, @unchecked Sendable {
    private let fileStore: FileStore
    private let logger = Logger(subsystem: "com.nestory", category: "ExportService")

    public init() throws {
        fileStore = try FileStore(directory: .applicationSupport, subdirectory: "exports")
    }

    public func exportToCSV(_ data: [some Encodable]) async throws -> Data {
        let signpost = OSSignposter()
        let state = signpost.beginInterval("export_csv", id: signpost.makeSignpostID())
        defer { signpost.endInterval("export_csv", state) }

        guard !data.isEmpty else {
            throw ExportError.emptyData
        }

        let encoder = CSVEncoder()

        do {
            let csvData = try encoder.encode(data)
            logger.info("Exported \(data.count) items to CSV")
            return csvData
        } catch {
            logger.error("CSV export failed: \(error.localizedDescription)")
            throw ExportError.encodingFailed(error.localizedDescription)
        }
    }

    public func exportToJSON(_ data: [some Encodable]) async throws -> Data {
        let signpost = OSSignposter()
        let state = signpost.beginInterval("export_json", id: signpost.makeSignpostID())
        defer { signpost.endInterval("export_json", state) }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        encoder.dateEncodingStrategy = .iso8601

        do {
            let jsonData = try encoder.encode(data)
            logger.info("Exported \(data.count) items to JSON")
            return jsonData
        } catch {
            logger.error("JSON export failed: \(error.localizedDescription)")
            throw ExportError.encodingFailed(error.localizedDescription)
        }
    }

    public func exportToPDF(_ data: ExportData) async throws -> Data {
        let signpost = OSSignposter()
        let state = signpost.beginInterval("export_pdf", id: signpost.makeSignpostID())
        defer { signpost.endInterval("export_pdf", state) }

        let pdfDocument = PDFDocument()
        let pageSize = CGSize(width: 612, height: 792)

        let titlePage = createTitlePage(data: data, size: pageSize)
        pdfDocument.insert(titlePage, at: 0)

        var currentPage = 1
        let _: CGFloat = 700 // currentY unused
        let itemsPerPage = 25

        for (index, _) in data.items.enumerated() {
            if index % itemsPerPage == 0, index > 0 {
                let page = createItemPage(
                    items: Array(data.items[index ..< min(index + itemsPerPage, data.items.count)]),
                    pageNumber: currentPage + 1,
                    size: pageSize
                )
                pdfDocument.insert(page, at: currentPage)
                currentPage += 1
            }
        }

        if let summaryPage = createSummaryPage(data: data, size: pageSize) {
            pdfDocument.insert(summaryPage, at: pdfDocument.pageCount)
        }

        guard let pdfData = pdfDocument.dataRepresentation() else {
            throw ExportError.pdfGenerationFailed
        }

        logger.info("Exported \(data.items.count) items to PDF (\(pdfDocument.pageCount) pages)")
        return pdfData
    }

    public func createBackup(inventory: [Item]) async throws -> BackupPackage {
        let signpost = OSSignposter()
        let state = signpost.beginInterval("create_backup", id: signpost.makeSignpostID())
        defer { signpost.endInterval("create_backup", state) }

        let metadata = BackupMetadata(
            version: "1.0",
            createdAt: Date(),
            deviceName: ProcessInfo.processInfo.hostName,
            itemCount: inventory.count,
            checksum: nil
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let itemsData = try encoder.encode(inventory)
        let checksum = itemsData.hashValue

        var updatedMetadata = metadata
        updatedMetadata.checksum = String(checksum)

        let package = BackupPackage(
            metadata: updatedMetadata,
            items: inventory,
            images: []
        )

        let filename = "backup_\(Date().timeIntervalSince1970).nestory"
        let packageData = try encoder.encode(package)

        try await fileStore.saveData(packageData, to: filename)

        logger.info("Created backup with \(inventory.count) items")
        return package
    }

    public func restoreBackup(from package: BackupPackage) async throws -> [Item] {
        let signpost = OSSignposter()
        let state = signpost.beginInterval("restore_backup", id: signpost.makeSignpostID())
        defer { signpost.endInterval("restore_backup", state) }

        guard package.metadata.version == "1.0" else {
            throw ExportError.incompatibleVersion(package.metadata.version)
        }

        if let checksum = package.metadata.checksum {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let itemsData = try encoder.encode(package.items)
            let calculatedChecksum = String(itemsData.hashValue)

            guard checksum == calculatedChecksum else {
                throw ExportError.checksumMismatch
            }
        }

        logger.info("Restored \(package.items.count) items from backup")
        return package.items
    }

    private func createTitlePage(data: ExportData, size: CGSize) -> PDFPage {
        let page = PDFPage()
        let bounds = CGRect(origin: .zero, size: size)

        let _: String = "Inventory Report" // title unused
        let _: String = "Generated on \(Date().formatted())" // subtitle unused
        let _: String = "\(data.items.count) items • Total value: \(formatCurrency(data.totalValue))" // summary unused

        let _: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 36, weight: .bold),
            .foregroundColor: UIColor.black,
        ] // titleAttributes unused

        let _: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18),
            .foregroundColor: UIColor.gray,
        ] // subtitleAttributes unused

        let _: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.darkGray,
        ] // summaryAttributes unused

        page.setBounds(bounds, for: .mediaBox)

        return page
    }

    private func createItemPage(items _: [Item], pageNumber _: Int, size: CGSize) -> PDFPage {
        let page = PDFPage()
        page.setBounds(CGRect(origin: .zero, size: size), for: .mediaBox)
        return page
    }

    private func createSummaryPage(data: ExportData, size: CGSize) -> PDFPage? {
        guard !data.categories.isEmpty else { return nil }

        let page = PDFPage()
        page.setBounds(CGRect(origin: .zero, size: size), for: .mediaBox)
        return page
    }

    private func formatCurrency(_ value: Decimal?) -> String {
        guard let value else { return "$0.00" }

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"

        return formatter.string(from: value as NSNumber) ?? "$0.00"
    }
}

struct CSVEncoder {
    func encode(_ values: [some Encodable]) throws -> Data {
        guard !values.isEmpty else {
            return Data()
        }

        let mirror = Mirror(reflecting: values[0])
        let headers = mirror.children.compactMap(\.label)

        var csv = headers.joined(separator: ",") + "\n"

        for value in values {
            let mirror = Mirror(reflecting: value)
            let row = mirror.children.map { child -> String in
                if let value = child.value as? String {
                    return escapeCSV(value)
                } else if let value = child.value as? any CustomStringConvertible {
                    return escapeCSV(value.description)
                } else {
                    return ""
                }
            }.joined(separator: ",")

            csv += row + "\n"
        }

        guard let data = csv.data(using: .utf8) else {
            throw ExportError.encodingFailed("Failed to encode CSV")
        }

        return data
    }

    private func escapeCSV(_ string: String) -> String {
        if string.contains(",") || string.contains("\"") || string.contains("\n") {
            return "\"\(string.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return string
    }
}

public struct ExportData {
    public let items: [Item]
    public let categories: [Category]
    public let totalValue: Decimal?
    public let metadata: [String: Any]

    public init(
        items: [Item],
        categories: [Category] = [],
        totalValue: Decimal? = nil,
        metadata: [String: Any] = [:]
    ) {
        self.items = items
        self.categories = categories
        self.totalValue = totalValue
        self.metadata = metadata
    }
}

public struct BackupPackage: Codable {
    public let metadata: BackupMetadata
    public let items: [Item]
    public let images: [BackupImage]
    
    public init(metadata: BackupMetadata, items: [Item], images: [BackupImage]) {
        self.metadata = metadata
        self.items = items
        self.images = images
    }
}

public struct BackupMetadata: Codable {
    public let version: String
    public let createdAt: Date
    public let deviceName: String
    public let itemCount: Int
    public var checksum: String?
    
    public init(version: String, createdAt: Date, deviceName: String, itemCount: Int, checksum: String? = nil) {
        self.version = version
        self.createdAt = createdAt
        self.deviceName = deviceName
        self.itemCount = itemCount
        self.checksum = checksum
    }
}

public struct BackupImage: Codable {
    public let itemId: UUID
    public let imageData: Data
    public let thumbnail: Data?
    
    public init(itemId: UUID, imageData: Data, thumbnail: Data? = nil) {
        self.itemId = itemId
        self.imageData = imageData
        self.thumbnail = thumbnail
    }
}

public enum ExportError: LocalizedError {
    case emptyData
    case encodingFailed(String)
    case pdfGenerationFailed
    case incompatibleVersion(String)
    case checksumMismatch
    case backupCorrupted

    public var errorDescription: String? {
        switch self {
        case .emptyData:
            "No data to export"
        case let .encodingFailed(reason):
            "Export encoding failed: \(reason)"
        case .pdfGenerationFailed:
            "Failed to generate PDF"
        case let .incompatibleVersion(version):
            "Incompatible backup version: \(version)"
        case .checksumMismatch:
            "Backup integrity check failed"
        case .backupCorrupted:
            "Backup file is corrupted"
        }
    }
}
