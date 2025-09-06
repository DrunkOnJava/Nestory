//
// Layer: Tests
// Module: TestFactories
// Purpose: Specialized factory for Receipt and Warranty test data
//

import Foundation
@testable import Nestory

/// Specialized factory for creating Receipt and Warranty test data
@MainActor
struct ReceiptWarrantyTestFactory {
    
    // MARK: - Receipt Test Data
    
    /// Generate comprehensive receipt test data for OCR testing
    static func createReceiptTestData() -> Receipt {
        let total = Money(minorUnits: 249999, currencyCode: "USD") // $2499.99
        let receipt = Receipt(
            vendor: "Apple Store",
            total: total,
            purchaseDate: Date()
        )
        receipt.receiptNumber = "APL-2024-001234"
        receipt.paymentMethod = "Credit Card (**** 4567)"
        receipt.confidence = 0.95
        receipt.rawText = createAppleStoreReceiptText()
        return receipt
    }
    
    /// Generate receipt for specific vendor and amount
    static func createReceiptForVendor(
        vendor: String,
        amount: Decimal,
        currency: String = "USD"
    ) -> Receipt {
        let total = Money(amount: amount, currencyCode: currency)
        let receipt = Receipt(
            vendor: vendor,
            total: total,
            purchaseDate: Calendar.current.date(byAdding: .day, value: -Int.random(in: 1...30), to: Date()) ?? Date()
        )
        receipt.receiptNumber = generateReceiptNumber(for: vendor)
        receipt.paymentMethod = ["Credit Card", "Debit Card", "Cash", "Digital Wallet"].randomElement() ?? "Credit Card"
        receipt.confidence = Double.random(in: 0.85...0.99)
        receipt.rawText = createReceiptText(for: vendor, amount: amount)
        return receipt
    }
    
    /// Generate low-confidence receipt for OCR error testing
    static func createLowConfidenceReceipt() -> Receipt {
        let receipt = createReceiptTestData()
        receipt.confidence = Double.random(in: 0.3...0.7)
        receipt.rawText = createGarbledReceiptText()
        return receipt
    }
    
    // MARK: - Warranty Test Data
    
    /// Generate comprehensive warranty test data
    static func createWarrantyTestData() -> Warranty {
        let warranty = Warranty(
            provider: "Apple Inc.",
            type: .extended,
            startDate: Date(),
            expiresAt: Calendar.current.date(byAdding: .year, value: 3, to: Date()) ?? Date()
        )
        warranty.policyNumber = "APL-CARE-001234"
        warranty.coverageNotes = "Hardware repairs, accidental damage protection"
        warranty.claimPhone = "1-800-APL-CARE"
        warranty.isRegistered = true
        warranty.registrationDate = Date()
        return warranty
    }
    
    /// Generate warranty for specific provider and duration
    static func createWarrantyForProvider(
        provider: String,
        type: Nestory.WarrantyType = .manufacturer,
        durationYears: Int = 1
    ) -> Warranty {
        let startDate = Calendar.current.date(byAdding: .month, value: -Int.random(in: 0...6), to: Date()) ?? Date()
        let expiresAt = Calendar.current.date(byAdding: .year, value: durationYears, to: startDate) ?? Date()
        
        let warranty = Warranty(
            provider: provider,
            type: type,
            startDate: startDate,
            expiresAt: expiresAt
        )
        warranty.policyNumber = generatePolicyNumber(for: provider)
        warranty.coverageNotes = generateCoverageNotes(for: type)
        warranty.claimPhone = generateClaimPhone(for: provider)
        warranty.isRegistered = Bool.random()
        if warranty.isRegistered {
            warranty.registrationDate = Calendar.current.date(byAdding: .day, value: Int.random(in: 1...30), to: startDate)
        }
        return warranty
    }
    
    /// Generate expired warranty for testing expiration scenarios
    static func createExpiredWarranty() -> Warranty {
        let startDate = Calendar.current.date(byAdding: .year, value: -3, to: Date()) ?? Date()
        let expiresAt = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        
        let warranty = Warranty(
            provider: "Generic Warranty Co.",
            type: .manufacturer,
            startDate: startDate,
            expiresAt: expiresAt
        )
        warranty.policyNumber = "EXP-2022-5678"
        warranty.coverageNotes = "Basic hardware coverage"
        warranty.isRegistered = true
        warranty.registrationDate = startDate
        return warranty
    }
    
    /// Generate warranty expiring soon for notification testing
    static func createExpiringWarranty(daysUntilExpiry: Int = 30) -> Warranty {
        let startDate = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        let expiresAt = Calendar.current.date(byAdding: .day, value: daysUntilExpiry, to: Date()) ?? Date()
        
        let warranty = Warranty(
            provider: "Soon-to-Expire Warranties Inc.",
            type: .extended,
            startDate: startDate,
            expiresAt: expiresAt
        )
        warranty.policyNumber = "EXPIRING-2024-\(String(format: "%04d", Int.random(in: 1000...9999)))"
        warranty.coverageNotes = "Extended coverage including parts and labor"
        warranty.claimPhone = "1-800-EXPIRING"
        warranty.isRegistered = true
        warranty.registrationDate = startDate
        return warranty
    }
    
