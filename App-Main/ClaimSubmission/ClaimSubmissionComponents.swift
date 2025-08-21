//
// Layer: App
// Module: ClaimSubmission
// Purpose: Reusable UI components for claim submission workflow
//

import SwiftUI

// MARK: - Item Selection Components

public struct ItemSelectionRow: View {
    let item: Item
    let isSelected: Bool
    let onToggle: () -> Void

    public init(item: Item, isSelected: Bool, onToggle: @escaping () -> Void) {
        self.item = item
        self.isSelected = isSelected
        self.onToggle = onToggle
    }

    public var body: some View {
        HStack {
            Button(action: onToggle) {
                HStack {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? .blue : .gray)

                    VStack(alignment: .leading) {
                        Text(item.name)
                            .fontWeight(.medium)

                        HStack {
                            Text(item.category?.name ?? "No Category")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Spacer()

                            if let price = item.purchasePrice {
                                Text(price, format: .currency(code: "USD"))
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                        }
                    }

                    Spacer()
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
        .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
        .cornerRadius(8)
    }
}

public struct ItemSelectionControls: View {
    let selectedCount: Int
    let onSelectAll: () -> Void
    let onClearAll: () -> Void

    public init(selectedCount: Int, onSelectAll: @escaping () -> Void, onClearAll: @escaping () -> Void) {
        self.selectedCount = selectedCount
        self.onSelectAll = onSelectAll
        self.onClearAll = onClearAll
    }

    public var body: some View {
        HStack {
            Text("\(selectedCount) items selected")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            Button("Select All", action: onSelectAll)
                .font(.caption)

            Button("Clear All", action: onClearAll)
                .font(.caption)
        }
        .padding(.bottom, 8)
    }
}

// MARK: - Validation Components

public struct ValidationSummaryView: View {
    let results: ClaimValidationResults

    public init(results: ClaimValidationResults) {
        self.results = results
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: results.isReadyForSubmission ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .foregroundColor(results.isReadyForSubmission ? .green : .orange)

                Text(results.isReadyForSubmission ? "Ready for Submission" : "Needs Attention")
                    .fontWeight(.medium)

                Spacer()

                Text(results.completenessGrade)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(gradeColor(results.completenessGrade))
                    .cornerRadius(4)
            }

            VStack(alignment: .leading, spacing: 4) {
                ProgressView("Overall Completeness", value: results.overallCompleteness, total: 1.0)
                Text("\(Int(results.overallCompleteness * 100))% complete")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if !results.criticalIssues.isEmpty {
                Label("\(results.criticalIssues.count) Critical Issues", systemImage: "exclamationmark.circle.fill")
                    .foregroundColor(.red)
                    .font(.caption)
            }

            if !results.warnings.isEmpty {
                Label("\(results.warnings.count) Warnings", systemImage: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .font(.caption)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(8)
    }

    private func gradeColor(_ grade: String) -> Color {
        switch grade {
        case "Excellent": .green.opacity(0.2)
        case "Good": .blue.opacity(0.2)
        case "Fair": .orange.opacity(0.2)
        default: .red.opacity(0.2)
        }
    }
}

public struct ValidationResultsView: View {
    let results: ClaimValidationResults?
    let onDismiss: () -> Void

    public init(results: ClaimValidationResults?, onDismiss: @escaping () -> Void) {
        self.results = results
        self.onDismiss = onDismiss
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                if let results {
                    VStack(alignment: .leading, spacing: 20) {
                        // Summary
                        ValidationSummaryView(results: results)

                        // Critical Issues
                        if !results.criticalIssues.isEmpty {
                            issueSection(
                                title: "Critical Issues",
                                issues: results.criticalIssues,
                                color: .red
                            )
                        }

                        // Warnings
                        if !results.warnings.isEmpty {
                            issueSection(
                                title: "Warnings",
                                issues: results.warnings,
                                color: .orange
                            )
                        }

                        // Suggestions
                        if !results.suggestions.isEmpty {
                            issueSection(
                                title: "Suggestions",
                                issues: results.suggestions,
                                color: .blue
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Validation Results")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done", action: onDismiss)
                }
            }
        }
    }

    private func issueSection(
        title: String,
        issues: [ValidationIssue],
        color: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(color)

            ForEach(issues) { issue in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: issue.severity.icon)
                            .foregroundColor(colorForSeverity(issue.severity))

                        Text(issue.message)
                            .fontWeight(.medium)
                    }

                    if !issue.affectedItems.isEmpty {
                        Text("\(issue.affectedItems.count) items affected")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    if let suggestion = issue.suggestion {
                        Text(suggestion)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
                .padding()
                .background(colorForSeverity(issue.severity).opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
    
    private func colorForSeverity(_ severity: ValidationSeverity) -> Color {
        switch severity {
        case .critical, .error:
            return .red
        case .warning:
            return .orange
        case .info:
            return .blue
        }
    }
}

// MARK: - Submission Components

public struct SubmissionMethodCard: View {
    let method: SubmissionMethod
    let isSelected: Bool
    let onSelect: () -> Void

    public init(method: SubmissionMethod, isSelected: Bool, onSelect: @escaping () -> Void) {
        self.method = method
        self.isSelected = isSelected
        self.onSelect = onSelect
    }

    public var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 8) {
                Image(systemName: methodIcon(method))
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .blue)

                Text(method.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(isSelected ? Color.blue : Color.blue.opacity(0.1))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.blue, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func methodIcon(_ method: SubmissionMethod) -> String {
        switch method {
        case .email: "envelope"
        case .onlinePortal: "globe"
        case .mobileApp: "iphone"
        case .cloudUpload: "icloud.and.arrow.up"
        case .physicalMail: "mail"
        case .fax: "printer"
        case .inPerson: "person.fill"
        }
    }
}

public struct CloudServiceGrid: View {
    let services: [CloudStorageService]
    let selectedService: CloudStorageService?
    let onSelect: (CloudStorageService) -> Void

    public init(services: [CloudStorageService], selectedService: CloudStorageService?, onSelect: @escaping (CloudStorageService) -> Void) {
        self.services = services
        self.selectedService = selectedService
        self.onSelect = onSelect
    }

    public var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
        ], spacing: 8) {
            ForEach(services, id: \.name) { service in
                Button(service.name) {
                    onSelect(service)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
    }
}

// MARK: - Form Components

public struct ClaimTypeSelector: View {
    @Binding var claimType: InsuranceClaimType

    public init(claimType: Binding<InsuranceClaimType>) {
        self._claimType = claimType
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Claim Type")
                .fontWeight(.medium)
            Picker("Claim Type", selection: $claimType) {
                ForEach(InsuranceClaimType.allCases, id: \.self) { type in
                    Label(type.rawValue, systemImage: type.icon)
                        .tag(type)
                }
            }
            .pickerStyle(.menu)
        }
    }
}

public struct InsuranceCompanySelector: View {
    @Binding var insuranceCompany: InsuranceCompanyFormat

    public init(insuranceCompany: Binding<InsuranceCompanyFormat>) {
        self._insuranceCompany = insuranceCompany
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Insurance Company")
                .fontWeight(.medium)
            Picker("Insurance Company", selection: $insuranceCompany) {
                ForEach(InsuranceCompanyFormat.allCases, id: \.self) { company in
                    Text(company.rawValue).tag(company)
                }
            }
            .pickerStyle(.menu)
        }
    }
}

public struct PolicyNumberField: View {
    @Binding var policyNumber: String

    public init(policyNumber: Binding<String>) {
        self._policyNumber = policyNumber
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Policy Number")
                .fontWeight(.medium)
            TextField("Enter policy number", text: $policyNumber)
                .textFieldStyle(.roundedBorder)
        }
    }
}

public struct IncidentDatePicker: View {
    @Binding var incidentDate: Date

    public init(incidentDate: Binding<Date>) {
        self._incidentDate = incidentDate
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Incident Date")
                .fontWeight(.medium)
            DatePicker("Incident Date", selection: $incidentDate, displayedComponents: .date)
                .datePickerStyle(.compact)
        }
    }
}

public struct IncidentDescriptionEditor: View {
    @Binding var incidentDescription: String

    public init(incidentDescription: Binding<String>) {
        self._incidentDescription = incidentDescription
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Incident Description")
                .fontWeight(.medium)
            TextEditor(text: $incidentDescription)
                .frame(minHeight: 100)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

public struct RecipientEmailField: View {
    @Binding var recipientEmail: String

    public init(recipientEmail: Binding<String>) {
        self._recipientEmail = recipientEmail
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recipient Email")
                .fontWeight(.medium)
            TextField("claims@insurance.com", text: $recipientEmail)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
        }
    }
}

// MARK: - Progress Components

public struct WorkflowProgressView: View {
    let currentStep: Int
    let totalSteps: Int

    public init(currentStep: Int, totalSteps: Int) {
        self.currentStep = currentStep
        self.totalSteps = totalSteps
    }

    public var body: some View {
        VStack(spacing: 8) {
            ProgressView(value: Double(currentStep), total: Double(totalSteps))
                .padding(.horizontal)

            Text("Step \(currentStep) of \(totalSteps)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Layout Components

public struct StepContainer<Content: View>: View {
    let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(12)
    }
}
