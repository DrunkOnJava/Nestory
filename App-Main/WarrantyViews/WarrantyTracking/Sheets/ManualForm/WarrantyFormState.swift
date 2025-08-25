//
// Layer: App-Main
// Module: WarrantyViews/WarrantyTracking/Sheets/ManualForm
// Purpose: Warranty form state management with validation logic
//

import Foundation
import SwiftUI

@MainActor
public final class WarrantyFormState: ObservableObject, @unchecked Sendable {
    @Published public var warrantyType: WarrantyType = .manufacturer
    @Published public var provider = ""
    @Published public var startDate = Date()
    @Published public var endDate = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
    @Published public var terms = ""
    @Published public var registrationRequired = false
    @Published public var isRegistered = false
    
    public init() {}
    
    // MARK: - Validation
    
    public var isValid: Bool {
        !provider.isEmpty && endDate > startDate
    }
    
    public var isDateRangeValid: Bool {
        endDate > startDate
    }
    
    public var dateValidationMessage: String {
        isDateRangeValid ? "" : "End date must be after start date"
    }
    
    // MARK: - Form Reset
    
    public func reset() {
        warrantyType = .manufacturer
        provider = ""
        startDate = Date()
        endDate = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
        terms = ""
        registrationRequired = false
        isRegistered = false
    }
    
    // MARK: - Auto-Population
    
    public func populateFromDetection(_ result: WarrantyDetectionResult) {
        provider = result.suggestedProvider ?? "Unknown"
        
        if let duration = Calendar.current.date(byAdding: .month, value: result.suggestedDuration ?? 12, to: startDate) {
            endDate = duration
        }
        
        if let extractedText = result.extractedText {
            terms = extractedText
        }
    }
}