//
// Layer: App-Main
// Module: DamageAssessment
// Purpose: Generate and display comprehensive damage assessment reports - Modularized Architecture
//

import SwiftUI
import SwiftData
import PDFKit

struct DamageAssessmentReportView: View {
    let workflow: DamageAssessmentWorkflow
    @State private var damageService: (any DamageAssessmentServiceProtocol)?
    @State private var generatedReport: Data?
    @State private var isGeneratingReport = false
    @State private var showingShareSheet = false
    @State private var reportURL: URL?
    @State private var reportError: (any Error)?
    @Environment(\.dismiss) private var dismiss
    
    // Report action manager
    private let actionManager: ReportActionManager

    init(workflow: DamageAssessmentWorkflow, modelContext: ModelContext) {
        self.workflow = workflow
        self.actionManager = ReportActionManager(workflow: workflow)
        do {
            self.damageService = try DamageAssessmentService(modelContext: modelContext)
        } catch {
            print("⚠️ Failed to initialize DamageAssessmentService: \(error)")
            self.damageService = MockDamageAssessmentService()
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Report header with title and description
                    ReportHeaderView()

                    // Assessment summary with key metrics
                    AssessmentSummarySection(workflow: workflow)

                    // Report generation status and workflow progress
                    ReportStatusSection(workflow: workflow)

                    // Report generation interface or actions
                    reportContentSection
                    
                    // Report features overview
                    ReportFeaturesSection()
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
                        Button(action: shareReport) {
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
            Text(reportError?.localizedDescription ?? "An unknown error occurred")
        }
    }
    
    // MARK: - Content Sections
    
    @ViewBuilder
    private var reportContentSection: some View {
        if let reportData = generatedReport {
            ReportActionsSection(
                reportData: reportData,
                onShare: shareReport,
                onSaveToFiles: { saveToFiles(reportData) },
                onEmail: { emailReport(reportData) }
            )
        } else {
            ReportGenerationSection(
                workflow: workflow,
                isGenerating: $isGeneratingReport,
                onGenerate: generateReport
            )
        }
    }

    // MARK: - Actions

    private func generateReport() {
        isGeneratingReport = true

        Task {
            do {
                let reportData = try await damageService?.generateAssessmentReport(workflow) ?? Data()

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

        do {
            let tempURL = try actionManager.createTemporaryReportURL(from: reportData)
            reportURL = tempURL
            showingShareSheet = true
        } catch {
            reportError = error
        }
    }

    private func saveToFiles(_ reportData: Data) {
        do {
            let fileURL = try actionManager.saveReportToDocuments(reportData: reportData)
            // Could show success message or notification
            print("Report saved to: \(fileURL)")
        } catch {
            reportError = error
        }
    }

    private func emailReport(_ reportData: Data) {
        // This would use MFMailComposeViewController to compose email
        // For now, just trigger share sheet
        shareReport()
    }
}

// ShareSheet is imported from UI/UI-Components/ShareSheet.swift

#Preview {
    @MainActor
    struct PreviewContainer: View {
        var body: some View {
            let workflow = DamageAssessmentWorkflow(
                damageType: .fire,
                assessment: DamageAssessment(
                    itemId: UUID(),
                    damageType: .fire,
                    severity: .moderate,
                    incidentDescription: "Fire damage from kitchen incident"
                )
            )

            // Use simple fallback approach for previews
            if let container = try? ModelContainer(for: Item.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true)) {
                DamageAssessmentReportView(
                    workflow: workflow,
                    modelContext: ModelContext(container)
                )
            } else {
                Text("Preview Error: Failed to create ModelContainer")
                    .foregroundColor(.red)
            }
        }
    }
    
    return PreviewContainer()
}

// MARK: - Architecture Documentation

//
// 🏗️ MODULAR ARCHITECTURE: Specialized sections organized by responsibility
// - ReportHeaderView: Title and description presentation
// - AssessmentSummarySection: Key metrics and assessment data display
// - ReportStatusSection: Workflow progress and completion status
// - ReportGenerationSection: Report creation interface with progress
// - ReportActionsSection: Share, save, and distribution actions
// - ReportFeaturesSection: Feature overview and capabilities
// - ReportActionManager: File management and sharing operations utility
//
// 🎯 BENEFITS ACHIEVED:
// - Single Responsibility: Each section handles one specific UI concern
// - Reusability: Components can be used independently in different contexts
// - Maintainability: Changes to one section don't affect others
// - Testability: Individual components can be unit tested in isolation
// - User Experience: Focused interfaces with clear functionality
//