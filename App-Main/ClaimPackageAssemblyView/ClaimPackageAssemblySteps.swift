//
// Layer: App-Main
// Module: ClaimPackageAssembly
// Purpose: Step-specific views for the claim package assembly workflow
//

import SwiftUI
import SwiftData

// MARK: - Item Selection Step

public struct ItemSelectionStepView: View {
    let allItems: [Item]
    let selectedItems: Set<UUID>
    let onToggleItem: (UUID) -> Void
    let onSelectAll: () -> Void
    let onClearAll: () -> Void
    
    public init(
        allItems: [Item],
        selectedItems: Set<UUID>,
        onToggleItem: @escaping (UUID) -> Void,
        onSelectAll: @escaping () -> Void,
        onClearAll: @escaping () -> Void
    ) {
        self.allItems = allItems
        self.selectedItems = selectedItems
        self.onToggleItem = onToggleItem
        self.onSelectAll = onSelectAll
        self.onClearAll = onClearAll
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Selection controls
            HStack {
                Text("\(selectedItems.count) of \(allItems.count) selected")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button("All", action: onSelectAll)
                    .font(.caption)
                
                Button("None", action: onClearAll)
                    .font(.caption)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            
            // Items list
            List {
                ForEach(allItems) { item in
                    ClaimItemRow(
                        item: item,
                        isSelected: selectedItems.contains(item.id),
                        onToggle: { onToggleItem(item.id) }
                    )
                }
            }
            .listStyle(.plain)
        }
    }
}

// MARK: - Scenario Setup Step

public struct ScenarioSetupStepView: View {
    @Binding var scenario: ClaimScenario
    let selectedItemCount: Int
    let onAdvancedSetup: () -> Void
    
    public init(
        scenario: Binding<ClaimScenario>,
        selectedItemCount: Int,
        onAdvancedSetup: @escaping () -> Void
    ) {
        self._scenario = scenario
        self.selectedItemCount = selectedItemCount
        self.onAdvancedSetup = onAdvancedSetup
    }
    
