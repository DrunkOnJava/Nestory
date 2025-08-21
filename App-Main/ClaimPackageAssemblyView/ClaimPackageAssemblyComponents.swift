//
// Layer: App-Main
// Module: ClaimPackageAssembly
// Purpose: Reusable UI components for claim package assembly interface
//

import SwiftUI
import SwiftData

// MARK: - Progress Components

public struct AssemblyProgressView: View {
    let currentStep: AssemblyStep
    let progress: Double
    
    public init(currentStep: AssemblyStep, progress: Double) {
        self.currentStep = currentStep
        self.progress = progress
    }
    
    public var body: some View {
        VStack(spacing: 8) {
            // Progress bar
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
            
            // Step indicator
            HStack {
                ForEach(AssemblyStep.allCases, id: \.self) { step in
                    StepIndicator(
                        step: step,
                        isCurrent: step == currentStep,
                        isCompleted: step.rawValue < currentStep.rawValue
                    )
                    
                    if step != AssemblyStep.allCases.last {
                        Rectangle()
                            .fill(Color.secondary.opacity(0.3))
                            .frame(height: 1)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            
            // Current step title
            Text(currentStep.title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

public struct StepIndicator: View {
    let step: AssemblyStep
    let isCurrent: Bool
    let isCompleted: Bool
    
    public init(step: AssemblyStep, isCurrent: Bool, isCompleted: Bool) {
        self.step = step
        self.isCurrent = isCurrent
        self.isCompleted = isCompleted
    }
    
    public var body: some View {
        ZStack {
            Circle()
                .fill(backgroundColor)
                .frame(width: 24, height: 24)
            
            if isCompleted {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            } else {
                Text("\(step.rawValue + 1)")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(textColor)
            }
        }
    }
    
    private var backgroundColor: Color {
        if isCompleted {
            return .green
        } else if isCurrent {
            return .blue
        } else {
            return Color(.systemGray4)
        }
    }
    
    private var textColor: Color {
        if isCurrent {
            return .white
        } else {
            return Color(.systemGray)
        }
    }
}

// MARK: - Action Bar Components

public struct AssemblyActionBar: View {
    let currentStep: AssemblyStep
    let canProceed: Bool
    let isLastStep: Bool
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onFinish: () -> Void
    
    public init(
        currentStep: AssemblyStep,
        canProceed: Bool,
        isLastStep: Bool,
        onPrevious: @escaping () -> Void,
        onNext: @escaping () -> Void,
        onFinish: @escaping () -> Void
    ) {
        self.currentStep = currentStep
        self.canProceed = canProceed
        self.isLastStep = isLastStep
        self.onPrevious = onPrevious
        self.onNext = onNext
        self.onFinish = onFinish
    }
    
    public var body: some View {
        HStack {
            // Previous button
            if currentStep != .itemSelection {
                Button("Previous") {
                    onPrevious()
                }
                .foregroundColor(.blue)
            } else {
                Spacer()
            }
            
            Spacer()
            
            // Next/Finish button
            if isLastStep {
                Button("Finish") {
                    onFinish()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canProceed)
            } else {
                Button("Next") {
                    onNext()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canProceed)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .fill(Color(.separator))
                .frame(height: 0.5),
            alignment: .top
        )
    }
}

// MARK: - Summary Components

public struct SelectionSummaryCard: View {
    let selectedItemCount: Int
    let totalValue: Decimal
    let scenario: ClaimScenario
    
    public init(selectedItemCount: Int, totalValue: Decimal, scenario: ClaimScenario) {
        self.selectedItemCount = selectedItemCount
        self.totalValue = totalValue
        self.scenario = scenario
    }
    
    public var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Label("Selection Summary", systemImage: "list.bullet.clipboard")
                    .font(.headline)
                    .foregroundColor(.blue)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Items Selected")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(selectedItemCount)")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Total Value")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(totalValue, format: .currency(code: "USD"))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                }
                
                if !scenario.description.isEmpty {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Claim Scenario")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(scenario.type.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Modal Views

public struct ClaimScenarioSetupView: View {
    @Binding var scenario: ClaimScenario
    @Environment(\.dismiss) private var dismiss
    
    public init(scenario: Binding<ClaimScenario>) {
        self._scenario = scenario
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section("Claim Details") {
                    Picker("Claim Type", selection: $scenario.type) {
                        ForEach(ClaimType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    
                    DatePicker("Incident Date", selection: $scenario.incidentDate)
                }
                
                Section("Incident Description") {
                    TextEditor(text: $scenario.description)
                        .frame(minHeight: 120)
                } footer: {
                    Text("Provide a detailed description of what happened and how it affected your items.")
                }
                
                Section("Additional Information") {
                    TextField("Police Report Number", text: $scenario.policeReportNumber)
                    TextField("Insurance Adjuster", text: $scenario.insuranceAdjuster)
                    TextField("Reference Number", text: $scenario.referenceNumber)
                }
            }
            .navigationTitle("Claim Scenario")
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
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

public struct ClaimPackageOptionsView: View {
    @Binding var options: ClaimPackageOptions
    @Environment(\.dismiss) private var dismiss
    
    public init(options: Binding<ClaimPackageOptions>) {
        self._options = options
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section("Documentation Level") {
                    Picker("Detail Level", selection: $options.documentationLevel) {
                        ForEach(DocumentationLevel.allCases, id: \.self) { level in
                            VStack(alignment: .leading) {
                                Text(level.displayName)
                                Text(level.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .tag(level)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }
                
                Section("Media Inclusion") {
                    Toggle("Include Item Photos", isOn: $options.includePhotos)
                    Toggle("Include Damage Photos", isOn: $options.includeDamagePhotos)
                    Toggle("Include Receipt Images", isOn: $options.includeReceipts)
                    Toggle("Include Warranty Documents", isOn: $options.includeWarranties)
                }
                
                Section("Export Formats") {
                    Picker("Primary Format", selection: $options.primaryFormat) {
                        ForEach(ExportFormat.allCases, id: \.self) { format in
                            Label(format.displayName, systemImage: format.icon)
                                .tag(format)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    
                    Toggle("Generate PDF Backup", isOn: $options.includePDFBackup)
                    Toggle("Generate CSV Inventory", isOn: $options.includeCSVInventory)
                }
                
                Section("Organization") {
                    Toggle("Group by Category", isOn: $options.groupByCategory)
                    Toggle("Sort by Value", isOn: $options.sortByValue)
                    Toggle("Include Item Indexes", isOn: $options.includeItemIndexes)
                }
            }
            .navigationTitle("Package Options")
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
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Extensions for Display Names

extension ClaimType {
    var displayName: String {
        switch self {
        case .fire: "Fire Damage"
        case .water: "Water Damage"
        case .theft: "Theft"
        case .burglary: "Burglary"
        case .vandalism: "Vandalism"
        case .naturalDisaster: "Natural Disaster"
        case .accident: "Accidental Damage"
        case .windStorm: "Wind/Storm Damage"
        case .generalLoss: "General Loss"
        }
    }
}

extension ClaimScope {
    var displayName: String {
        switch self {
        case .singleItem: "Single Item"
        case .multipleItems: "Multiple Items"
        case .roomBased: "Room/Area Based"
        case .theft: "Theft"
        case .totalLoss: "Total Loss"
        }
    }
}

extension DocumentationLevel {
    var displayName: String {
        switch self {
        case .basic: "Basic"
        case .detailed: "Detailed"
        case .comprehensive: "Comprehensive"
        }
    }
    
    var description: String {
        switch self {
        case .basic: "Essential information only"
        case .detailed: "Includes photos and descriptions"
        case .comprehensive: "Full documentation with all media"
        }
    }
}

extension ExportFormat {
    var displayName: String {
        switch self {
        case .pdf: "PDF Document"
        case .html: "HTML Package"
        case .spreadsheet: "Excel Spreadsheet"
        }
    }
    
    var icon: String {
        switch self {
        case .pdf: "doc.text"
        case .html: "globe"
        case .spreadsheet: "tablecells"
        }
    }
}