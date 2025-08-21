//
// Layer: Services
// Module: NotificationService
// Purpose: Notification persistence and recovery system for app restart scenarios
//

import Foundation
import SwiftData
import os.log

/// Persistent storage and recovery system for notifications
@MainActor
public final class NotificationPersistence: @unchecked Sendable {
    private let logger: Logger
    private let userDefaults: UserDefaults
    private let fileManager: FileManager
    private let documentsURL: URL

    // Storage keys and file paths
    private enum Storage {
        static let scheduledNotificationsKey = "scheduled_notifications_v1"
        static let notificationStateKey = "notification_state_v1"
        static let backgroundTasksKey = "background_tasks_v1"
        static let recoveryDataFile = "notification_recovery.json"
    }

    public init(userDefaults: UserDefaults = .standard, fileManager: FileManager = .default) {
        self.logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory", category: "NotificationPersistence")
        self.userDefaults = userDefaults
        self.fileManager = fileManager

        // Set up documents directory for persistent storage
        self.documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!

        // Ensure recovery directory exists
        setupStorageDirectories()
    }

    // MARK: - Setup

    private func setupStorageDirectories() {
        let notificationDir = documentsURL.appendingPathComponent("Notifications")

        if !fileManager.fileExists(atPath: notificationDir.path) {
            do {
                try fileManager.createDirectory(at: notificationDir, withIntermediateDirectories: true)
                logger.info("Created notification storage directory")
            } catch {
                logger.error("Failed to create notification directory: \(error)")
            }
        }
    }

    // MARK: - State Persistence

    /// Save current notification state for recovery
    public func saveNotificationState(_ state: NotificationState) async throws {
        logger.info("Saving notification state with \(state.scheduledRequests.count) scheduled requests")

        do {
            // Save to UserDefaults for quick access
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601

            let data = try encoder.encode(state)
            userDefaults.set(data, forKey: Storage.notificationStateKey)

            // Also save to file for backup
            let fileURL = documentsURL.appendingPathComponent("Notifications").appendingPathComponent(Storage.recoveryDataFile)
            try data.write(to: fileURL)

            logger.info("Successfully saved notification state")

        } catch {
            logger.error("Failed to save notification state: \(error)")
            throw NotificationServiceError.persistenceFailed("Failed to save state: \(error.localizedDescription)")
        }
    }

    /// Restore notification state from persistence
    public func restoreNotificationState() async throws -> NotificationState {
        logger.info("Restoring notification state")

        var restoredState: NotificationState?

        // Try UserDefaults first
        if let data = userDefaults.data(forKey: Storage.notificationStateKey) {
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                restoredState = try decoder.decode(NotificationState.self, from: data)
                logger.info("Restored state from UserDefaults")
            } catch {
                logger.warning("Failed to decode state from UserDefaults: \(error)")
            }
        }

        // Fallback to file storage
        if restoredState == nil {
            let fileURL = documentsURL.appendingPathComponent("Notifications").appendingPathComponent(Storage.recoveryDataFile)

            if fileManager.fileExists(atPath: fileURL.path) {
                do {
                    let data = try Data(contentsOf: fileURL)
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    restoredState = try decoder.decode(NotificationState.self, from: data)
                    logger.info("Restored state from file backup")
                } catch {
                    logger.error("Failed to restore from file: \(error)")
                }
            }
        }

        let finalState = restoredState ?? NotificationState()
        logger.info("Restored notification state with \(finalState.scheduledRequests.count) scheduled requests")