    public var body: some View {
        Form {
            Section("Claim Type") {
                Picker("Type", selection: $scenario.type) {
                    ForEach(ClaimType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            Section("Incident Details", content: {
                DatePicker("Incident Date", selection: $scenario.incidentDate, displayedComponents: .date)
                
                TextEditor(text: $scenario.description)
                    .frame(minHeight: 80)
            }) {
                Text("Describe what happened and how the items were affected.")
            }
            
            Section("Quick Stats") {
                HStack {
                    Text("Selected Items")
                    Spacer()
                    Text("\(selectedItemCount)")
                        .foregroundColor(.secondary)
                }
            }
            
            Section {
                Button("Advanced Scenario Setup") {
                    onAdvancedSetup()
                }
            }
        }
    }
}

// MARK: - Package Options Step

public struct PackageOptionsStepView: View {
    @Binding var options: ClaimPackageOptions
    let onAdvancedOptions: () -> Void
    
    public init(
        options: Binding<ClaimPackageOptions>,
        onAdvancedOptions: @escaping () -> Void
    ) {
        self._options = options
        self.onAdvancedOptions = onAdvancedOptions
    }
    
    public var body: some View {
        Form {
            Section("Documentation Level", content: {
                Picker("Level", selection: $options.documentationLevel) {
                    Text("Basic").tag(DocumentationLevel.basic)
                    Text("Detailed").tag(DocumentationLevel.detailed)
                    Text("Comprehensive").tag(DocumentationLevel.comprehensive)
                }
                .pickerStyle(.segmented)
            }) {
                Text("Choose how much detail to include in the package.")
            }
            
            Section("Include Photos") {
                Toggle("Item Photos", isOn: $options.includePhotos)
                Toggle("Damage Photos", isOn: $options.includeDamagePhotos)
                Toggle("Receipts", isOn: $options.includeReceipts)
            }
            
            Section("Export Format") {
                Picker("Primary Format", selection: $options.primaryFormat) {
                    Text("PDF").tag(ExportFormat.pdf)
                    Text("HTML").tag(ExportFormat.html)
                    Text("Spreadsheet").tag(ExportFormat.spreadsheet)
                }
            }
            
            Section {
                Button("Advanced Package Options") {
                    onAdvancedOptions()
                }
            }
        }
    }
}

// MARK: - Validation Step

public struct ValidationStepView: View {
    let selectedItems: [Item]
    let scenario: ClaimScenario
    let options: ClaimPackageOptions
    
    public init(
        selectedItems: [Item],
        scenario: ClaimScenario,
        options: ClaimPackageOptions
    ) {
        self.selectedItems = selectedItems
        self.scenario = scenario
        self.options = options
    }
    
    public var body: some View {
        Form {
            Section("Package Summary") {
                HStack {
                    Text("Items")
                    Spacer()
                    Text("\(selectedItems.count)")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Total Value")
                    Spacer()
                    Text(totalValue, format: .currency(code: "USD"))
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Claim Type")
                    Spacer()
                    Text(scenario.type.rawValue)
                        .foregroundColor(.secondary)
                }
            }
            
            Section("Validation Checks") {
                ValidationCheckRow(
                    title: "Items Selected",
                    isValid: !selectedItems.isEmpty,
                    detail: "\(selectedItems.count) items"
                )
                
                ValidationCheckRow(
                    title: "Incident Description",
                    isValid: !scenario.description.isEmpty,
                    detail: scenario.description.isEmpty ? "Missing" : "Provided"
                )
                
                ValidationCheckRow(
                    title: "Item Photos",
                    isValid: hasPhotos,
                    detail: photoStatus
                )
                
                ValidationCheckRow(
                    title: "Purchase Information",
                    isValid: hasPurchaseInfo,
                    detail: purchaseInfoStatus
                )
            }
            
            if !warnings.isEmpty {
                Section("Warnings") {
                    ForEach(warnings, id: \.self) { warning in
                        Label(warning, systemImage: "exclamationmark.triangle")
                            .foregroundColor(.orange)
                    }
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var totalValue: Decimal {
        selectedItems.compactMap(\.purchasePrice).reduce(0, +)
    }
    
    private var hasPhotos: Bool {
        selectedItems.contains { item in
            !(item.photos?.isEmpty ?? true)
        }
    }
    
    private var photoStatus: String {
        let itemsWithPhotos = selectedItems.filter { !(item.photos?.isEmpty ?? true) }.count
        return "\(itemsWithPhotos)/\(selectedItems.count) items have photos"
    }
    
    private var hasPurchaseInfo: Bool {
        selectedItems.contains { $0.purchasePrice != nil }
    }
    
    private var purchaseInfoStatus: String {
        let itemsWithPrices = selectedItems.filter { $0.purchasePrice != nil }.count
        return "\(itemsWithPrices)/\(selectedItems.count) items have prices"
    }
    
    private var warnings: [String] {
        var warnings: [String] = []
        
        if selectedItems.filter({ $0.purchasePrice == nil }).count > 0 {
            warnings.append("Some items are missing purchase prices")
        }
        
        if selectedItems.filter({ $0.photos?.isEmpty ?? true }).count > 0 {
            warnings.append("Some items don't have photos")
        }
        
        if scenario.description.count < 50 {
            warnings.append("Incident description could be more detailed")
        }
        
        return warnings
    }
}

// MARK: - Assembly Step

public struct AssemblyStepView: View {
    let assemblyService: ClaimPackageAssemblerService
    let generatedPackage: ClaimPackage?
    let errorAlert: ErrorAlert?
    
    public init(
        assemblyService: ClaimPackageAssemblerService,
        generatedPackage: ClaimPackage?,
        errorAlert: ErrorAlert?
    ) {
        self.assemblyService = assemblyService
        self.generatedPackage = generatedPackage
        self.errorAlert = errorAlert
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            if let package = generatedPackage {
                // Package successfully generated
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("Package Assembled Successfully")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Package ID:")
                            Spacer()
                            Text(String(package.id.uuidString.prefix(8)))
                                .font(.monospaced(.body)())
                        }
                        
                        HStack {
                            Text("Items Included:")
                            Spacer()
                            Text("\(package.itemCount)")
                        }
                        
                        HStack {
                            Text("Total Value:")
                            Spacer()
                            Text(package.totalValue, format: .currency(code: "USD"))
                        }
                        
                        HStack {
                            Text("Files Generated:")
                            Spacer()
                            Text("\(package.fileCount)")
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            } else if let error = errorAlert {
                // Assembly failed
                VStack(spacing: 16) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.red)
                    
                    Text("Assembly Failed")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(error.message)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
            } else {
                // Assembly in progress
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                    
                    Text("Assembling Package...")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("This may take a moment while we process your items and generate documentation.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
    }
}

// MARK: - Export Step

public struct ExportStepView: View {
    let generatedPackage: ClaimPackage?
    let onExportAction: () -> Void
    
    public init(
        generatedPackage: ClaimPackage?,
        onExportAction: @escaping () -> Void
    ) {
        self.generatedPackage = generatedPackage
        self.onExportAction = onExportAction
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            if let package = generatedPackage {
                VStack(spacing: 16) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Ready to Export")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Your claim package is ready to share with your insurance company.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    
                    Button("Export Package") {
                        onExportAction()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
            } else {
                Text("No package available for export")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}

// MARK: - Supporting Views

public struct ClaimItemRow: View {
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
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.body)
                
                HStack {
                    if let category = item.category {
                        Text(category.name)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
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
        .contentShape(Rectangle())
        .onTapGesture {
            onToggle()
        }
    }
}

public struct ValidationCheckRow: View {
    let title: String
    let isValid: Bool
    let detail: String
    
    public init(title: String, isValid: Bool, detail: String) {
        self.title = title
        self.isValid = isValid
        self.detail = detail
    }
    
    public var body: some View {
        HStack {
            Image(systemName: isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isValid ? .green : .red)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                
                Text(detail)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}