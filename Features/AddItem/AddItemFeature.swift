//
// Layer: Features
// Module: AddItem
// Purpose: TCA Feature for adding new items with form validation and data persistence
//

import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
struct AddItemFeature {
    @ObservableState
    struct State: Equatable {
        // Core item properties
        var name = ""
        var itemDescription = ""
        var quantity = 1
        var selectedCategory: Category?
        var brand = ""
        var modelNumber = ""
        var serialNumber = ""
        var notes = ""
        var purchasePrice = ""
        var purchaseDate = Date()
        var imageData: Data?
        
        // UI state
        var showPurchaseDetails = false
        var showingPhotoCapture = false
        var showingBarcodeScanner = false
        var showingWarrantyDetection = false
        var isDetectingWarranty = false
        var isSaving = false
        var errorMessage: String?
        
        // Loaded data
        var categories: [Category] = []
        var tempItem = Item(name: "")
        var detectedWarranty: WarrantyDetectionResult?
        
        // Computed properties
        var canSave: Bool {
            !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        
        var purchasePriceDecimal: Decimal? {
            guard !purchasePrice.isEmpty else { return nil }
            return Decimal(string: purchasePrice.replacingOccurrences(of: ",", with: ""))
        }
    }
    
    enum Action: Equatable {
        case onAppear
        case categoriesLoaded([Category])
        
        // Form actions
        case nameChanged(String)
        case descriptionChanged(String)
        case quantityChanged(Int)
        case categorySelected(Category?)
        case brandChanged(String)
        case modelNumberChanged(String)
        case serialNumberChanged(String)
        case notesChanged(String)
        case purchasePriceChanged(String)
        case purchaseDateChanged(Date)
        case imageDataSet(Data?)
        
        // UI actions
        case togglePurchaseDetails
        case photoCaptureButtonTapped
        case barcodeScannerButtonTapped
        case warrantyDetectionButtonTapped
        case photoCapturePresented(Bool)
        case barcodeScannerPresented(Bool)
        case warrantyDetectionPresented(Bool)
        
        // Item management
        case saveButtonTapped
        case cancelButtonTapped
        case itemSaved
        case saveFailed(String)
        
        // Warranty detection
        case warrantyDetectionStarted
        case warrantyDetected(WarrantyDetectionResult?)
        case warrantyDetectionFailed(String)
        
        // Barcode scanning
        case barcodeScanned(String)
        case barcodeDataLoaded(ProductInfo?)
    }
    
    @Dependency(\.inventoryService) var inventoryService
    @Dependency(\.categoryService) var categoryService
    @Dependency(\.warrantyTrackingService) var warrantyTrackingService
    @Dependency(\.barcodeScannerService) var barcodeScannerService
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    do {
                        let categories = try await categoryService.fetchCategories()
                        await send(.categoriesLoaded(categories))
                    } catch {
                        // Categories loading is not critical, continue without
                    }
                }
                
            case let .categoriesLoaded(categories):
                state.categories = categories
                return .none
                
            // MARK: - Form Actions
            case let .nameChanged(name):
                state.name = name
                return .none
                
            case let .descriptionChanged(description):
                state.itemDescription = description
                return .none
                
            case let .quantityChanged(quantity):
                state.quantity = max(1, quantity)
                return .none
                
            case let .categorySelected(category):
                state.selectedCategory = category
                return .none
                
            case let .brandChanged(brand):
                state.brand = brand
                return .none
                
            case let .modelNumberChanged(modelNumber):
                state.modelNumber = modelNumber
                return .none
                
            case let .serialNumberChanged(serialNumber):
                state.serialNumber = serialNumber
                return .none
                
            case let .notesChanged(notes):
                state.notes = notes
                return .none
                
            case let .purchasePriceChanged(price):
                state.purchasePrice = price
                return .none
                
            case let .purchaseDateChanged(date):
                state.purchaseDate = date
                return .none
                
            case let .imageDataSet(imageData):
                state.imageData = imageData
                return .none
                
            // MARK: - UI Actions
            case .togglePurchaseDetails:
                state.showPurchaseDetails.toggle()
                return .none
                
            case .photoCaptureButtonTapped:
                state.showingPhotoCapture = true
                return .none
                
            case .barcodeScannerButtonTapped:
                state.showingBarcodeScanner = true
                return .none
                
