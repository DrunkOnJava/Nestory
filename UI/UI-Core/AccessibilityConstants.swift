//
// Layer: Foundation
// Module: Core
// Purpose: Standardized accessibility constants and utilities for comprehensive app accessibility
//

import SwiftUI

/// Standardized accessibility constants for consistent app experience
public struct AccessibilityConstants {
    
    // MARK: - Accessibility Identifiers
    
    /// Standard identifiers for UI automation and testing
    public enum Identifiers {
        // Navigation
        public static let backButton = "navigation.back"
        public static let homeTab = "tab.home"
        public static let searchTab = "tab.search" 
        public static let settingsTab = "tab.settings"
        
        // Item Management
        public static let addItemButton = "item.add"
        public static let editItemButton = "item.edit"
        public static let deleteItemButton = "item.delete"
        public static let itemCard = "item.card"
        public static let itemImage = "item.image"
        
        // Search & Filtering
        public static let searchField = "search.field"
        public static let searchClearButton = "search.clear"
        public static let filterButton = "filter.button"
        public static let sortButton = "sort.button"
        
        // Actions
        public static let saveButton = "action.save"
        public static let cancelButton = "action.cancel"
        public static let confirmButton = "action.confirm"
        public static let primaryAction = "action.primary"
        public static let secondaryAction = "action.secondary"
        
        // Forms
        public static let textField = "form.textfield"
        public static let picker = "form.picker"
        public static let datePicker = "form.datepicker"
        public static let toggle = "form.toggle"
        
        // Insurance & Claims
        public static let claimButton = "claim.create"
        public static let exportButton = "export.create"
        public static let reportButton = "report.generate"
    }
    
    // MARK: - Accessibility Labels
    
    /// Standardized accessibility labels for common UI elements
    public enum Labels {
        // Item-specific labels
        public static func itemCard(name: String, category: String?, price: String?) -> String {
            var components = [name]
            if let category = category {
                components.append("Category: \(category)")
            }
            if let price = price {
                components.append("Price: \(price)")
            }
            return components.joined(separator: ", ")
        }
        
        public static func itemStatus(status: String) -> String {
            "Status: \(status)"
        }
        
        // Navigation labels
        public static let backButton = "Go back"
        public static let homeTab = "Home"
        public static let searchTab = "Search items"
        public static let settingsTab = "Settings"
        
        // Action labels
        public static let addItem = "Add new item"
        public static let editItem = "Edit item details"
        public static let deleteItem = "Delete item"
        public static let saveChanges = "Save changes"
        public static let cancelChanges = "Cancel changes"
        
        // Search & filtering
        public static let searchField = "Search items by name, brand, or description"
        public static let clearSearch = "Clear search text"
        public static let openFilters = "Open search filters"
        public static let sortItems = "Sort items"
        
        // Loading states
        public static let loading = "Loading, please wait"
        public static let processingAction = "Processing your request"
        
        // Empty states
        public static let noItems = "No items found"
        public static let noSearchResults = "No search results"
        public static let noClaimsYet = "No insurance claims created yet"
    }
    
    // MARK: - Accessibility Hints
    
    /// Helpful hints for complex interactions
    public enum Hints {
        // Item interactions
        public static let itemCard = "Tap to view item details and options"
        public static let addItem = "Tap to start adding a new item to your inventory"
        public static let editItem = "Tap to modify this item's information"
        public static let deleteItem = "Warning: This will permanently remove the item"
        
        // Navigation hints
        public static let backButton = "Returns to previous screen"
        public static let tabButton = "Switches to this section"
        
        // Search hints
        public static let searchField = "Enter text to search your inventory"
        public static let filterButton = "Tap to show advanced filtering options"
        public static let sortButton = "Tap to change how items are sorted"
        
        // Form hints
        public static let requiredField = "This field is required"
        public static let optionalField = "This field is optional"
        public static let dateField = "Tap to select a date"
        public static let currencyField = "Enter amount in your local currency"
        
        // Actions
        public static let destructiveAction = "This action cannot be undone"
        public static let saveAction = "Saves your changes to this item"
        public static let exportAction = "Creates a shareable document"
        
        // Loading states
        public static let processingHint = "Please wait while we process your request"
    }
    
    // MARK: - Voice Control
    
    /// Voice control friendly names for common actions
    public enum VoiceCommands {
        public static let addItem = "Add Item"
        public static let search = "Search"
        public static let save = "Save"
        public static let cancel = "Cancel"
        public static let delete = "Delete"
        public static let edit = "Edit"
        public static let back = "Back"
        public static let done = "Done"
        public static let next = "Next"
        public static let previous = "Previous"
    }
    
    // MARK: - Accessibility Utilities
    
    /// Utility functions for accessibility setup
    public enum Utils {
        
        /// Creates a comprehensive accessibility label for monetary values
        public static func formatCurrency(_ amount: Double, currency: String = "USD") -> String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = currency
            
            if let formatted = formatter.string(from: NSNumber(value: amount)) {
                return formatted
            } else {
                return "\(amount) \(currency)"
            }
        }
        
        /// Creates accessibility-friendly date descriptions
        public static func formatDate(_ date: Date, style: DateFormatter.Style = .medium) -> String {
            let formatter = DateFormatter()
            formatter.dateStyle = style
            formatter.doesRelativeDateFormatting = true
            return formatter.string(from: date)
        }
        
        /// Combines multiple accessibility elements into a single readable string
        public static func combineLabels(_ labels: [String?]) -> String {
            labels.compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: ", ")
        }
        
        /// Creates contextual hints based on current state
        public static func dynamicHint(isLoading: Bool, isEmpty: Bool, hasError: Bool) -> String {
            if hasError {
                return "There was an error. Tap to try again."
            } else if isLoading {
                return Hints.processingHint
            } else if isEmpty {
                return "No content available"
            } else {
                return "Tap for more options"
            }
        }
    }
}

// MARK: - SwiftUI Accessibility Extensions

extension View {
    /// Applies standard accessibility configuration for item cards
    public func itemCardAccessibility(
        name: String, 
        category: String? = nil, 
        price: String? = nil,
        status: String? = nil
    ) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(AccessibilityConstants.Labels.itemCard(
                name: name, 
                category: category, 
                price: price
            ))
            .accessibilityHint(AccessibilityConstants.Hints.itemCard)
            .accessibilityIdentifier(AccessibilityConstants.Identifiers.itemCard)
    }
    
    /// Applies standard accessibility configuration for action buttons
    public func actionButtonAccessibility(
        label: String,
        hint: String? = nil,
        isDestructive: Bool = false,
        isLoading: Bool = false
    ) -> some View {
        self
            .accessibilityLabel(isLoading ? AccessibilityConstants.Labels.loading : label)
            .accessibilityHint(hint ?? AccessibilityConstants.Hints.saveAction)
            .accessibilityAddTraits(.isButton)
            .accessibilityAddTraits(isDestructive ? .playsSound : [])
    }
    
    /// Applies accessibility configuration for form fields
    public func formFieldAccessibility(
        label: String,
        hint: String? = nil,
        isRequired: Bool = false
    ) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? (isRequired ? AccessibilityConstants.Hints.requiredField : AccessibilityConstants.Hints.optionalField))
    }
    
    /// Applies accessibility configuration for navigation elements
    public func navigationAccessibility(
        label: String,
        hint: String? = nil
    ) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? AccessibilityConstants.Hints.backButton)
            .accessibilityAddTraits(.isButton)
    }
}