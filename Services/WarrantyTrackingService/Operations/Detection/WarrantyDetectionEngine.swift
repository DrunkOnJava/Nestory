//
// Layer: Services
// Module: WarrantyTrackingService/Operations/Detection
// Purpose: AI-powered warranty detection from receipts and product information
//

import Foundation
import os.log

/// Handles warranty detection from various sources including receipts and product metadata
public struct WarrantyDetectionEngine {
    
    private let logger: Logger
    
    public init(logger: Logger) {
        self.logger = logger
    }
    
    // MARK: - Receipt-based Detection
    
    public func detectWarrantyFromReceipt(item: Item, receiptText: String?) async throws -> WarrantyDetectionResult? {
        guard let receiptText, !receiptText.isEmpty else {
            return nil
        }

        var confidence = 0.5
        var detectedDuration = 0
        var detectedProvider = "Retailer"

        let text = receiptText.lowercased()

        // Look for explicit warranty mentions
        let warrantyPatterns = [
            "warranty",
            "guarantee", 
            "coverage",
            "protection plan",
            "extended service",
        ]

        for pattern in warrantyPatterns {
            if text.contains(pattern) {
                confidence += 0.2
                break
            }
        }

        // Look for duration patterns
        let durationRegex = try NSRegularExpression(pattern: "(\\d+)\\s*(year|month|yr|mo)", options: .caseInsensitive)
        let matches = durationRegex.matches(in: receiptText, options: [], range: NSRange(location: 0, length: receiptText.count))

        if let match = matches.first,
           let numberRange = Range(match.range(at: 1), in: receiptText),
           let unitRange = Range(match.range(at: 2), in: receiptText),
           let number = Int(String(receiptText[numberRange]))
        {
            let unit = String(receiptText[unitRange]).lowercased()

            if unit.contains("year") || unit.contains("yr") {
                detectedDuration = number * 12
            } else if unit.contains("month") || unit.contains("mo") {
                detectedDuration = number
            }

            confidence += 0.3
        }

        // Look for brand/provider names
        if let brand = item.brand, !brand.isEmpty, text.contains(brand.lowercased()) {
            detectedProvider = brand
            confidence += 0.2
        }

        // If no explicit warranty info found, use category defaults
        if detectedDuration == 0 {
            let categoryDefaults = CategoryWarrantyDefaults.getDefaults(for: item.category?.name)
            detectedDuration = categoryDefaults.months
            detectedProvider = categoryDefaults.provider
            confidence = max(confidence, 0.3) // Minimum confidence for category defaults
        }

        guard confidence > 0.3 else {
            return nil // Too low confidence
        }

        return WarrantyDetectionResult.detected(
            duration: detectedDuration,
            provider: detectedProvider,
            confidence: min(confidence, 1.0),
            extractedText: receiptText
        )
    }
    
    // MARK: - Product-based Detection
    
    public func detectWarrantyFromProduct(
        brand: String?,
        model: String?,
        serialNumber: String?,
        purchaseDate: Date?
    ) async throws -> WarrantyDetectionResult {
        var confidence: Double = 0.4
        var detectedDuration = 12 // Default 1 year
        var detectedProvider = "Manufacturer"

        // Brand-specific warranty detection
        if let brand = brand, !brand.isEmpty {
            let brandLower = brand.lowercased()
            
            switch brandLower {
            case "apple":
                detectedDuration = 12
                detectedProvider = "Apple"
                confidence += 0.4
            case "samsung":
                detectedDuration = 24
                detectedProvider = "Samsung"
                confidence += 0.3
            case "sony":
                detectedDuration = 12
                detectedProvider = "Sony"
                confidence += 0.2
            case "lg":
                detectedDuration = 24
                detectedProvider = "LG Electronics"
                confidence += 0.2
            case "whirlpool", "kitchenaid":
                detectedDuration = 12
                detectedProvider = brand
                confidence += 0.2
            default:
                confidence += 0.1
            }
        }

        if let model = model, !model.isEmpty {
            confidence += 0.1

            // Model-specific adjustments
            let modelLower = model.lowercased()
            if modelLower.contains("pro") || modelLower.contains("premium") {
                detectedDuration += 6 // Premium products often have longer warranties
                confidence += 0.1
            }
        }

        if let serialNumber = serialNumber, !serialNumber.isEmpty {
            confidence += 0.1
        }

        if let purchaseDate = purchaseDate {
            confidence += 0.1

            // Adjust based on age - older items might have expired manufacturer warranties
            let ageInMonths = Calendar.current.dateComponents([.month], from: purchaseDate, to: Date()).month ?? 0
            if ageInMonths > 12 {
                // Item is older, might have expired warranty
                confidence -= 0.1
            }
        }

        // Cap confidence at 1.0
        confidence = min(confidence, 1.0)

        guard confidence > 0.4 else {
            throw WarrantyTrackingError.detectionFailed("Insufficient information to detect warranty details")
        }

        return WarrantyDetectionResult.detected(
            duration: detectedDuration,
            provider: detectedProvider,
            confidence: confidence,
            extractedText: "Auto-detected from brand: \(brand ?? "Unknown"), model: \(model ?? "Unknown")"
        )
    }
    
    // MARK: - Provider Suggestion
    
    public func suggestWarrantyProvider(for item: Item) async -> String? {
        // Check if brand is available
        if let brand = item.brand, !brand.isEmpty {
            return brand
        }
        
        // Check category-based defaults
        if let categoryName = item.category?.name {
            let defaults = CategoryWarrantyDefaults.getDefaults(for: categoryName)
            return defaults.provider
        }
        
        // Fallback
        return "Manufacturer"
    }
}

// MARK: - Supporting Types
// Note: WarrantyDetectionResult is imported from Foundation/Models/WarrantyStatus.swift

// MARK: - Category Warranty Defaults
// Note: CategoryWarrantyDefaults is imported from WarrantyTrackingService.swift