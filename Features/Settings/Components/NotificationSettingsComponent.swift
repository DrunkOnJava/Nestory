//
// Layer: Features
// Module: Settings/Components
// Purpose: Notification settings and analytics components
//

import SwiftUI
import Foundation

struct NotificationSettingsComponent {
    
    @MainActor
    static func notificationAnalyticsView() -> some View {
        NotificationAnalyticsView()
    }
    
    @MainActor
    static func notificationFrequencyView() -> some View {
        Form {
            Section("Warranty Notifications") {
                Picker("Frequency", selection: .constant("Weekly")) {
                    Text("Daily").tag("Daily")
                    Text("Weekly").tag("Weekly")
                    Text("Monthly").tag("Monthly")
                }
            }
            
            Section("Insurance Reminders") {
                Picker("Frequency", selection: .constant("Monthly")) {
                    Text("Weekly").tag("Weekly")
                    Text("Monthly").tag("Monthly")
                    Text("Quarterly").tag("Quarterly")
                }
            }
            
            Section("Document Updates") {
                Toggle("Real-time Updates", isOn: .constant(true))
                Toggle("Daily Summary", isOn: .constant(false))
            }
        }
        .navigationTitle("Notification Frequency")
    }
}