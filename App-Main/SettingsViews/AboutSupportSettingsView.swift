//
// Layer: App
// Module: Settings
// Purpose: About and support information section
//

import SwiftUI

struct AboutSupportSettingsView: View {
    @State private var showingPrivacyPolicy = false
    @State private var showingTermsOfService = false
    
    var body: some View {
        Group {
            // Support Section
            Section("Support") {
                Link(destination: URL(string: "https://github.com/DrunkOnJava/Nestory")!) {
                    Label("GitHub Repository", systemImage: "link")
                }

                Link(destination: URL(string: "mailto:support@nestory.app")!) {
                    Label("Contact Support", systemImage: "envelope")
                }

                Button(action: {}) {
                    Label("Rate on App Store", systemImage: "star")
                }
            }

            // About Section
            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Build")
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1")
                        .foregroundColor(.secondary)
                }

                Button("Privacy Policy") {
                    showingPrivacyPolicy = true
                }
                
                Button("Terms of Service") {
                    showingTermsOfService = true
                }

                HStack {
                    Text("Made with")
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .font(.caption)
                    Text("using Swift 6")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
        }
        .sheet(isPresented: $showingPrivacyPolicy) {
            PrivacyPolicyView()
        }
        .sheet(isPresented: $showingTermsOfService) {
            TermsOfServiceView()
        }
    }
}

#Preview {
    Form {
        AboutSupportSettingsView()
    }
}
