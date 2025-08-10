//
// Layer: App
// Module: Settings
// Purpose: General settings for currency and defaults
//

import SwiftUI

struct GeneralSettingsView: View {
    @AppStorage("currencyCode") private var currencyCode = "USD"

    var body: some View {
        Section("General") {
            Picker("Currency", selection: $currencyCode) {
                Text("USD ($)").tag("USD")
                Text("EUR (€)").tag("EUR")
                Text("GBP (£)").tag("GBP")
                Text("JPY (¥)").tag("JPY")
                Text("CAD (C$)").tag("CAD")
                Text("AUD (A$)").tag("AUD")
            }

            HStack {
                Text("Default Category")
                Spacer()
                Text("Electronics")
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    Form {
        GeneralSettingsView()
    }
}
