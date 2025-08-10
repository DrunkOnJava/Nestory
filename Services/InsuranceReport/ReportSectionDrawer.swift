//
// Layer: Services
// Module: InsuranceReport
// Purpose: Draw individual sections of insurance PDF reports
//

import Foundation
import UIKit

@MainActor
public struct ReportSectionDrawer {
    public init() {}

    // MARK: - Header Section

    public func drawHeader(
        in _: UIGraphicsPDFRendererContext,
        at yPosition: CGFloat,
        metadata: InsuranceReportService.ReportMetadata,
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

        // Add policy info if available
        var offsetY: CGFloat = 60
        if let policyNumber = metadata.policyNumber {
            "Policy #: \(policyNumber)".draw(
                at: CGPoint(x: 50, y: yPosition + offsetY),
                withAttributes: subtitleAttributes,
            )
            offsetY += 15
        }

        if let address = metadata.propertyAddress {
            "Property: \(address)".draw(
                at: CGPoint(x: 50, y: yPosition + offsetY),
                withAttributes: subtitleAttributes,
            )
            offsetY += 15
        }

        return yPosition + offsetY + 10
    }

    // MARK: - Summary Section

    public func drawSummary(
        in _: UIGraphicsPDFRendererContext,
        at yPosition: CGFloat,
        items: [Item],
        categories: [Category],
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

        let formatter = ReportDataFormatter()
        let summaryItems = formatter.generateSummaryItems(items: items, categories: categories)

        for item in summaryItems {
            item.draw(at: CGPoint(x: 70, y: currentY), withAttributes: bodyAttributes)
            currentY += 18
        }

        return currentY + 10
    }

    // MARK: - Category Header

    public func drawCategoryHeader(
        category: Category,
        in _: UIGraphicsPDFRendererContext,
        at yPosition: CGFloat,
    ) -> CGFloat {
        let categoryAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 14),
            .foregroundColor: UIColor.systemBlue,
        ]

        category.name.draw(at: CGPoint(x: 60, y: yPosition), withAttributes: categoryAttributes)
        return yPosition + 20
    }

    // MARK: - Item Details

    public func drawItemDetails(
        item: Item,
        in _: UIGraphicsPDFRendererContext,
        at yPosition: CGFloat,
        options: InsuranceReportService.ReportOptions,
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

        // Build and draw detail strings
        let formatter = ReportDataFormatter()
        let details = formatter.generateItemDetails(item: item, options: options)

        for detail in details {
            detail.draw(at: CGPoint(x: 90, y: currentY), withAttributes: detailAttributes)
            currentY += 14
        }

        // Add description if available
        if let description = item.itemDescription {
            let truncated = String(description.prefix(100))
            truncated.draw(at: CGPoint(x: 90, y: currentY), withAttributes: detailAttributes)
            currentY += 14
        }

        return currentY + 8
    }

    // MARK: - Footer

    public func drawFooter(
        in _: UIGraphicsPDFRendererContext,
        metadata _: InsuranceReportService.ReportMetadata,
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
            height: footerSize.height,
        )

        footer.draw(in: footerRect, withAttributes: footerAttributes)
    }
}
