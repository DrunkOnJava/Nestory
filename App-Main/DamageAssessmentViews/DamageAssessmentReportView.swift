//
// Layer: App-Main
// Module: DamageAssessment
// Purpose: Generate and display comprehensive damage assessment reports
//

import SwiftUI
import SwiftData
import PDFKit

struct DamageAssessmentReportView: View {
    let workflow: DamageAssessmentWorkflow
    @StateObject private var damageService: DamageAssessmentService
    @State private var generatedReport: Data?
    @State private var isGeneratingReport = false
    @State private var showingShareSheet = false
    @State private var reportURL: URL?
    @State private var reportError: Error?
    @Environment(\.dismiss) private var dismiss

    init(workflow: DamageAssessmentWorkflow, modelContext: ModelContext) {
        self.workflow = workflow
        self._damageService = StateObject(wrappedValue: {
            do {
                return try DamageAssessmentService(modelContext: modelContext)
            } catch {
                fatalError("Failed to initialize DamageAssessmentService: \(error)")
            }
        }())
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "doc.richtext.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)

                        Text("Assessment Report")
                            .font(.title2)
                            .fontWeight(.semibold)

                        Text("Professional damage assessment documentation")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal)

                    // Assessment Summary
                    assessmentSummarySection

                    // Report Status
                    reportStatusSection

                    // Report Preview/Actions
                    if let reportData = generatedReport {
                        reportActionsSection(reportData: reportData)
                    } else {
                        reportGenerationSection
                    }

