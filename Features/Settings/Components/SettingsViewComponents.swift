//
// Layer: Features
// Module: Settings
// Purpose: Reusable view components for Settings feature implementation
//

import SwiftUI
import Foundation
import ComposableArchitecture

struct SettingsViewComponents {
    
    // MARK: - Currency Converter
    
    @MainActor
    static func currencyConverterView() -> some View {
        VStack(spacing: 20) {
            Text("Currency Converter")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Convert between different currencies for accurate item valuations.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            VStack(spacing: 16) {
                HStack {
                    TextField("Amount", text: .constant("100"))
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                    
                    Picker("From", selection: .constant("USD")) {
                        Text("USD").tag("USD")
                        Text("EUR").tag("EUR")
                        Text("GBP").tag("GBP")
                    }
                    .pickerStyle(.menu)
                }
                
                Image(systemName: "arrow.down")
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("85.32")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    Picker("To", selection: .constant("EUR")) {
                        Text("USD").tag("USD")
                        Text("EUR").tag("EUR") 
                        Text("GBP").tag("GBP")
                    }
                    .pickerStyle(.menu)
                }
            }
            
            Text("Rates updated daily")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Currency Converter")
    }
    
    // MARK: - Notification Analytics
    
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
    
    // MARK: - Support Views
    
