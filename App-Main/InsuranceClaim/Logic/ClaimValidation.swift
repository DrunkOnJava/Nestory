//
// Layer: App-Main
// Module: InsuranceClaim/Logic
// Purpose: Claim validation logic and step progression rules
//

import Foundation

public struct ClaimValidation {
    
    // MARK: - Step Validation
    
    public static func canProceedFromStep(_ step: Int, with data: ClaimFormData) -> Bool {
        switch step {
        case 1:
            return true // Claim type is always selected
        case 2:
            return !data.incidentDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case 3:
            return !data.contactName.isEmpty && 
                   !data.contactPhone.isEmpty && 
                   !data.contactEmail.isEmpty && 
                   !data.contactAddress.isEmpty
        default:
            return false
        }
    }
    
    public static func canGenerateClaim(with data: ClaimFormData, items: [Item]) -> Bool {
        canProceedFromStep(3, with: data) && !items.isEmpty
    }
    
    // MARK: - Email Validation
    
    public static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    // MARK: - Phone Validation
    
    public static func isValidPhoneNumber(_ phone: String) -> Bool {
        let cleaned = phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return cleaned.count >= 10
    }
    
    // MARK: - Required Fields Check
    
    public static func getMissingRequiredFields(for data: ClaimFormData) -> [String] {
        var missing: [String] = []
        
        if data.contactName.isEmpty {
            missing.append("Full Name")
        }
        
        if data.contactPhone.isEmpty {
            missing.append("Phone Number")
        } else if !isValidPhoneNumber(data.contactPhone) {
            missing.append("Valid Phone Number")
        }
        
        if data.contactEmail.isEmpty {
            missing.append("Email Address")
        } else if !isValidEmail(data.contactEmail) {
            missing.append("Valid Email Address")
        }
        
        if data.contactAddress.isEmpty {
            missing.append("Address")
        }
        
        if data.incidentDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            missing.append("Incident Description")
        }
        
        return missing
    }
}

// MARK: - Supporting Types

public struct ClaimFormData {
    public var selectedClaimType: ClaimType = .generalLoss
    public var selectedCompany: InsuranceCompany = .aaa
    public var incidentDate: Date = Date()
    public var incidentDescription: String = ""
    public var policyNumber: String = ""
    public var claimNumber: String = ""
    public var contactName: String = ""
    public var contactPhone: String = ""
    public var contactEmail: String = ""
    public var contactAddress: String = ""
    public var emergencyContact: String = ""
    
    public init() {}
}