//
// Layer: Features
// Module: Settings
// Purpose: TCA-driven Settings coordinator view
//
// 🏗️ TCA SETTINGS COORDINATOR: Central configuration hub
// - Organizes all app settings using TCA state management
// - Provides access to utility features and data management
// - ✅ MIGRATED: Now uses SettingsFeature for state management
// - Primary entry point for data export and backup operations
//
// 🎯 INSURANCE WORKFLOW INTEGRATION: Critical utility access
// - Import/Export: Backup data for insurance documentation
// - Insurance Reports: Generate comprehensive claim packages
// - Cloud Backup: Protect data against device loss
// - Notification Settings: Warranty expiration reminders
// - Currency Settings: Accurate valuation across regions
//
// 📱 SETTINGS ARCHITECTURE: Section-based organization
// - AppearanceSettings: Theme and visual preferences
// - GeneralSettings: Core app behavior configuration
// - CurrencySettings: Financial calculation preferences
// - NotificationSettings: Alert and reminder management
// - DataStorageSettings: Local data management and cleanup
// - CloudBackupSettings: iCloud integration and sync
// - ImportExportSettings: Data portability and backup
// - AboutSupportSettings: Help, feedback, and app information
// - DangerZoneSettings: Destructive operations (reset, delete)
//
// 🔄 TCA MIGRATION STATUS:
// - Part 1: Keep functional alongside new TCA architecture
// - Part 2: Migrate to SettingsFeature with TCA state management
// - Part 3: Remove legacy environment object dependencies
//
// ⚡ FEATURE WIRING CHECKLIST:
// - ✅ Import/Export Service (accessible)
// - ✅ Insurance Reports (accessible)
// - ✅ Backup/Restore (accessible)
// - 🔄 Account Management (planned for Part 3)
// - 🔄 Premium Features (planned for StoreKit integration)
//
// 🍎 APPLE FRAMEWORK OPPORTUNITIES (Phase 3):
// - TipKit: Contextual tips for insurance best practices
// - StoreKit: Premium features and subscription management
// - MessageUI: Feedback email with attachment support
//

import ComposableArchitecture
import SwiftData
import SwiftUI

public struct SettingsView: View {
    @Bindable var store: StoreOf<SettingsFeature>
    @State private var showingDeveloperTools = false
    @State private var developerTapCount = 0

    public var body: some View {
        NavigationStack {
            Form {
                appearanceSection
                currencySection
                notificationsSection
                dataStorageSection
                cloudBackupSection
                importExportSection
                supportAboutSection
                dangerZoneSection
            }
            .navigationTitle("Settings")
            .onAppear {
                store.send(.onAppear)
            }
            .alert(store: store.scope(state: \.$alert, action: \.alert))
            .sheet(isPresented: Binding(
                get: { store.showingExportOptions },
                set: { _ in store.send(.hideExportOptions) }
            )) {
                exportOptionsSheet
            }
            .sheet(isPresented: Binding(
                get: { store.showingImportOptions },
                set: { _ in store.send(.hideImportOptions) }
            )) {
                importOptionsSheet
            }
            .sheet(isPresented: $showingDeveloperTools) {
                DeveloperToolsView()
            }
        }
    }
    
    // MARK: - Form Sections
    
    
    private var cloudBackupSection: some View {
        #if !DEBUG
        Section {
            cloudBackupToggle
            
            if store.cloudBackupEnabled {
                lastBackupRow
                backupNowButton
                
                if store.isBackingUp {
                    backupProgress
                }
            }
        } header: {
            Text("iCloud Backup")
        }
        #else
        Section {
            Text("iCloud backup is disabled in Debug builds")
                .foregroundColor(.secondary)
        } header: {
            Text("iCloud Backup")
        }
        #endif
    }
    
    private var importExportSection: some View {
        Section {
            Button("Export Data") {
                store.send(.exportData)
            }

            Button("Import Data") {
                store.send(.showImportOptions)
            }
            
            NavigationLink("Cloud Storage Options") {
                cloudStorageOptionsView
            }
            
            NavigationLink("Receipt Processing Dashboard") {
                receiptProcessingDashboardView
            }

            Button("Generate Insurance Report") {
                // TODO: Add insurance report generation action
                // store.send(.generateInsuranceReport)
            }
        } header: {
            Text("Import & Export")
        }
    }
    
    
    // MARK: - iCloud Backup Components
    
