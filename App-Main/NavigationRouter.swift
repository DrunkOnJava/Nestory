//
// Layer: App
// Module: Main
// Purpose: Deterministic navigation router for UI testing
//

import SwiftUI
import ComposableArchitecture

/// Navigation router for deterministic screen access
public struct NavigationRouter {
    
    // MARK: - Properties
    
    private let store: StoreOf<RootFeature>
    
    // MARK: - Initialization
    
    public init(store: StoreOf<RootFeature>) {
        self.store = store
    }
    
    // MARK: - Navigation
    
    /// Navigate directly to a specific screen route
    @MainActor
    public func navigate(to route: ScreenRoute) async {
        UITestMode.log("Navigating to: \(route.displayName)")
        
        // For tab-level navigation
        if let tabIndex = route.tabIndex {
            await navigateToTab(at: tabIndex)
            return
        }
        
        // For sub-screens, navigate to parent tab first
        if let parentRoute = route.parentRoute,
           let parentTabIndex = parentRoute.tabIndex {
            await navigateToTab(at: parentTabIndex)
            // Wait for tab to load
            try? await Task.sleep(nanoseconds: 500_000_000)
        }
        
        // Then navigate to the specific screen
        switch route {
        case .inventory, .search, .capture, .analytics, .settings:
            // Already at tab level
            break
            
        // Inventory flows
        case .itemDetail:
            await navigateToItemDetail()
        case .itemEdit:
            await navigateToItemEdit()
        case .addItem:
            await navigateToAddItem()
        case .categoryPicker:
            await navigateToCategoryPicker()
        case .roomPicker:
            await navigateToRoomPicker()
            
        // Search flows
        case .searchResults:
            await navigateToSearchResults()
        case .searchFilters:
            await navigateToSearchFilters()
        case .advancedSearch:
            await navigateToAdvancedSearch()
            
        // Settings flows
        case .importExport:
            await navigateToImportExport()
        case .csvImport:
            await navigateToCSVImport()
        case .jsonExport:
            await navigateToJSONExport()
        case .cloudBackup:
            await navigateToCloudBackup()
        case .notifications:
            await navigateToNotifications()
        case .appearance:
            await navigateToAppearance()
        case .about:
            await navigateToAbout()
            
        // Insurance flows
        case .insuranceReport:
            await navigateToInsuranceReport()
        case .claimSubmission:
            await navigateToClaimSubmission()
        case .claimHistory:
            await navigateToClaimHistory()
        case .damageAssessment:
            await navigateToDamageAssessment()
        case .emergencyContacts:
            await navigateToEmergencyContacts()
            
        // Warranty flows
        case .warrantyList:
            await navigateToWarrantyList()
        case .warrantyDetail:
            await navigateToWarrantyDetail()
        case .addWarranty:
            await navigateToAddWarranty()
        case .expiringWarranties:
            await navigateToExpiringWarranties()
            
        default:
            UITestMode.log("Route not yet implemented: \(route)")
        }
    }
    
    // MARK: - Tab Navigation
    
    @MainActor
    private func navigateToTab(at index: Int) async {
        let tabs = RootFeature.State.Tab.allCases
        guard index < tabs.count else { return }
        let tab = tabs[tabs.index(tabs.startIndex, offsetBy: index)]
        store.send(.tabSelected(tab))
        // Wait for animation
        try? await Task.sleep(nanoseconds: 200_000_000)
    }
    
    // MARK: - Inventory Navigation
    
    @MainActor
    private func navigateToItemDetail() async {
        // Navigate to inventory tab first
        await navigateToTab(at: 0)
        
        // If using test fixtures, select first item from current state
        if UITestMode.useTestFixtures {
            // Note: Item selection would need to be handled differently in TCA
            // The actual navigation would be triggered by the UI, not programmatically
            UITestMode.log("Item detail navigation should be triggered via UI interaction")
        }
        
        try? await Task.sleep(nanoseconds: 200_000_000)
    }
    
    @MainActor
    private func navigateToItemEdit() async {
        await navigateToItemDetail()
        // TODO: Add editItemTapped action to InventoryFeature
        // store.send(.inventory(.editItemTapped))
        try? await Task.sleep(nanoseconds: 200_000_000)
    }
    
    @MainActor
    private func navigateToAddItem() async {
        await navigateToTab(at: 0)
        store.send(.inventory(.itemOperation(.addItemTapped)))
        try? await Task.sleep(nanoseconds: 200_000_000)
    }
    
    @MainActor
    private func navigateToCategoryPicker() async {
        await navigateToAddItem()
        // TODO: Add categoryPickerTapped action to InventoryFeature
        // store.send(.inventory(.categoryPickerTapped))
        try? await Task.sleep(nanoseconds: 200_000_000)
    }
    
    @MainActor
    private func navigateToRoomPicker() async {
        await navigateToAddItem()
        // TODO: Add roomPickerTapped action to InventoryFeature
        // store.send(.inventory(.roomPickerTapped))
        try? await Task.sleep(nanoseconds: 200_000_000)
    }
    
    // MARK: - Search Navigation
    
    @MainActor
    private func navigateToSearchResults() async {
        await navigateToTab(at: 1)
        
        if UITestMode.useTestFixtures {
            store.send(.search(.searchTextChanged("MacBook")))
            // TODO: Add searchSubmitted action to SearchFeature
            // store.send(.search(.searchSubmitted))
        }
        
        try? await Task.sleep(nanoseconds: 200_000_000)
    }
    
    @MainActor
    private func navigateToSearchFilters() async {
        await navigateToTab(at: 1)
        // TODO: Add filtersTapped action to SearchFeature
        // store.send(.search(.filtersTapped))
        try? await Task.sleep(nanoseconds: 200_000_000)
    }
    
