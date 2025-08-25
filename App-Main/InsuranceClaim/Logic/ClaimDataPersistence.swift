//
// Layer: App-Main
// Module: InsuranceClaim/Logic
// Purpose: Contact information persistence using UserDefaults
//

import Foundation

public struct ClaimDataPersistence {
    
    // MARK: - UserDefaults Keys
    
    private enum Keys {
        static let contactName = "insurance_contact_name"
        static let contactPhone = "insurance_contact_phone"
        static let contactEmail = "insurance_contact_email"
        static let contactAddress = "insurance_contact_address"
        static let emergencyContact = "insurance_emergency_contact"
    }
    
    // MARK: - Save Methods
    
    public static func saveContactInfo(_ data: ClaimFormData) {
        let defaults = UserDefaults.standard
        defaults.set(data.contactName, forKey: Keys.contactName)
        defaults.set(data.contactPhone, forKey: Keys.contactPhone)
        defaults.set(data.contactEmail, forKey: Keys.contactEmail)
        defaults.set(data.contactAddress, forKey: Keys.contactAddress)
        defaults.set(data.emergencyContact, forKey: Keys.emergencyContact)
    }
    
    public static func saveContactInfo(
        name: String,
        phone: String,
        email: String,
        address: String,
        emergencyContact: String
    ) {
        let defaults = UserDefaults.standard
        defaults.set(name, forKey: Keys.contactName)
        defaults.set(phone, forKey: Keys.contactPhone)
        defaults.set(email, forKey: Keys.contactEmail)
        defaults.set(address, forKey: Keys.contactAddress)
        defaults.set(emergencyContact, forKey: Keys.emergencyContact)
    }
    
    // MARK: - Load Methods
    
    public static func loadContactInfo() -> (name: String, phone: String, email: String, address: String, emergencyContact: String) {
        let defaults = UserDefaults.standard
        return (
            name: defaults.string(forKey: Keys.contactName) ?? "",
            phone: defaults.string(forKey: Keys.contactPhone) ?? "",
            email: defaults.string(forKey: Keys.contactEmail) ?? "",
            address: defaults.string(forKey: Keys.contactAddress) ?? "",
            emergencyContact: defaults.string(forKey: Keys.emergencyContact) ?? ""
        )
    }
    
    public static func loadContactInfoIntoFormData(_ data: inout ClaimFormData) {
        let saved = loadContactInfo()
        data.contactName = saved.name
        data.contactPhone = saved.phone
        data.contactEmail = saved.email
        data.contactAddress = saved.address
        data.emergencyContact = saved.emergencyContact
    }
    
    // MARK: - Clear Methods
    
    public static func clearSavedContactInfo() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: Keys.contactName)
        defaults.removeObject(forKey: Keys.contactPhone)
        defaults.removeObject(forKey: Keys.contactEmail)
        defaults.removeObject(forKey: Keys.contactAddress)
        defaults.removeObject(forKey: Keys.emergencyContact)
    }
    
    // MARK: - Check Methods
    
    public static func hasSavedContactInfo() -> Bool {
        let saved = loadContactInfo()
        return !saved.name.isEmpty || !saved.phone.isEmpty || !saved.email.isEmpty || !saved.address.isEmpty
    }
}