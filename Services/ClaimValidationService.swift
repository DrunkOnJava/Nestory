//
// Layer: Services
// Module: ClaimValidation
// Purpose: Comprehensive validation and quality assurance for insurance claim submissions
//

import Foundation
import SwiftData
import Vision
import CoreImage

// MARK: - Validation Service

@MainActor
public final class ClaimValidationService: ObservableObject {
    @Published public var isValidating = false
    @Published public var validationProgress = 0.0
    @Published public var validationResults: ClaimValidationResults?

    public init() {}

    // MARK: - Main Validation Method

    public func validateClaim(
        items: [Item],
        claimType: InsuranceClaimType,
        insuranceCompany: InsuranceCompanyFormat,
        requirements: ClaimValidationRequirements = .standard
    ) async throws -> ClaimValidationResults {
        isValidating = true
        validationProgress = 0.0
        defer {
            isValidating = false
            validationProgress = 1.0
        }

        var results = ClaimValidationResults()

        // Basic data validation
        validationProgress = 0.1
        try await validateBasicRequirements(items: items, requirements: requirements, results: &results)

        // Photo quality validation
        validationProgress = 0.3
        await validatePhotoQuality(items: items, results: &results)

        // Receipt validation
        validationProgress = 0.5
        await validateReceiptDocumentation(items: items, results: &results)

        // Value assessment validation
        validationProgress = 0.7
        await validateValueAssessments(items: items, claimType: claimType, results: &results)

        // Company-specific requirements
        validationProgress = 0.9
        await validateCompanyRequirements(
            items: items,
            company: insuranceCompany,
            claimType: claimType,
            results: &results
        )

        validationProgress = 1.0
        validationResults = results

        return results
    }

    // MARK: - Basic Requirements Validation

    private func validateBasicRequirements(
        items: [Item],
        requirements: ClaimValidationRequirements,
        results: inout ClaimValidationResults
    ) async throws {
        // Check for empty items list
        if items.isEmpty {
            results.criticalIssues.append(ValidationIssue(
                type: .missingData,
                severity: .critical,
                message: "No items selected for claim",
                affectedItems: []
            ))
            return
        }

        // Check photo requirements
        if requirements.requiresPhotos {
            let itemsWithoutPhotos = items.filter(\.photos.isEmpty)
            if !itemsWithoutPhotos.isEmpty {
                results.warnings.append(ValidationIssue(
                    type: .missingPhotos,
                    severity: .warning,
                    message: "\(itemsWithoutPhotos.count) items missing photos",
                    affectedItems: itemsWithoutPhotos.map(\.id)
                ))
                results.photoCompleteness = Double(items.count - itemsWithoutPhotos.count) / Double(items.count)
            } else {
                results.photoCompleteness = 1.0
            }
        }

        // Check receipt requirements
        if requirements.requiresReceipts {
            let itemsWithoutReceipts = items.filter(\.receipts.isEmpty)
            if !itemsWithoutReceipts.isEmpty {
                results.warnings.append(ValidationIssue(
                    type: .missingReceipts,
                    severity: .warning,
                    message: "\(itemsWithoutReceipts.count) items missing receipts",
                    affectedItems: itemsWithoutReceipts.map(\.id)
                ))
                results.receiptCompleteness = Double(items.count - itemsWithoutReceipts.count) / Double(items.count)
            } else {
                results.receiptCompleteness = 1.0
            }
        }

        // Check serial number requirements
        if requirements.requiresSerialNumbers {
            let itemsWithoutSerial = items.filter { $0.serialNumber?.isEmpty != false }
            if !itemsWithoutSerial.isEmpty {
                results.warnings.append(ValidationIssue(
                    type: .missingSerialNumbers,
                    severity: .warning,
                    message: "\(itemsWithoutSerial.count) items missing serial numbers",
                    affectedItems: itemsWithoutSerial.map(\.id)
                ))
            }
        }

        // Check minimum value requirements
        if let minValue = requirements.minimumItemValue {
            let lowValueItems = items.filter { ($0.purchasePrice ?? 0) < minValue }
            if !lowValueItems.isEmpty {
                results.warnings.append(ValidationIssue(
                    type: .valueThreshold,
                    severity: .info,
                    message: "\(lowValueItems.count) items below minimum value threshold (\(minValue))",
                    affectedItems: lowValueItems.map(\.id)
                ))
            }
        }

        // Calculate overall completeness
        let totalFields = items.count * 4 // name, price, photos, receipts
        var completedFields = items.count // names are always present

        completedFields += items.count(where: { $0.purchasePrice != nil })
        completedFields += items.count(where: { !$0.photos.isEmpty })
        completedFields += items.count(where: { !$0.receipts.isEmpty })

        results.overallCompleteness = Double(completedFields) / Double(totalFields)
    }

