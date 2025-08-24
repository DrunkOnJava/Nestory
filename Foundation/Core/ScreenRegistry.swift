//
// Layer: Foundation
// Module: Core
// Purpose: Enumerable screen registry for deterministic navigation
//

import Foundation

/// Complete registry of all navigable screens in Nestory
public enum ScreenRoute: String, CaseIterable {
    // MARK: - Tab Bar Screens
    case inventory = "inventory"
    case search = "search"
    case capture = "capture"
    case analytics = "analytics"
    case settings = "settings"
    
    // MARK: - Inventory Flows
    case itemDetail = "item_detail"
    case itemEdit = "item_edit"
    case addItem = "add_item"
    case categoryPicker = "category_picker"
    case roomPicker = "room_picker"
    
    // MARK: - Search Flows
    case searchResults = "search_results"
    case searchFilters = "search_filters"
    case advancedSearch = "advanced_search"
    
    // MARK: - Capture Flows
    case cameraCapture = "camera_capture"
    case photoLibrary = "photo_library"
    case receiptScanner = "receipt_scanner"
    case barcodeScanner = "barcode_scanner"
    
    // MARK: - Analytics Flows
    case valueByCategory = "value_by_category"
    case valueByRoom = "value_by_room"
    case warrantyReport = "warranty_report"
    case depreciationReport = "depreciation_report"
    
    // MARK: - Settings Flows
    case importExport = "import_export"
    case csvImport = "csv_import"
    case jsonExport = "json_export"
    case cloudBackup = "cloud_backup"
    case notifications = "notifications"
    case appearance = "appearance"
    case about = "about"
    
    // MARK: - Insurance Flows
    case insuranceReport = "insurance_report"
    case claimSubmission = "claim_submission"
    case claimHistory = "claim_history"
    case damageAssessment = "damage_assessment"
    case emergencyContacts = "emergency_contacts"
    
    // MARK: - Warranty Flows
    case warrantyList = "warranty_list"
    case warrantyDetail = "warranty_detail"
    case addWarranty = "add_warranty"
    case expiringWarranties = "expiring_warranties"
    
    // MARK: - Properties
    
    /// Human-readable name for the screen
    public var displayName: String {
        switch self {
        case .inventory: return "Inventory"
        case .search: return "Search"
        case .capture: return "Capture"
        case .analytics: return "Analytics"
        case .settings: return "Settings"
        case .itemDetail: return "Item Detail"
        case .itemEdit: return "Edit Item"
        case .addItem: return "Add Item"
        case .categoryPicker: return "Category Picker"
        case .roomPicker: return "Room Picker"
        case .searchResults: return "Search Results"
        case .searchFilters: return "Search Filters"
        case .advancedSearch: return "Advanced Search"
        case .cameraCapture: return "Camera Capture"
        case .photoLibrary: return "Photo Library"
        case .receiptScanner: return "Receipt Scanner"
        case .barcodeScanner: return "Barcode Scanner"
        case .valueByCategory: return "Value by Category"
        case .valueByRoom: return "Value by Room"
        case .warrantyReport: return "Warranty Report"
        case .depreciationReport: return "Depreciation Report"
        case .importExport: return "Import/Export"
        case .csvImport: return "CSV Import"
        case .jsonExport: return "JSON Export"
        case .cloudBackup: return "Cloud Backup"
        case .notifications: return "Notifications"
        case .appearance: return "Appearance"
        case .about: return "About"
        case .insuranceReport: return "Insurance Report"
        case .claimSubmission: return "Claim Submission"
        case .claimHistory: return "Claim History"
        case .damageAssessment: return "Damage Assessment"
        case .emergencyContacts: return "Emergency Contacts"
        case .warrantyList: return "Warranty List"
        case .warrantyDetail: return "Warranty Detail"
        case .addWarranty: return "Add Warranty"
        case .expiringWarranties: return "Expiring Warranties"
        }
    }
    
    /// Accessibility identifier for UI testing
    public var accessibilityIdentifier: String {
        "screen_\(rawValue)"
    }
    
    /// Whether this screen requires data to display properly
    public var requiresData: Bool {
        switch self {
        case .itemDetail, .itemEdit, .searchResults, 
             .warrantyDetail, .claimHistory:
            return true
        default:
            return false
        }
    }
    