        return finalState
    }

    /// Clear all persisted state
    public func clearPersistedState() async throws {
        logger.info("Clearing all persisted notification state")

        userDefaults.removeObject(forKey: Storage.notificationStateKey)
        userDefaults.removeObject(forKey: Storage.scheduledNotificationsKey)
        userDefaults.removeObject(forKey: Storage.backgroundTasksKey)

        // Remove files
        let notificationDir = documentsURL.appendingPathComponent("Notifications")
        let fileURL = notificationDir.appendingPathComponent(Storage.recoveryDataFile)

        if fileManager.fileExists(atPath: fileURL.path) {
            do {
                try fileManager.removeItem(at: fileURL)
                logger.info("Removed recovery file")
            } catch {
                logger.error("Failed to remove recovery file: \(error)")
            }
        }
    }

    // MARK: - Scheduled Request Tracking

    /// Save scheduled notification requests for tracking
    public func saveScheduledRequests(_ requests: [NotificationScheduleRequest]) async throws {
        logger.info("Saving \(requests.count) scheduled notification requests")

        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601

            let persistentRequests = requests.map { request in
                PersistentScheduleRequest(from: request)
            }

            let data = try encoder.encode(persistentRequests)
            userDefaults.set(data, forKey: Storage.scheduledNotificationsKey)

            logger.info("Successfully saved scheduled requests")

        } catch {
            logger.error("Failed to save scheduled requests: \(error)")
            throw NotificationServiceError.persistenceFailed("Failed to save requests: \(error.localizedDescription)")
        }
    }

    /// Load scheduled notification requests
    public func loadScheduledRequests() async throws -> [NotificationScheduleRequest] {
        guard let data = userDefaults.data(forKey: Storage.scheduledNotificationsKey) else {
            return []
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            let persistentRequests = try decoder.decode([PersistentScheduleRequest].self, from: data)
            let requests = persistentRequests.map { $0.toScheduleRequest() }

            logger.info("Loaded \(requests.count) scheduled notification requests")
            return requests

        } catch {
            logger.error("Failed to load scheduled requests: \(error)")
            throw NotificationServiceError.persistenceFailed("Failed to load requests: \(error.localizedDescription)")
        }
    }

    // MARK: - Background Task Management

    /// Save background task information
    public func saveBackgroundTaskInfo(_ taskInfo: BackgroundTaskInfo) async throws {
        var tasks = loadBackgroundTasks()
        tasks[taskInfo.identifier] = taskInfo

        // Clean up expired tasks
        let now = Date()
        tasks = tasks.filter { $0.value.expirationTime > now }

        do {
            let data = try JSONEncoder().encode(tasks)
            userDefaults.set(data, forKey: Storage.backgroundTasksKey)
            logger.info("Saved background task: \(taskInfo.identifier)")
        } catch {
            logger.error("Failed to save background task info: \(error)")
        }
    }

    /// Load background task information
    public func loadBackgroundTasks() -> [String: BackgroundTaskInfo] {
        guard let data = userDefaults.data(forKey: Storage.backgroundTasksKey),
              let tasks = try? JSONDecoder().decode([String: BackgroundTaskInfo].self, from: data)
        else {
            return [:]
        }

        return tasks
    }

    /// Remove completed background task
    public func removeBackgroundTask(_ identifier: String) async throws {
        var tasks = loadBackgroundTasks()
        tasks.removeValue(forKey: identifier)

        let data = try JSONEncoder().encode(tasks)
        userDefaults.set(data, forKey: Storage.backgroundTasksKey)
        logger.info("Removed background task: \(identifier)")
    }

    // MARK: - Recovery Operations

    /// Perform notification recovery after app restart
    public func performRecovery() async throws -> NotificationRecoveryResult {
        logger.info("Starting notification recovery process")

        let state = try await restoreNotificationState()
        let scheduledRequests = try await loadScheduledRequests()
        let backgroundTasks = loadBackgroundTasks()

        // Analyze what needs recovery
        let now = Date()
        let expiredRequests = scheduledRequests.filter { $0.scheduledDate < now }
        let futureRequests = scheduledRequests.filter { $0.scheduledDate >= now }
        let expiredTasks = backgroundTasks.values.filter { $0.expirationTime < now }

        let recoveryResult = NotificationRecoveryResult(
            totalRestored: scheduledRequests.count,
            expiredRequests: expiredRequests.count,
            futureRequests: futureRequests.count,
            expiredBackgroundTasks: expiredTasks.count,
            lastSaveDate: state.lastSaveDate
        )

        logger.info("Recovery completed: \(recoveryResult.totalRestored) total, \(recoveryResult.futureRequests) future, \(recoveryResult.expiredRequests) expired")

        return recoveryResult
    }

    /// Validate notification system integrity
    public func validateSystemIntegrity() async throws -> ValidationResult {
        logger.info("Validating notification system integrity")

        var issues: [String] = []
        var warnings: [String] = []

        // Check state consistency
        do {
            let state = try await restoreNotificationState()
            if state.scheduledRequests.isEmpty, state.lastSchedulingDate != nil {
                warnings.append("State shows scheduling activity but no requests stored")
            }
        } catch {
            issues.append("Failed to restore state: \(error.localizedDescription)")
        }

        // Check scheduled requests
        do {
            let requests = try await loadScheduledRequests()
            let duplicateIds = Set(requests.map(\.itemId)).count != requests.count
            if duplicateIds {
                warnings.append("Duplicate item IDs found in scheduled requests")
            }

            let pastRequests = requests.filter { $0.scheduledDate < Date() }
            if !pastRequests.isEmpty {
                warnings.append("\(pastRequests.count) requests scheduled in the past")
            }
        } catch {
            issues.append("Failed to validate scheduled requests: \(error.localizedDescription)")
        }

        // Check storage health
        let notificationDir = documentsURL.appendingPathComponent("Notifications")
        if !fileManager.fileExists(atPath: notificationDir.path) {
            issues.append("Notification storage directory missing")
        }

        let isValid = issues.isEmpty
        let result = ValidationResult(
            isValid: isValid,
            issues: issues,
            warnings: warnings,
            checkedAt: Date()
        )

        logger.info("Validation completed: \(isValid ? "VALID" : "INVALID"), \(issues.count) issues, \(warnings.count) warnings")
        return result
    }

    // MARK: - Cleanup Operations

    /// Clean up old and expired data
    public func performCleanup() async throws {
        logger.info("Starting notification persistence cleanup")

        // Clean up expired requests
        var requests = try await loadScheduledRequests()
        let originalCount = requests.count
        requests = requests.filter { $0.scheduledDate > Date() }

        if requests.count != originalCount {
            try await saveScheduledRequests(requests)
            logger.info("Cleaned up \(originalCount - requests.count) expired requests")
        }

        // Clean up expired background tasks
        var tasks = loadBackgroundTasks()
        let originalTaskCount = tasks.count
        tasks = tasks.filter { $0.value.expirationTime > Date() }

        if tasks.count != originalTaskCount {
            let data = try JSONEncoder().encode(tasks)
            userDefaults.set(data, forKey: Storage.backgroundTasksKey)
            logger.info("Cleaned up \(originalTaskCount - tasks.count) expired background tasks")
        }

        logger.info("Cleanup completed")
    }
}