            case .warrantyDetectionButtonTapped:
                state.showingWarrantyDetection = true
                return .none
                
            case let .photoCapturePresented(isPresented):
                state.showingPhotoCapture = isPresented
                return .none
                
            case let .barcodeScannerPresented(isPresented):
                state.showingBarcodeScanner = isPresented
                return .none
                
            case let .warrantyDetectionPresented(isPresented):
                state.showingWarrantyDetection = isPresented
                return .none
                
            // MARK: - Item Management
            case .saveButtonTapped:
                guard state.canSave else { return .none }
                
                state.isSaving = true
                state.errorMessage = nil
                
                return .run { [state = state] send in
                    do {
                        let item = Item(name: state.name.trimmingCharacters(in: .whitespacesAndNewlines))
                        item.itemDescription = state.itemDescription.isEmpty ? nil : state.itemDescription
                        item.quantity = state.quantity
                        item.category = state.selectedCategory
                        item.brand = state.brand.isEmpty ? nil : state.brand
                        item.modelNumber = state.modelNumber.isEmpty ? nil : state.modelNumber
                        item.serialNumber = state.serialNumber.isEmpty ? nil : state.serialNumber
                        item.notes = state.notes.isEmpty ? nil : state.notes
                        item.purchasePrice = state.purchasePriceDecimal
                        item.purchaseDate = state.showPurchaseDetails ? state.purchaseDate : nil
                        item.imageData = state.imageData
                        item.barcode = (state.tempItem.barcode?.isEmpty == false) ? state.tempItem.barcode : nil
                        
                        try await inventoryService.saveItem(item)
                        await send(.itemSaved)
                    } catch {
                        await send(.saveFailed(error.localizedDescription))
                    }
                }
                
            case .cancelButtonTapped:
                return .run { _ in await dismiss() }
                
            case .itemSaved:
                return .run { _ in await dismiss() }
                
            case let .saveFailed(error):
                state.isSaving = false
                state.errorMessage = error
                return .none
                
            // MARK: - Warranty Detection
            case .warrantyDetectionStarted:
                state.isDetectingWarranty = true
                return .run { [state = state] send in
                    do {
                        let result = try await warrantyTrackingService.detectWarrantyInfo(
                            brand: state.brand.isEmpty ? nil : state.brand,
                            model: state.modelNumber.isEmpty ? nil : state.modelNumber,
                            serialNumber: state.serialNumber.isEmpty ? nil : state.serialNumber,
                            purchaseDate: state.showPurchaseDetails ? state.purchaseDate : nil
                        )
                        await send(.warrantyDetected(result))
                    } catch {
                        await send(.warrantyDetectionFailed(error.localizedDescription))
                    }
                }
                
            case let .warrantyDetected(result):
                state.isDetectingWarranty = false
                state.detectedWarranty = result
                return .none
                
            case let .warrantyDetectionFailed(error):
                state.isDetectingWarranty = false
                state.errorMessage = error
                return .none
                
            // MARK: - Barcode Scanning
            case let .barcodeScanned(barcode):
                // Update temp item with barcode for downstream processing
                state.tempItem.barcode = barcode
                return .run { send in
                    let productInfo = await barcodeScannerService.lookupProduct(barcode: barcode, type: "")
                    await send(.barcodeDataLoaded(productInfo))
                }
                
            case let .barcodeDataLoaded(productInfo):
                // Apply any scanned values from tempItem back to form state
                if let scannedSerial = state.tempItem.serialNumber, !scannedSerial.isEmpty {
                    state.serialNumber = scannedSerial
                }
                if let scannedModel = state.tempItem.modelNumber, !scannedModel.isEmpty {
                    state.modelNumber = scannedModel
                }
                if let scannedBrand = state.tempItem.brand, !scannedBrand.isEmpty {
                    state.brand = scannedBrand
                }
                // If name was populated from product lookup
                if !state.tempItem.name.isEmpty && state.name.isEmpty {
                    state.name = state.tempItem.name
                }
                // Apply product info if available
                if let productInfo = productInfo {
                    if state.name.isEmpty {
                        state.name = productInfo.name
                    }
                    state.brand = productInfo.brand ?? state.brand
                    if let model = productInfo.model {
                        state.modelNumber = model
                    }
                }
                state.showingBarcodeScanner = false
                return .none
            }
        }
    }
}