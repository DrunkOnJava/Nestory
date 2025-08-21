//
// Layer: App-Main
// Module: SettingsViews
// Purpose: TCA-driven notification frequency and timing preferences
//
// 🏗️ TCA PATTERN: Dependency injection for service access
// - Uses @Dependency for NotificationService instead of @StateObject
// - Clean separation between UI logic and service implementation
// - Testable through TCA dependency injection system

import ComposableArchitecture
import SwiftUI

struct NotificationFrequencyView: View {
    @Dependency(\.notificationService) var notificationService
    @State private var settings = NotificationSettings()
    @State private var selectedFrequency: NotificationFrequency = .normal
    @State private var optimalHour = 9
    @State private var weekendNotifications = false
    @State private var summaryNotifications = true
    @State private var analyticsEnabled = true
    @State private var isUpdating = false
    @State private var statusMessage: String?

    var body: some View {
        List {
            // Frequency Selection
            Section {
                ForEach(NotificationFrequency.allCases, id: \.self) { frequency in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(frequency.displayName)
                                .font(.headline)
                            Text(frequencyDescription(frequency))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        if selectedFrequency == frequency {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        } else {
                            Image(systemName: "circle")
                                .foregroundColor(.gray)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedFrequency = frequency
                        updateFrequency()
                    }
                }
            } header: {
                Text("Notification Frequency")
            } footer: {
                Text("Choose how often you want to receive notifications. This affects the number and timing of reminders.")
            }

            // Timing Preferences
            Section("Timing Preferences") {
                HStack {
                    Text("Preferred Time")
                    Spacer()
                    Picker("Hour", selection: $optimalHour) {
                        ForEach(6 ... 22, id: \.self) { hour in
                            Text(formatHour(hour)).tag(hour)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: optimalHour) { _, _ in
                        updateSettings()
                    }
                }

                Toggle("Weekend Notifications", isOn: $weekendNotifications)
                    .onChange(of: weekendNotifications) { _, _ in
                        updateSettings()
                    }

                HStack {
                    VStack(alignment: .leading) {
                        Text("Summary Notifications")
                        Text("Weekly digest of expiring items")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Toggle("", isOn: $summaryNotifications)
                        .onChange(of: summaryNotifications) { _, _ in
                            updateSettings()
                        }
                }
            }

            // Advanced Options
            Section("Advanced Options") {
                Toggle("Analytics Collection", isOn: $analyticsEnabled)
                    .onChange(of: analyticsEnabled) { _, _ in
                        updateSettings()
                    }

                Button {
                    Task {
                        await applyOptimalTiming()
                    }
                } label: {
                    HStack {
                        Label("Apply Optimal Timing", systemImage: "wand.and.rays")
                        Spacer()
                        if isUpdating {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                }
                .disabled(isUpdating || !analyticsEnabled)

                Button {
                    resetToRecommended()
                } label: {
                    Label("Reset to Recommended", systemImage: "arrow.counterclockwise")
                }
                .foregroundColor(.blue)
            }

            // Current Status
            Section("Current Status") {
                if let message = statusMessage {
                    Text(message)
                        .font(.caption)
                        .foregroundColor(.blue)
                }

                StatusInfoRow(title: "Active Frequency", value: selectedFrequency.displayName)
                StatusInfoRow(title: "Optimal Time", value: formatHour(optimalHour))
                StatusInfoRow(title: "Weekend Notifications", value: weekendNotifications ? "Enabled" : "Disabled")
                StatusInfoRow(title: "Summary Enabled", value: summaryNotifications ? "Yes" : "No")
            }

            // Frequency Preview
            Section("Preview") {
                FrequencyPreviewView(frequency: selectedFrequency)
            }
        }
        .navigationTitle("Notification Frequency")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadCurrentSettings()
        }
    }

    // MARK: - Settings Management

    private func loadCurrentSettings() {
        selectedFrequency = settings.frequency
        optimalHour = settings.optimalNotificationHour
        weekendNotifications = settings.weekendNotificationsEnabled
        summaryNotifications = settings.summaryNotificationsEnabled
        analyticsEnabled = settings.analyticsEnabled
    }

    private func updateFrequency() {
        settings.frequency = selectedFrequency
        statusMessage = "Frequency updated to \(selectedFrequency.displayName)"

        Task {
            // Apply frequency changes to existing scheduled notifications
            do {
                try await notificationService.rescheduleNotificationsWithPriority()
                statusMessage = "All notifications updated with new frequency"
            } catch {
                statusMessage = "Failed to update notifications: \(error.localizedDescription)"
            }
        }
    }

    private func updateSettings() {
        settings.optimalNotificationHour = optimalHour
        settings.weekendNotificationsEnabled = weekendNotifications
        settings.summaryNotificationsEnabled = summaryNotifications
        settings.analyticsEnabled = analyticsEnabled

        statusMessage = "Settings updated"
    }

    private func applyOptimalTiming() async {
        isUpdating = true
        statusMessage = "Calculating optimal timing from analytics..."

        do {
            let notificationAnalytics = try await notificationService.getNotificationAnalytics()
            let analytics = try await notificationAnalytics.generateAnalytics()

            if let mostEffectiveTime = analytics.mostEffectiveTime {
                let calendar = Calendar.current
                let hour = calendar.component(.hour, from: mostEffectiveTime)

                optimalHour = hour
                settings.optimalNotificationHour = hour

                statusMessage = "Applied optimal timing: \(formatHour(hour))"
            } else {
                statusMessage = "Not enough data to determine optimal timing"
            }
        } catch {
            statusMessage = "Failed to calculate optimal timing: \(error.localizedDescription)"
        }

        isUpdating = false
    }

    private func resetToRecommended() {
        // Calculate recommended settings based on user's context
        // This is a simplified version - real implementation would analyze user's inventory
        selectedFrequency = .normal
        optimalHour = 9
        weekendNotifications = false
        summaryNotifications = true
        analyticsEnabled = true

        // Apply settings
        updateFrequency()
        updateSettings()

        statusMessage = "Reset to recommended settings"
    }

    // MARK: - Helper Methods

    private func frequencyDescription(_ frequency: NotificationFrequency) -> String {
        switch frequency {
        case .minimal:
            "Only critical notifications (50% fewer)"
        case .normal:
            "Standard notification timing"
        case .frequent:
            "More frequent reminders (50% more)"
        case .maximum:
            "All possible notifications (100% more)"
        }
    }

    private func formatHour(_ hour: Int) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short

        let calendar = Calendar.current
        let date = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: Date()) ?? Date()

        return formatter.string(from: date)
    }
}

// MARK: - Supporting Views

struct StatusInfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct FrequencyPreviewView: View {
    let frequency: NotificationFrequency

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Example Schedule")
                .font(.headline)

            Text("For an item expiring in 30 days:")
                .font(.caption)
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 4) {
                ForEach(getExampleSchedule(), id: \.self) { day in
                    HStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 6, height: 6)

                        Text("\(day) days before expiration")
                            .font(.caption)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }

    private func getExampleSchedule() -> [Int] {
        let baseDays = [30, 7, 1]

        switch frequency {
        case .minimal:
            return [30, 1]
        case .normal:
            return baseDays
        case .frequent:
            return [30, 14, 7, 3, 1]
        case .maximum:
            return [30, 21, 14, 10, 7, 5, 3, 2, 1]
        }
    }
}
