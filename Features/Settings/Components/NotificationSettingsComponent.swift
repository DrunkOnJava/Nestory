//
// Layer: Features
// Module: Settings/Components
// Purpose: Notification settings and preferences component
//

import SwiftUI
import UserNotifications
import Foundation

struct NotificationSettingsComponent: View {
    @State private var notificationsEnabled = false
    @State private var warrantyNotifications = true
    @State private var reminderNotifications = false
    @State private var maintenanceReminders = false
    @State private var warrantyReminderDays = 30
    @State private var notificationTime = Date()
    @State private var showingPermissionAlert = false
    
    var body: some View {
        Section("Notifications") {
            Toggle("Enable Notifications", isOn: $notificationsEnabled)
                .onChange(of: notificationsEnabled) { _, newValue in
                    if newValue {
                        requestNotificationPermission()
                    }
                }
            
            if notificationsEnabled {
                Group {
                    Toggle("Warranty Expiration Alerts", isOn: $warrantyNotifications)
                        .padding(.leading)
                    
                    if warrantyNotifications {
                        HStack {
                            Text("Remind me")
                            Spacer()
                            Picker("Days", selection: $warrantyReminderDays) {
                                Text("7 days before").tag(7)
                                Text("14 days before").tag(14)
                                Text("30 days before").tag(30)
                                Text("60 days before").tag(60)
                                Text("90 days before").tag(90)
                            }
                        }
                        .padding(.leading)
                    }
                    
                    Toggle("Maintenance Reminders", isOn: $maintenanceReminders)
                        .padding(.leading)
                    
                    Toggle("Item Value Updates", isOn: $reminderNotifications)
                        .padding(.leading)
                    
                    DatePicker("Notification Time", selection: $notificationTime, displayedComponents: .hourAndMinute)
                        .padding(.leading)
                }
            }
            
            NavigationLink("Notification History") {
                NotificationHistoryView()
            }
            
            Button("Test Notification") {
                sendTestNotification()
            }
            .disabled(!notificationsEnabled)
        }
        
        Section("Critical Alerts") {
            Toggle("Emergency Notifications", isOn: .constant(false))
            Text("Critical alerts for disaster-related events")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .alert("Notification Permission Required", isPresented: $showingPermissionAlert) {
            Button("Settings") {
                openAppSettings()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please enable notifications in Settings to receive warranty and maintenance reminders.")
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if !granted {
                    notificationsEnabled = false
                    showingPermissionAlert = true
                }
            }
        }
    }
    
    private func sendTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Nestory Test Notification"
        content.body = "This is a test notification to verify your settings are working correctly."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func openAppSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}

private struct NotificationHistoryView: View {
    @State private var notifications: [NotificationRecord] = [
        NotificationRecord(
            date: Date(),
            title: "Warranty Expiring Soon",
            message: "Your MacBook Pro warranty expires in 30 days",
            type: .warranty
        ),
        NotificationRecord(
            date: Date().addingTimeInterval(-86400),
            title: "Maintenance Reminder",
            message: "Time to service your HVAC system",
            type: .maintenance
        ),
        NotificationRecord(
            date: Date().addingTimeInterval(-172800),
            title: "Value Update Suggestion",
            message: "Consider updating values for 5 items",
            type: .valueUpdate
        )
    ]
    
    var body: some View {
        List {
            ForEach(notifications) { notification in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(notification.title)
                            .font(.headline)
                        
                        Spacer()
                        
                        NotificationTypeBadge(type: notification.type)
                    }
                    
                    Text(notification.message)
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Text(notification.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 2)
            }
            .onDelete(perform: deleteNotifications)
        }
        .navigationTitle("Notification History")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
    }
    
    private func deleteNotifications(offsets: IndexSet) {
        notifications.remove(atOffsets: offsets)
    }
}

private struct NotificationTypeBadge: View {
    let type: NotificationType
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: type.iconName)
            Text(type.displayName)
        }
        .font(.caption)
        .padding(.horizontal, 8)
        .padding(.vertical, 2)
        .background(type.color.opacity(0.2))
        .foregroundColor(type.color)
        .clipShape(Capsule())
    }
}

private struct NotificationRecord: Identifiable {
    let id = UUID()
    let date: Date
    let title: String
    let message: String
    let type: NotificationType
}

private enum NotificationType {
    case warranty, maintenance, valueUpdate, emergency
    
    var displayName: String {
        switch self {
        case .warranty: return "Warranty"
        case .maintenance: return "Maintenance"
        case .valueUpdate: return "Value Update"
        case .emergency: return "Emergency"
        }
    }
    
    var iconName: String {
        switch self {
        case .warranty: return "shield.checkerboard"
        case .maintenance: return "wrench.and.screwdriver"
        case .valueUpdate: return "dollarsign.circle"
        case .emergency: return "exclamationmark.triangle"
        }
    }
    
    var color: Color {
        switch self {
        case .warranty: return .blue
        case .maintenance: return .green
        case .valueUpdate: return .orange
        case .emergency: return .red
        }
    }
}

#Preview {
    NavigationView {
        List {
            NotificationSettingsComponent()
        }
        .navigationTitle("Settings")
    }
}