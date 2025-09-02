//
// Layer: Features
// Module: Settings
// Purpose: Main component coordinator for Settings feature implementation
//

import SwiftUI
import Foundation
import ComposableArchitecture

struct SettingsViewComponents {
    
    // MARK: - Currency Converter
    @MainActor
    static func currencyConverterView() -> some View {
        CurrencyConverterComponent.currencyConverterView()
    }
    
    // MARK: - Notification Analytics
    @MainActor
    static func notificationAnalyticsView() -> some View {
        NotificationSettingsComponent.notificationAnalyticsView()
    }
    
    @MainActor
    static func notificationFrequencyView() -> some View {
        NotificationSettingsComponent.notificationFrequencyView()
    }
    
    // MARK: - Support Views
    @MainActor
    static func helpFaqView() -> some View {
        SupportComponent.helpFaqView()
    }
    
    @MainActor
    static func privacyPolicyView() -> some View {
        SupportComponent.privacyPolicyView()
    }
    
    @MainActor
    static func termsOfServiceView() -> some View {
        SupportComponent.termsOfServiceView()
    }
    
    // MARK: - Helper Views
    @MainActor
    static func analyticsCard(_ title: String, value: String, subtitle: String) -> some View {
        HelperViewsComponent.analyticsCard(title, value: value, subtitle: subtitle)
    }
    
    // MARK: - Cloud Storage Options
    @MainActor
    static func cloudStorageOptionsView() -> some View {
        CloudStorageComponent.cloudStorageOptionsView()
    }
    
    // MARK: - Receipt Processing Dashboard
    @MainActor
    static func receiptProcessingDashboardView() -> some View {
        ReceiptProcessingComponent.receiptProcessingDashboardView()
    }
    
    // MARK: - Insurance & Claims Components
    @MainActor
    static func claimsDashboardView() -> some View {
        InsuranceClaimsComponent.claimsDashboardView()
    }
    
    @MainActor
    static func insuranceReportsView() -> some View {
        InsuranceClaimsComponent.insuranceReportsView()
    }
    
    @MainActor
    static func claimTemplatesView() -> some View {
        InsuranceClaimsComponent.claimTemplatesView()
    }
    
    @MainActor
    static func cloudBackupSettingsView() -> some View {
        CloudBackupSettingsView()
    }
    
    @MainActor
    static func claimSubmissionView() -> some View {
        ClaimSubmissionView()
    }
    
    @MainActor
    static func claimPackageAssemblyView() -> some View {
        ClaimPackageAssemblyView()
    }
    
    @MainActor
    static func insuranceExportOptionsView() -> some View {
        // Placeholder view for settings - show info about the feature
        VStack(spacing: 16) {
            Image(systemName: "doc.text.below.ecg")
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
            Text("Insurance Export Options")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Export your inventory data in various formats for insurance companies. Access this feature from individual item details or the main inventory view.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Text("Navigate to an item's detail page to access full export functionality.")
                .font(.caption)
                .foregroundColor(.blue)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
        }
        .padding()
        .navigationTitle("Insurance Export")
    }
    
    @MainActor
    static func warrantyTrackingView() -> some View {
        // Placeholder view for settings - show info about the feature
        VStack(spacing: 16) {
            Image(systemName: "shield.checkerboard")
                .font(.system(size: 50))
                .foregroundColor(.green)
            
            Text("Warranty Tracking")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Track warranty information and expiration dates for your items. Get notifications before warranties expire.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Text("Navigate to an item's detail page to manage warranty information.")
                .font(.caption)
                .foregroundColor(.green)
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
        }
        .padding()
        .navigationTitle("Warranty Tracking")
    }
    
    @MainActor
    static func warrantyDashboardView() -> some View {
        WarrantyDashboardView()
    }
    
    @MainActor
    static func warrantyDocumentsView() -> some View {
        // Placeholder view for settings - show info about the feature
        VStack(spacing: 16) {
            Image(systemName: "doc.on.doc")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Warranty Documents")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("View and manage warranty documents, receipts, and proof of purchase for your items.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Text("Navigate to an item's detail page to access warranty documents.")
                .font(.caption)
                .foregroundColor(.orange)
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
        }
        .padding()
        .navigationTitle("Warranty Documents")
    }
    
    @MainActor
    static func notificationSettingsView() -> some View {
        NotificationSettingsView()
    }
}