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

struct SettingsView: View {
    @Bindable var store: StoreOf<SettingsFeature>

    var body: some View {
        NavigationStack {
            Form {
                // Appearance Settings Section
                Section("Appearance") {
                    Picker("Theme", selection: $store.selectedTheme.sending(\.themeChanged)) {
                        ForEach(SettingsFeature.AppTheme.allCases, id: \.self) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // Currency Settings Section
                Section("Currency") {
                    Picker("Currency", selection: $store.selectedCurrency.sending(\.currencyChanged)) {
                        ForEach(store.availableCurrencies, id: \.self) { currency in
                            Text(currency).tag(currency)
                        }
                    }
                }

                // Notification Settings Section
                Section("Notifications") {
                    Toggle("Enable Notifications", isOn: $store.notificationsEnabled.sending(\.notificationsToggled))

                    if store.notificationsEnabled {
                        Toggle("Warranty Reminders", isOn: $store.warrantyRemindersEnabled.sending(\.warrantyRemindersToggled))
                        Toggle("Export Reminders", isOn: $store.exportRemindersEnabled.sending(\.exportRemindersToggled))

                        Picker("Reminder Frequency", selection: $store.reminderFrequency.sending(\.reminderFrequencyChanged)) {
                            ForEach(SettingsFeature.ReminderFrequency.allCases, id: \.self) { frequency in
                                Text(frequency.rawValue).tag(frequency)
                            }
                        }
                    }
                }

                // Data & Storage Section
                Section("Data & Storage") {
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

                // iCloud Backup Section
                #if !DEBUG
                    Section("iCloud Backup") {
                        Toggle("Enable iCloud Backup", isOn: $store.cloudBackupEnabled.sending(\.cloudBackupToggled))

                        if store.cloudBackupEnabled {
                            HStack {
                                Text("Last Backup")
                                Spacer()
                                Text(store.lastBackupDate?.formatted(date: .abbreviated, time: .shortened) ?? "Never")
                                    .foregroundColor(.secondary)
                            }

                            Button("Backup Now") {
                                store.send(.manualBackupRequested)
                            }
                            .disabled(store.isBackingUp)

                            if store.isBackingUp {
                                HStack {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("Backing up...")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                #else
                    Section("iCloud Backup") {
                        Text("iCloud backup is disabled in Debug builds")
                            .foregroundColor(.secondary)
                    }
                #endif

                // Import & Export Section
                Section("Import & Export") {
                    Button("Export Data") {
                        store.send(.exportDataRequested)
                    }

                    Button("Import Data") {
                        store.send(.importDataRequested)
                    }

                    Button("Generate Insurance Report") {
                        store.send(.generateInsuranceReportRequested)
                    }
                }

                // Support & About Section
                Section("Support & About") {
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
                        Text(store.appVersion)
                            .foregroundColor(.secondary)
                    }
                }

                // Danger Zone Section
                Section("Danger Zone") {
                    Button("Reset All Settings") {
                        store.send(.resetSettingsRequested)
                    }
                    .foregroundColor(.orange)

                    Button("Delete All Data") {
                        store.send(.deleteAllDataRequested)
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                store.send(.onAppear)
            }
            .alert($store.scope(state: \.alert, action: \.alert))
            .sheet(isPresented: $store.showingExportOptions) {
                Text("Export Options Coming Soon")
            }
            .sheet(isPresented: $store.showingImportOptions) {
                Text("Import Options Coming Soon")
            }
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
