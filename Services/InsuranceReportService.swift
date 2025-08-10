//
// Layer: Services
// Module: Insurance
// Purpose: Generate comprehensive insurance claim reports
//
// REMINDER: This service is WIRED UP in SettingsView via "Generate Insurance Report" button
// Always ensure new services are accessible from the UI!

import Foundation
import PDFKit
import SwiftData
import SwiftUI

@MainActor
public final class InsuranceReportService: ObservableObject {
    public enum ReportError: LocalizedError {
        case noItems
        case pdfGenerationFailed
        case dataAccessError

        public var errorDescription: String? {
            switch self {
            case .noItems:
                "No items to include in report"
            case .pdfGenerationFailed:
                "Failed to generate PDF report"
            case .dataAccessError:
                "Could not access inventory data"
            }
        }
    }

    public struct ReportOptions {
        public var includePhotos: Bool = true
        public var includeReceipts: Bool = true
        public var includeDepreciation: Bool = false
        public var groupByRoom: Bool = true
        public var includeSerialNumbers: Bool = true
        public var includePurchaseInfo: Bool = true
        public var includeTotalValue: Bool = true

        public init() {}
    }

    public struct ReportMetadata {
        public let generatedDate: Date
        public let totalItems: Int
        public let totalValue: Decimal
        public let reportId: UUID
        public let propertyAddress: String?
        public let policyNumber: String?

        public init(
            totalItems: Int,
            totalValue: Decimal,
            propertyAddress: String? = nil,
            policyNumber: String? = nil
        ) {
            generatedDate = Date()
            self.totalItems = totalItems
            self.totalValue = totalValue
            reportId = UUID()
            self.propertyAddress = propertyAddress
            self.policyNumber = policyNumber
        }
    }

    public init() {}

    // Generate PDF report with proper concurrency
    public func generateInsuranceReport(
        items: [Item],
        categories: [Category],
        options: ReportOptions = ReportOptions()
    ) async throws -> Data {
        guard !items.isEmpty else {
            throw ReportError.noItems
        }

        return try await withCheckedThrowingContinuation { continuation in
            Task { @MainActor in
                do {
                    let pdfData = try createPDF(
                        items: items,
                        categories: categories,
                        options: options
                    )
                    continuation.resume(returning: pdfData)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    @MainActor
    private func createPDF(
        items: [Item],
        categories: [Category],
        options: ReportOptions
    ) throws -> Data {
        let metadata = ReportMetadata(
            totalItems: items.count,
            totalValue: calculateTotalValue(items: items)
        )

        // Create PDF document
        let format = UIGraphicsPDFRendererFormat()
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792) // Letter size

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let data = renderer.pdfData { context in
            context.beginPage()

            var yPosition: CGFloat = 50

            // Header
            yPosition = drawHeader(in: context, at: yPosition, metadata: metadata)

            // Summary section
            yPosition = drawSummary(in: context, at: yPosition, items: items, categories: categories)

            // Items by category/room
            if options.groupByRoom {
                yPosition = drawItemsByCategory(
                    in: context,
                    startingAt: yPosition,
                    items: items,
                    categories: categories,
                    options: options
                )
            } else {
                yPosition = drawItemsList(
                    in: context,
                    startingAt: yPosition,
                    items: items,
                    options: options
                )
            }

            // Footer on last page
            drawFooter(in: context, metadata: metadata)
        }

        return data
    }

    private func drawHeader(
        in _: UIGraphicsPDFRendererContext,
        at yPosition: CGFloat,
        metadata: ReportMetadata
    ) -> CGFloat {
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 24),
            .foregroundColor: UIColor.label,
        ]

        let title = "Home Inventory Insurance Report"
        title.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: titleAttributes)

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short

        let subtitleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.secondaryLabel,
        ]

        let subtitle = "Generated: \(dateFormatter.string(from: metadata.generatedDate))"
        subtitle.draw(at: CGPoint(x: 50, y: yPosition + 30), withAttributes: subtitleAttributes)

        let reportId = "Report ID: \(metadata.reportId.uuidString)"
        reportId.draw(at: CGPoint(x: 50, y: yPosition + 45), withAttributes: subtitleAttributes)