    // MARK: - Batch Creation
    
    /// Create multiple receipts for different vendors
    static func createMultipleReceipts(count: Int = 5) -> [Receipt] {
        let vendors = ["Apple Store", "Best Buy", "Amazon", "Target", "Walmart", "Home Depot", "Costco", "Office Depot"]
        
        return (0..<count).map { _ in
            let vendor = vendors.randomElement() ?? "Generic Store"
            let amount = Decimal(Double.random(in: 10...2000))
            return createReceiptForVendor(vendor: vendor, amount: amount)
        }
    }
    
    /// Create multiple warranties with different expiration dates
    static func createMultipleWarranties(count: Int = 5) -> [Warranty] {
        let providers = ["Apple Inc.", "Samsung", "Sony", "Dell", "HP", "Best Buy", "SquareTrade", "Asurion"]
        let types: [Nestory.WarrantyType] = [.manufacturer, .extended, .dealer]
        
        return (0..<count).map { index in
            let provider = providers[index % providers.count]
            let type = types.randomElement() ?? .manufacturer
            let duration = Int.random(in: 1...5)
            return createWarrantyForProvider(provider: provider, type: type, durationYears: duration)
        }
    }
    
    // MARK: - Helper Methods
    
    private static func generateReceiptNumber(for vendor: String) -> String {
        let prefix = String(vendor.prefix(3).uppercased())
        let year = Calendar.current.component(.year, from: Date())
        let random = String(format: "%06d", Int.random(in: 100000...999999))
        return "\(prefix)-\(year)-\(random)"
    }
    
    private static func generatePolicyNumber(for provider: String) -> String {
        let prefix = String(provider.prefix(3).uppercased())
        let random = String(format: "%08d", Int.random(in: 10000000...99999999))
        return "\(prefix)-\(random)"
    }
    
    private static func generateCoverageNotes(for type: Nestory.WarrantyType) -> String {
        switch type {
        case .manufacturer:
            return "Manufacturer warranty including repair or replacement for covered defects"
        case .extended:
            return "Extended warranty with additional coverage for parts, labor, and accidental damage"
        case .dealer:
            return "Dealer warranty providing local service and support for covered items"
        case .thirdParty:
            return "Third-party warranty with comprehensive coverage and convenient claim process"
        case .insurance:
            return "Insurance coverage providing replacement value protection against damage or loss"
        case .service:
            return "Service contract covering maintenance, repairs, and technical support"
        case .store:
            return "Store warranty providing in-house service and replacement guarantees"
        }
    }
    
    private static func generateClaimPhone(for provider: String) -> String {
        // Generate realistic phone numbers for different providers
        switch provider.lowercased() {
        case let p where p.contains("apple"):
            return "1-800-APL-CARE"
        case let p where p.contains("samsung"):
            return "1-800-SAMSUNG"
        case let p where p.contains("sony"):
            return "1-800-222-SONY"
        default:
            return "1-800-\(String(format: "%03d", Int.random(in: 100...999)))-\(String(format: "%04d", Int.random(in: 1000...9999)))"
        }
    }
    
    private static func createAppleStoreReceiptText() -> String {
        return """
        APPLE STORE
        1 Stockton St, San Francisco, CA 94108
        
        Receipt #: APL-2024-001234
        Date: \(Date().formatted(date: .numeric, time: .shortened))
        
        MacBook Pro 16-inch M3        $2,274.00
        AppleCare+                      $199.00
        Sales Tax (8.75%)               $216.39
        
        Subtotal:                     $2,473.00
        Tax:                            $216.39
        Total:                        $2,499.99
        
        Credit Card (**** 4567)       $2,499.99
        
        Thank you for your purchase!
        """
    }
    
    private static func createReceiptText(for vendor: String, amount: Decimal) -> String {
        let tax = amount * Decimal(0.0875) // 8.75% tax
        let subtotal = amount - tax
        
        return """
        \(vendor.uppercased())
        Receipt #: \(generateReceiptNumber(for: vendor))
        Date: \(Date().formatted(date: .numeric, time: .shortened))
        
        Purchase Item                 $\(subtotal)
        Sales Tax                     $\(tax)
        
        Total:                        $\(amount)
        
        Thank you for shopping with us!
        """
    }
    
    private static func createGarbledReceiptText() -> String {
        return """
        APP1E ST0RE
        1 St0ckt0n St, San Franc1sc0, CA 94108
        
        Rece1pt #: APL-2O24-OO1234
        D4te: \(Date().formatted(date: .numeric, time: .shortened))
        
        M4cB00k Pr0 16-1nch M3        $2,274.OO
        App1eC4re+                      $199.OO
        S4les T4x (8.75%)               $216.39
        
        Subt0t41:                     $2,473.OO
        T4x:                            $216.39
        T0t41:                        $2,499.99
        
        Cred1t C4rd (**** 4567)       $2,499.99
        
        Th4nk y0u f0r y0ur purch4se!
        """
    }
}

// MARK: - Supporting Types

// Note: WarrantyType enum is defined in Foundation/Models/Warranty.swift to avoid duplicate declarations