    // MARK: - Photo Quality Validation

    private func validatePhotoQuality(
        items: [Item],
        results: inout ClaimValidationResults
    ) async {
        var totalPhotos = 0
        var qualityIssues = 0
        var itemsWithQualityIssues: [UUID] = []

        for item in items {
            for photoPath in item.photos {
                totalPhotos += 1

                if let url = URL(string: photoPath),
                   let data = try? Data(contentsOf: url),
                   let image = CIImage(data: data)
                {
                    let qualityScore = await assessPhotoQuality(image)

                    if qualityScore < 0.6 { // Below acceptable quality threshold
                        qualityIssues += 1
                        if !itemsWithQualityIssues.contains(item.id) {
                            itemsWithQualityIssues.append(item.id)
                        }
                    }
                }
            }
        }

        if qualityIssues > 0 {
            let severity: ValidationSeverity = qualityIssues > totalPhotos / 2 ? .warning : .info
            results.warnings.append(ValidationIssue(
                type: .photoQuality,
                severity: severity,
                message: "\(qualityIssues) of \(totalPhotos) photos may have quality issues",
                affectedItems: itemsWithQualityIssues
            ))
        }

        results.photoQualityScore = totalPhotos > 0 ? Double(totalPhotos - qualityIssues) / Double(totalPhotos) : 1.0
    }

    private func assessPhotoQuality(_ image: CIImage) async -> Double {
        // Simplified quality assessment
        // In production, would use more sophisticated image analysis

        var qualityScore = 1.0

        // Check image resolution
        let imageSize = image.extent.size
        let megapixels = (imageSize.width * imageSize.height) / 1_000_000

        if megapixels < 1.0 {
            qualityScore -= 0.3 // Low resolution penalty
        }

        // Check for blur (simplified)
        let blurFilter = CIFilter(name: "CIGaussianBlur")!
        blurFilter.setValue(image, forKey: kCIInputImageKey)
        blurFilter.setValue(2.0, forKey: kCIInputRadiusKey)

        if let blurredImage = blurFilter.outputImage {
            let variance = calculateImageVariance(blurredImage)
            if variance < 100 { // Threshold for blur detection
                qualityScore -= 0.4
            }
        }

        return max(0.0, qualityScore)
    }

    private func calculateImageVariance(_: CIImage) -> Double {
        // Simplified variance calculation
        // Would use proper statistical methods in production
        150.0 // Mock value
    }

    // MARK: - Receipt Validation

    private func validateReceiptDocumentation(
        items: [Item],
        results: inout ClaimValidationResults
    ) async {
        var itemsWithReceiptIssues: [UUID] = []
        var totalReceiptValue: Decimal = 0
        var verifiedReceiptValue: Decimal = 0

        for item in items {
            if let purchasePrice = item.purchasePrice {
                totalReceiptValue += purchasePrice

                var hasValidReceipt = false

                for receipt in item.receipts {
                    // In production, would perform OCR validation of receipt
                    if await validateReceiptContent(receipt, expectedPrice: purchasePrice) {
                        hasValidReceipt = true
                        verifiedReceiptValue += purchasePrice
                        break
                    }
                }

                if !hasValidReceipt, !item.receipts.isEmpty {
                    itemsWithReceiptIssues.append(item.id)
                }
            }
        }

        if !itemsWithReceiptIssues.isEmpty {
            results.warnings.append(ValidationIssue(
                type: .receiptMismatch,
                severity: .warning,
                message: "\(itemsWithReceiptIssues.count) items have receipt validation issues",
                affectedItems: itemsWithReceiptIssues
            ))
        }

        results.receiptVerificationScore = totalReceiptValue > 0 ?
            Double(truncating: verifiedReceiptValue as NSNumber) / Double(truncating: totalReceiptValue as NSNumber) : 1.0
    }

