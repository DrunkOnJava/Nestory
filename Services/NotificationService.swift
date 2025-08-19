//
// Layer: Services
// Module: NotificationService
// Purpose: Manages warranty expiration and other notifications
//

import Foundation
import UserNotifications
import SwiftData

@MainActor
@Observable
public final class NotificationService: ObservableObject {
    private let notificationCenter = UNUserNotificationCenter.current()
    private let modelContext: ModelContext?
    
    // Notification identifiers
    private enum NotificationIdentifier {
        static func warrantyExpiration(itemId: UUID, days: Int) -> String {
            "warranty-expiration-\(itemId)-\(days)days"
        }
        
        static func insurancePolicyRenewal(policyId: String) -> String {
            "insurance-renewal-\(policyId)"
        }
        
        static func documentUpdateReminder(itemId: UUID) -> String {
            "document-update-\(itemId)"
        }
        
        static func maintenanceReminder(itemId: UUID) -> String {
            "maintenance-reminder-\(itemId)"
        }
    }
    
    // Notification settings keys
    private enum NotificationSettings {
        static let notificationsEnabled = "notificationsEnabled"
        static let warrantyNotificationsEnabled = "warrantyNotificationsEnabled"
        static let insuranceNotificationsEnabled = "insuranceNotificationsEnabled"
        static let documentNotificationsEnabled = "documentNotificationsEnabled"
        static let maintenanceNotificationsEnabled = "maintenanceNotificationsEnabled"
        
        // Days before expiration to notify
        static let warrantyNotificationDays = "warrantyNotificationDays"
        static let defaultNotificationDays = [30, 60, 90] // 30, 60, 90 days before
    }
    
