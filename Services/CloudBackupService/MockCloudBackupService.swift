//
// Layer: Services
// Module: CloudBackupService
// Purpose: Mock implementation of cloud backup service for testing
//

import Foundation
import SwiftData

public final class MockCloudBackupService: CloudBackupService {
    public var isBackingUp = false
    public var isRestoring = false
    public var lastBackupDate: Date? = nil
    public var backupStatus: BackupStatus = .idle
    public var errorMessage: String? = nil
    public var progress = 0.0
    public var isCloudKitAvailable = true

    // Track operations for testing
    public var backupCalled = false
    public var restoreCalled = false
    public var backupItems: [Item] = []
    public var backupCategories: [Category] = []
    public var backupRooms: [Room] = []

    // Mock responses
    public var shouldFailBackup = false
    public var shouldFailRestore = false
    public var mockBackupInfo: BackupMetadata?
    public var mockRestoreResult: RestoreResult?

    public init() {
        // Set up some default mock data
        mockBackupInfo = BackupMetadata(
            forCloudBackup: Date(),
            itemCount: 42,
            deviceName: "Mock Device"
        )

        mockRestoreResult = RestoreResult(
            itemsRestored: 42,
            categoriesRestored: 5,
            roomsRestored: 8,
            backupDate: Date(),
        )
    }

    // MARK: - CloudKit Management

    public func checkCloudKitAvailability() async -> Bool {
        isCloudKitAvailable
    }

    // MARK: - Backup Operations

    public func performBackup(items: [Item], categories: [Category], rooms: [Room]) async throws {
        backupCalled = true
        backupItems = items
        backupCategories = categories
        backupRooms = rooms

        if shouldFailBackup {
            throw BackupError.backupFailed("Mock backup failure")
        }

        // Simulate backup progress
        isBackingUp = true
        backupStatus = .backing(.preparing)

        for phase in [BackupStatus.BackupPhase.clearing, .categories, .rooms, .items, .metadata] {
            backupStatus = .backing(phase)
            progress += 0.2
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        }

        isBackingUp = false
        backupStatus = .completed
        lastBackupDate = Date()
        progress = 1.0
    }

    public func estimateBackupSize(items: [Item]) -> String {
        let size = items.count * 1024 // Mock 1KB per item
        return ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .binary)
    }

    public func getBackupInfo() async throws -> BackupMetadata? {
        mockBackupInfo
    }

    // MARK: - Restore Operations

    public func performRestore(modelContext _: ModelContext) async throws -> RestoreResult {
        restoreCalled = true

        if shouldFailRestore {
            throw BackupError.restoreFailed("Mock restore failure")
        }

        // Simulate restore progress
        isRestoring = true
        backupStatus = .restoring(.preparing)

        for phase in [BackupStatus.RestorePhase.categories, .rooms, .items] {
            backupStatus = .restoring(phase)
            progress += 0.33
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        }

        isRestoring = false
        backupStatus = .completed
        progress = 1.0

        return mockRestoreResult ?? RestoreResult(
            itemsRestored: 0,
            categoriesRestored: 0,
            roomsRestored: 0,
            backupDate: Date(),
        )
    }
}
