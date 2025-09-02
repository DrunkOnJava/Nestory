//
// Layer: Features
// Module: Settings/Components
// Purpose: Support and help components
//

import SwiftUI
import Foundation

struct SupportComponent {
    
    @MainActor
    static func supportView() -> some View {
        VStack {
            Text("Support")
                .font(.title2)
            // TODO: Implement support view
        }
    }
    
    @MainActor
    static func contactSupportView() -> some View {
        VStack {
            Text("Contact Support")
                .font(.title2)
            // TODO: Implement contact support view
        }
    }
    
    @MainActor
    static func bugReportView() -> some View {
        VStack {
            Text("Bug Report")
                .font(.title2)
            // TODO: Implement bug report view
        }
    }
    
    @MainActor
    static func featureRequestView() -> some View {
        VStack {
            Text("Feature Request")
                .font(.title2)
            // TODO: Implement feature request view
        }
    }
    
    // MARK: - FAQ and Support Documentation
    
    @MainActor
    static func helpFaqView() -> some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        
                        Text("Frequently Asked Questions")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Get answers to common questions about Nestory")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    }
                    .padding(.bottom)
                    
                    // Getting Started Section
                    DisclosureGroup("Getting Started") {
                        VStack(alignment: .leading, spacing: 12) {
                            FAQItem(
                                question: "How do I add my first item?",
                                answer: "Tap the '+' button on the main screen and choose 'Add Item'. You can take photos, enter details, and categorize your belongings for insurance documentation."
                            )
                            
                            FAQItem(
                                question: "What information should I include for each item?",
                                answer: "Include photos, purchase price, serial numbers, warranties, and receipts when available. This information is crucial for insurance claims and replacement value documentation."
                            )
                            
                            FAQItem(
                                question: "How do I organize my items?",
                                answer: "Use Categories (like Electronics, Furniture) and Rooms (like Living Room, Bedroom) to organize your inventory. This makes it easier to find items and generate room-specific reports."
                            )
                        }
                        .padding(.vertical)
                    }
                    .accentColor(.blue)
                    
                    // Insurance & Claims Section
                    DisclosureGroup("Insurance & Claims") {
                        VStack(alignment: .leading, spacing: 12) {
                            FAQItem(
                                question: "How do I generate an insurance report?",
                                answer: "Go to Settings > Export Options and select 'Insurance Report'. Choose your format (PDF, CSV) and the items you want to include. The report will contain all necessary information for insurance companies."
                            )
                            
                            FAQItem(
                                question: "What should I do in case of theft or damage?",
                                answer: "Use the Damage Assessment feature to document the incident. Take photos of damage, create a detailed report, and export your inventory for insurance claims. Keep digital and physical copies safe."
                            )
                            
                            FAQItem(
                                question: "How often should I update my inventory?",
                                answer: "Update your inventory whenever you purchase new items, especially high-value ones. Review and update item values annually to ensure accurate insurance coverage."
                            )
                        }
                        .padding(.vertical)
                    }
                    .accentColor(.green)
                    
                    // Photos & Documentation Section
                    DisclosureGroup("Photos & Documentation") {
                        VStack(alignment: .leading, spacing: 12) {
                            FAQItem(
                                question: "What makes a good item photo?",
                                answer: "Take clear, well-lit photos showing the entire item. Include serial numbers, brand labels, and any unique identifying features. Multiple angles help with identification and valuation."
                            )
                            
                            FAQItem(
                                question: "How do I add receipts?",
                                answer: "Use the receipt scanning feature to photograph receipts. The app will automatically extract key information like purchase date, amount, and store details using AI-powered OCR technology."
                            )
                            
                            FAQItem(
                                question: "Can I add items I bought before using Nestory?",
                                answer: "Absolutely! You can add items purchased at any time. Estimate purchase dates and values as best as you can, and include any documentation you still have."
                            )
                        }
                        .padding(.vertical)
                    }
                    .accentColor(.orange)
                    
                    // Data & Privacy Section
                    DisclosureGroup("Data & Privacy") {
                        VStack(alignment: .leading, spacing: 12) {
                            FAQItem(
                                question: "Where is my data stored?",
                                answer: "Your data is stored locally on your device and optionally synced with iCloud. This ensures your personal inventory information remains private and secure."
                            )
                            
                            FAQItem(
                                question: "Can I export my data?",
                                answer: "Yes! You can export your inventory in multiple formats (CSV, JSON, PDF) for backup purposes or to use with other applications. Go to Settings > Import/Export."
                            )
                            
                            FAQItem(
                                question: "How do I backup my inventory?",
                                answer: "Enable iCloud sync for automatic backup. Additionally, regularly export your data as backup files and store them in a secure location separate from your device."
                            )
                        }
                        .padding(.vertical)
                    }
                    .accentColor(.purple)
                    
