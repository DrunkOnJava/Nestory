//
// Layer: App
// Module: Settings
// Purpose: Notification settings for alerts and reminders
//

import os.log
import SwiftUI
import UserNotifications

struct NotificationSettingsView: View {
    @StateObject private var notificationService = LiveNotificationService()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory.dev", category: "NotificationSettings")
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("warrantyNotificationsEnabled") private var warrantyNotificationsEnabled = true
    @AppStorage("insuranceNotificationsEnabled") private var insuranceNotificationsEnabled = true
    @AppStorage("documentNotificationsEnabled") private var documentNotificationsEnabled = false
    @AppStorage("maintenanceNotificationsEnabled") private var maintenanceNotificationsEnabled = false

    @State private var showingAuthorizationAlert = false
    @State private var selectedNotificationDays = Set<Int>([30, 60, 90])
    @State private var showingTestNotification = false
    @State private var isSchedulingNotifications = false

    private let availableNotificationDays = [7, 14, 30, 60, 90, 180]

    var body: some View {
        List {
            Section {
                // Main notification toggle with authorization status
                HStack {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { _, newValue in
                            if newValue {
                                Task {
                                    await handleNotificationToggle()
                                }
                            }
                        }

                    if notificationService.authorizationStatus == .denied {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .help("Notifications are disabled in Settings")
                    }
                }

                if notificationService.authorizationStatus == .denied {
                    Button {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Label("Open Settings", systemImage: "gear")
                            .foregroundColor(.blue)
                    }
                }
            } header: {
                Text("Notifications")
            } footer: {
                Text(authorizationStatusText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if notificationsEnabled, notificationService.isAuthorized {
                Section("Notification Types") {
                    Toggle("Warranty Expiration", isOn: $warrantyNotificationsEnabled)
                        .onChange(of: warrantyNotificationsEnabled) { _, newValue in
                            notificationService.updateNotificationSettings(warrantyEnabled: newValue)
                            if newValue {
                                scheduleAllWarrantyNotifications()
                            }
                        }

                    Toggle("Insurance Policy Renewal", isOn: $insuranceNotificationsEnabled)
                        .onChange(of: insuranceNotificationsEnabled) { _, newValue in
                            notificationService.updateNotificationSettings(insuranceEnabled: newValue)
                        }

                    Toggle("Document Update Reminders", isOn: $documentNotificationsEnabled)
                        .onChange(of: documentNotificationsEnabled) { _, newValue in
                            notificationService.updateNotificationSettings(documentEnabled: newValue)
                        }

                    Toggle("Maintenance Reminders", isOn: $maintenanceNotificationsEnabled)
                        .onChange(of: maintenanceNotificationsEnabled) { _, newValue in
                            notificationService.updateNotificationSettings(maintenanceEnabled: newValue)
                        }
                }

                if warrantyNotificationsEnabled {
                    Section {
                        ForEach(availableNotificationDays, id: \.self) { days in
                            HStack {
                                Label {
                                    Text("\(days) days before expiration")
                                } icon: {
                                    Image(systemName: selectedNotificationDays.contains(days) ?
                                        "checkmark.circle.fill" : "circle")
                                        .foregroundColor(selectedNotificationDays.contains(days) ?
                                            .blue : .gray)
                                }

                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                toggleNotificationDay(days)
                            }
                        }
                    } header: {
                        Text("Warranty Reminder Schedule")
                    } footer: {
                        Text("Choose when to receive warranty expiration reminders")
                    }
                }

                Section("Actions") {
                    Button {
                        scheduleAllWarrantyNotifications()
                    } label: {
                        HStack {
                            Label("Update All Notifications", systemImage: "bell.badge")
                            Spacer()
                            if isSchedulingNotifications {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                        }
                    }
                    .disabled(isSchedulingNotifications)

                    Button {
                        Task {
                            await testNotification()
                        }
                    } label: {
                        Label("Send Test Notification", systemImage: "bell.circle")
                    }

                    Button(role: .destructive) {
                        Task {
                            await notificationService.cancelAllNotifications()
                        }
                    } label: {
                        Label("Clear All Scheduled Notifications", systemImage: "bell.slash")
                    }
                }

                Section("Scheduled Notifications") {
                    NotificationListView(notificationService: notificationService)
                }
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Enable Notifications", isPresented: $showingAuthorizationAlert) {
            Button("Not Now", role: .cancel) {
                notificationsEnabled = false
            }
            Button("Enable") {
                Task {
                    await requestNotificationPermission()
                }
            }
        } message: {
            Text("Nestory needs permission to send you warranty expiration reminders and other important notifications.")
        }
        .task {
            await notificationService.checkAuthorizationStatus()
            loadNotificationDays()
        }
    }

    private var authorizationStatusText: String {
        switch notificationService.authorizationStatus {
        case .notDetermined:
            return "Tap to enable notifications"
        case .denied:
            return "Notifications disabled in Settings"
        case .authorized:
            return "Notifications enabled"
        case .provisional:
            return "Provisional notifications enabled"
        case .ephemeral:
            return "Ephemeral notifications enabled"
        @unknown default:
            return "Unknown status"
        }
    }

    private func handleNotificationToggle() async {
        await notificationService.checkAuthorizationStatus()

        if notificationService.authorizationStatus == .notDetermined {
            showingAuthorizationAlert = true
        } else if notificationService.authorizationStatus == .denied {
            notificationsEnabled = false
        }
    }

    private func requestNotificationPermission() async {
        do {
            let authorized = try await notificationService.requestAuthorization()
            notificationsEnabled = authorized

            if authorized {
                await notificationService.setupNotificationCategories()
                scheduleAllWarrantyNotifications()
            }
        } catch {
            notificationsEnabled = false
        }
    }

    private func toggleNotificationDay(_ days: Int) {
        if selectedNotificationDays.contains(days) {
            selectedNotificationDays.remove(days)
        } else {
            selectedNotificationDays.insert(days)
        }

        // Save to UserDefaults
        let daysArray = Array(selectedNotificationDays).sorted()
        notificationService.updateNotificationSettings(notificationDays: daysArray)

        // Reschedule notifications with new settings
        scheduleAllWarrantyNotifications()
    }

    private func loadNotificationDays() {
        let settings = notificationService.getNotificationSettings()
        selectedNotificationDays = Set(settings.days)
    }

    private func scheduleAllWarrantyNotifications() {
        guard warrantyNotificationsEnabled else { return }

        isSchedulingNotifications = true
        Task {
            do {
                try await notificationService.scheduleAllWarrantyNotifications()
            } catch {
                logger.error("Failed to schedule notifications: \(error)")
            }
            isSchedulingNotifications = false
        }
    }

    func testNotification() async {
        let content = UNMutableNotificationContent()
        content.title = "Test Notification"
        content.body = "Your warranty notifications are working correctly!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(
            identifier: "test-notification",
            content: content,
            trigger: trigger,
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
            showingTestNotification = true
        } catch {
            logger.error("Failed to send test notification: \(error)")
        }
    }
}

// MARK: - Notification List View

struct NotificationListView: View {
    let notificationService: NotificationService
    @State private var pendingNotifications: [NotificationRequestData] = []
    @State private var isLoading = true

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity)
            } else if pendingNotifications.isEmpty {
                Text("No scheduled notifications")
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                ForEach(pendingNotifications, id: \.identifier) { notification in
                    NotificationRowView(notification: notification)
                }
            }
        }
        .task {
            await loadPendingNotifications()
        }
    }

    private func loadPendingNotifications() async {
        pendingNotifications = await notificationService.getPendingNotifications()
        isLoading = false
    }
}

// MARK: - Notification Row View

struct NotificationRowView: View {
    let notification: NotificationRequestData

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(notification.title)
                .font(.system(.body, design: .rounded))

            Text(notification.body)
                .font(.caption)
                .foregroundColor(.secondary)

            if let triggerDate = notification.triggerDate {
                Label {
                    Text(triggerDate, style: .relative)
                } icon: {
                    Image(systemName: "clock")
                        .font(.caption)
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    NavigationStack {
        NotificationSettingsView()
    }
}
