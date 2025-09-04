//
// Layer: UI
// Module: UI-Core/AccessibilityConstants
// Purpose: Centralized accessibility identifiers and labels for UI testing and VoiceOver support
//

import Foundation

// MARK: - Accessibility Identifiers

public enum AccessibilityIdentifier {
    
    // MARK: - Main Navigation
    public enum MainNavigation {
        public static let tabBar = "main_tab_bar"
        public static let inventoryTab = "inventory_tab"
        public static let searchTab = "search_tab"
        public static let analyticsTab = "analytics_tab"
        public static let settingsTab = "settings_tab"
        public static let captureTab = "capture_tab"
    }
    
    // MARK: - Inventory
    public enum Inventory {
        public static let itemsList = "items_list"
        public static let addItemButton = "add_item_button"
        public static let itemCell = "item_cell"
        public static let itemImage = "item_image"
        public static let itemName = "item_name"
        public static let itemValue = "item_value"
        public static let itemCategory = "item_category"
        public static let deleteButton = "delete_item_button"
        public static let editButton = "edit_item_button"
        public static let shareButton = "share_item_button"
    }
    
    // MARK: - Item Details
    public enum ItemDetail {
        public static let scrollView = "item_detail_scroll"
        public static let photoCarousel = "photo_carousel"
        public static let nameField = "name_field"
        public static let valueField = "value_field"
        public static let categoryPicker = "category_picker"
        public static let roomPicker = "room_picker"
        public static let dateField = "purchase_date_field"
        public static let notesField = "notes_field"
        public static let saveButton = "save_button"
        public static let cancelButton = "cancel_button"
        public static let warrantySection = "warranty_section"
        public static let receiptSection = "receipt_section"
    }
    
    // MARK: - Search
    public enum Search {
        public static let searchBar = "search_bar"
        public static let filterButton = "filter_button"
        public static let sortButton = "sort_button"
        public static let resultsCount = "results_count"
        public static let noResultsView = "no_results_view"
        public static let categoryFilter = "category_filter"
        public static let roomFilter = "room_filter"
        public static let valueFilter = "value_filter"
        public static let clearFiltersButton = "clear_filters_button"
    }
    
    // MARK: - Analytics
    public enum Analytics {
        public static let dashboardView = "analytics_dashboard"
        public static let totalValueCard = "total_value_card"
        public static let categoryChart = "category_chart"
        public static let roomChart = "room_chart"
        public static let valueChart = "value_chart"
        public static let exportButton = "export_analytics_button"
        public static let refreshButton = "refresh_analytics_button"
    }
    
    // MARK: - Settings
    public enum Settings {
        public static let settingsList = "settings_list"
        public static let exportSection = "export_section"
        public static let importSection = "import_section"
        public static let notificationSection = "notification_section"
        public static let cloudSection = "cloud_section"
        public static let supportSection = "support_section"
        public static let aboutSection = "about_section"
        public static let exportButton = "export_data_button"
        public static let importButton = "import_data_button"
        public static let backupButton = "backup_button"
        public static let restoreButton = "restore_button"
    }
    
    // MARK: - Capture
    public enum Capture {
        public static let cameraView = "camera_view"
        public static let captureButton = "capture_button"
        public static let flashButton = "flash_button"
        public static let switchCameraButton = "switch_camera_button"
        public static let galleryButton = "gallery_button"
        public static let previewImage = "preview_image"
        public static let retakeButton = "retake_button"
        public static let usePhotoButton = "use_photo_button"
        public static let barcodeOverlay = "barcode_overlay"
        public static let scanInstructions = "scan_instructions"
    }
    
    // MARK: - Forms
    public enum Forms {
        public static let textField = "text_field"
        public static let numberField = "number_field"
        public static let dateField = "date_field"
        public static let picker = "picker"
        public static let toggle = "toggle"
        public static let stepper = "stepper"
        public static let slider = "slider"
        public static let submitButton = "submit_button"
        public static let resetButton = "reset_button"
        public static let validationMessage = "validation_message"
    }
    
