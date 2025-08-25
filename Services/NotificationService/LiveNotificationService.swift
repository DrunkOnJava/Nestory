//
// Layer: Services
// Module: NotificationService
// Purpose: Live implementation of notification service managing warranty expiration and other notifications
//

import Foundation
import os.log
import SwiftData
@preconcurrency import UserNotifications

// APPLE_FRAMEWORK_OPPORTUNITY: Replace with Speech Framework - Add voice-activated item queries and hands-free inventory management using SFSpeechRecognizer

@MainActor
public final class LiveNotificationService: NotificationService, ObservableObject {
    // Internal access to shared utilities
    let notificationActor: NotificationActor
    let modelContext: ModelContext?
    let logger: Logger
    let resilientExecutor: ResilientOperationExecutor

    // Error recovery and retry attempts
    private var authorizationRetryCount = 0
    private let maxAuthorizationRetries = 3

    // Published properties for settings (keeping sync for compatibility)
    @Published public var isAuthorized = false
    @Published public var authorizationStatus: UNAuthorizationStatus = .notDetermined

    public init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        notificationActor = NotificationActor()
        logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory", category: "NotificationService")
        resilientExecutor = ResilientOperationExecutor()

        Task {
            await checkAuthorizationStatus()
        }
    }

    // MARK: - Authorization

    public func requestAuthorization() async throws -> Bool {
        try await resilientExecutor.execute(
            operation: { @MainActor [weak self] in
                guard let self else {
                    throw ServiceError.unknown(underlying: "NotificationService deallocated")
                }

                let authorized = try await notificationActor.requestAuthorization(
                    options: [.alert, .badge, .sound],
                )

                await checkAuthorizationStatus()

                if !authorized {
                    authorizationRetryCount += 1
                    if authorizationRetryCount < maxAuthorizationRetries {
                        throw ServiceError.permissionDenied(resource: "notifications")
                    } else {
                        throw NotificationServiceError.authorizationDenied
                    }
                }

                authorizationRetryCount = 0 // Reset on success
                return authorized
            },
            fallbackValue: false,
            operationType: "requestNotificationAuthorization",
        )
    }

    /// Legacy method for backward compatibility - returns Bool instead of throwing
    @available(*, deprecated, message: "Use requestAuthorization() throws instead")
    public func requestAuthorizationLegacy() async -> Bool {
        do {
            return try await requestAuthorization()
        } catch {
            logger.error("Failed to request notification authorization: \(error)")
            return false
        }
    }

    public func checkAuthorizationStatus() async {
        let settings = await notificationActor.getSettingsData()
        authorizationStatus = settings.authorizationStatus
        isAuthorized = settings.authorizationStatus == .authorized
    }

    // MARK: - Core Notification Scheduling

    public func scheduleNotification(
        id: String,
        content: UNNotificationContent,
        trigger: UNNotificationTrigger
    ) async throws {
        // Create the request locally - the actor's @preconcurrency import handles Sendable
        let request = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: trigger
        )
        
        // The NotificationActor uses @preconcurrency import for UserNotifications
        // to properly handle non-Sendable types across actor boundaries
        try await notificationActor.add(request)
    }

    // All notification operations have been moved to extension files:
    // - NotificationWarrantyOperations.swift - warranty-specific operations
    // - NotificationOtherOperations.swift - insurance, document, maintenance operations
    // - NotificationManagement.swift - management utilities and settings
}