                    // Technical Support Section
                    DisclosureGroup("Technical Support") {
                        VStack(alignment: .leading, spacing: 12) {
                            FAQItem(
                                question: "The app is running slowly. What can I do?",
                                answer: "Try closing and reopening the app. If problems persist, restart your device. Large photo libraries can impact performance - consider reducing photo sizes in Settings."
                            )
                            
                            FAQItem(
                                question: "I'm having trouble with receipt scanning",
                                answer: "Ensure good lighting and hold your device steady. Clean receipts scan better than crumpled ones. If scanning fails, you can manually enter receipt information."
                            )
                            
                            FAQItem(
                                question: "How do I report a bug or suggest a feature?",
                                answer: "Use the 'Contact Support' option in Settings to report issues or suggest improvements. We value your feedback and actively work to improve Nestory."
                            )
                        }
                        .padding(.vertical)
                    }
                    .accentColor(.red)
                }
                .padding()
            }
            .navigationTitle("Help & FAQ")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @MainActor
    static func privacyPolicyView() -> some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "hand.raised.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        
                        Text("Privacy Policy")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Your privacy is our priority")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom)
                    
                    // Privacy Policy Content
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Last Updated: January 2025")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        PrivacySection(
                            title: "Information We Collect",
                            content: "Nestory is designed with privacy in mind. The app stores your inventory data locally on your device. When you enable iCloud sync, your data is stored in your personal iCloud account and encrypted in transit and at rest. We do not collect or store any personal information on our servers."
                        )
                        
                        PrivacySection(
                            title: "How We Use Your Information",
                            content: "Your inventory data is used solely to provide the app's functionality: organizing your belongings, generating reports, and syncing across your devices. We never access, analyze, or share your personal inventory information."
                        )
                        
                        PrivacySection(
                            title: "Data Storage and Security",
                            content: "All data is stored locally on your device using iOS's secure data storage mechanisms. iCloud sync uses Apple's end-to-end encryption. Photos and documents are stored in your device's secure storage and are not transmitted to any third-party servers."
                        )
                        
                        PrivacySection(
                            title: "Third-Party Services",
                            content: "Nestory uses Apple's built-in frameworks for OCR (text recognition) and other device functionality. These services process data locally on your device and do not transmit information to external servers."
                        )
                        
                        PrivacySection(
                            title: "Your Rights",
                            content: "You have complete control over your data. You can export, delete, or modify your inventory at any time. Since data is stored locally, you maintain full ownership and control of your information."
                        )
                        
                        PrivacySection(
                            title: "Changes to This Policy",
                            content: "We may update this privacy policy from time to time. Any changes will be reflected in app updates and will be clearly communicated to users."
                        )
                        
                        PrivacySection(
                            title: "Contact Us",
                            content: "If you have any questions about this privacy policy or how your data is handled, please contact us through the app's support feature."
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @MainActor
    static func termsOfServiceView() -> some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        
                        Text("Terms of Service")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Please read these terms carefully")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom)
                    
                    // Terms of Service Content
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Last Updated: January 2025")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TermsSection(
                            title: "1. Acceptance of Terms",
                            content: "By downloading, installing, or using Nestory, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the app."
                        )
                        
                        TermsSection(
                            title: "2. Description of Service",
                            content: "Nestory is a personal inventory management application designed to help users catalog their belongings for insurance documentation, warranty tracking, and personal organization purposes."
                        )
                        
                        TermsSection(
                            title: "3. User Responsibilities",
                            content: "You are responsible for maintaining the accuracy of your inventory data, backing up important information, and using the app in compliance with applicable laws. You agree to use the app only for lawful purposes."
                        )
                        
                        TermsSection(
                            title: "4. Data and Privacy",
                            content: "Your inventory data remains under your control. We do not claim ownership of your data. Please refer to our Privacy Policy for detailed information about how your data is handled."
                        )
                        
                        TermsSection(
                            title: "5. Intellectual Property",
                            content: "Nestory and its features are protected by copyright, trademark, and other intellectual property laws. You may not copy, distribute, or create derivative works based on the app."
                        )
                        
                        TermsSection(
                            title: "6. Limitation of Liability",
                            content: "Nestory is provided 'as is' without warranties. We are not liable for any loss of data, damages, or other issues that may arise from use of the app. Always maintain backup copies of important information."
                        )
                        
                        TermsSection(
                            title: "7. Insurance Disclaimer",
                            content: "While Nestory helps organize inventory for insurance purposes, we make no guarantees about insurance claim outcomes. Always consult with your insurance provider about their specific requirements and documentation needs."
                        )
                        
                        TermsSection(
                            title: "8. Updates and Changes",
                            content: "We may update the app and these terms from time to time. Continued use of the app after updates constitutes acceptance of any changes to these terms."
                        )
                        
                        TermsSection(
                            title: "9. Contact Information",
                            content: "For questions about these terms or the app, please use the support feature within Nestory to contact us."
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Terms of Service")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Supporting Views

private struct FAQItem: View {
    let question: String
    let answer: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(question)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(answer)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 4)
    }
}

private struct PrivacySection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(content)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 4)
    }
}

private struct TermsSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(content)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 4)
    }
}