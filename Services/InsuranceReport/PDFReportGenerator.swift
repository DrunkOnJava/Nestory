//
// Layer: Services
// Module: InsuranceReport
// Purpose: Generate PDF documents for insurance reports
//

import Foundation
import PDFKit
import UIKit

// APPLE_FRAMEWORK_OPPORTUNITY: Replace with PDFKit - Already using PDFKit but could leverage PDFDocument for more advanced features

@MainActor
public struct PDFReportGenerator {
    private let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792) // Letter size
    private let margin: CGFloat = 50
    private let pageHeight: CGFloat = 792

    public init() {}

    public func generatePDF(
        items: [Item],
        categories: [Category],
        options: ReportOptions,
        metadata: ReportMetadata,
    ) throws -> Data {
        let format = UIGraphicsPDFRendererFormat()
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let sectionDrawer = ReportSectionDrawer()

        let data = renderer.pdfData { context in
            context.beginPage()

            var yPosition: CGFloat = margin

            // Draw header
            yPosition = sectionDrawer.drawHeader(
                in: context,
                at: yPosition,
                metadata: metadata,
            )

            // Draw summary
            yPosition = sectionDrawer.drawSummary(
                in: context,
                at: yPosition,
                items: items,
                categories: categories,
            )

            // Draw items based on grouping preference
            if options.groupByRoom {
                yPosition = drawItemsByCategory(
                    in: context,
                    startingAt: yPosition,
                    items: items,
                    categories: categories,
                    options: options,
                    sectionDrawer: sectionDrawer,
                )
            } else {
                yPosition = drawItemsList(
                    in: context,
                    startingAt: yPosition,
                    items: items,
                    options: options,
                    sectionDrawer: sectionDrawer,
                )
            }

            // Draw footer
            sectionDrawer.drawFooter(in: context, metadata: metadata)
        }

        return data
    }

    private func drawItemsByCategory(
        in context: UIGraphicsPDFRendererContext,
        startingAt yPosition: CGFloat,
        items: [Item],
        categories: [Category],
        options: ReportOptions,
        sectionDrawer: ReportSectionDrawer,
    ) -> CGFloat {
        var currentY = yPosition + 20

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
            currentY = sectionDrawer.drawCategoryHeader(
                category: category,
                in: context,
                at: currentY,
            )

            // Draw items in category
            for item in categoryItems {
                currentY = sectionDrawer.drawItemDetails(
                    item: item,
                    in: context,
                    at: currentY,
                    options: options,
                )

                // Check page break
                if currentY > pageHeight - 100 {
                    context.beginPage()
                    currentY = margin
                }
            }

            currentY += 15 // Space between categories
        }

        // Handle uncategorized items
        currentY = drawUncategorizedItems(
            items: items,
            in: context,
            at: currentY,
            options: options,
            sectionDrawer: sectionDrawer,
        )

        return currentY
    }

    private func drawItemsList(
        in context: UIGraphicsPDFRendererContext,
        startingAt yPosition: CGFloat,
        items: [Item],
        options: ReportOptions,
        sectionDrawer: ReportSectionDrawer,
    ) -> CGFloat {
        var currentY = yPosition

        for item in items {
            currentY = sectionDrawer.drawItemDetails(
                item: item,
                in: context,
                at: currentY,
                options: options,
            )

            if currentY > pageHeight - 100 {
                context.beginPage()
                currentY = margin
            }
        }

        return currentY
    }

    private func drawUncategorizedItems(
        items: [Item],
        in context: UIGraphicsPDFRendererContext,
        at yPosition: CGFloat,
        options: ReportOptions,
        sectionDrawer: ReportSectionDrawer,
    ) -> CGFloat {
        var currentY = yPosition
        let uncategorizedItems = items.filter { $0.category == nil }

        guard !uncategorizedItems.isEmpty else { return currentY }

        if currentY > pageHeight - 150 {
            context.beginPage()
            currentY = margin
        }

        let sectionAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 14),
            .foregroundColor: UIColor.systemBlue,
        ]

        "Uncategorized Items".draw(at: CGPoint(x: 60, y: currentY), withAttributes: sectionAttributes)
        currentY += 20

        for item in uncategorizedItems {
            currentY = sectionDrawer.drawItemDetails(
                item: item,
                in: context,
                at: currentY,
                options: options,
            )

            if currentY > pageHeight - 100 {
                context.beginPage()
                currentY = margin
            }
        }

        return currentY
    }
}
