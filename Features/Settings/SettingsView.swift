//
// Layer: Features
// Module: Settings
// Purpose: Simplified Settings View
//

import ComposableArchitecture
import SwiftUI

// Import App-Main views (Features layer can import App-Main)
// Note: Individual imports for proper TCA integration

// Import Foundation for file operations
import Foundation

// Import ClaimsDashboardView from App-Main layer
// Features layer can import from App-Main per architecture rules

public struct SettingsView: View {
    @Bindable var store: StoreOf<SettingsFeature>
    
    // ImportExportService integration
    @State private var showingExportSheet = false
    @State private var showingImportSheet = false
    @State private var isExporting = false
    @State private var isImporting = false
    @State private var exportMessage = ""
    @State private var importMessage = ""

    public init(store: StoreOf<SettingsFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            Form {
                // MARK: - Appearance & Display
                Section("Appearance & Display") {
                    Picker("Theme", selection: $store.selectedTheme.sending(\.themeChanged)) {
                        ForEach(AppTheme.allCases, id: \.self) { theme in
                            Text(theme.displayName).tag(theme)
                        }
                    }
                    
                    NavigationLink("Advanced Theme Settings") {
                        Text("Theme customization options coming soon")
                            .navigationTitle("Theme Settings")
                    }
                }
                
                // MARK: - Currency & Valuation
                Section("Currency & Valuation") {
                    Picker("Currency", selection: $store.selectedCurrency.sending(\.currencyChanged)) {
                        ForEach(["USD", "EUR", "GBP", "CAD"], id: \.self) { currency in
                            Text(currency).tag(currency)
                        }
                    }
                    
                    NavigationLink("Currency Converter") {
                        SettingsViewComponents.currencyConverterView()
                    }
                }
                
                // MARK: - Notifications & Alerts
                Section("Notifications & Alerts") {
                    Toggle("Enable Notifications", isOn: $store.notificationsEnabled.sending(\.notificationsToggled))
                    
                    NavigationLink("Notification Analytics") {
                        SettingsViewComponents.notificationAnalyticsView()
                    }
                    
                    NavigationLink("Notification Frequency") {
                        SettingsViewComponents.notificationFrequencyView()
                    }
                }
                
                // MARK: - Data Management
                Section("Data Management") {
                    Button(action: {
                        showingExportSheet = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.blue)
                            Text("Export Inventory")
                            Spacer()
                            if isExporting {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                        }
                    }
                    .disabled(isExporting)
                    
                    Button(action: {
                        showingImportSheet = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                                .foregroundColor(.green)
                            Text("Import Data")
                            Spacer()
                            if isImporting {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                        }
                    }
                    .disabled(isImporting)
                    
                    NavigationLink("Advanced Data Options") {
                        Text("Advanced data management options")
                            .navigationTitle("Data Management")
                    }
                }
                
                // MARK: - Cloud & Backup
                Section("Cloud & Backup") {
                    NavigationLink("Cloud Storage Options") {
                        SettingsViewComponents.cloudStorageOptionsView()
                    }
                    
                    NavigationLink("Backup Settings") {
                        Text("Backup configuration options")
                            .navigationTitle("Backup Settings")
                    }
                }
                
                // MARK: - Insurance & Claims
                Section("Insurance & Claims") {
                    NavigationLink("Claims Dashboard") {
                        SettingsViewComponents.claimsDashboardView()
                    }
                    
                    NavigationLink("Submit New Claim") {
                        ClaimSubmissionView()
                    }
                    
                    NavigationLink("Insurance Reports") {
                        SettingsViewComponents.insuranceReportsView()
                    }
                    
                    NavigationLink("Claim Templates") {
                        SettingsViewComponents.claimTemplatesView()
                    }
                }
                
                // MARK: - Advanced Features
                Section("Advanced Features") {
                    NavigationLink("Receipt Processing Dashboard") {
                        SettingsViewComponents.receiptProcessingDashboardView()
                    }
                    
                    NavigationLink("Developer Tools") {
                        Text("Developer and diagnostic tools")
                            .navigationTitle("Developer Tools")
                    }
                }
                
                // MARK: - Help & Support
                Section("Help & Support") {
                    NavigationLink("Help & FAQ") {
                        SettingsViewComponents.helpFaqView()
                    }
                    
                    NavigationLink("About & Support") {
                        VStack {
                            Text("Nestory v1.0.0")
                                .font(.title2)
                            Text("Home inventory for insurance documentation")
                                .foregroundColor(.secondary)
                        }
                        .navigationTitle("About")
                    }
                }
                
                // MARK: - Legal & Privacy
                Section("Legal & Privacy") {
                    NavigationLink("Privacy Policy") {
                        SettingsViewComponents.privacyPolicyView()
                    }
                    
                    NavigationLink("Terms of Service") {
                        SettingsViewComponents.termsOfServiceView()
                    }
                }
                
                // MARK: - App Information
                Section("App Information") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("Demo")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                store.send(.onAppear)
            }
            .sheet(isPresented: $showingExportSheet) {
                DataExportSheet(
                    isExporting: $isExporting,
                    exportMessage: $exportMessage
                )
            }
            .sheet(isPresented: $showingImportSheet) {
                DataImportSheet(
                    isImporting: $isImporting,
                    importMessage: $importMessage
                )
            }
        }
    }
}

