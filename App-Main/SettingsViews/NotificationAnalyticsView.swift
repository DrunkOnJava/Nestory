//
// Layer: App-Main
// Module: SettingsViews
// Purpose: TCA-driven notification analytics visualization and insights
//
// 🏗️ TCA PATTERN: Dependency injection for service access
// - Uses @Dependency for NotificationService instead of @StateObject
// - Clean separation between UI logic and service implementation
// - Testable through TCA dependency injection system

import ComposableArchitecture
import SwiftUI

// Use NotificationAnalyticsData from Services layer
// (NotificationAnalyticsData struct is defined in Services/NotificationService/NotificationSchedulingTypes.swift)

struct NotificationAnalyticsView: View {
    @Dependency(\.notificationService) var notificationService
    @State private var analytics: NotificationAnalyticsData?
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        List {
            if isLoading {
                Section {
                    HStack {
                        ProgressView()
                        Text("Loading analytics...")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowBackground(Color.clear)
                }
            } else if let errorMessage {
                Section {
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.title)
                            .foregroundColor(.orange)
                        Text("Unable to Load Analytics")
                            .font(.headline)
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                }
            } else if let analytics {
                // Overview Section
                Section("Performance Overview") {
                    AnalyticsMetricRow(
                        title: "Total Scheduled",
                        value: "\(analytics.totalScheduled)",
                        icon: "calendar.badge.plus"
                    )

                    AnalyticsMetricRow(
                        title: "Delivery Rate",
                        value: String(format: "%.1f%%", analytics.deliveryRate * 100),
                        icon: "paperplane.fill",
                        color: analytics.deliveryRate > 0.8 ? .green : analytics.deliveryRate > 0.5 ? .orange : .red
                    )

                    AnalyticsMetricRow(
                        title: "Interaction Rate",
                        value: String(format: "%.1f%%", analytics.interactionRate * 100),
                        icon: "hand.tap.fill",
                        color: analytics.interactionRate > 0.5 ? .green : analytics.interactionRate > 0.3 ? .orange : .red
                    )

                    if analytics.averageResponseTime > 0 {
                        AnalyticsMetricRow(
                            title: "Avg Response Time",
                            value: formatTimeInterval(analytics.averageResponseTime),
                            icon: "clock.fill"
                        )
                    }
                }

                // Effectiveness by Type
                if !analytics.interactionRateByType.isEmpty {
                    Section("Effectiveness by Type") {
                        ForEach(Array(analytics.interactionRateByType.keys.sorted(by: { $0.rawValue < $1.rawValue })), id: \.self) { type in
                            let rate = analytics.interactionRateByType[type] ?? 0

                            HStack {
                                VStack(alignment: .leading) {
                                    Text(type.displayName)
                                        .font(.headline)
                                    Text("Interaction Rate")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                VStack(alignment: .trailing) {
                                    Text("\(rate * 100, specifier: "%.1f")%")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(rate > 0.5 ? .green : rate > 0.3 ? .orange : .red)

                                    // Simple progress bar
                                    ProgressView(value: rate)
                                        .frame(width: 60)
                                        .tint(rate > 0.5 ? .green : rate > 0.3 ? .orange : .red)
                                }
                            }
                        }
                    }
                }

                // Timing Insights
                Section("Timing Insights") {
                    if let mostEffective = analytics.mostEffectiveTime {
                        AnalyticsMetricRow(
                            title: "Most Effective Time",
                            value: DateFormatter.shortTime.string(from: mostEffective),
                            icon: "star.fill",
                            color: .yellow
                        )
                    }

                    if let leastEffective = analytics.leastEffectiveTime {
                        AnalyticsMetricRow(
                            title: "Least Effective Time",
                            value: DateFormatter.shortTime.string(from: leastEffective),
                            icon: "star.slash.fill",
                            color: .gray
                        )
                    }
                }

                // Snooze Patterns
                if !analytics.snoozePattersByType.isEmpty {
                    Section("Snooze Patterns") {
                        ForEach(Array(analytics.snoozePattersByType.keys.sorted(by: { $0.rawValue < $1.rawValue })), id: \.self) { type in
                            let snoozeCount = analytics.snoozePattersByType[type] ?? 0

                            AnalyticsMetricRow(
                                title: type.displayName,
                                value: "\(snoozeCount) snoozes",
                                icon: "moon.zzz.fill"
                            )
                        }
                    }
                }

                // Insights & Recommendations
                Section("Recommendations") {
                    AnalyticsInsightsView(analytics: analytics)
                }

            } else {
                Section {
                    Text("No analytics data available")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowBackground(Color.clear)
                }
            }
        }
        .navigationTitle("Notification Analytics")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await loadAnalytics()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Refresh") {
                    Task {
                        await loadAnalytics()
                    }
                }
                .disabled(isLoading)
            }
        }
        .task {
            await loadAnalytics()
        }
    }

    private func loadAnalytics() async {
        isLoading = true
        errorMessage = nil

        do {
            analytics = try await notificationService.getNotificationAnalytics()
        } catch {
            errorMessage = "Failed to load analytics: \(error.localizedDescription)"
        }

        isLoading = false
    }

    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        if interval < 60 {
            "\(Int(interval))s"
        } else if interval < 3600 {
            "\(Int(interval / 60))m"
        } else {
            "\(Int(interval / 3600))h"
        }
    }
}

// MARK: - Supporting Views

struct AnalyticsMetricRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    init(title: String, value: String, icon: String, color: Color = .blue) {
        self.title = title
        self.value = value
        self.icon = icon
        self.color = color
    }

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)

            Text(title)

            Spacer()

            Text(value)
                .font(.headline)
                .foregroundColor(color)
        }
    }
}

struct AnalyticsInsightsView: View {
    let analytics: NotificationAnalyticsData

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if analytics.interactionRate < 0.3 {
                InsightCard(
                    icon: "exclamationmark.triangle.fill",
                    color: .orange,
                    title: "Low Interaction Rate",
                    description: "Consider reducing notification frequency or adjusting timing."
                )
            }

            if analytics.deliveryRate < 0.8 {
                InsightCard(
                    icon: "paperplane.slash.fill",
                    color: .red,
                    title: "Delivery Issues",
                    description: "Some notifications aren't being delivered. Check notification permissions."
                )
            }

            if analytics.interactionRate > 0.7 {
                InsightCard(
                    icon: "checkmark.circle.fill",
                    color: .green,
                    title: "Great Engagement",
                    description: "Your notification settings are working well!"
                )
            }

            // Dynamic recommendations based on timing
            if let mostEffective = analytics.mostEffectiveTime {
                let hour = Calendar.current.component(.hour, from: mostEffective)
                InsightCard(
                    icon: "clock.fill",
                    color: .blue,
                    title: "Optimal Timing",
                    description: "Your users respond best around \(hour):00. Consider scheduling important notifications then."
                )
            }
        }
    }
}

struct InsightCard: View {
    let icon: String
    let color: Color
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(color)

                Text(description)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

extension DateFormatter {
    static let shortTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
}