    // MARK: - Alerts and Modals
    public enum Alerts {
        public static let alertDialog = "alert_dialog"
        public static let confirmButton = "confirm_button"
        public static let cancelButton = "cancel_button"
        public static let destructiveButton = "destructive_button"
        public static let modalView = "modal_view"
        public static let closeButton = "close_button"
        public static let errorMessage = "error_message"
        public static let successMessage = "success_message"
    }
}

// MARK: - Accessibility Labels

public enum AccessibilityLabel {
    
    // MARK: - Navigation Labels
    public enum Navigation {
        public static let inventoryTab = "Inventory"
        public static let searchTab = "Search"
        public static let analyticsTab = "Analytics"
        public static let settingsTab = "Settings"
        public static let captureTab = "Add Item"
        public static let backButton = "Back"
        public static let closeButton = "Close"
        public static let moreButton = "More options"
    }
    
    // MARK: - Item Labels
    public enum Item {
        public static let itemImage = "Item photo"
        public static let addPhoto = "Add photo"
        public static let editPhoto = "Edit photo"
        public static let deletePhoto = "Delete photo"
        public static let noPhoto = "No photo available"
        public static let multiplePhotos = "Multiple photos"
        
        public static func itemValue(_ value: String) -> String {
            return "Value: \(value)"
        }
        
        public static func itemCategory(_ category: String) -> String {
            return "Category: \(category)"
        }
        
        public static func itemRoom(_ room: String) -> String {
            return "Room: \(room)"
        }
        
        public static func purchaseDate(_ date: String) -> String {
            return "Purchased on \(date)"
        }
    }
    
    // MARK: - Action Labels
    public enum Action {
        public static let add = "Add"
        public static let edit = "Edit"
        public static let delete = "Delete"
        public static let save = "Save"
        public static let cancel = "Cancel"
        public static let share = "Share"
        public static let export = "Export"
        public static let importData = "Import"
        public static let backup = "Backup"
        public static let restore = "Restore"
        public static let search = "Search"
        public static let filter = "Filter"
        public static let sort = "Sort"
        public static let refresh = "Refresh"
        public static let capture = "Capture photo"
        public static let retake = "Retake photo"
        public static let usePhoto = "Use this photo"
    }
    
    // MARK: - Form Labels
    public enum Form {
        public static let required = "Required field"
        public static let optional = "Optional field"
        public static let invalid = "Invalid input"
        public static let validationError = "Validation error"
        
        public static func fieldValue(_ field: String, _ value: String) -> String {
            return "\(field): \(value)"
        }
        
        public static func picker(_ field: String, _ selected: String) -> String {
            return "\(field): \(selected) selected"
        }
        
        public static func toggle(_ field: String, _ enabled: Bool) -> String {
            return "\(field): \(enabled ? "enabled" : "disabled")"
        }
    }
    
    // MARK: - Status Labels
    public enum Status {
        public static let loading = "Loading"
        public static let error = "Error occurred"
        public static let success = "Success"
        public static let empty = "No items"
        public static let offline = "Offline"
        public static let syncing = "Syncing"
        public static let synced = "Synced"
        
        public static func itemCount(_ count: Int) -> String {
            switch count {
            case 0:
                return "No items"
            case 1:
                return "1 item"
            default:
                return "\(count) items"
            }
        }
        
        public static func searchResults(_ count: Int) -> String {
            switch count {
            case 0:
                return "No results found"
            case 1:
                return "1 result found"
            default:
                return "\(count) results found"
            }
        }
    }
    
    // MARK: - Analytics Labels
    public enum Analytics {
        public static let totalValue = "Total inventory value"
        public static let categoryChart = "Items by category chart"
        public static let roomChart = "Items by room chart"
        public static let valueChart = "Value distribution chart"
        public static let trending = "Trending data"
        
        public static func percentage(_ value: Double) -> String {
            return "\(Int(value))% of total"
        }
        
