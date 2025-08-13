//
// Layer: App
// Module: Settings
// Purpose: Privacy Policy display view
//

import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Privacy Policy")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Last Updated: \(lastUpdatedDate)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom)
                    
                    // Introduction
                    Section {
                        Text("""
                        Nestory ("we," "our," or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your information when you use our home inventory application.
                        
                        By using Nestory, you agree to the collection and use of information in accordance with this policy.
                        """)
                    }
                    
                    // Information We Collect
                    sectionHeader("Information We Collect")
                    
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            bulletPoint("Personal Information", description: "Name, email address, and other contact information you provide when creating an account or contacting support.")
                            
                            bulletPoint("Inventory Data", description: "Information about items you catalog, including descriptions, photos, purchase details, warranties, and receipts.")
                            
                            bulletPoint("Usage Data", description: "Information about how you interact with the app, including features used and time spent.")
                            
                            bulletPoint("Device Information", description: "Device type, operating system version, and unique device identifiers for app functionality and troubleshooting.")
                        }
                    }
                    
                    // How We Use Your Information
                    sectionHeader("How We Use Your Information")
                    
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            bulletPoint("Service Provision", description: "To provide and maintain our home inventory service.")
                            
                            bulletPoint("Backup & Sync", description: "To enable iCloud backup and synchronization across your devices.")
                            
                            bulletPoint("Insurance Reports", description: "To generate documentation for insurance purposes at your request.")
                            
                            bulletPoint("Customer Support", description: "To respond to your inquiries and provide technical assistance.")
                            
                            bulletPoint("Improvements", description: "To understand usage patterns and improve our app's functionality.")
                        }
                    }
                    
                    // Data Storage & Security
                    sectionHeader("Data Storage & Security")
                    
                    Section {
                        Text("""
                        Your data is stored locally on your device and, if enabled, in your personal iCloud account. We implement industry-standard security measures to protect your information:
                        
                        • All sensitive data is encrypted using AES-256 encryption
                        • Photos and documents are stored securely in your device's protected storage
                        • iCloud sync uses Apple's end-to-end encryption
                        • We do not have access to your iCloud data
                        • Regular security audits and updates
                        """)
                    }
                    
                    // Data Sharing
                    sectionHeader("Data Sharing")
                    
                    Section {
                        Text("""
                        We do not sell, trade, or rent your personal information to third parties. We may share your information only in the following circumstances:
                        
                        • With your explicit consent
                        • To comply with legal obligations
                        • To protect our rights, privacy, safety, or property
                        • In connection with a merger, sale, or acquisition of all or a portion of our assets
                        """)
                    }
                    
                    // Your Rights
                    sectionHeader("Your Rights")
                    
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            bulletPoint("Access", description: "You can access all your data within the app at any time.")
                            
                            bulletPoint("Export", description: "Export your inventory data in standard formats (CSV, JSON, PDF).")
                            
                            bulletPoint("Deletion", description: "Delete your data at any time through the app's settings.")
                            
                            bulletPoint("Portability", description: "Transfer your data to another service using our export features.")
                            
                            bulletPoint("Opt-out", description: "Disable analytics and usage tracking in settings.")
                        }
                    }
                    
                    // Children's Privacy
                    sectionHeader("Children's Privacy")
                    
                    Section {
                        Text("""
                        Nestory is not intended for use by children under 13 years of age. We do not knowingly collect personal information from children under 13. If you become aware that a child has provided us with personal information, please contact us.
                        """)
                    }
                    
                    // Changes to This Policy
                    sectionHeader("Changes to This Policy")
                    
                    Section {
                        Text("""
                        We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last Updated" date.
                        
                        Your continued use of the app after any changes indicates your acceptance of the updated policy.
                        """)
                    }
                    
                    // Contact Us
                    sectionHeader("Contact Us")
                    
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("If you have questions about this Privacy Policy, please contact us:")
                            
                            Link("support@nestory.app", destination: URL(string: "mailto:support@nestory.app")!)
                                .foregroundColor(.blue)
                            
                            Text("""
                            
                            Nestory Support Team
                            Privacy Inquiries
                            """)
                        }
                    }
                    
                    // Footer
                    Text("© 2024 Nestory. All rights reserved.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var lastUpdatedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: Date())
    }
    
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.title2)
            .fontWeight(.semibold)
            .padding(.top, 8)
    }
    
    private func bulletPoint(_ title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "circle.fill")
                .font(.system(size: 6))
                .foregroundColor(.secondary)
                .padding(.top, 6)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .fontWeight(.medium)
                Text(description)
                    .font(.callout)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    PrivacyPolicyView()
}