    @MainActor
    private func navigateToAdvancedSearch() async {
        await navigateToSearchFilters()
        // TODO: Add advancedSearchTapped action to SearchFeature
        // store.send(.search(.advancedSearchTapped))
        try? await Task.sleep(nanoseconds: 200_000_000)
    }
    
    // MARK: - Settings Navigation
    
    @MainActor
    private func navigateToImportExport() async {
        await navigateToTab(at: 4)
        // TODO: Add importExportTapped action to SettingsFeature
        // store.send(.settings(.importExportTapped))
        try? await Task.sleep(nanoseconds: 200_000_000)
    }
    
    @MainActor
    private func navigateToCSVImport() async {
        await navigateToImportExport()
        // TODO: Add csvImportTapped action to SettingsFeature
        // store.send(.settings(.csvImportTapped))
        try? await Task.sleep(nanoseconds: 200_000_000)
    }
    
    @MainActor
    private func navigateToJSONExport() async {
        await navigateToImportExport()
        // TODO: Add jsonExportTapped action to SettingsFeature
        // store.send(.settings(.jsonExportTapped))
        try? await Task.sleep(nanoseconds: 200_000_000)
    }
    
    @MainActor
    private func navigateToCloudBackup() async {
        await navigateToTab(at: 4)
        // TODO: Add cloudBackupTapped action to SettingsFeature
        // store.send(.settings(.cloudBackupTapped))
        try? await Task.sleep(nanoseconds: 200_000_000)
    }
    
    @MainActor
    private func navigateToNotifications() async {
        await navigateToTab(at: 4)
        // TODO: Add notificationsTapped action to SettingsFeature
        // store.send(.settings(.notificationsTapped))
        try? await Task.sleep(nanoseconds: 200_000_000)
    }
    
    @MainActor
    private func navigateToAppearance() async {
        await navigateToTab(at: 4)
        // TODO: Add appearanceTapped action to SettingsFeature
        // store.send(.settings(.appearanceTapped))
        try? await Task.sleep(nanoseconds: 200_000_000)
    }
    
    @MainActor
    private func navigateToAbout() async {
        await navigateToTab(at: 4)
        // TODO: Add aboutTapped action to SettingsFeature
        // store.send(.settings(.aboutTapped))
        try? await Task.sleep(nanoseconds: 200_000_000)
    }
    
    // MARK: - Insurance Navigation
    
    @MainActor
    private func navigateToInsuranceReport() async {
        await navigateToTab(at: 4)
        // TODO: Add insuranceReportTapped action to SettingsFeature
        // store.send(.settings(.insuranceReportTapped))
        try? await Task.sleep(nanoseconds: 200_000_000)
    }
    
    @MainActor
    private func navigateToClaimSubmission() async {
        await navigateToTab(at: 4)
        // TODO: Add claimSubmissionTapped action to SettingsFeature
        // store.send(.settings(.claimSubmissionTapped))
        try? await Task.sleep(nanoseconds: 200_000_000)
    }
    
    @MainActor
    private func navigateToClaimHistory() async {
        await navigateToTab(at: 4)
        // TODO: Add claimHistoryTapped action to SettingsFeature
        // store.send(.settings(.claimHistoryTapped))
        try? await Task.sleep(nanoseconds: 200_000_000)
    }
    
    @MainActor
    private func navigateToDamageAssessment() async {
        await navigateToTab(at: 4)
        // TODO: Add damageAssessmentTapped action to SettingsFeature
        // store.send(.settings(.damageAssessmentTapped))
        try? await Task.sleep(nanoseconds: 200_000_000)
    }
    
    @MainActor
    private func navigateToEmergencyContacts() async {
        await navigateToTab(at: 4)
        // TODO: Add emergencyContactsTapped action to SettingsFeature
        // store.send(.settings(.emergencyContactsTapped))
        try? await Task.sleep(nanoseconds: 200_000_000)
    }
    
    // MARK: - Warranty Navigation
    
    @MainActor
    private func navigateToWarrantyList() async {
        await navigateToTab(at: 4)
        // TODO: Add warrantyListTapped action to SettingsFeature
        // store.send(.settings(.warrantyListTapped))
        try? await Task.sleep(nanoseconds: 200_000_000)
    }
    
    @MainActor
    private func navigateToWarrantyDetail() async {
        await navigateToWarrantyList()
        
        if UITestMode.useTestFixtures {
            // TODO: Add warrantyTapped action to SettingsFeature
            // store.send(.settings(.warrantyTapped("test-warranty-001")))
        }
        
        try? await Task.sleep(nanoseconds: 200_000_000)
    }
    
    @MainActor
    private func navigateToAddWarranty() async {
        await navigateToWarrantyList()
        // TODO: Add addWarrantyTapped action to SettingsFeature
        // store.send(.settings(.addWarrantyTapped))
        try? await Task.sleep(nanoseconds: 200_000_000)
    }
    
    @MainActor
    private func navigateToExpiringWarranties() async {
        await navigateToTab(at: 4)
        // TODO: Add expiringWarrantiesTapped action to SettingsFeature
        // store.send(.settings(.expiringWarrantiesTapped))
        try? await Task.sleep(nanoseconds: 200_000_000)
    }
}

// MARK: - Test Helper

extension NavigationRouter {
    /// Create a router for testing with mock store
    @MainActor
    public static func testRouter() -> NavigationRouter {
        let store = Store(initialState: RootFeature.State()) {
            RootFeature()
        }
        return NavigationRouter(store: store)
    }
}