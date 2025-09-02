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
    
    private let assemblerService: any ClaimPackageAssemblerService
    private let contentGenerator: ClaimContentGenerator
    private let documentProcessor: ClaimDocumentProcessor
    private let packageCore: ClaimPackageCore
    private let packageExporter: ClaimPackageExporter
    
    // Public access to dependencies for view layer
    public var assemblyService: any ClaimPackageAssemblerService {
        assemblerService
    }
    
    public var claimContentGenerator: ClaimContentGenerator {
        contentGenerator
    }
    
    public var claimDocumentProcessor: ClaimDocumentProcessor {
        documentProcessor
    }
    
    public var claimPackageCore: ClaimPackageCore {
        packageCore
    }
    
    public var claimPackageExporter: ClaimPackageExporter {
        packageExporter
    }
    
    // MARK: - Initialization
    
    public init(assemblerService: any ClaimPackageAssemblerService = LiveClaimPackageAssemblerService()) {
        self.assemblerService = assemblerService
        self.contentGenerator = ClaimContentGenerator()
        self.documentProcessor = ClaimDocumentProcessor()
        self.packageCore = ClaimPackageCore()
        self.packageExporter = ClaimPackageExporter()
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
    
    public func generateCoverLetter(for items: [Item]) async throws -> ClaimCoverLetter {
        return try await contentGenerator.generateCoverLetter(
            scenario: claimScenario,
            items: items,
            options: packageOptions
        )
    }
    
    public func collectDocumentation(for items: [Item]) async throws -> [ItemDocumentation] {
        return try await documentProcessor.collectDocumentation(
            items: items,
            options: packageOptions
        )
    }
    
    public func exportPackage() {
        showingExportOptions = true
    }
    
    // MARK: - Package Export Actions
    
    public func exportAsZIP() async {
        guard let package = generatedPackage else { return }
        
        Task {
            do {
                let zipURL = try await packageExporter.exportAsZIP(package: package)
                await MainActor.run {
                    // Share the ZIP file using UIActivityViewController
                    shareFile(at: zipURL)
                }
            } catch {
                await MainActor.run {
                    self.errorAlert = ErrorAlert(message: "Export failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    public func exportAsPDF() async {
        guard let package = generatedPackage else { return }
        
        Task {
            do {
                let pdfURL = try await packageExporter.exportAsPDF(package: package)
                await MainActor.run {
                    // Share the PDF file using UIActivityViewController
                    shareFile(at: pdfURL)
                }
            } catch {
                await MainActor.run {
                    self.errorAlert = ErrorAlert(message: "PDF export failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    public func prepareForEmail() async {
        guard let package = generatedPackage else { return }
        
        Task {
            do {
                let emailPackage = try await packageExporter.prepareForEmail(package: package)
                await MainActor.run {
                    // Open email composition with prepared package
                    openEmailComposer(with: emailPackage)
                }
            } catch {
                await MainActor.run {
                    self.errorAlert = ErrorAlert(message: "Email preparation failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func shareFile(at url: URL) {
        // This would trigger UIActivityViewController in the UI layer
        // For now, we'll store the URL for the UI to handle
        // The UI layer will implement the actual sharing
        print("Ready to share file at: \(url)")
    }
    
    private func openEmailComposer(with emailPackage: EmailPackage) {
        // This would trigger MFMailComposeViewController in the UI layer
        // For now, we'll store the email package for the UI to handle
        print("Ready to compose email with package: \(emailPackage.subject)")
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

public struct ClaimPackageRequest: Sendable {
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