        return yPosition + 70
    }

    private func drawSummary(
        in _: UIGraphicsPDFRendererContext,
        at yPosition: CGFloat,
        items: [Item],
        categories: [Category]
    ) -> CGFloat {
        var currentY = yPosition + 20

        let sectionAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor: UIColor.label,
        ]

        "Executive Summary".draw(at: CGPoint(x: 50, y: currentY), withAttributes: sectionAttributes)
        currentY += 25

        let bodyAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.label,
        ]

        let totalValue = calculateTotalValue(items: items)
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"

        let summaryItems = [
            "Total Items: \(items.count)",
            "Total Categories: \(categories.count)",
            "Total Declared Value: \(formatter.string(from: totalValue as NSNumber) ?? "$0")",
            "Items with Photos: \(items.count(where: { $0.imageData != nil }))",
            "Items with Serial Numbers: \(items.count(where: { $0.serialNumber != nil }))",
        ]

        for item in summaryItems {
            item.draw(at: CGPoint(x: 70, y: currentY), withAttributes: bodyAttributes)
            currentY += 18
        }

        return currentY + 10
    }

    private func drawItemsByCategory(
        in context: UIGraphicsPDFRendererContext,
        startingAt yPosition: CGFloat,
        items: [Item],
        categories: [Category],
        options: ReportOptions
    ) -> CGFloat {
        var currentY = yPosition + 20
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 50

        let sectionAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor: UIColor.label,
        ]

        "Inventory Details".draw(at: CGPoint(x: 50, y: currentY), withAttributes: sectionAttributes)
        currentY += 30

        // Group items by category
        for category in categories {
            let categoryItems = items.filter { $0.category?.id == category.id }
            guard !categoryItems.isEmpty else { continue }

            // Check if we need a new page
            if currentY > pageHeight - 150 {
                context.beginPage()
                currentY = margin
            }

            // Draw category header
            let categoryAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 14),
                .foregroundColor: UIColor.systemBlue,
            ]

            category.name.draw(at: CGPoint(x: 60, y: currentY), withAttributes: categoryAttributes)
            currentY += 20

            // Draw items in category
            for item in categoryItems {
                currentY = drawItemDetails(
                    item: item,
                    in: context,
                    at: currentY,
                    options: options
                )

                // Check page break
                if currentY > pageHeight - 100 {
                    context.beginPage()
                    currentY = margin
                }
            }

            currentY += 15 // Space between categories
        }

        // Uncategorized items
        let uncategorizedItems = items.filter { $0.category == nil }
        if !uncategorizedItems.isEmpty {
            if currentY > pageHeight - 150 {
                context.beginPage()
                currentY = margin
            }

            "Uncategorized Items".draw(at: CGPoint(x: 60, y: currentY), withAttributes: sectionAttributes)
            currentY += 20

            for item in uncategorizedItems {
                currentY = drawItemDetails(
                    item: item,
                    in: context,
                    at: currentY,
                    options: options
                )

                if currentY > pageHeight - 100 {
                    context.beginPage()
                    currentY = margin
                }
            }
        }

        return currentY
    }

    private func drawItemsList(
        in context: UIGraphicsPDFRendererContext,
        startingAt yPosition: CGFloat,
        items: [Item],
        options: ReportOptions
    ) -> CGFloat {
        var currentY = yPosition

        for item in items {
            currentY = drawItemDetails(
                item: item,
                in: context,
                at: currentY,
                options: options
            )
        }

        return currentY
    }

    private func drawItemDetails(
        item: Item,
        in _: UIGraphicsPDFRendererContext,
        at yPosition: CGFloat,
        options: ReportOptions
    ) -> CGFloat {
        var currentY = yPosition

        let nameAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 12),
            .foregroundColor: UIColor.label,
        ]

        let detailAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.secondaryLabel,
        ]

        // Item name
        item.name.draw(at: CGPoint(x: 80, y: currentY), withAttributes: nameAttributes)
        currentY += 16

        // Build detail string
        var details: [String] = []

        if let brand = item.brand {
            details.append("Brand: \(brand)")
        }

        if let model = item.modelNumber {
            details.append("Model: \(model)")
        }

        if options.includeSerialNumbers, let serial = item.serialNumber {
            details.append("Serial: \(serial)")
        }

        if options.includePurchaseInfo {
            if let price = item.purchasePrice {
                let formatter = NumberFormatter()
                formatter.numberStyle = .currency
                formatter.currencyCode = item.currency
                details.append("Value: \(formatter.string(from: price as NSNumber) ?? "$0")")
            }

            if let date = item.purchaseDate {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                details.append("Purchased: \(formatter.string(from: date))")
            }
        }

        details.append("Quantity: \(item.quantity)")

        // Draw details
        for detail in details {
            detail.draw(at: CGPoint(x: 90, y: currentY), withAttributes: detailAttributes)
            currentY += 14
        }

        if let description = item.itemDescription {
            let truncated = String(description.prefix(100))
            truncated.draw(at: CGPoint(x: 90, y: currentY), withAttributes: detailAttributes)
            currentY += 14
        }

        return currentY + 8
    }

    private func drawFooter(
        in _: UIGraphicsPDFRendererContext,
        metadata _: ReportMetadata
    ) {
        let footerAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.tertiaryLabel,
        ]

        let footer = "Nestory Home Inventory - Confidential Insurance Documentation"
        let footerSize = footer.size(withAttributes: footerAttributes)
        let footerRect = CGRect(
            x: (612 - footerSize.width) / 2,
            y: 792 - 40,
            width: footerSize.width,
            height: footerSize.height
        )

        footer.draw(in: footerRect, withAttributes: footerAttributes)
    }

    private func calculateTotalValue(items: [Item]) -> Decimal {
        items.reduce(Decimal(0)) { total, item in
            let itemValue = (item.purchasePrice ?? 0) * Decimal(item.quantity)
            return total + itemValue
        }
    }
}

// MARK: - Export Options Extension

public extension InsuranceReportService {
    @MainActor
    func exportReport(
        _ data: Data,
        filename: String = "HomeInventory_Insurance_Report"
    ) async throws -> URL {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
            .replacingOccurrences(of: "/", with: "-")

        let fileName = "\(filename)_\(timestamp).pdf"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        try data.write(to: tempURL)
        return tempURL
    }

    @MainActor
    func shareReport(_ url: URL) async {
        let activityVC = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController
        {
            // Handle iPad popover
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = rootVC.view
                popover.sourceRect = CGRect(x: rootVC.view.bounds.midX, y: rootVC.view.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }

            rootVC.present(activityVC, animated: true)
        }
    }
}
