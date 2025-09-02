//
// Layer: App
// Module: ClaimExportView
// Purpose: Export and share insurance claim documents with multiple format options
//

import ComposableArchitecture
import SwiftUI
import SwiftData

struct ClaimExportView: View {
    let claim: GeneratedClaim
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Dependency(\.insuranceClaimService) var claimService
    @State private var trackingService: ClaimTrackingService?

    @State private var selectedFormats: Set<ClaimDocumentFormat> = []
    @State private var includePhotos = true
    @State private var includeReceipts = true
    @State private var addToTracking = true
    @State private var exportProgress: Double = 0
    @State private var isExporting = false
    @State private var exportedURLs: [URL] = []
    @State private var showingShareSheet = false
    @State private var exportError: String?
    @State private var showingError = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Current format info
                        GroupBox("Current Document") {
                            HStack {
                                Image(systemName: "doc.fill")
                                    .foregroundColor(.blue)

                                VStack(alignment: .leading) {
                                    Text(claim.filename)
                                        .font(.headline)
                                    Text(claim.format.rawValue)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Text(formatFileSize(claim.documentData.count))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }

                        // Additional format options
                        GroupBox("Export Additional Formats") {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Generate additional document formats:")
                                    .font(.headline)

                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible()),
                                ], spacing: 12) {
                                    ForEach(availableFormats, id: \.self) { format in
                                        FormatToggle(
                                            format: format,
                                            isSelected: selectedFormats.contains(format)
                                        ) {
                                            if selectedFormats.contains(format) {
                                                selectedFormats.remove(format)
                                            } else {
                                                selectedFormats.insert(format)
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Export options
                        GroupBox("Export Options") {
                            VStack(alignment: .leading, spacing: 12) {
                                Toggle("Include Item Photos", isOn: $includePhotos)
                                    .toggleStyle(SwitchToggleStyle())

                                Toggle("Include Receipt Images", isOn: $includeReceipts)
                                    .toggleStyle(SwitchToggleStyle())

                                Toggle("Add to Claim Tracking", isOn: $addToTracking)
                                    .toggleStyle(SwitchToggleStyle())

                                if includePhotos || includeReceipts {
                                    Text("Including images will create larger files but provide complete documentation.")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }

                        // Submission instructions
                        if !claim.submissionInstructions.isEmpty {
                            GroupBox("Submission Instructions") {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(claim.submissionInstructions)
                                        .font(.caption)

                                    Button("Copy Instructions") {
                                        UIPasteboard.general.string = claim.submissionInstructions
                                    }
                                    .buttonStyle(.bordered)
                                    .font(.caption)
                                }
                            }
                        }

                        // Export progress
                        if isExporting {
                            GroupBox("Export Progress") {
                                VStack(spacing: 12) {
                                    ProgressView(value: exportProgress)
                                        .progressViewStyle(LinearProgressViewStyle())

                                    Text("Generating documents...")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }

                        // Exported files
                        if !exportedURLs.isEmpty {
                            GroupBox("Exported Files") {
                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(Array(exportedURLs.enumerated()), id: \.offset) { _, url in
                                        HStack {
                                            Image(systemName: iconForFileType(url))
                                                .foregroundColor(.blue)

                                            Text(url.lastPathComponent)
                                                .font(.caption)

                                            Spacer()

                                            Text(formatFileSize(fileSize(for: url)))
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }

                // Action buttons
                VStack(spacing: 12) {
                    if !exportedURLs.isEmpty {
                        Button("Share All Files") {
                            showingShareSheet = true
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isExporting)
                    } else {
                        Button("Export Documents") {
                            Task {
                                await exportDocuments()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isExporting || (selectedFormats.isEmpty && exportedURLs.isEmpty))
                    }

                    Button("Save to Files") {
                        Task {
                            await saveToFiles()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isExporting || exportedURLs.isEmpty)
                }
                .padding()
            }
            .navigationTitle("Export Claim")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .disabled(isExporting)
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: exportedURLs)
        }
        .alert("Export Error", isPresented: $showingError) {
            Button("OK") {}
        } message: {
            if let error = exportError {
                Text(error)
            }
        }
        .onAppear {
            // Initialize tracking service with modelContext
            if trackingService == nil {
                trackingService = ClaimTrackingService(
                    modelContext: modelContext,
                    notificationService: nil
                )
            }

            // Include the original format in exported URLs
            if let originalURL = createTemporaryURL(for: claim) {
                exportedURLs = [originalURL]
            }
        }
    }

    // MARK: - Helper Views

    private func FormatToggle(
        format: ClaimDocumentFormat,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: iconForFormat(format))
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .accentColor)

                Text(format.rawValue)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 70)
            .background(isSelected ? Color.accentColor : Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Export Logic

    private var availableFormats: [ClaimDocumentFormat] {
        ClaimDocumentFormat.allCases.filter { $0 != claim.format }
    }

    private func exportDocuments() async {
        guard !selectedFormats.isEmpty else { return }

        isExporting = true
        exportProgress = 0
        var newURLs: [URL] = []

        let totalFormats = selectedFormats.count

        for (index, format) in selectedFormats.enumerated() {
            do {
                // Create new request with different format
                let modifiedRequest = claim.request
                let newRequest = ClaimRequest(
                    claimType: modifiedRequest.claimType,
                    insuranceCompany: modifiedRequest.insuranceCompany,
                    items: modifiedRequest.items,
                    incidentDate: modifiedRequest.incidentDate,
                    incidentDescription: modifiedRequest.incidentDescription,
                    policyNumber: modifiedRequest.policyNumber,
                    claimNumber: modifiedRequest.claimNumber,
                    contactInfo: modifiedRequest.contactInfo,
                    additionalDocuments: modifiedRequest.additionalDocuments,
                    documentNames: modifiedRequest.documentNames,
                    estimatedTotalLoss: modifiedRequest.estimatedTotalLoss,
                    format: format
                )

                // Generate new claim with different format
                let newClaim = try await claimService.generateClaim(for: newRequest)

                // Export the new claim
                let url = try await claimService.exportClaim(
                    newClaim,
                    includePhotos: includePhotos
                )

                newURLs.append(url)

                await MainActor.run {
                    exportProgress = Double(index + 1) / Double(totalFormats)
                }

            } catch {
                await MainActor.run {
                    exportError = "Failed to export \(format.rawValue): \(error.localizedDescription)"
                    showingError = true
                }
            }
        }

        await MainActor.run {
            exportedURLs.append(contentsOf: newURLs)
            isExporting = false

            // Add to tracking if requested
            if addToTracking {
                Task {
                    try? await trackingService?.trackClaim(claim)
                }
            }
        }
    }

    private func saveToFiles() async {
        // This would integrate with DocumentPicker to save files
        // For now, we'll just copy to a more permanent location

        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let claimFolder = documentsPath.appendingPathComponent("Insurance Claims/\(claim.id.uuidString)")

        do {
            try FileManager.default.createDirectory(at: claimFolder, withIntermediateDirectories: true)

            for url in exportedURLs {
                let destinationURL = claimFolder.appendingPathComponent(url.lastPathComponent)
                try FileManager.default.copyItem(at: url, to: destinationURL)
            }

            // Show success feedback
        } catch {
            exportError = "Failed to save files: \(error.localizedDescription)"
            showingError = true
        }
    }

    // MARK: - Helper Functions

    private func createTemporaryURL(for claim: GeneratedClaim) -> URL? {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(claim.filename)
        do {
            try claim.documentData.write(to: tempURL)
            return tempURL
        } catch {
            return nil
        }
    }

    private func iconForFormat(_ format: ClaimDocumentFormat) -> String {
        switch format {
        case .pdf:
            "doc.fill"
        case .standardPDF:
            "doc.fill"
        case .detailedPDF:
            "doc.fill"
        case .militaryFormat:
            "doc.fill"
        case .structuredJSON:
            "curlybraces"
        case .htmlPackage:
            "globe"
        case .spreadsheet:
            "tablecells"
        }
    }

    private func iconForFileType(_ url: URL) -> String {
        let pathExtension = url.pathExtension.lowercased()
        switch pathExtension {
        case "pdf":
            return "doc.fill"
        case "json":
            return "curlybraces"
        case "html":
            return "globe"
        case "xlsx", "csv":
            return "tablecells"
        default:
            return "doc"
        }
    }

    private func formatFileSize(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }

    private func fileSize(for url: URL) -> Int {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            return attributes[.size] as? Int ?? 0
        } catch {
            return 0
        }
    }
}

// ShareSheet is imported from UI/UI-Components/ShareSheet.swift

// MARK: - Preview

#Preview {
    let mockRequest = ClaimRequest(
        claimType: .theft,
        insuranceCompany: .stateFarm,
        items: [],
        incidentDate: Date(),
        incidentDescription: "Items stolen from garage",
        contactInfo: ClaimContactInfo(
            name: "John Doe",
            phone: "555-0123",
            email: "john@example.com",
            address: "123 Main St, Anytown, ST 12345"
        )
    )

    let mockClaim = GeneratedClaim(
        request: mockRequest,
        documentData: "Mock PDF Data".data(using: .utf8)!,
        filename: "Insurance_Claim_Theft_StateFarm_2024-01-15.pdf",
        format: .standardPDF,
        checklistItems: ["Review claim", "Submit documents"],
        submissionInstructions: "Submit online at statefarm.com"
    )

    ClaimExportView(claim: mockClaim)
}