    @MainActor
    static func helpFaqView() -> some View {
        NavigationStack {
            List {
                Section("📱 Getting Started") {
                    DisclosureGroup("How to add your first item") {
                        Text("Tap '+' to add items. Use the barcode scanner for automatic product information lookup, or add manually. Include purchase date, price, and photos for complete insurance documentation.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    DisclosureGroup("Taking effective photos for insurance") {
                        Text("Take multiple angles: full item, serial number, damage areas, and in-context room photos. Nestory automatically analyzes photo quality and suggests improvements for insurance documentation.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    DisclosureGroup("Smart categorization system") {
                        Text("Use categories like Electronics, Furniture, Jewelry for better organization. Categories help with insurance claim grouping and value analysis across your inventory.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("🔍 Advanced Receipt Processing") {
                    DisclosureGroup("AI-powered receipt scanning") {
                        Text("Nestory uses 3-tier ML processing: Apple frameworks, custom ML models, and pattern recognition. Simply capture receipts and watch automatic data extraction fill in purchase details, tax amounts, and vendor information.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    DisclosureGroup("Document perspective correction") {
                        Text("Don't worry about perfect angles - Nestory automatically corrects receipt perspective and enhances text clarity for optimal OCR processing.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    DisclosureGroup("Confidence scoring system") {
                        Text("Each extracted field shows confidence levels. Review low-confidence extractions (marked with ⚠️) to ensure accuracy for insurance purposes.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("🛡️ Professional Damage Assessment") {
                    DisclosureGroup("Damage type-specific workflows") {
                        Text("Choose from specialized templates: Fire, Water, Theft, Natural Disaster. Each provides specific photo requirements and assessment criteria tailored for insurance claims.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    DisclosureGroup("Photo comparison system") {
                        Text("Take 'before' photos during normal inventory, then 'after' photos post-incident. The app guides you through proper documentation angles and lighting for maximum insurance impact.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    DisclosureGroup("Automated damage valuation") {
                        Text("The app calculates repair vs. replacement costs based on item age, condition, and damage severity. This helps determine total loss vs. repairable items for insurance adjusters.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("📊 Insurance Claim Generation") {
                    DisclosureGroup("Company-specific claim templates") {
                        Text("Nestory includes templates optimized for major insurers (Allstate, GEICO, State Farm, etc.). Select your insurance company for properly formatted claim documents with correct logos and field requirements.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    DisclosureGroup("Multi-format document export") {
                        Text("Generate claims in multiple formats: Professional PDFs for adjusters, spreadsheets for detailed analysis, HTML for web submission, and JSON for digital processing.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    DisclosureGroup("Claim package assembly") {
                        Text("The app automatically assembles complete claim packages including inventory lists, photos, receipts, damage assessments, and supporting documentation in insurance-ready formats.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("📈 Advanced Analytics & Tracking") {
                    DisclosureGroup("Claim tracking dashboard") {
                        Text("Monitor claim progress with milestone tracking, correspondence logging, and automated follow-up reminders. View timeline analytics and performance metrics for multiple claims.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    DisclosureGroup("Multi-currency value tracking") {
                        Text("Track items in different currencies with live exchange rates. Useful for travelers or items purchased abroad. Analytics show value trends across currencies.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    DisclosureGroup("Warranty expiration analytics") {
                        Text("Smart warranty detection from receipts and manual entries. Get early warnings before expiration, track warranty status across categories, and receive automated renewal reminders.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("🔄 Smart Data Management") {
                    DisclosureGroup("CloudKit backup with asset management") {
                        Text("Automatic cloud backup includes photos, documents, and data with intelligent asset management. Progress tracking and conflict resolution ensure reliable data protection.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    DisclosureGroup("Flexible import/export system") {
                        Text("Import from CSV, JSON, or photos. Export to multiple formats with flexible formatting options. Batch processing handles large datasets efficiently.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    DisclosureGroup("Advanced search and filtering") {
                        Text("Search across multiple criteria: names, descriptions, tags, categories. Filter by date ranges, price ranges, condition status, and documentation completeness.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("🔔 Intelligent Notifications") {
                    DisclosureGroup("Smart notification scheduling") {
                        Text("Notifications adapt to your usage patterns with snooze functionality, batch scheduling, and priority-based rescheduling. Analytics track which notifications are most effective.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    DisclosureGroup("Warranty and maintenance alerts") {
                        Text("Automated reminders for warranty expiration, maintenance schedules, and insurance policy renewals. Customizable intervals and recurring notifications keep you protected.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("💡 Pro Tips") {
                    DisclosureGroup("Maximizing insurance coverage") {
                        Text("Document everything immediately after purchase. Include serial numbers, receipts, and context photos. Regular updates ensure accurate replacement values for insurance claims.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    DisclosureGroup("Barcode scanning for quick entry") {
                        Text("Use the barcode scanner for electronics, appliances, and packaged goods. It automatically looks up product information, estimated values, and warranty periods.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    DisclosureGroup("Condition tracking over time") {
                        Text("Update item conditions periodically with photos. This creates a condition history valuable for insurance claims and helps establish depreciation patterns.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Help & FAQ")
        }
    }
    
    @MainActor
    static func privacyPolicyView() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Privacy Policy")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Your privacy is important to us. This policy explains how Nestory handles your data.")
                
                Text("Data Collection")
                    .font(.headline)
                
                Text("Nestory stores your inventory data locally on your device. We do not collect or transmit personal information without your explicit consent.")
                
                Text("Data Storage")
                    .font(.headline)
                
                Text("All your inventory data is stored securely on your device and in your personal iCloud account if you enable backup.")
                
                Text("Last updated: \(Date().formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
    }
    
    @MainActor
    static func termsOfServiceView() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Terms of Service")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("By using Nestory, you agree to these terms of service.")
                
                Text("License")
                    .font(.headline)
                
                Text("Nestory is licensed for personal use to help you manage your home inventory for insurance and warranty purposes.")
                
                Text("Limitations")
                    .font(.headline)
                
                Text("While we strive for accuracy, Nestory is provided as-is. Please verify all information for insurance claims.")
                
                Text("Last updated: \(Date().formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Terms of Service")
    }
    
    // MARK: - Helper Views
    
    @MainActor
    static func analyticsCard(_ title: String, value: String, subtitle: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.blue)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    // MARK: - Cloud Storage Options
    
    @MainActor
    static func cloudStorageOptionsView() -> some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "icloud.and.arrow.up")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("Cloud Storage Options")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Backup your inventory data to cloud storage services for secure access across devices.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                
                // Service Options
                VStack(spacing: 12) {
                    CloudStorageServiceRow(
                        serviceName: "iCloud Drive",
                        icon: "icloud",
                        description: "Built-in Apple cloud storage"
                    )
                    
                    CloudStorageServiceRow(
                        serviceName: "Google Drive",
                        icon: "doc.circle",
                        description: "Google cloud storage service"
                    )
                    
                    CloudStorageServiceRow(
                        serviceName: "Dropbox",
                        icon: "square.and.arrow.up.on.square",
                        description: "Popular file sharing service"
                    )
                    
                    CloudStorageServiceRow(
                        serviceName: "OneDrive",
                        icon: "square.grid.3x3",
                        description: "Microsoft cloud storage"
                    )
                }
                
                Spacer()
                
                // Info Box
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                        Text("Information")
                            .font(.headline)
                    }
                    
                    Text("• Cloud storage integration requires compatible services to be installed on your device")
                    Text("• Your data is encrypted before upload for security")
                    Text("• Backups include inventory items, categories, and associated documentation")
                    
                }
                .font(.caption)
                .foregroundColor(.secondary)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            .padding()
            .navigationTitle("Cloud Storage")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Receipt Processing Dashboard
    
    @MainActor
    static func receiptProcessingDashboardView() -> some View {
        SettingsReceiptComponents.receiptProcessingDashboardView()
    }
}

private struct CloudStorageServiceRow: View {
    let serviceName: String
    let icon: String
    let description: String
    
    var body: some View {
        Button(action: {
            // TODO: Implement cloud storage service selection
            // This would typically open the service selection flow
        }) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(serviceName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}