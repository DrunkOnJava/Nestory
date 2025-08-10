//
//  SettingsView.swift
//  Nestory
//
//  REMINDER: Settings is a common place to wire up utility features like:
//  - Import/Export (✓ Wired)
//  - Insurance Reports (✓ Wired)
//  - Backup/Restore
//  - Account Management
//  Always check if new services should be accessible from Settings!

import SwiftUI
import SwiftData

struct SettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @Query private var categories: [Category]
    @Query private var rooms: [Room]
    
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("autoBackupEnabled") private var autoBackupEnabled = false
    @AppStorage("currencyCode") private var currencyCode = "USD"
    
    @State private var showingExportOptions = false
    @State private var showingClearDataAlert = false
    @State private var showingExportSuccess = false
    @State private var exportedFileURL: URL?
    @State private var showingInsuranceReportOptions = false
    @State private var isGeneratingReport = false
    @State private var reportError: Error?
    @StateObject private var insuranceReportService = InsuranceReportService()
    @StateObject private var importExportService = ImportExportService()
    @StateObject private var cloudBackup = CloudBackupService()
    @StateObject private var insuranceExportService = InsuranceExportService()
    @State private var showingImportPicker = false
    @State private var importResult: ImportExportService.ImportResult?
    @State private var showingImportResult = false
    @State private var showingBackupOptions = false
    @State private var showingRestoreConfirmation = false
    @State private var backupResult: String?
    @State private var showingBackupResult = false
    @State private var showingInsuranceExportOptions = false
    
    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Appearance
                Section("Appearance") {
                    Toggle("Use System Theme", isOn: $themeManager.useSystemTheme)
                    
                    if !themeManager.useSystemTheme {
                        Toggle("Dark Mode", isOn: $themeManager.darkModeEnabled)
                    }
                    
                    Picker("App Icon", selection: .constant("Default")) {
                        Text("Default").tag("Default")
                        Text("Dark").tag("Dark")
                        Text("Colorful").tag("Colorful")
                    }
                }
                
                // MARK: - General
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
                
                // MARK: - Notifications
                Section("Notifications") {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                    
                    if notificationsEnabled {
                        Toggle("Warranty Expiration", isOn: .constant(true))
                        Toggle("Insurance Policy Renewal", isOn: .constant(true))
                        Toggle("Document Update Reminders", isOn: .constant(false))
                    }
                }
                
                // MARK: - Data & Storage
                Section("Data & Storage") {
                    HStack {
                        Label("Total Items", systemImage: "shippingbox.fill")
                        Spacer()
                        Text("\(items.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Label("Categories", systemImage: "square.grid.2x2")
                        Spacer()
                        Text("\(categories.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Label("Storage Used", systemImage: "internaldrive")
                        Spacer()
                        Text(formatStorageSize())
                            .foregroundColor(.secondary)
                    }
                    
                    Toggle("Auto Backup", isOn: $autoBackupEnabled)
                }
                
                // MARK: - iCloud Backup
                Section("iCloud Backup") {
                    // Backup status
                    if let lastBackup = cloudBackup.lastBackupDate {
                        HStack {
                            Label("Last Backup", systemImage: "clock")
                            Spacer()
                            Text(lastBackup.formatted(.relative(presentation: .named)))
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    
                    // Backup button
                    Button(action: { performBackup() }) {
                        if cloudBackup.isBackingUp {
                            HStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .scaleEffect(0.8)
                                Text("Backing up... \(Int(cloudBackup.progress * 100))%")
                            }
                        } else {
                            Label("Backup Now", systemImage: "icloud.and.arrow.up")
                        }
                    }
                    .disabled(cloudBackup.isBackingUp || cloudBackup.isRestoring)
                    
                    // Restore button
                    Button(action: { showingRestoreConfirmation = true }) {
                        if cloudBackup.isRestoring {
                            HStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .scaleEffect(0.8)
                                Text("Restoring... \(Int(cloudBackup.progress * 100))%")
                            }
                        } else {
                            Label("Restore from iCloud", systemImage: "icloud.and.arrow.down")
                        }
                    }
                    .disabled(cloudBackup.isBackingUp || cloudBackup.isRestoring)
                    
                    // REMINDER: CloudKit backup is wired here for disaster recovery!
                    if cloudBackup.errorMessage != nil {
                        Text(cloudBackup.errorMessage!)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                // MARK: - Import & Export
                Section("Import & Export") {
                    Button(action: { showingExportOptions = true }) {
                        Label("Export Data", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(action: { showingImportPicker = true }) {
                        Label("Import Data", systemImage: "square.and.arrow.down")
                    }
                    
                    Button(action: { showingInsuranceReportOptions = true }) {
                        if isGeneratingReport {
                            HStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .scaleEffect(0.8)
                                Text("Generating Report...")
                            }
                        } else {
                            Label("Generate Insurance Report", systemImage: "doc.text")
                        }
                    }
                    .disabled(items.isEmpty || isGeneratingReport)
                    
                    // REMINDER: InsuranceExportService is wired here!
                    Button(action: { showingInsuranceExportOptions = true }) {
                        if insuranceExportService.isExporting {
                            HStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .scaleEffect(0.8)
                                Text("Exporting... \(Int(insuranceExportService.exportProgress * 100))%")
                            }
                        } else {
                            Label("Export for Insurance Company", systemImage: "doc.richtext")
                        }
                    }
                    .disabled(items.isEmpty || insuranceExportService.isExporting)
                }
                
                // MARK: - Support
                Section("Support") {
                    Link(destination: URL(string: "https://github.com/yourusername/Nestory")!) {
                        Label("GitHub Repository", systemImage: "link")
                    }
                    
                    Link(destination: URL(string: "mailto:support@nestory.app")!) {
                        Label("Contact Support", systemImage: "envelope")
                    }
                    
                    Button(action: { }) {
                        Label("Rate on App Store", systemImage: "star")
                    }
                }
                
                // MARK: - About
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
                    
                    Link("Privacy Policy", destination: URL(string: "https://nestory.app/privacy")!)
                    Link("Terms of Service", destination: URL(string: "https://nestory.app/terms")!)
                    
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
                
                // MARK: - Danger Zone
                Section {
                    Button("Clear All Data", role: .destructive) {
                        showingClearDataAlert = true
                    }
                } header: {
                    Text("Danger Zone")
                } footer: {
                    Text("This action cannot be undone.")
                }
            }
            .navigationTitle("Settings")
            .alert("Clear All Data?", isPresented: $showingClearDataAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    clearAllData()
                }
            } message: {
                Text("This will permanently delete all items and categories. This action cannot be undone.")
            }
            .sheet(isPresented: $showingExportOptions) {
                ExportOptionsView(items: items, categories: categories)
            }
            .sheet(isPresented: $showingInsuranceReportOptions) {
                InsuranceReportOptionsView(
                    items: items,
                    categories: categories,
                    insuranceReportService: insuranceReportService,
                    isGenerating: $isGeneratingReport
                )
            }
            .sheet(isPresented: $showingInsuranceExportOptions) {
                InsuranceExportOptionsView(
                    items: items,
                    categories: categories,
                    rooms: rooms,
                    exportService: insuranceExportService
                )
            }
            .alert("Report Error", isPresented: .constant(reportError != nil)) {
                Button("OK") { reportError = nil }
            } message: {
                Text(reportError?.localizedDescription ?? "An error occurred while generating the report.")
            }
            .fileImporter(
                isPresented: $showingImportPicker,
                allowedContentTypes: [.json, .commaSeparatedText],
                allowsMultipleSelection: false
            ) { result in
                Task {
                    switch result {
                    case .success(let urls):
                        if let url = urls.first {
                            await handleImport(url: url)
                        }
                    case .failure(let error):
                        importResult = ImportExportService.ImportResult(
                            itemsImported: 0,
                            itemsSkipped: 0,
                            errors: [error.localizedDescription]
                        )
                        showingImportResult = true
                    }
                }
            }
            .alert("Import Complete", isPresented: $showingImportResult) {
                Button("OK") { }
            } message: {
                if let importResult = importResult {
                    Text(importResult.summary)
                }
            }
            .alert("Restore from iCloud?", isPresented: $showingRestoreConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Restore", role: .destructive) {
                    performRestore()
                }
            } message: {
                Text("This will replace all current data with the backup from iCloud. Your current data will be lost.")
            }
            .alert("Backup Result", isPresented: $showingBackupResult) {
                Button("OK") { }
            } message: {
                Text(backupResult ?? "Operation completed")
            }
        }
    }
    
    private func formatStorageSize() -> String {
        let totalSize = calculateStorageSize()
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(totalSize))
    }
    
    private func calculateStorageSize() -> Int {
        var totalSize = 0
        for item in items {
            totalSize += item.name.count
            totalSize += item.itemDescription?.count ?? 0
            totalSize += item.notes?.count ?? 0
            totalSize += item.imageData?.count ?? 0
        }
        return totalSize
    }
    
    private func clearAllData() {
        for item in items {
            modelContext.delete(item)
        }
        for category in categories {
            modelContext.delete(category)
        }
        try? modelContext.save()
    }
    
    @MainActor
    private func handleImport(url: URL) async {
        do {
            // Start accessing the security-scoped resource
            guard url.startAccessingSecurityScopedResource() else {
                throw ImportExportService.ImportError.dataConversionError
            }
            defer { url.stopAccessingSecurityScopedResource() }
            
            // Determine file type and import
            if url.pathExtension.lowercased() == "csv" {
                importResult = try await importExportService.importCSV(from: url, modelContext: modelContext)
            } else if url.pathExtension.lowercased() == "json" {
                importResult = try await importExportService.importJSON(from: url, modelContext: modelContext)
            } else {
                throw ImportExportService.ImportError.invalidFormat
            }
            
            showingImportResult = true
        } catch {
            importResult = ImportExportService.ImportResult(
                itemsImported: 0,
                itemsSkipped: 0,
                errors: [error.localizedDescription]
            )
            showingImportResult = true
        }
    }
    
    private func performBackup() {
        Task {
            do {
                try await cloudBackup.performBackup(
                    items: items,
                    categories: categories,
                    rooms: rooms
                )
                backupResult = "Backup completed successfully! \(items.count) items backed up to iCloud."
                showingBackupResult = true
            } catch {
                backupResult = "Backup failed: \(error.localizedDescription)"
                showingBackupResult = true
            }
        }
    }
    
    private func performRestore() {
        Task {
            do {
                let result = try await cloudBackup.performRestore(modelContext: modelContext)
                backupResult = "Restore completed! Restored \(result.itemsRestored) items, \(result.categoriesRestored) categories, and \(result.roomsRestored) rooms from \(result.backupDate.formatted())."
                showingBackupResult = true
            } catch {
                backupResult = "Restore failed: \(error.localizedDescription)"
                showingBackupResult = true
            }
        }
    }
}

