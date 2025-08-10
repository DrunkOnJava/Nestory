//
// Layer: App
// Module: Settings
// Purpose: Notification settings for alerts and reminders
//

import SwiftUI

struct NotificationSettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true

    var body: some View {
        Section("Notifications") {
            Toggle("Enable Notifications", isOn: $notificationsEnabled)

            if notificationsEnabled {
                Toggle("Warranty Expiration", isOn: .constant(true))
                Toggle("Insurance Policy Renewal", isOn: .constant(true))
                Toggle("Document Update Reminders", isOn: .constant(false))
            }
        }
    }
}

#Preview {
    Form {
        NotificationSettingsView()
    }
}
