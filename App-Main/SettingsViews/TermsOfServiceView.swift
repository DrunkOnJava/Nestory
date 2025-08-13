//
// Layer: App
// Module: Settings
// Purpose: Terms of Service display view
//

import SwiftUI

struct TermsOfServiceView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Terms of Service")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Effective Date: \(effectiveDate)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom)
                    
                    // Agreement
                    Section {
                        Text("""
                        These Terms of Service ("Terms") govern your use of the Nestory application ("App") provided by Nestory ("we," "our," or "us"). By downloading, installing, or using the App, you agree to be bound by these Terms.
                        
                        If you do not agree to these Terms, please do not use the App.
                        """)
                    }
                    
                    // 1. Acceptance of Terms
                    sectionHeader("1. Acceptance of Terms")
                    
                    Section {
                        Text("""
                        By accessing or using Nestory, you agree to these Terms and our Privacy Policy. These Terms apply to all users of the App. If you are using the App on behalf of an organization, you agree to these Terms on behalf of that organization.
                        """)
                    }
                    
                    // 2. Description of Service
                    sectionHeader("2. Description of Service")
                    
                    Section {
                        Text("""
                        Nestory is a home inventory management application that allows users to:
                        
                        • Catalog personal belongings and assets
                        • Store photos, receipts, and warranty information
                        • Generate reports for insurance documentation
                        • Track item values and purchase information
                        • Organize items by category and location
                        • Back up data to iCloud
                        """)
                    }
                    
                    // 3. User Accounts
                    sectionHeader("3. User Accounts")
                    
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("When using Nestory, you agree to:")
                            
                            bulletPoint("Provide accurate and complete information")
                            bulletPoint("Maintain the security of your device and account")
                            bulletPoint("Promptly notify us of any unauthorized use")
                            bulletPoint("Be responsible for all activities under your account")
                            bulletPoint("Not share your account with others")
                        }
                    }
                    
                    // 4. User Content
                    sectionHeader("4. User Content")
                    
                    Section {
                        Text("""
                        You retain ownership of all content you create, upload, or store in Nestory ("User Content"). By using the App, you grant us a limited license to:
                        
                        • Store and backup your content
                        • Display your content within the App
                        • Generate reports and exports at your request
                        • Sync your content across your devices
                        
                        You are responsible for:
                        • The accuracy of your inventory data
                        • Ensuring you have rights to all uploaded content
                        • Backing up your data regularly
                        • Maintaining copies of important documents
                        """)
                    }
                    
                    // 5. Acceptable Use
                    sectionHeader("5. Acceptable Use")
                    
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("You agree NOT to:")
                            
                            bulletPoint("Use the App for illegal purposes")
                            bulletPoint("Upload malicious code or viruses")
                            bulletPoint("Attempt to gain unauthorized access")
                            bulletPoint("Interfere with the App's operation")
                            bulletPoint("Reverse engineer the App")
                            bulletPoint("Use the App to store illegal content")
                            bulletPoint("Violate any applicable laws or regulations")
                        }
                    }
                    
                    // 6. Intellectual Property
                    sectionHeader("6. Intellectual Property")
                    
                    Section {
                        Text("""
                        The App and its original content (excluding User Content), features, and functionality are owned by Nestory and are protected by international copyright, trademark, patent, trade secret, and other intellectual property laws.
                        
                        Our trademarks and trade dress may not be used without our prior written consent.
                        """)
                    }
                    
                    // 7. Privacy
                    sectionHeader("7. Privacy")
                    
                    Section {
                        Text("""
                        Your use of the App is also governed by our Privacy Policy. Please review our Privacy Policy, which explains how we collect, use, and protect your information.
                        """)
                    }
                    
                    // 8. Disclaimers
                    sectionHeader("8. Disclaimers")
                    
                    Section {
                        Text("""
                        THE APP IS PROVIDED "AS IS" AND "AS AVAILABLE" WITHOUT WARRANTIES OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO:
                        
                        • MERCHANTABILITY
                        • FITNESS FOR A PARTICULAR PURPOSE
                        • NON-INFRINGEMENT
                        • ACCURACY OR RELIABILITY OF INFORMATION
                        
                        We do not warrant that:
                        • The App will be error-free or uninterrupted
                        • Defects will be corrected
                        • The App is free of viruses or harmful components
                        • Results from the App will be accurate or reliable
                        """)
                            .font(.callout)
                    }
                    
                    // 9. Limitation of Liability
                    sectionHeader("9. Limitation of Liability")
                    
                    Section {
                        Text("""
                        TO THE MAXIMUM EXTENT PERMITTED BY LAW, NESTORY SHALL NOT BE LIABLE FOR ANY:
                        
                        • INDIRECT, INCIDENTAL, SPECIAL, OR CONSEQUENTIAL DAMAGES
                        • LOSS OF PROFITS, DATA, USE, OR GOODWILL
                        • BUSINESS INTERRUPTION
                        • SUBSTITUTE GOODS OR SERVICES
                        
                        This applies whether based on warranty, contract, tort, or any other legal theory, and whether or not we have been informed of the possibility of such damages.
                        
                        Our total liability shall not exceed the amount you paid for the App in the twelve months preceding the claim.
                        """)
                            .font(.callout)
                    }
                    
                    // 10. Insurance Disclaimer
                    sectionHeader("10. Insurance Disclaimer")
                    
                    Section {
                        Text("""
                        IMPORTANT: Nestory is a tool to help organize and document your belongings. We are not:
                        
                        • An insurance company or broker
                        • A professional appraisal service
                        • A legal advisor
                        
                        Reports generated by the App are for your personal use. Insurance companies may have specific requirements for documentation. You are responsible for:
                        
                        • Verifying documentation requirements with your insurer
                        • Maintaining accurate and up-to-date records
                        • Obtaining professional appraisals when required
                        • Ensuring compliance with insurance policy terms
                        """)
                            .font(.callout)
                    }
                    
                    // 11. Indemnification
                    sectionHeader("11. Indemnification")
                    
                    Section {
                        Text("""
                        You agree to indemnify and hold harmless Nestory, its officers, directors, employees, and agents from any claims, damages, losses, liabilities, and expenses (including legal fees) arising from:
                        
                        • Your use of the App
                        • Your violation of these Terms
                        • Your violation of any third-party rights
                        • Your User Content
                        """)
                    }
                    
                    // 12. Termination
                    sectionHeader("12. Termination")
                    
                    Section {
                        Text("""
                        We may terminate or suspend your access to the App immediately, without prior notice or liability, for any reason, including if you breach these Terms.
                        
                        Upon termination:
                        • Your right to use the App will cease immediately
                        • You should export and save your data
                        • We may delete your data after a reasonable period
                        
                        You may terminate your use of the App at any time by deleting it from your device.
                        """)
                    }
                    
                    // 13. Changes to Terms
                    sectionHeader("13. Changes to Terms")
                    
                    Section {
                        Text("""
                        We reserve the right to modify these Terms at any time. If we make material changes, we will notify you through the App or by other means.
                        
                        Your continued use of the App after changes become effective constitutes acceptance of the revised Terms.
                        """)
                    }
                    
                    // 14. Governing Law
                    sectionHeader("14. Governing Law")
                    
                    Section {
                        Text("""
                        These Terms are governed by the laws of the United States and the State of California, without regard to conflict of law principles.
                        
                        Any disputes arising from these Terms shall be resolved in the courts of California.
                        """)
                    }
                    
                    // 15. Contact Information
                    sectionHeader("15. Contact Information")
                    
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("For questions about these Terms, please contact us:")
                            
                            Link("support@nestory.app", destination: URL(string: "mailto:support@nestory.app")!)
                                .foregroundColor(.blue)
                            
                            Link("GitHub Repository", destination: URL(string: "https://github.com/DrunkOnJava/Nestory")!)
                                .foregroundColor(.blue)
                            
                            Text("""
                            
                            Nestory Support Team
                            Legal Inquiries
                            """)
                        }
                    }
                    
                    // Footer
                    VStack(spacing: 8) {
                        Text("By using Nestory, you acknowledge that you have read, understood, and agree to be bound by these Terms of Service.")
                            .font(.caption)
                            .italic()
                        
                        Text("© 2024 Nestory. All rights reserved.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
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
    
    private var effectiveDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: Date())
    }
    
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.title3)
            .fontWeight(.semibold)
            .padding(.top, 8)
    }
    
    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "circle.fill")
                .font(.system(size: 6))
                .foregroundColor(.secondary)
                .padding(.top, 6)
            
            Text(text)
                .font(.callout)
        }
    }
}

#Preview {
    TermsOfServiceView()
}