    private func validateReceiptContent(_ receipt: Receipt, expectedPrice: Decimal) async -> Bool {
        // Simplified receipt validation
        // In production, would use OCR and text analysis

        // Check if receipt has minimum required fields
        guard !receipt.merchantName.isEmpty,
              receipt.totalAmount > 0,
              receipt.dateOfPurchase != nil
        else {
            return false
        }

        // Check price variance (allow 10% difference for tax/fees)
        let priceDifference = abs(receipt.totalAmount - expectedPrice)
        let allowableVariance = expectedPrice * 0.1

        return priceDifference <= allowableVariance
    }

    // MARK: - Value Assessment Validation

    private func validateValueAssessments(
        items: [Item],
        claimType: InsuranceClaimType,
        results: inout ClaimValidationResults
    ) async {
        var highValueItems: [UUID] = []
        var suspiciousValueItems: [UUID] = []
        let totalValue = items.compactMap(\.purchasePrice).reduce(0, +)

        for item in items {
            guard let price = item.purchasePrice else { continue }

            // Check for unusually high values
            if price > 5000 {
                highValueItems.append(item.id)
            }

            // Check for suspicious value patterns
            if await isSuspiciousValue(item: item, claimType: claimType) {
                suspiciousValueItems.append(item.id)
            }
        }

        if !highValueItems.isEmpty {
            results.warnings.append(ValidationIssue(
                type: .highValue,
                severity: .info,
                message: "\(highValueItems.count) items have high values (>$5,000) - may require additional documentation",
                affectedItems: highValueItems
            ))
        }

        if !suspiciousValueItems.isEmpty {
            results.warnings.append(ValidationIssue(
                type: .valueAnomalies,
                severity: .warning,
                message: "\(suspiciousValueItems.count) items have value patterns that may require review",
                affectedItems: suspiciousValueItems
            ))
        }

        // Calculate claim value assessment
        results.totalClaimValue = totalValue
        results.averageItemValue = items.isEmpty ? 0 : totalValue / Decimal(items.count)

        // Flag if total claim value is unusually high
        if totalValue > 100_000 {
            results.warnings.append(ValidationIssue(
                type: .highClaimValue,
                severity: .info,
                message: "Total claim value exceeds $100,000 - may require additional underwriting review",
                affectedItems: []
            ))
        }
    }

    private func isSuspiciousValue(item: Item, claimType _: InsuranceClaimType) async -> Bool {
        guard let price = item.purchasePrice,
              let purchaseDate = item.purchaseDate
        else {
            return false
        }

        // Check for depreciation inconsistencies
        let ageInYears = Date().timeIntervalSince(purchaseDate) / (365.24 * 24 * 3600)

        // Electronics depreciate faster
        if item.category?.name.lowercased().contains("electronic") == true {
            let expectedDepreciatedValue = price * pow(0.8, ageInYears) // 20% per year
            if price > expectedDepreciatedValue * 1.5 {
                return true // Value too high for age
            }
        }

        return false
    }

    // MARK: - Company-Specific Requirements

    private func validateCompanyRequirements(
        items: [Item],
        company: InsuranceCompanyFormat,
        claimType: InsuranceClaimType,
        results: inout ClaimValidationResults
    ) async {
        switch company {
        case .usaa:
            await validateUSAARequirements(items: items, claimType: claimType, results: &results)
        case .statefarm:
            await validateStateFarmRequirements(items: items, claimType: claimType, results: &results)
        case .allstate:
            await validateAllstateRequirements(items: items, claimType: claimType, results: &results)
        case .acord:
            await validateACORDRequirements(items: items, claimType: claimType, results: &results)
        default:
            // Generic validation
            break
        }
    }

    private func validateUSAARequirements(
        items: [Item],
        claimType _: InsuranceClaimType,
        results: inout ClaimValidationResults
    ) async {
        // USAA specific requirements
        let itemsWithoutSerial = items.filter { item in
            (item.purchasePrice ?? 0) > 1000 && (item.serialNumber?.isEmpty != false)
        }

        if !itemsWithoutSerial.isEmpty {
            results.warnings.append(ValidationIssue(
                type: .missingSerialNumbers,
                severity: .warning,
                message: "USAA requires serial numbers for items over $1,000",
                affectedItems: itemsWithoutSerial.map(\.id)
            ))
        }
    }

