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
            .font: UIFont.boldSystemFont(ofSize: PDFConstants.FontSize.title),
            .foregroundColor: UIColor.label,
        ]

        let title = "Home Inventory Insurance Report"
        title.draw(at: CGPoint(x: PDFConstants.Indent.none, y: yPosition), withAttributes: titleAttributes)

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short

        let subtitleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: PDFConstants.FontSize.body),
            .foregroundColor: UIColor.secondaryLabel,
        ]

        let subtitle = "Generated: \(dateFormatter.string(from: metadata.generatedDate))"
        subtitle.draw(at: CGPoint(x: PDFConstants.Indent.none, y: yPosition + PDFConstants.LineHeight.title), withAttributes: subtitleAttributes)

        let reportId = "Report ID: \(metadata.reportId.uuidString)"
        reportId.draw(at: CGPoint(x: PDFConstants.Indent.none, y: yPosition + PDFConstants.Spacing.titleBelow), withAttributes: subtitleAttributes)

        // Add policy info if available
        var offsetY: CGFloat = PDFConstants.Spacing.subtitleBelow
        if let policyNumber = metadata.policyNumber {
            "Policy #: \(policyNumber)".draw(
                at: CGPoint(x: PDFConstants.Indent.none, y: yPosition + offsetY),
                withAttributes: subtitleAttributes,
            )
            offsetY += PDFConstants.Spacing.medium
        }

        if let address = metadata.propertyAddress {
            "Property: \(address)".draw(
                at: CGPoint(x: PDFConstants.Indent.none, y: yPosition + offsetY),
                withAttributes: subtitleAttributes,
            )
            offsetY += PDFConstants.Spacing.medium
        }

        return yPosition + offsetY + PDFConstants.Spacing.small
    }

    // MARK: - Summary Section

    public func drawSummary(
        in _: UIGraphicsPDFRendererContext,
        at yPosition: CGFloat,
        items: [Item],
        categories: [Category],
    ) -> CGFloat {
        var currentY = yPosition + PDFConstants.Spacing.large

        let sectionAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: PDFConstants.FontSize.sectionHeader),
            .foregroundColor: UIColor.label,
        ]

        "Executive Summary".draw(at: CGPoint(x: PDFConstants.Indent.none, y: currentY), withAttributes: sectionAttributes)
        currentY += PDFConstants.Spacing.extraLarge

        let bodyAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: PDFConstants.FontSize.body),
            .foregroundColor: UIColor.label,
        ]

        let formatter = ReportDataFormatter()
        let summaryItems = formatter.generateSummaryItems(items: items, categories: categories)

        for item in summaryItems {
            item.draw(at: CGPoint(x: PDFConstants.Indent.item, y: currentY), withAttributes: bodyAttributes)
            currentY += PDFConstants.LineHeight.body
        }

        return currentY + PDFConstants.Spacing.small
    }

    // MARK: - Category Header

    public func drawCategoryHeader(
        category: Category,
        in _: UIGraphicsPDFRendererContext,
        at yPosition: CGFloat,
    ) -> CGFloat {
        let categoryAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: PDFConstants.FontSize.categoryHeader),
            .foregroundColor: UIColor.systemBlue,
        ]

        category.name.draw(at: CGPoint(x: PDFConstants.Indent.category, y: yPosition), withAttributes: categoryAttributes)
        return yPosition + PDFConstants.Spacing.large
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
            .font: UIFont.boldSystemFont(ofSize: PDFConstants.FontSize.itemName),
            .foregroundColor: UIColor.label,
        ]

        let detailAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: PDFConstants.FontSize.detail),
            .foregroundColor: UIColor.secondaryLabel,
        ]

        // Item name
        item.name.draw(at: CGPoint(x: PDFConstants.Indent.itemName, y: currentY), withAttributes: nameAttributes)
        currentY += PDFConstants.LineHeight.item

        // Build and draw detail strings
        let formatter = ReportDataFormatter()
        let details = formatter.generateItemDetails(item: item, options: options)

        for detail in details {
            detail.draw(at: CGPoint(x: PDFConstants.Indent.detail, y: currentY), withAttributes: detailAttributes)
            currentY += PDFConstants.LineHeight.detail
        }

        // Add description if available
        if let description = item.itemDescription {
            let truncated = String(description.prefix(PDFConstants.Content.maxDescriptionLength))
            truncated.draw(at: CGPoint(x: PDFConstants.Indent.detail, y: currentY), withAttributes: detailAttributes)
            currentY += PDFConstants.LineHeight.detail
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