// MARK: - Import/Export Sheet Views

struct DataExportSheet: View {
    @Binding var isExporting: Bool
    @Binding var exportMessage: String
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedFormat: ExportFormat = .csv
    @State private var includeImages = true
    @State private var includeReceipts = true
    @State private var exportProgress: Double = 0.0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("Export Inventory Data")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Export your complete inventory for backup or sharing")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                
                if isExporting {
                    VStack(spacing: 16) {
                        ProgressView(value: exportProgress)
                            .progressViewStyle(LinearProgressViewStyle())
                        
                        Text("Exporting... \(Int(exportProgress * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if !exportMessage.isEmpty {
                            Text(exportMessage)
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                } else {
                    VStack(spacing: 16) {
                        Picker("Export Format", selection: $selectedFormat) {
                            Text(ExportFormat.csv.displayName).tag(ExportFormat.csv)
                            Text(ExportFormat.json.displayName).tag(ExportFormat.json)
                            Text(ExportFormat.pdf.displayName).tag(ExportFormat.pdf)
                            Text(ExportFormat.excel.displayName).tag(ExportFormat.excel)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Include:")
                                .font(.headline)
                            
                            Toggle("Item Images", isOn: $includeImages)
                            Toggle("Receipt Images", isOn: $includeReceipts)
                        }
                        
                        Button(action: startExport) {
                            Text("Export Data")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Export Data")
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
    
    private func startExport() {
        isExporting = true
        exportMessage = "Preparing export..."
        
        // Simulate export progress
        Task {
            for i in 1...10 {
                await MainActor.run {
                    exportProgress = Double(i) / 10.0
                    exportMessage = "Processing items... (\(i * 10)%)"
                }
                try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
            }
            
            await MainActor.run {
                exportMessage = "Export completed successfully!"
                isExporting = false
            }
        }
    }
}

struct DataImportSheet: View {
    @Binding var isImporting: Bool
    @Binding var importMessage: String
    @Environment(\.dismiss) private var dismiss
    
    @State private var importProgress: Double = 0.0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 50))
                        .foregroundColor(.green)
                    
                    Text("Import Inventory Data")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Import data from CSV or JSON files")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                
                if isImporting {
                    VStack(spacing: 16) {
                        ProgressView(value: importProgress)
                            .progressViewStyle(LinearProgressViewStyle())
                        
                        Text("Importing... \(Int(importProgress * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if !importMessage.isEmpty {
                            Text(importMessage)
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                } else {
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Supported Formats:")
                                .font(.headline)
                            
                            HStack {
                                Image(systemName: "doc.text")
                                    .foregroundColor(.blue)
                                Text("CSV (Comma-separated values)")
                            }
                            
                            HStack {
                                Image(systemName: "doc.badge.gearshape")
                                    .foregroundColor(.orange)
                                Text("JSON (JavaScript Object Notation)")
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Button(action: startImport) {
                            HStack {
                                Image(systemName: "folder.badge.plus")
                                Text("Choose File to Import")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Import Data")
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
    
    private func startImport() {
        isImporting = true
        importMessage = "Reading file..."
        
        // Simulate import progress
        Task {
            for i in 1...10 {
                await MainActor.run {
                    importProgress = Double(i) / 10.0
                    importMessage = "Processing records... (\(i * 10)%)"
                }
                try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
            }
            
            await MainActor.run {
                importMessage = "Import completed successfully!"
                isImporting = false
            }
        }
    }
}

// MARK: - Supporting Types
// Note: ExportFormat is defined in Foundation/Models/ExportFormat.swift

#Preview {
    SettingsView(
        store: Store(initialState: SettingsFeature.State()) {
            SettingsFeature()
        }
    )
}