// MARK: - Data Types

/// Complete notification state for persistence
public struct NotificationState: Codable, Sendable {
    public let scheduledRequests: [NotificationScheduleRequest]
    public let lastSchedulingDate: Date?
    public let lastSaveDate: Date
    public let version: String

    public init(
        scheduledRequests: [NotificationScheduleRequest] = [],
        lastSchedulingDate: Date? = nil,
        lastSaveDate: Date = Date(),
        version: String = "1.0"
    ) {
        self.scheduledRequests = scheduledRequests
        self.lastSchedulingDate = lastSchedulingDate
        self.lastSaveDate = lastSaveDate
        self.version = version
    }
}

/// Persistent version of NotificationScheduleRequest with Codable conformance
private struct PersistentScheduleRequest: Codable {
    let itemId: String
    let type: String
    let scheduledDate: Date
    let title: String
    let body: String
    let priority: Int
    let recurring: String?
    let customInterval: Int?
    let metadata: [String: String]

    init(from request: NotificationScheduleRequest) {
        self.itemId = request.itemId.uuidString
        self.type = request.type.rawValue
        self.scheduledDate = request.scheduledDate
        self.title = request.title
        self.body = request.body
        self.priority = request.priority.rawValue
        self.recurring = request.recurring?.rawValue
        self.customInterval = request.customInterval
        self.metadata = request.metadata
    }

    func toScheduleRequest() -> NotificationScheduleRequest {
        NotificationScheduleRequest(
            itemId: UUID(uuidString: itemId) ?? UUID(),
            type: ReminderType(rawValue: type) ?? .maintenance,
            scheduledDate: scheduledDate,
            title: title,
            body: body,
            priority: NotificationPriority(rawValue: priority) ?? .normal,
            recurring: recurring.flatMap { RecurringInterval(rawValue: $0) },
            customInterval: customInterval,
            metadata: metadata
        )
    }
}

/// Background task information for persistence
public struct BackgroundTaskInfo: Codable, Sendable {
    public let identifier: String
    public let taskType: String
    public let createdAt: Date
    public let expirationTime: Date
    public let metadata: [String: String]

    public init(
        identifier: String,
        taskType: String,
        createdAt: Date = Date(),
        expirationTime: Date,
        metadata: [String: String] = [:]
    ) {
        self.identifier = identifier
        self.taskType = taskType
        self.createdAt = createdAt
        self.expirationTime = expirationTime
        self.metadata = metadata
    }
}

/// Result of notification recovery operation
public struct NotificationRecoveryResult: Sendable {
    public let totalRestored: Int
    public let expiredRequests: Int
    public let futureRequests: Int
    public let expiredBackgroundTasks: Int
    public let lastSaveDate: Date?

    public var recoveryRate: Double {
        guard totalRestored > 0 else { return 0 }
        return Double(futureRequests) / Double(totalRestored)
    }
}

/// Result of system validation
public struct ValidationResult: Sendable {
    public let isValid: Bool
    public let issues: [String]
    public let warnings: [String]
    public let checkedAt: Date

    public var hasWarnings: Bool {
        !warnings.isEmpty
    }

    public var hasIssues: Bool {
        !issues.isEmpty
    }
}
