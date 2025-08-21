//
// Layer: App-Main
// Module: ClaimPackageAssembly
// Purpose: Core state management and business logic for claim package assembly workflow
//

import SwiftUI
import SwiftData

@MainActor
public final class ClaimPackageAssemblyCore: ObservableObject {
    // MARK: - Published State
    
    @Published public var selectedItems: Set<UUID> = []
    @Published public var claimScenario = ClaimScenario(
        type: .multipleItems,
        incidentDate: Date(),
        description: ""
    )
    @Published public var packageOptions = ClaimPackageOptions()
    @Published public var currentStep: AssemblyStep = .itemSelection
    @Published public var generatedPackage: ClaimPackage?
    @Published public var errorAlert: ErrorAlert?
    
    // Sheet state
    @Published public var showingScenarioSetup = false
    @Published public var showingOptionsSetup = false
    @Published public var showingValidation = false
    @Published public var showingExportOptions = false
    
    // MARK: - Dependencies
    
    private let assemblerService: ClaimPackageAssemblerService
    
    // Public access to dependencies for view layer
    public var assemblyService: ClaimPackageAssemblerService {
        assemblerService
    }
    
    // MARK: - Initialization
    
    public init(assemblerService: ClaimPackageAssemblerService = LiveClaimPackageAssemblerService()) {
        self.assemblerService = assemblerService
    }
    
    // MARK: - Computed Properties
    
    public func selectedItemsList(from allItems: [Item]) -> [Item] {
        allItems.filter { selectedItems.contains($0.id) }
    }
    
    public func totalSelectedValue(from allItems: [Item]) -> Decimal {
        selectedItemsList(from: allItems).compactMap(\.purchasePrice).reduce(0, +)
    }
    
    public var canProceed: Bool {
        switch currentStep {
        case .itemSelection:
            !selectedItems.isEmpty
        case .scenarioSetup:
            !claimScenario.description.isEmpty
        case .packageOptions:
            true // Options are always valid with defaults
        case .validation:
            true // Validation is informational
        case .assembly:
            generatedPackage != nil
        case .export:
            true
        }
    }
    
    public var isLastStep: Bool {
        currentStep == AssemblyStep.allCases.last
    }
    
    public var progress: Double {
        currentStep.progress
    }
    
    // MARK: - Actions
    
    public func toggleItemSelection(_ itemId: UUID) {
        if selectedItems.contains(itemId) {
            selectedItems.remove(itemId)
        } else {
            selectedItems.insert(itemId)
        }
    }
    
    public func selectAllItems(from allItems: [Item]) {
        selectedItems = Set(allItems.map(\.id))
    }
    
    public func clearAllSelections() {
        selectedItems.removeAll()
    }
    
    public func nextStep() {
        guard let currentIndex = AssemblyStep.allCases.firstIndex(of: currentStep),
              currentIndex < AssemblyStep.allCases.count - 1 else { return }
        
        currentStep = AssemblyStep.allCases[currentIndex + 1]
        
        // Trigger appropriate actions for new step
        switch currentStep {
        case .validation:
            performValidation()
        case .assembly:
            startAssembly()
        default:
            break
        }
    }
    
    public func previousStep() {
        guard let currentIndex = AssemblyStep.allCases.firstIndex(of: currentStep),
              currentIndex > 0 else { return }
        
        currentStep = AssemblyStep.allCases[currentIndex - 1]
    }
    
    public func goToStep(_ step: AssemblyStep) {
        currentStep = step
    }
    
    // MARK: - Business Logic
    
    public func performValidation() {
        // Validation logic would go here
        // For now, we'll simulate validation
    }
    
    public func startAssembly() {
        Task {
            do {
                let packageRequest = ClaimPackageRequest(
                    selectedItemIds: Array(selectedItems),
                    scenario: claimScenario,
                    options: packageOptions
                )
                
                let package = try await assemblerService.assemblePackage(request: packageRequest)
                
                await MainActor.run {
                    self.generatedPackage = package
                }
            } catch {
                await MainActor.run {
                    self.errorAlert = ErrorAlert(message: error.localizedDescription)
                }
            }
        }
    }
    
    public func exportPackage() {
        showingExportOptions = true
    }
    
    public func resetAssembly() {
        selectedItems.removeAll()
        claimScenario = ClaimScenario(
            type: .multipleItems,
            incidentDate: Date(),
            description: ""
        )
        packageOptions = ClaimPackageOptions()
        currentStep = .itemSelection
        generatedPackage = nil
        errorAlert = nil
    }
}

// MARK: - Supporting Types

public struct ClaimPackageRequest {
    public let selectedItemIds: [UUID]
    public let scenario: ClaimScenario
    public let options: ClaimPackageOptions
    
    public init(selectedItemIds: [UUID], scenario: ClaimScenario, options: ClaimPackageOptions) {
        self.selectedItemIds = selectedItemIds
        self.scenario = scenario
        self.options = options
    }
}

public enum AssemblyStep: Int, CaseIterable {
    case itemSelection = 0
    case scenarioSetup = 1
    case packageOptions = 2
    case validation = 3
    case assembly = 4
    case export = 5

    public var title: String {
        switch self {
        case .itemSelection: "Select Items"
        case .scenarioSetup: "Scenario"
        case .packageOptions: "Options"
        case .validation: "Validation"
        case .assembly: "Assembly"
        case .export: "Export"
        }
    }

    public var progress: Double {
        Double(rawValue) / Double(AssemblyStep.allCases.count - 1)
    }
}

public struct ErrorAlert {
    public let message: String
    
    public init(message: String) {
        self.message = message
    }
}