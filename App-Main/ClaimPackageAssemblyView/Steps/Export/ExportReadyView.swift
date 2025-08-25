//
// Layer: App-Main
// Module: ClaimPackageAssembly/Steps/Export
// Purpose: Ready-to-export state view with action button
//

import SwiftUI

public struct ExportReadyView: View {
    public let package: ClaimPackage
    public let onExportAction: @Sendable () -> Void
    
    // Add access to the ClaimPackageExporter for actual export functionality
    @StateObject private var packageExporter = ClaimPackageExporter()
    @State private var isExporting = false
    @State private var exportError: String?
    @State private var showingShareSheet = false
    @State private var shareURL: URL?
    
    public init(
        package: ClaimPackage,
        onExportAction: @escaping @Sendable () -> Void
    ) {
        self.package = package
        self.onExportAction = onExportAction
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Ready to Export")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Your claim package is ready to share with your insurance company.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            // Export options
            VStack(spacing: 12) {
                Button("Export as ZIP") {
                    exportAsZIP()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(isExporting)
                
                HStack(spacing: 12) {
                    Button("Export as PDF") {
                        exportAsPDF()
                    }
                    .buttonStyle(.bordered)
                    .disabled(isExporting)
                    
                    Button("Prepare for Email") {
                        prepareForEmail()
                    }
                    .buttonStyle(.bordered)
                    .disabled(isExporting)
                }
            }
            
            if isExporting {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Exporting...")
                        .foregroundColor(.secondary)
                }
            }
            
            if let exportError = exportError {
                Text(exportError)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let shareURL = shareURL {
                ShareSheet(activityItems: [shareURL])
            }
        }
    }
    
    // MARK: - Export Actions
    
    private func exportAsZIP() {
        Task {
            isExporting = true
            exportError = nil
            
            do {
                let zipURL = try await packageExporter.exportAsZIP(package: package)
                await MainActor.run {
                    self.shareURL = zipURL
                    self.showingShareSheet = true
                    self.isExporting = false
                }
            } catch {
                await MainActor.run {
                    self.exportError = "ZIP export failed: \(error.localizedDescription)"
                    self.isExporting = false
                }
            }
        }
    }
    
    private func exportAsPDF() {
        Task {
            isExporting = true
            exportError = nil
            
            do {
                let pdfURL = try await packageExporter.exportAsPDF(package: package)
                await MainActor.run {
                    self.shareURL = pdfURL
                    self.showingShareSheet = true
                    self.isExporting = false
                }
            } catch {
                await MainActor.run {
                    self.exportError = "PDF export failed: \(error.localizedDescription)"
                    self.isExporting = false
                }
            }
        }
    }
    
    private func prepareForEmail() {
        Task {
            isExporting = true
            exportError = nil
            
            do {
                let emailPackage = try await packageExporter.prepareForEmail(package: package)
                await MainActor.run {
                    self.isExporting = false
                    // In a real implementation, this would open MFMailComposeViewController
                    // For now, we'll show the summary PDF
                    self.shareURL = emailPackage.summaryPDF
                    self.showingShareSheet = true
                }
            } catch {
                await MainActor.run {
                    self.exportError = "Email preparation failed: \(error.localizedDescription)"
                    self.isExporting = false
                }
            }
        }
    }
}

// Note: Using ShareSheet from UI layer

#Preview {
    let package = ClaimPackage(
        id: UUID(),
        scenario: ClaimScenario(
            type: .fire,
            incidentDate: Date(),
            description: "Sample fire damage claim"
        ),
        items: [],
        coverLetter: ClaimCoverLetter(
            summary: ClaimSummary(
                claimType: .propertyDamage,
                incidentDate: Date(),
                totalItems: 0,
                totalValue: 0,
                affectedRooms: [],
                description: "Sample property damage summary"
            ),
            content: "This is a sample claim.",
            generatedDate: Date(),
            policyHolder: "John Doe",
            policyNumber: "POL123456"
        ),
        documentation: [],
        forms: [],
        attestations: [],
        validation: PackageValidation(
            isValid: true,
            issues: [],
            missingRequirements: [],
            totalItems: 0,
            documentedItems: 0,
            totalValue: 0,
            validationDate: Date()
        ),
        packageURL: URL(fileURLWithPath: "/tmp/sample.zip"),
        createdDate: Date(),
        options: ClaimPackageOptions()
    )
    
    ExportReadyView(package: package) {}
}