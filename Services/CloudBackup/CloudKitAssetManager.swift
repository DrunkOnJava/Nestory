//
// Layer: Services
// Module: CloudBackup
// Purpose: Manage CKAsset creation and loading for CloudKit backup
//

import CloudKit
import Foundation

public struct CloudKitAssetManager: @unchecked Sendable {
    private let tempDirectory: URL

    public init() {
        tempDirectory = FileManager.default.temporaryDirectory
    }

    // MARK: - Asset Creation

    public func createAsset(from data: Data, filename: String) async throws -> CKAsset {
        let fileURL = tempDirectory.appendingPathComponent(filename)

        // Write data to temporary file
        try data.write(to: fileURL)

        // Create CKAsset from file
        return CKAsset(fileURL: fileURL)
    }

    // MARK: - Asset Loading

    public func loadData(from asset: CKAsset) async throws -> Data? {
        guard let fileURL = asset.fileURL else {
            return nil
        }

        return try Data(contentsOf: fileURL)
    }

    // MARK: - Batch Asset Creation

    public func createAssets(from dataMap: [String: Data]) async throws -> [String: CKAsset] {
        var assets: [String: CKAsset] = [:]

        for (filename, data) in dataMap {
            assets[filename] = try await createAsset(from: data, filename: filename)
        }

        return assets
    }

    // MARK: - Cleanup

    public func cleanupTemporaryFiles(matching pattern: String? = nil) {
        do {
            let contents = try FileManager.default.contentsOfDirectory(
                at: tempDirectory,
                includingPropertiesForKeys: nil,
            )

            for url in contents {
                if let pattern {
                    if url.lastPathComponent.contains(pattern) {
                        try? FileManager.default.removeItem(at: url)
                    }
                } else {
                    // Clean all temp files created by this service
                    if url.lastPathComponent.hasPrefix("item_") ||
                        url.lastPathComponent.hasPrefix("receipt_") ||
                        url.lastPathComponent.hasPrefix("backup_")
                    {
                        try? FileManager.default.removeItem(at: url)
                    }
                }
            }
        } catch {
            // Ignore cleanup errors
        }
    }

    // MARK: - File Size Management

    public func estimateAssetSize(for data: Data) -> Int {
        // CKAsset adds some overhead, estimate ~10% increase
        Int(Double(data.count) * 1.1)
    }

    public func totalAssetSize(for items: [Item]) -> Int {
        var totalSize = 0

        for item in items {
            if let imageData = item.imageData {
                totalSize += estimateAssetSize(for: imageData)
            }
            if let receiptData = item.receiptImageData {
                totalSize += estimateAssetSize(for: receiptData)
            }
        }

        return totalSize
    }
}