    // Published properties for settings
    @Published public var isAuthorized = false
    @Published public var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    public init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        Task {
            await checkAuthorizationStatus()
        }
    }
    
    // MARK: - Authorization
    
    public func requestAuthorization() async -> Bool {
        do {
            let authorized = try await notificationCenter.requestAuthorization(
                options: [.alert, .badge, .sound]
            )
            await checkAuthorizationStatus()
            return authorized
        } catch {
            print("Failed to request notification authorization: \(error)")
            return false
        }
    }
    
    public func checkAuthorizationStatus() async {
        let settings = await notificationCenter.notificationSettings()
        authorizationStatus = settings.authorizationStatus
        isAuthorized = settings.authorizationStatus == .authorized
    }
    
    // MARK: - Warranty Notifications
    
    public func scheduleWarrantyExpirationNotifications(for item: Item) async throws {
        guard isAuthorized else {
            print("Notifications not authorized")
            return
        }
        
        guard let warrantyDate = item.warrantyExpirationDate else {
            print("No warranty expiration date for item: \(item.name)")
            return
        }
        
        // Cancel existing notifications for this item
        await cancelWarrantyNotifications(for: item.id)
        
        // Get notification days from settings or use defaults
        let notificationDays = UserDefaults.standard.array(
            forKey: NotificationSettings.warrantyNotificationDays
        ) as? [Int] ?? NotificationSettings.defaultNotificationDays
        
        // Schedule notifications for each reminder period
        for days in notificationDays {
            let notificationDate = warrantyDate.addingTimeInterval(-Double(days * 24 * 60 * 60))
            
            // Only schedule if the notification date is in the future
            if notificationDate > Date() {
                let content = UNMutableNotificationContent()
                content.title = "Warranty Expiring Soon"
                content.body = "\(item.name) warranty expires in \(days) days"
                content.sound = .default
                content.badge = 1
                content.categoryIdentifier = "WARRANTY_EXPIRATION"
                
                // Add item info to userInfo for deep linking
                content.userInfo = [
                    "itemId": item.id.uuidString,
                    "itemName": item.name,
                    "warrantyDate": warrantyDate.timeIntervalSince1970,
                    "daysRemaining": days
                ]
                
                // Create date components for the trigger
                let triggerDate = Calendar.current.dateComponents(
                    [.year, .month, .day, .hour, .minute],
                    from: notificationDate
                )
                
                let trigger = UNCalendarNotificationTrigger(
                    dateMatching: triggerDate,
                    repeats: false
                )
                
                let identifier = NotificationIdentifier.warrantyExpiration(
                    itemId: item.id,
                    days: days
                )
                
                let request = UNNotificationRequest(
                    identifier: identifier,
                    content: content,
                    trigger: trigger
                )
                
                try await notificationCenter.add(request)
                print("Scheduled warranty notification for \(item.name) - \(days) days before expiration")
            }
        }
    }
    
    public func cancelWarrantyNotifications(for itemId: UUID) async {
        let identifiers = [30, 60, 90].map { days in
            NotificationIdentifier.warrantyExpiration(itemId: itemId, days: days)
        }
        
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
        print("Cancelled warranty notifications for item: \(itemId)")
    }
    
    // MARK: - Batch Scheduling
    
    public func scheduleAllWarrantyNotifications() async throws {
        guard let modelContext = modelContext else {
            print("No model context available")
            return
        }
        
        let descriptor = FetchDescriptor<Item>(
            predicate: #Predicate { item in
                item.warrantyExpirationDate != nil
            }
        )
        
        do {
            let items = try modelContext.fetch(descriptor)
            print("Found \(items.count) items with warranty dates")
            
            for item in items {
                try await scheduleWarrantyExpirationNotifications(for: item)
            }
        } catch {
            print("Failed to fetch items: \(error)")
            throw error
        }
    }
    
    // MARK: - Upcoming Warranties
    
    public func getUpcomingWarrantyExpirations(within days: Int = 90) async throws -> [Item] {
        guard let modelContext = modelContext else {
            return []
        }
        
        let futureDate = Date().addingTimeInterval(Double(days * 24 * 60 * 60))
        let now = Date()
        
        let descriptor = FetchDescriptor<Item>(
            predicate: #Predicate { item in
                item.warrantyExpirationDate != nil &&
                item.warrantyExpirationDate! > now &&
                item.warrantyExpirationDate! <= futureDate
            },
            sortBy: [SortDescriptor(\.warrantyExpirationDate)]
        )
        
        return try modelContext.fetch(descriptor)
    }
    
    // MARK: - Insurance Policy Notifications
    
    public func scheduleInsurancePolicyRenewal(
        policyId: String,
        policyName: String,
        renewalDate: Date
    ) async throws {
        guard isAuthorized else { return }
        
        // Schedule 30 days before renewal
        let notificationDate = renewalDate.addingTimeInterval(-30 * 24 * 60 * 60)
        
        guard notificationDate > Date() else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Insurance Policy Renewal"
        content.body = "\(policyName) needs renewal in 30 days"
        content.sound = .default
        content.categoryIdentifier = "INSURANCE_RENEWAL"
        content.userInfo = ["policyId": policyId]
        
        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour],
            from: notificationDate
        )
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: triggerDate,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: NotificationIdentifier.insurancePolicyRenewal(policyId: policyId),
            content: content,
            trigger: trigger
        )
        
        try await notificationCenter.add(request)
    }
    
    // MARK: - Document Update Reminders
    
    public func scheduleDocumentUpdateReminder(for item: Item, afterDays days: Int = 180) async throws {
        guard isAuthorized else { return }
        
        let reminderDate = Date().addingTimeInterval(Double(days * 24 * 60 * 60))
        
        let content = UNMutableNotificationContent()
        content.title = "Document Update Reminder"
        content.body = "Review and update documentation for \(item.name)"
        content.sound = .default
        content.categoryIdentifier = "DOCUMENT_UPDATE"
        content.userInfo = ["itemId": item.id.uuidString]
        
        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour],
            from: reminderDate
        )
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: triggerDate,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: NotificationIdentifier.documentUpdateReminder(itemId: item.id),
            content: content,
            trigger: trigger
        )
        
        try await notificationCenter.add(request)
    }
    
    // MARK: - Maintenance Reminders
    
    public func scheduleMaintenanceReminder(
        for item: Item,
        maintenanceType: String,
        date: Date
    ) async throws {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Maintenance Reminder"
        content.body = "\(item.name) needs \(maintenanceType)"
        content.sound = .default
        content.categoryIdentifier = "MAINTENANCE"
        content.userInfo = [
            "itemId": item.id.uuidString,
            "maintenanceType": maintenanceType
        ]
        
        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour],
            from: date
        )
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: triggerDate,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: NotificationIdentifier.maintenanceReminder(itemId: item.id),
            content: content,
            trigger: trigger
        )
        
        try await notificationCenter.add(request)
    }
    
    // MARK: - Notification Management
    
    public func getPendingNotifications() async -> [UNNotificationRequest] {
        await notificationCenter.pendingNotificationRequests()
    }
    
    public func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
    }
    
    public func clearDeliveredNotifications() {
        notificationCenter.removeAllDeliveredNotifications()
    }
    
    // MARK: - Notification Categories Setup
    
    public func setupNotificationCategories() {
        let warrantyCategory = UNNotificationCategory(
            identifier: "WARRANTY_EXPIRATION",
            actions: [
                UNNotificationAction(
                    identifier: "VIEW_ITEM",
                    title: "View Item",
                    options: .foreground
                ),
                UNNotificationAction(
                    identifier: "RENEW_WARRANTY",
                    title: "Renew Warranty",
                    options: .foreground
                )
            ],
            intentIdentifiers: []
        )
        
        let insuranceCategory = UNNotificationCategory(
            identifier: "INSURANCE_RENEWAL",
            actions: [
                UNNotificationAction(
                    identifier: "VIEW_POLICY",
                    title: "View Policy",
                    options: .foreground
                )
            ],
            intentIdentifiers: []
        )
        
        let documentCategory = UNNotificationCategory(
            identifier: "DOCUMENT_UPDATE",
            actions: [
                UNNotificationAction(
                    identifier: "UPDATE_NOW",
                    title: "Update Now",
                    options: .foreground
                ),
                UNNotificationAction(
                    identifier: "REMIND_LATER",
                    title: "Remind in 1 Week",
                    options: []
                )
            ],
            intentIdentifiers: []
        )
        
        let maintenanceCategory = UNNotificationCategory(
            identifier: "MAINTENANCE",
            actions: [
                UNNotificationAction(
                    identifier: "MARK_COMPLETE",
                    title: "Mark Complete",
                    options: []
                ),
                UNNotificationAction(
                    identifier: "RESCHEDULE",
                    title: "Reschedule",
                    options: .foreground
                )
            ],
            intentIdentifiers: []
        )
        
        notificationCenter.setNotificationCategories([
            warrantyCategory,
            insuranceCategory,
            documentCategory,
            maintenanceCategory
        ])
    }
}