    /// Tab index if this is a root tab screen
    public var tabIndex: Int? {
        switch self {
        case .inventory: return 0
        case .search: return 1
        case .capture: return 2
        case .analytics: return 3
        case .settings: return 4
        default: return nil
        }
    }
    
    /// Parent route for navigation hierarchy
    public var parentRoute: ScreenRoute? {
        switch self {
        // Inventory children
        case .itemDetail, .itemEdit, .addItem, 
             .categoryPicker, .roomPicker:
            return .inventory
            
        // Search children
        case .searchResults, .searchFilters, .advancedSearch:
            return .search
            
        // Capture children
        case .cameraCapture, .photoLibrary, 
             .receiptScanner, .barcodeScanner:
            return .capture
            
        // Analytics children
        case .valueByCategory, .valueByRoom, 
             .warrantyReport, .depreciationReport:
            return .analytics
            
        // Settings children
        case .importExport, .csvImport, .jsonExport,
             .cloudBackup, .notifications, .appearance, .about:
            return .settings
            
        // Insurance flows (from Settings)
        case .insuranceReport, .claimSubmission, 
             .claimHistory, .damageAssessment, .emergencyContacts:
            return .settings
            
        // Warranty flows (from Settings)
        case .warrantyList, .warrantyDetail, 
             .addWarranty, .expiringWarranties:
            return .settings
            
        // Root tabs have no parent
        default:
            return nil
        }
    }
    
    /// Test data fixture for this screen
    public var testFixture: String? {
        switch self {
        case .itemDetail:
            return "test_item_laptop"
        case .searchResults:
            return "test_search_electronics"
        case .warrantyDetail:
            return "test_warranty_appliance"
        default:
            return nil
        }
    }
}

// MARK: - Screen Groups

extension ScreenRoute {
    /// Logical grouping of screens for test organization
    public enum ScreenGroup: String, CaseIterable {
        case tabs = "Main Tabs"
        case inventory = "Inventory Management"
        case search = "Search & Discovery"
        case capture = "Data Capture"
        case analytics = "Analytics & Reports"
        case settings = "Settings & Config"
        case insurance = "Insurance & Claims"
        case warranty = "Warranty Tracking"
        
        public var routes: [ScreenRoute] {
            switch self {
            case .tabs:
                return [.inventory, .search, .capture, .analytics, .settings]
            case .inventory:
                return [.itemDetail, .itemEdit, .addItem, .categoryPicker, .roomPicker]
            case .search:
                return [.searchResults, .searchFilters, .advancedSearch]
            case .capture:
                return [.cameraCapture, .photoLibrary, .receiptScanner, .barcodeScanner]
            case .analytics:
                return [.valueByCategory, .valueByRoom, .warrantyReport, .depreciationReport]
            case .settings:
                return [.importExport, .csvImport, .jsonExport, .cloudBackup, 
                       .notifications, .appearance, .about]
            case .insurance:
                return [.insuranceReport, .claimSubmission, .claimHistory, 
                       .damageAssessment, .emergencyContacts]
            case .warranty:
                return [.warrantyList, .warrantyDetail, .addWarranty, .expiringWarranties]
            }
        }
    }
}

// MARK: - Navigation Metadata

extension ScreenRoute {
    /// Navigation requirements for reaching this screen
    public struct NavigationRequirements {
        public let requiresAuth: Bool
        public let requiresPermissions: [Permission]
        public let requiredFeatureFlags: [String]
        public let minimumDataCount: Int
        
        public enum Permission: String {
            case camera
            case photoLibrary
            case notifications
            case location
        }
    }
    
    public var navigationRequirements: NavigationRequirements {
        switch self {
        case .cameraCapture:
            return NavigationRequirements(
                requiresAuth: false,
                requiresPermissions: [.camera],
                requiredFeatureFlags: [],
                minimumDataCount: 0
            )
        case .photoLibrary:
            return NavigationRequirements(
                requiresAuth: false,
                requiresPermissions: [.photoLibrary],
                requiredFeatureFlags: [],
                minimumDataCount: 0
            )
        case .notifications:
            return NavigationRequirements(
                requiresAuth: false,
                requiresPermissions: [.notifications],
                requiredFeatureFlags: [],
                minimumDataCount: 0
            )
        default:
            return NavigationRequirements(
                requiresAuth: false,
                requiresPermissions: [],
                requiredFeatureFlags: [],
                minimumDataCount: 0
            )
        }
    }
}