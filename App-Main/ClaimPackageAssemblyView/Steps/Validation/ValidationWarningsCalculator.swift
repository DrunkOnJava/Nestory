//
// Layer: App-Main
// Module: ClaimPackageAssembly/Steps/Validation
// Purpose: Validation warnings calculation logic with concurrency safety
//

import Foundation

@MainActor
public struct ValidationWarningsCalculator: Sendable {
    
    public static func calculateWarnings(
        selectedItems: [Item],
        scenario: ClaimScenario
    ) -> [String] {
        var warnings: [String] = []
        
        // Check for missing purchase prices
        if selectedItems.filter({ $0.purchasePrice == nil }).count > 0 {
            warnings.append("Some items are missing purchase prices")
        }
        
        // Check for missing photos
        if selectedItems.filter({ $0.photos.isEmpty }).count > 0 {
            warnings.append("Some items don't have photos")
        }
        
        // Check for detailed incident description
        if scenario.description.count < 50 {
            warnings.append("Incident description could be more detailed")
        }
        
        return warnings
    }
    
    // MARK: - Detailed Analysis
    
    public static func analyzePurchaseInfoCompleteness(for items: [Item]) -> (complete: Int, total: Int) {
        let complete = items.filter { $0.purchasePrice != nil }.count
        return (complete: complete, total: items.count)
    }
    
    public static func analyzePhotoCompleteness(for items: [Item]) -> (complete: Int, total: Int) {
        let complete = items.filter { !$0.photos.isEmpty }.count
        return (complete: complete, total: items.count)
    }
    
    public static func calculateCompletionScore(
        selectedItems: [Item],
        scenario: ClaimScenario
    ) -> Double {
        var score: Double = 0
        let maxScore: Double = 4
        
        // Items selected (25%)
        if !selectedItems.isEmpty {
            score += 1
        }
        
        // Incident description (25%)
        if !scenario.description.isEmpty {
            score += scenario.description.count >= 50 ? 1 : 0.5
        }
        
        // Photos (25%)
        let photoCompletion = analyzePhotoCompleteness(for: selectedItems)
        if photoCompletion.total > 0 {
            score += Double(photoCompletion.complete) / Double(photoCompletion.total)
        }
        
        // Purchase info (25%)
        let purchaseCompletion = analyzePurchaseInfoCompleteness(for: selectedItems)
        if purchaseCompletion.total > 0 {
            score += Double(purchaseCompletion.complete) / Double(purchaseCompletion.total)
        }
        
        return score / maxScore
    }
}