    private var cloudBackupToggle: some View {
        Toggle("Enable iCloud Backup", isOn: $store.cloudBackupEnabled.sending(\.cloudBackupToggled))
    }
    
    private var lastBackupRow: some View {
        HStack {
            Text("Last Backup")
            Spacer()
            Text(store.lastBackupDate?.formatted(date: .abbreviated, time: .shortened) ?? "Never")
                .foregroundColor(.secondary)
        }
    }
    
    private var backupNowButton: some View {
        Button("Backup Now") {
            store.send(.performManualBackup)
        }
        .disabled(store.isBackingUp)
    }
    
    private var backupProgress: some View {
        HStack {
            ProgressView()
                .scaleEffect(0.8)
            Text("Backing up...")
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Sheet Content
    
    private var exportOptionsSheet: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Export Options")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                VStack(spacing: 12) {
                    Button("Export to JSON") {
                        store.send(.exportFormatChanged(.json))
                        store.send(.exportData)
                        store.send(.hideExportOptions)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Export to CSV") {
                        store.send(.exportFormatChanged(.csv))
                        store.send(.exportData)
                        store.send(.hideExportOptions)
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Generate PDF Report") {
                        store.send(.exportFormatChanged(.pdf))
                        store.send(.exportData)
                        store.send(.hideExportOptions)
                    }
                    .buttonStyle(.bordered)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        store.send(.hideExportOptions)
                    }
                }
            }
        }
    }
    
    private var importOptionsSheet: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Import Options")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                VStack(spacing: 12) {
                    Button("Import from JSON") {
                        // Import functionality would be handled through document picker
                        store.send(.hideImportOptions)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Import from CSV") {
                        // Import functionality would be handled through document picker
                        store.send(.hideImportOptions)
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Import from Photos") {
                        // Import functionality would be handled through photo picker
                        store.send(.hideImportOptions)
                    }
                    .buttonStyle(.bordered)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Import Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        store.send(.hideImportOptions)
                    }
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var appearanceSection: some View {
        Section {
            Picker("Theme", selection: Binding(
                get: { store.selectedTheme },
                set: { store.send(.themeChanged($0)) }
            )) {
                ForEach(AppTheme.allCases, id: \.self) { theme in
                    Text(theme.rawValue).tag(theme)
                }
            }
            .pickerStyle(.segmented)
        } header: {
            Text("Appearance")
        }
    }
    
    private var currencySection: some View {
        Section {
            Picker("Default Currency", selection: Binding(
                get: { store.selectedCurrency },
                set: { store.send(.currencyChanged($0)) }
            )) {
                ForEach(store.availableCurrencies, id: \.self) { currency in
                    Text(currency).tag(currency)
                }
            }
            
            NavigationLink("Currency Converter") {
                currencyConverterView
            }
        } header: {
            Text("Currency")
        }
    }
    
    private var notificationsSection: some View {
        Section {
            Toggle("Enable Notifications", isOn: $store.notificationsEnabled.sending(\.notificationsToggled))

            if store.notificationsEnabled {
                Toggle("Warranty Notifications", isOn: $store.warrantyNotificationsEnabled.sending(\.warrantyNotificationsToggled))
                Toggle("Insurance Notifications", isOn: $store.insuranceNotificationsEnabled.sending(\.insuranceNotificationsToggled))
                Toggle("Document Notifications", isOn: $store.documentNotificationsEnabled.sending(\.documentNotificationsToggled))
                Toggle("Maintenance Notifications", isOn: $store.maintenanceNotificationsEnabled.sending(\.maintenanceNotificationsToggled))
                
                NavigationLink("Notification Analytics") {
                    notificationAnalyticsView
                }
                
                NavigationLink("Notification Frequency") {
                    notificationFrequencyView
                }
            }
        } header: {
            Text("Notifications")
        }
    }
    
    // MARK: - Additional Sections
    
    private var dataStorageSection: some View {
        Section {
            HStack {
                Text("Items")
                Spacer()
                Text("\(store.totalItems)")
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Storage Used")
                Spacer()
                Text(store.storageUsed)
                    .foregroundColor(.secondary)
            }
            
            Button("Clear Cache") {
                store.send(.clearCacheRequested)
            }
            .foregroundColor(.orange)
        } header: {
            Text("Data & Storage")
        }
    }
    
    private var supportAboutSection: some View {
        Section {
            NavigationLink("Help & FAQ") {
                helpFaqView
            }
            
            NavigationLink("Privacy Policy") {
                privacyPolicyView
            }
            
            NavigationLink("Terms of Service") {
                termsOfServiceView
            }
            
            HStack {
                Text("App Version")
                Spacer()
                Text(store.appVersion)
                    .foregroundColor(.secondary)
            }
        } header: {
            Text("Support & About")
        }
    }
    
    private var dangerZoneSection: some View {
        Section {
            Button("Reset All Settings") {
                store.send(.showResetAlert)
            }
            .foregroundColor(.orange)
            
            Button("Delete All Data") {
                store.send(.deleteAllDataRequested)
            }
            .foregroundColor(.red)
        } header: {
            Text("Danger Zone")
        }
    }
    
    // MARK: - Legacy Inline Sections (deprecated)
    
    /*
    @ViewBuilder
    private var inlineDataStorageSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Manual section header
            Text("Data & Storage")
                .font(.caption)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 8)
            
            // Section content wrapped in a GroupBox for visual consistency
            GroupBox {
                VStack(spacing: 12) {
                    HStack {
                        Text("Items")
                        Spacer()
                        Text("\(store.totalItems)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Storage Used")
                        Spacer()
                        Text(store.storageUsed)
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Clear Cache") {
                        store.send(.clearCacheRequested)
                    }
                    .foregroundColor(.orange)
                }
                .padding(4)
            }
        }
    }
    
    @ViewBuilder
    private var inlineSupportAboutSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Manual section header
            Text("Support & About")
                .font(.caption)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 8)
            
            // Section content wrapped in a GroupBox for visual consistency
            GroupBox {
                VStack(spacing: 12) {
                    NavigationLink("Help & FAQ") {
                        Text("Coming Soon")
                    }
                    
                    NavigationLink("Privacy Policy") {
                        Text("Coming Soon")
                    }
                    
                    NavigationLink("Contact Support") {
                        Text("Coming Soon")
                    }
                    
                    HStack {
                        Text("App Version")
                        Spacer()
                        Button(action: { handleVersionTap() }) {
                            Text(store.appVersion)
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(4)
            }
        }
    }
    
    @ViewBuilder
    private var inlineDangerZoneSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Manual section header
            Text("Danger Zone")
                .font(.caption)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 8)
            
            // Section content wrapped in a GroupBox for visual consistency
            GroupBox {
                VStack(spacing: 12) {
                    Button("Reset All Settings") {
                        store.send(.showResetAlert)
                    }
                    .foregroundColor(.orange)
                    
                    Button("Delete All Data") {
                        store.send(.deleteAllDataRequested)
                    }
                    .foregroundColor(.red)
                }
                .padding(4)
            }
        }
    }
    */
    
    // MARK: - Component References
    
    private var currencyConverterView: some View {
        SettingsViewComponents.currencyConverterView()
    }
    
    private var notificationAnalyticsView: some View {
        SettingsViewComponents.notificationAnalyticsView()
    }
    
    private var notificationFrequencyView: some View {
        SettingsViewComponents.notificationFrequencyView()
    }
    
    private var helpFaqView: some View {
        SettingsViewComponents.helpFaqView()
    }
    
    private var privacyPolicyView: some View {
        SettingsViewComponents.privacyPolicyView()
    }
    
    private var termsOfServiceView: some View {
        SettingsViewComponents.termsOfServiceView()
    }
    
    private var cloudStorageOptionsView: some View {
        SettingsViewComponents.cloudStorageOptionsView()
    }
    
    private var receiptProcessingDashboardView: some View {
        SettingsViewComponents.receiptProcessingDashboardView()
    }
    
    // MARK: - Developer Tools Access
    
    private func handleVersionTap() {
        developerTapCount += 1
        
        // Enable developer tools after 7 taps (like iOS Settings)
        if developerTapCount >= 7 {
            showingDeveloperTools = true
            developerTapCount = 0
        }
        
        // Reset count after 3 seconds of inactivity
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            developerTapCount = 0
        }
    }
}

#Preview {
    SettingsView(
        store: Store(initialState: SettingsFeature.State()) {
            SettingsFeature()
        }
    )
}