// MARK: - Export Options View
struct ExportOptionsView: View {
    let items: [Item]
    let categories: [Category]
    @Environment(\.dismiss) private var dismiss
    @State private var exportFormat: ExportFormat = .json
    @State private var includeImages = false
    @State private var isExporting = false
    
    enum ExportFormat: String, CaseIterable {
        case json = "JSON"
        case csv = "CSV"
        case pdf = "PDF Report"
        
        var icon: String {
            switch self {
            case .json: return "doc.text"
            case .csv: return "tablecells"
            case .pdf: return "doc.richtext"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Export Format") {
                    ForEach(ExportFormat.allCases, id: \.self) { format in
                        HStack {
                            Image(systemName: format.icon)
                                .foregroundColor(.accentColor)
                                .frame(width: 30)
                            
                            Text(format.rawValue)
                            
                            Spacer()
                            
                            if exportFormat == format {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            exportFormat = format
                        }
                    }
                }
                
                Section("Options") {
                    Toggle("Include Images", isOn: $includeImages)
                        .disabled(exportFormat == .csv)
                    
                    HStack {
                        Text("Items to Export")
                        Spacer()
                        Text("\(items.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Estimated Size")
                        Spacer()
                        Text(estimatedSize())
                            .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    Button(action: performExport) {
                        if isExporting {
                            HStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .scaleEffect(0.8)
                                Text("Exporting...")
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            Text("Export")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(isExporting || items.isEmpty)
                }
            }
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func estimatedSize() -> String {
        var size = items.count * 500 // Base size per item
        if includeImages {
            size += items.compactMap { $0.imageData?.count }.reduce(0, +)
        }
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        return formatter.string(fromByteCount: Int64(size))
    }
    
    private func performExport() {
        isExporting = true
        
        Task {
            let importExportService = ImportExportService()
            var exportData: Data?
            var fileName: String
            
            switch exportFormat {
            case .csv:
                exportData = importExportService.exportToCSV(items: items)
                fileName = "Nestory_Export_\(Date().formatted(date: .abbreviated, time: .omitted)).csv"
            case .json:
                exportData = importExportService.exportToJSON(items: items)
                fileName = "Nestory_Export_\(Date().formatted(date: .abbreviated, time: .omitted)).json"
            case .pdf:
                // Use InsuranceReportService for PDF
                let reportService = InsuranceReportService()
                do {
                    exportData = try await reportService.generateInsuranceReport(
                        items: items,
                        categories: categories,
                        options: InsuranceReportService.ReportOptions()
                    )
                    fileName = "Nestory_Report_\(Date().formatted(date: .abbreviated, time: .omitted)).pdf"
                } catch {
                    print("PDF generation error: \(error)")
                    isExporting = false
                    return
                }
            }
            
            if let data = exportData {
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
                do {
                    try data.write(to: tempURL)
                    
                    await MainActor.run {
                        let activityVC = UIActivityViewController(
                            activityItems: [tempURL],
                            applicationActivities: nil
                        )
                        
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let window = windowScene.windows.first,
                           let rootVC = window.rootViewController {
                            
                            if let popover = activityVC.popoverPresentationController {
                                popover.sourceView = rootVC.view
                                popover.sourceRect = CGRect(x: rootVC.view.bounds.midX, y: rootVC.view.bounds.midY, width: 0, height: 0)
                                popover.permittedArrowDirections = []
                            }
                            
                            rootVC.present(activityVC, animated: true) {
                                isExporting = false
                                dismiss()
                            }
                        }
                    }
                } catch {
                    print("Export error: \(error)")
                    isExporting = false
                }
            } else {
                isExporting = false
            }
        }
    }
}

// MARK: - Insurance Report Options View
struct InsuranceReportOptionsView: View {
    let items: [Item]
    let categories: [Category]
    let insuranceReportService: InsuranceReportService
    @Binding var isGenerating: Bool
    @Environment(\.dismiss) private var dismiss
    
    @State private var includePhotos = true
    @State private var includeReceipts = true
    @State private var includeDepreciation = false
    @State private var groupByRoom = true
    @State private var includeSerialNumbers = true
    @State private var includePurchaseInfo = true
    @State private var includeTotalValue = true
    @State private var propertyAddress = ""
    @State private var policyNumber = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Report Options") {
                    Toggle("Include Photos", isOn: $includePhotos)
                    Toggle("Include Receipts", isOn: $includeReceipts)
                    Toggle("Include Purchase Information", isOn: $includePurchaseInfo)
                    Toggle("Include Serial Numbers", isOn: $includeSerialNumbers)
                    Toggle("Show Total Value", isOn: $includeTotalValue)
                    Toggle("Group by Room/Category", isOn: $groupByRoom)
                    Toggle("Calculate Depreciation", isOn: $includeDepreciation)
                }
                
                Section("Policy Information (Optional)") {
                    TextField("Property Address", text: $propertyAddress)
                        .textContentType(.fullStreetAddress)
                    
                    TextField("Policy Number", text: $policyNumber)
                        .textContentType(.none)
                }
                
                Section("Report Details") {
                    HStack {
                        Text("Total Items")
                        Spacer()
                        Text("\(items.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Total Value")
                        Spacer()
                        Text(formatTotalValue())
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Items with Photos")
                        Spacer()
                        Text("\(items.filter { $0.imageData != nil }.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Items with Serial Numbers")
                        Spacer()
                        Text("\(items.filter { $0.serialNumber != nil }.count)")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    Button(action: generateReport) {
                        if isGenerating {
                            HStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                Text("Generating Report...")
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            Text("Generate Report")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(isGenerating)
                }
            }
            .navigationTitle("Insurance Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func formatTotalValue() -> String {
        let total = items.compactMap { $0.purchasePrice }.reduce(0, +)
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: total as NSNumber) ?? "$0"
    }
    
    @MainActor
    private func generateReport() {
        isGenerating = true
        
        Task {
            do {
                let options = InsuranceReportService.ReportOptions()
                // Configure options based on toggles
                var mutableOptions = options
                mutableOptions.includePhotos = includePhotos
                mutableOptions.includeReceipts = includeReceipts
                mutableOptions.includeDepreciation = includeDepreciation
                mutableOptions.groupByRoom = groupByRoom
                mutableOptions.includeSerialNumbers = includeSerialNumbers
                mutableOptions.includePurchaseInfo = includePurchaseInfo
                mutableOptions.includeTotalValue = includeTotalValue
                
                // Generate the PDF
                let pdfData = try await insuranceReportService.generateInsuranceReport(
                    items: items,
                    categories: categories,
                    options: mutableOptions
                )
                
                // Export and share
                let url = try await insuranceReportService.exportReport(pdfData)
                await insuranceReportService.shareReport(url)
                
                isGenerating = false
                dismiss()
            } catch {
                isGenerating = false
                // Handle error - in production would show alert
                print("Error generating report: \(error)")
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(ThemeManager.shared)
        .modelContainer(for: [Item.self, Category.self], inMemory: true)
}