    private func validateStateFarmRequirements(
        items: [Item],
        claimType: InsuranceClaimType,
        results: inout ClaimValidationResults
    ) async {
        // State Farm specific requirements
        if claimType == .theft || claimType == .vandalism {
            let itemsWithoutPhotos = items.filter(\.photos.isEmpty)
            if !itemsWithoutPhotos.isEmpty {
                results.criticalIssues.append(ValidationIssue(
                    type: .missingPhotos,
                    severity: .critical,
                    message: "State Farm requires photos for all theft/vandalism claims",
                    affectedItems: itemsWithoutPhotos.map(\.id)
                ))
            }
        }
    }

    private func validateAllstateRequirements(
        items: [Item],
        claimType: InsuranceClaimType,
        results: inout ClaimValidationResults
    ) async {
        // Allstate specific requirements
        let totalValue = items.compactMap(\.purchasePrice).reduce(0, +)

        if totalValue > 50000, claimType == .fire {
            let itemsWithoutReceipts = items.filter(\.receipts.isEmpty)
            if Double(itemsWithoutReceipts.count) / Double(items.count) > 0.5 {
                results.criticalIssues.append(ValidationIssue(
                    type: .missingReceipts,
                    severity: .critical,
                    message: "Allstate requires receipts for majority of items in high-value fire claims",
                    affectedItems: itemsWithoutReceipts.map(\.id)
                ))
            }
        }
    }

    private func validateACORDRequirements(
        items: [Item],
        claimType _: InsuranceClaimType,
        results: inout ClaimValidationResults
    ) async {
        // ACORD standard requirements
        let itemsWithMissingData = items.filter { item in
            item.name.isEmpty ||
                item.purchasePrice == nil ||
                item.category?.name.isEmpty != false
        }

        if !itemsWithMissingData.isEmpty {
            results.criticalIssues.append(ValidationIssue(
                type: .missingData,
                severity: .critical,
                message: "ACORD format requires complete data for all items (name, price, category)",
                affectedItems: itemsWithMissingData.map(\.id)
            ))
        }
    }
}

// MARK: - Data Models

public struct ClaimValidationResults {
    public var overallCompleteness = 0.0
    public var photoCompleteness = 0.0
    public var receiptCompleteness = 0.0
    public var photoQualityScore = 0.0
    public var receiptVerificationScore = 0.0

    public var totalClaimValue: Decimal = 0
    public var averageItemValue: Decimal = 0

    public var criticalIssues: [ValidationIssue] = []
    public var warnings: [ValidationIssue] = []
    public var suggestions: [ValidationIssue] = []

    public var isReadyForSubmission: Bool {
        criticalIssues.isEmpty && overallCompleteness >= 0.8
    }

    public var completenessGrade: String {
        switch overallCompleteness {
        case 0.9...: "Excellent"
        case 0.8 ..< 0.9: "Good"
        case 0.7 ..< 0.8: "Fair"
        case 0.6 ..< 0.7: "Poor"
        default: "Incomplete"
        }
    }
}

public struct ClaimValidationIssue: Identifiable {
    public let id = UUID()
    public let type: ValidationIssueType
    public let severity: ValidationSeverity
    public let message: String
    public let affectedItems: [UUID]
    public let suggestion: String?

    public init(
        type: ValidationIssueType,
        severity: ValidationSeverity,
        message: String,
        affectedItems: [UUID],
        suggestion: String? = nil
    ) {
        self.type = type
        self.severity = severity
        self.message = message
        self.affectedItems = affectedItems
        self.suggestion = suggestion
    }
}

public enum ValidationIssueType: String, CaseIterable {
    case missingData = "Missing Data"
    case missingPhotos = "Missing Photos"
    case missingReceipts = "Missing Receipts"
    case missingSerialNumbers = "Missing Serial Numbers"
    case photoQuality = "Photo Quality"
    case receiptMismatch = "Receipt Mismatch"
    case valueThreshold = "Value Threshold"
    case valueAnomalies = "Value Anomalies"
    case highValue = "High Value Items"
    case highClaimValue = "High Claim Value"
    case companySpecific = "Company Requirements"
}

public enum ValidationSeverity: String, CaseIterable {
    case critical = "Critical"
    case warning = "Warning"
    case info = "Info"

    var color: String {
        switch self {
        case .critical: "red"
        case .warning: "orange"
        case .info: "blue"
        }
    }

    var icon: String {
        switch self {
        case .critical: "exclamationmark.circle.fill"
        case .warning: "exclamationmark.triangle.fill"
        case .info: "info.circle.fill"
        }
    }
}