                    // Report Features Overview
                    reportFeaturesSection
                }
                .padding(.vertical)
            }
            .navigationTitle("Damage Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }

                if generatedReport != nil {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            shareReport()
                        }) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let url = reportURL {
                ShareSheet(activityItems: [url])
            }
        }
        .alert("Report Generation Error", isPresented: .constant(reportError != nil)) {
            Button("OK") {
                reportError = nil
            }
        } message: {
            if let error = reportError {
                Text(error.localizedDescription)
            }
        }
    }

    // MARK: - Assessment Summary Section

    private var assessmentSummarySection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {
                Label("Assessment Summary", systemImage: "doc.text")
                    .font(.headline)
                    .foregroundColor(.blue)

                VStack(spacing: 12) {
                    SummaryRow(
                        label: "Damage Type",
                        value: workflow.damageType.rawValue,
                        icon: workflow.damageType.icon,
                        color: Color(hex: workflow.damageType.color)
                    )

                    SummaryRow(
                        label: "Severity",
                        value: workflow.assessment.severity.rawValue,
                        icon: workflow.assessment.severity.icon,
                        color: Color(hex: workflow.assessment.severity.color)
                    )

                    SummaryRow(
                        label: "Assessment Date",
                        value: workflow.assessment.assessmentDate.formatted(date: .abbreviated, time: .omitted),
                        icon: "calendar",
                        color: .secondary
                    )

                    SummaryRow(
                        label: "Progress",
                        value: "\(Int(workflow.progress * 100))% Complete",
                        icon: workflow.isComplete ? "checkmark.circle.fill" : "progress.indicator",
                        color: workflow.isComplete ? .green : .orange
                    )
                }
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Report Status Section

    private var reportStatusSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {
                Label("Report Status", systemImage: "chart.bar.doc.horizontal")
                    .font(.headline)
                    .foregroundColor(.purple)

                VStack(spacing: 12) {
                    StatusIndicator(
                        title: "Photo Documentation",
                        isComplete: hasPhotoDocumentation,
                        count: totalPhotos
                    )

                    StatusIndicator(
                        title: "Severity Assessment",
                        isComplete: hasSeverityAssessment,
                        detail: workflow.assessment.severity.rawValue
                    )

                    StatusIndicator(
                        title: "Cost Estimation",
                        isComplete: hasCostEstimation,
                        detail: costEstimationDetail
                    )

                    StatusIndicator(
                        title: "Assessment Notes",
                        isComplete: hasAssessmentNotes,
                        detail: "\(workflow.assessment.assessmentNotes.count) characters"
                    )
                }
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Report Generation Section

    private var reportGenerationSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {
                Label("Generate Report", systemImage: "doc.badge.plus")
                    .font(.headline)
                    .foregroundColor(.green)

                VStack(spacing: 12) {
                    Text("Create a comprehensive PDF report including all assessment data, photos, and cost estimates.")
                        .font(.body)
                        .foregroundColor(.secondary)

                    if isGeneratingReport {
                        VStack(spacing: 8) {
                            ProgressView()
                            Text("Generating report...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    } else {
                        Button(action: generateReport) {
                            HStack {
                                Image(systemName: "doc.richtext")
                                Text("Generate PDF Report")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(!workflow.isComplete)

                        if !workflow.isComplete {
                            Text("Complete the assessment workflow to generate a report")
                                .font(.caption)
                                .foregroundColor(.orange)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Report Actions Section

    private func reportActionsSection(reportData: Data) -> some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {
                Label("Report Generated", systemImage: "checkmark.circle.fill")
                    .font(.headline)
                    .foregroundColor(.green)

                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "doc.richtext.fill")
                            .font(.title2)
                            .foregroundColor(.blue)

                        VStack(alignment: .leading) {
                            Text("Assessment Report.pdf")
                                .font(.body)
                                .fontWeight(.medium)
                            Text("\(ByteCountFormatter.string(fromByteCount: Int64(reportData.count), countStyle: .file))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)

                    HStack(spacing: 12) {
                        Button(action: {
                            shareReport()
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                        }

                        Button(action: {
                            saveToFiles(reportData)
                        }) {
                            HStack {
                                Image(systemName: "folder")
                                Text("Save to Files")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple.opacity(0.1))
                            .foregroundColor(.purple)
                            .cornerRadius(8)
                        }
                    }

                    Button(action: {
                        emailReport(reportData)
                    }) {
                        HStack {
                            Image(systemName: "envelope")
                            Text("Email to Insurance")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .foregroundColor(.orange)
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Report Features Section

    private var reportFeaturesSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {
                Label("Report Includes", systemImage: "list.bullet.clipboard")
                    .font(.headline)
                    .foregroundColor(.indigo)

                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                ], spacing: 12) {
                    ReportFeature(
                        icon: "photo.stack",
                        title: "Photo Documentation",
                        description: "Before, after, and detail photos"
                    )

                    ReportFeature(
                        icon: "magnifyingglass.circle",
                        title: "Damage Analysis",
                        description: "Severity assessment and impact"
                    )

                    ReportFeature(
                        icon: "dollarsign.circle",
                        title: "Cost Estimates",
                        description: "Repair and replacement costs"
                    )

                    ReportFeature(
                        icon: "calendar",
                        title: "Timeline",
                        description: "Incident and assessment dates"
                    )

                    ReportFeature(
                        icon: "doc.text",
                        title: "Detailed Notes",
                        description: "Assessment observations"
                    )

                    ReportFeature(
                        icon: "person.badge.shield.checkmark",
                        title: "Professional Format",
                        description: "Insurance-ready document"
                    )
                }
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Computed Properties

    private var hasPhotoDocumentation: Bool {
        !workflow.assessment.beforePhotos.isEmpty ||
            !workflow.assessment.afterPhotos.isEmpty ||
            !workflow.assessment.detailPhotos.isEmpty
    }

    private var totalPhotos: Int {
        workflow.assessment.beforePhotos.count +
            workflow.assessment.afterPhotos.count +
            workflow.assessment.detailPhotos.count
    }

    private var hasSeverityAssessment: Bool {
        true // Always has severity from assessment creation
    }

    private var hasCostEstimation: Bool {
        workflow.assessment.repairEstimate != nil ||
            workflow.assessment.replacementCost != nil
    }

    private var costEstimationDetail: String {
        if let repairEstimate = workflow.assessment.repairEstimate {
            "$\(repairEstimate) repair"
        } else if let replacementCost = workflow.assessment.replacementCost {
            "$\(replacementCost) replacement"
        } else {
            "Not set"
        }
    }

    private var hasAssessmentNotes: Bool {
        !workflow.assessment.assessmentNotes.isEmpty
    }

    // MARK: - Actions

    private func generateReport() {
        isGeneratingReport = true

        Task {
            do {
                let reportData = try await damageService.generateAssessmentReport(workflow)

                await MainActor.run {
                    self.generatedReport = reportData
                    self.isGeneratingReport = false
                }
            } catch {
                await MainActor.run {
                    self.reportError = error
                    self.isGeneratingReport = false
                }
            }
        }
    }

    private func shareReport() {
        guard let reportData = generatedReport else { return }

        // Create temporary file
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("Damage_Assessment_Report_\(workflow.id.uuidString.prefix(8)).pdf")

        do {
            try reportData.write(to: tempURL)
            reportURL = tempURL
            showingShareSheet = true
        } catch {
            reportError = error
        }
    }

    private func saveToFiles(_ reportData: Data) {
        // This would use UIDocumentPickerViewController to save to Files app
        // For now, just copy to Documents directory
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent("Damage_Assessment_Report_\(Date().formatted(date: .numeric, time: .omitted)).pdf")

        do {
            try reportData.write(to: fileURL)
            // Could show success message
        } catch {
            reportError = error
        }
    }

    private func emailReport(_: Data) {
        // This would use MFMailComposeViewController to compose email
        // For now, just trigger share sheet
        shareReport()
    }
}

// MARK: - Supporting Views

struct SummaryRow: View {
    let label: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(color)
                .frame(width: 20)

            Text(label)
                .font(.body)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
    }
}

struct StatusIndicator: View {
    let title: String
    let isComplete: Bool
    var count: Int? = nil
    var detail: String? = nil

    var body: some View {
        HStack {
            Image(systemName: isComplete ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isComplete ? .green : .secondary)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)

                if let count {
                    Text("\(count) items")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else if let detail {
                    Text(detail)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()
        }
    }
}

struct ReportFeature: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.indigo)

            VStack(spacing: 4) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)

                Text(description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// ShareSheet is imported from UI/UI-Components/ShareSheet.swift

#Preview {
    let workflow = DamageAssessmentWorkflow(
        damageType: .fire,
        assessment: DamageAssessment(
            itemId: UUID(),
            damageType: .fire,
            severity: .moderate,
            incidentDescription: "Fire damage from kitchen incident"
        )
    )

    DamageAssessmentReportView(
        workflow: workflow,
        modelContext: ModelContext(
            try! ModelContainer(for: Item.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        )
    )
}