        public static func currency(_ amount: String) -> String {
            return "Amount: \(amount)"
        }
    }
    
    // MARK: - Camera Labels
    public enum Camera {
        public static let viewfinder = "Camera viewfinder"
        public static let flashOn = "Flash on"
        public static let flashOff = "Flash off"
        public static let flashAuto = "Flash auto"
        public static let frontCamera = "Front camera"
        public static let backCamera = "Back camera"
        public static let gallery = "Photo gallery"
        public static let barcodeFound = "Barcode detected"
        public static let focusOnBarcode = "Focus on barcode to scan"
        public static let scanComplete = "Scan complete"
    }
}

// MARK: - Accessibility Hints

public enum AccessibilityHint {
    
    public enum Navigation {
        public static let tapToNavigate = "Tap to navigate to this section"
        public static let doubleTapToSelect = "Double tap to select"
        public static let swipeForMore = "Swipe for more options"
    }
    
    public enum Item {
        public static let tapToViewDetails = "Tap to view item details"
        public static let swipeToDelete = "Swipe left to delete"
        public static let swipeToEdit = "Swipe right to edit"
        public static let longPressForOptions = "Long press for more options"
        public static let dragToReorder = "Drag to reorder items"
    }
    
    public enum Form {
        public static let enterText = "Enter text using the keyboard"
        public static let selectValue = "Select a value from the list"
        public static let adjustValue = "Swipe up or down to adjust value"
        public static let enterDate = "Enter date using the date picker"
        public static let toggleOption = "Double tap to toggle this option"
    }
    
    public enum Camera {
        public static let pointAtItem = "Point camera at item to capture photo"
        public static let pointAtBarcode = "Point camera at barcode to scan"
        public static let holdSteady = "Hold camera steady for best results"
        public static let moveCloser = "Move closer to the item"
        public static let ensureGoodLighting = "Ensure good lighting for clear photos"
    }
    
    public enum Search {
        public static let typeToSearch = "Type to search your inventory"
        public static let tapToFilter = "Tap to open filter options"
        public static let clearToReset = "Clear text to reset search"
        public static let selectFilter = "Select filter criteria"
    }
}

// MARK: - Accessibility Traits Extension

public extension AccessibilityIdentifier {
    
    // Convenience function to create full accessibility identifier
    static func makeIdentifier(_ components: String...) -> String {
        return components.joined(separator: "_")
    }
    
    // Create identifier with index for lists
    static func makeIndexedIdentifier(_ base: String, index: Int) -> String {
        return "\(base)_\(index)"
    }
}

// MARK: - VoiceOver Custom Actions

public enum AccessibilityCustomAction {
    public static let editItem = "Edit Item"
    public static let deleteItem = "Delete Item"
    public static let shareItem = "Share Item"
    public static let duplicateItem = "Duplicate Item"
    public static let addToFavorites = "Add to Favorites"
    public static let removeFromFavorites = "Remove from Favorites"
    public static let markAsGift = "Mark as Gift"
    public static let addWarranty = "Add Warranty"
    public static let addReceipt = "Add Receipt"
    public static let viewInRoom = "View in Room"
    public static let changeCategory = "Change Category"
    public static let updateValue = "Update Value"
}

// MARK: - Accessibility Notifications

public enum AccessibilityNotification {
    public static let itemAdded = "Item added to inventory"
    public static let itemUpdated = "Item updated successfully"
    public static let itemDeleted = "Item deleted from inventory"
    public static let photoAdded = "Photo added to item"
    public static let barcodeScanned = "Barcode scanned successfully"
    public static let dataExported = "Data exported successfully"
    public static let dataImported = "Data imported successfully"
    public static let syncCompleted = "Sync completed"
    public static let errorOccurred = "An error occurred"
    public static let validationFailed = "Please check your input"
    public static let searchCompleted = "Search completed"
    public static let filterApplied = "Filters applied"
    
    public static func itemCount(_ count: Int) -> String {
        return "\(count) \(count == 1 ? "item" : "items") found"
    }
}