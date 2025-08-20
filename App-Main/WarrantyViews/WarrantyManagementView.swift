//
// Layer: App-Main
// Module: WarrantyViews
// Purpose: Manage item warranty information
//

import os.log
import SwiftUI

struct WarrantyManagementView: View {
    @Bindable var item: Item
    @StateObject private var notificationService = LiveNotificationService()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory.dev", category: "WarrantyManagement")

    @State private var warrantyEnabled = false
    @State private var warrantyExpiration = Date()
    @State private var warrantyProvider = ""
    @State private var warrantyNotes = ""
    @State private var showingWarrantyAlert = false
    @State private var notificationsScheduled = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Toggle("Warranty Coverage", isOn: $warrantyEnabled)
                .tint(.green)

            if warrantyEnabled {
                GroupBox {
                    VStack(spacing: 12) {
                        DatePicker(
                            "Expiration Date",
                            selection: $warrantyExpiration,
                            in: Date()...,
                            displayedComponents: .date,
                        )

                        TextField("Warranty Provider", text: $warrantyProvider)
                            .textFieldStyle(.roundedBorder)

                        VStack(alignment: .leading) {
                            Text("Warranty Notes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextEditor(text: $warrantyNotes)
                                .frame(minHeight: 80)
                                .padding(4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(.systemGray4), lineWidth: 1),
                                )
                        }
                    }
                }

                // Warranty status display
                if let statusInfo = WarrantyStatusCalculator.calculate(expirationDate: warrantyExpiration) {
                    HStack {
                        Image(systemName: statusInfo.icon)
                            .foregroundColor(statusInfo.color)
                        Text(statusInfo.text)
                            .font(.caption)
                            .foregroundColor(statusInfo.color)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(statusInfo.color.opacity(0.1))
                    .cornerRadius(8)
                }

                // Show notification status
                if warrantyEnabled, notificationsScheduled {
                    HStack {
                        Image(systemName: "bell.badge.fill")
                            .foregroundColor(.blue)
                        Text("Expiration reminders scheduled")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                }
            }
        }
        .alert("Warranty Expiring Soon", isPresented: $showingWarrantyAlert) {
            Button("OK") {}
        } message: {
            Text("This warranty expires in less than 30 days. You'll receive a notification reminder.")
        }
        .onAppear {
            loadExistingData()
            checkNotificationAuthorization()
        }
        .onChange(of: warrantyEnabled) { _, _ in saveChanges() }
        .onChange(of: warrantyExpiration) { _, _ in saveChanges() }
        .onChange(of: warrantyProvider) { _, _ in saveChanges() }
        .onChange(of: warrantyNotes) { _, _ in saveChanges() }
    }

    private func loadExistingData() {
        warrantyEnabled = item.warrantyExpirationDate != nil
        warrantyExpiration = item.warrantyExpirationDate ?? Date()
        warrantyProvider = item.warrantyProvider ?? ""
        warrantyNotes = item.warrantyNotes ?? ""
    }

    private func checkNotificationAuthorization() {
        Task {
            await notificationService.checkAuthorizationStatus()
        }
    }

    private func saveChanges() {
        if warrantyEnabled {
            item.warrantyExpirationDate = warrantyExpiration
            item.warrantyProvider = warrantyProvider.isEmpty ? nil : warrantyProvider
            item.warrantyNotes = warrantyNotes.isEmpty ? nil : warrantyNotes

            // Check if warranty is expiring soon
            if let statusInfo = WarrantyStatusCalculator.calculate(expirationDate: warrantyExpiration),
               statusInfo.daysRemaining < 30, statusInfo.daysRemaining >= 0
            {
                showingWarrantyAlert = true
            }

            // Schedule notifications for warranty expiration
            scheduleWarrantyNotifications()
        } else {
            item.warrantyExpirationDate = nil
            item.warrantyProvider = nil
            item.warrantyNotes = nil

            // Cancel any existing warranty notifications
            cancelWarrantyNotifications()
        }

        item.updatedAt = Date()
    }

    private func scheduleWarrantyNotifications() {
        Task {
            // Check if notifications are authorized
            await notificationService.checkAuthorizationStatus()

            if notificationService.isAuthorized {
                do {
                    try await notificationService.scheduleWarrantyExpirationNotifications(for: item)
                    notificationsScheduled = true
                    logger.info("Warranty notifications scheduled for \(item.name)")
                } catch {
                    logger.error("Failed to schedule warranty notifications: \(error)")
                    notificationsScheduled = false
                }
            } else if notificationService.authorizationStatus == .notDetermined {
                // Request authorization if not determined
                do {
                    let authorized = try await notificationService.requestAuthorization()
                    if authorized {
                        await notificationService.setupNotificationCategories()
                        try await notificationService.scheduleWarrantyExpirationNotifications(for: item)
                        notificationsScheduled = true
                        logger.info("Warranty notifications scheduled for \(item.name)")
                    }
                } catch {
                    logger.error("Failed to request authorization or schedule notifications: \(error)")
                    notificationsScheduled = false
                }
            }
        }
    }

    private func cancelWarrantyNotifications() {
        Task { @MainActor in
            await notificationService.cancelWarrantyNotifications(for: item.id)
            notificationsScheduled = false
            logger.info("Warranty notifications cancelled for \(item.name)")
        }
    }
}