// MARK: - Notification Settings Extension

public extension NotificationService {
    func updateNotificationSettings(
        warrantyEnabled: Bool? = nil,
        insuranceEnabled: Bool? = nil,
        documentEnabled: Bool? = nil,
        maintenanceEnabled: Bool? = nil,
        notificationDays: [Int]? = nil
    ) {
        let defaults = UserDefaults.standard
        
        if let warrantyEnabled = warrantyEnabled {
            defaults.set(warrantyEnabled, forKey: NotificationSettings.warrantyNotificationsEnabled)
        }
        
        if let insuranceEnabled = insuranceEnabled {
            defaults.set(insuranceEnabled, forKey: NotificationSettings.insuranceNotificationsEnabled)
        }
        
        if let documentEnabled = documentEnabled {
            defaults.set(documentEnabled, forKey: NotificationSettings.documentNotificationsEnabled)
        }
        
        if let maintenanceEnabled = maintenanceEnabled {
            defaults.set(maintenanceEnabled, forKey: NotificationSettings.maintenanceNotificationsEnabled)
        }
        
        if let notificationDays = notificationDays {
            defaults.set(notificationDays, forKey: NotificationSettings.warrantyNotificationDays)
        }
    }
    
    func getNotificationSettings() -> (
        warranty: Bool,
        insurance: Bool,
        document: Bool,
        maintenance: Bool,
        days: [Int]
    ) {
        let defaults = UserDefaults.standard
        
        return (
            warranty: defaults.bool(forKey: NotificationSettings.warrantyNotificationsEnabled),
            insurance: defaults.bool(forKey: NotificationSettings.insuranceNotificationsEnabled),
            document: defaults.bool(forKey: NotificationSettings.documentNotificationsEnabled),
            maintenance: defaults.bool(forKey: NotificationSettings.maintenanceNotificationsEnabled),
            days: defaults.array(forKey: NotificationSettings.warrantyNotificationDays) as? [Int] ?? 
                  NotificationSettings.defaultNotificationDays
        )
    }
}