//
// Layer: Services
// Module: InsuranceClaim/ClaimDocumentGenerator
// Purpose: Specialized PDF generation for claim documents with layout and rendering
//

import Foundation
import PDFKit
import UIKit

@MainActor
public struct ClaimPDFGenerator {
    private let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792) // Letter size
    private let margin: CGFloat = 50

    public init() {}

    // MARK: - PDF Generation

    public func generatePDF(
        request: ClaimRequest,
        template: ClaimTemplate
    ) async throws -> Data {
        let format = UIGraphicsPDFRendererFormat()
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let data = renderer.pdfData { context in
            context.beginPage()

            var yPosition: CGFloat = margin

            // Draw claim header
            yPosition = drawClaimHeader(
                in: context,
                at: yPosition,
                request: request,
                template: template
            )

            // Draw incident details
            yPosition = drawIncidentDetails(
                in: context,
                at: yPosition,
                request: request
            )

            // Draw contact information
            yPosition = drawContactInformation(
                in: context,
                at: yPosition,
                request: request
            )

            // Draw items table
            yPosition = drawItemsTable(
                in: context,
                at: yPosition,
                request: request
            )

            // Draw photos section
            if request.format == .detailedPDF {
                yPosition = drawPhotosSection(
                    in: context,
                    at: yPosition,
                    request: request
                )
            }

            // Draw summary and totals
            yPosition = drawSummarySection(
                in: context,
                at: yPosition,
                request: request
            )

            // Draw signature section
            drawSignatureSection(
                in: context,
                at: yPosition,
                template: template
            )
        }

        return data
    }

    // MARK: - Drawing Methods

    private func drawClaimHeader(
        in _: UIGraphicsPDFRendererContext,
        at yPosition: CGFloat,
        request: ClaimRequest,
        template: ClaimTemplate
    ) -> CGFloat {
        var currentY = yPosition

        // Company logo area (if available)
        let logoRect = CGRect(x: margin, y: currentY, width: 100, height: 60)
        if let logoData = template.logoData,
           let logoImage = UIImage(data: logoData)
        {
            logoImage.draw(in: logoRect)
        }

        // Claim title
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 20),
            .foregroundColor: UIColor.label,
        ]

        let title = "\(request.insuranceCompany.rawValue) Insurance Claim"
        let titleSize = title.size(withAttributes: titleAttributes)
        let titleX = pageRect.width - margin - titleSize.width
        title.draw(at: CGPoint(x: titleX, y: currentY), withAttributes: titleAttributes)

        currentY += max(60, titleSize.height) + 20

        // Claim type and basic info
        let headerAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.label,
        ]

        let claimInfo = """
        Claim Type: \(request.claimType.rawValue)
        Incident Date: \(ClaimDocumentHelpers.formatDate(request.incidentDate))
        Claim ID: \(request.id.uuidString.prefix(8))
        Generated: \(ClaimDocumentHelpers.formatDate(request.createdAt))
        """

        if let policyNumber = request.policyNumber {
            let policyInfo = "Policy Number: \(policyNumber)"
            policyInfo.draw(at: CGPoint(x: margin, y: currentY), withAttributes: headerAttributes)
            currentY += 20
        }

        claimInfo.draw(at: CGPoint(x: margin, y: currentY), withAttributes: headerAttributes)
        currentY += 80

        // Draw separator line
        let separatorPath = UIBezierPath()
        separatorPath.move(to: CGPoint(x: margin, y: currentY))
        separatorPath.addLine(to: CGPoint(x: pageRect.width - margin, y: currentY))
        UIColor.systemGray.setStroke()
        separatorPath.stroke()

        return currentY + 20
    }

    private func drawIncidentDetails(
        in _: UIGraphicsPDFRendererContext,
        at yPosition: CGFloat,
        request: ClaimRequest
    ) -> CGFloat {
        var currentY = yPosition

        let sectionAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor: UIColor.label,
        ]

        let detailAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.label,
        ]

        "Incident Details".draw(at: CGPoint(x: margin, y: currentY), withAttributes: sectionAttributes)
        currentY += 25

        let incidentDescription = request.incidentDescription
        let descriptionRect = CGRect(
            x: margin,
            y: currentY,
            width: pageRect.width - (2 * margin),
            height: 100
        )

        incidentDescription.draw(in: descriptionRect, withAttributes: detailAttributes)
        return currentY + 120
    }

    private func drawContactInformation(
        in _: UIGraphicsPDFRendererContext,
        at yPosition: CGFloat,
        request: ClaimRequest
    ) -> CGFloat {
        var currentY = yPosition

        let sectionAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor: UIColor.label,
        ]

        let detailAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.label,
        ]

        "Contact Information".draw(at: CGPoint(x: margin, y: currentY), withAttributes: sectionAttributes)
        currentY += 25

        let contactInfo = """
        Phone: \(request.contactInfo.phone)
        Email: \(request.contactInfo.email)
        Address: \(request.contactInfo.address)
        """

        contactInfo.draw(at: CGPoint(x: margin, y: currentY), withAttributes: detailAttributes)
        return currentY + 80
    }

    private func drawItemsTable(
        in _: UIGraphicsPDFRendererContext,
        at yPosition: CGFloat,
        request: ClaimRequest
    ) -> CGFloat {
        var currentY = yPosition

        let sectionAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor: UIColor.label,
        ]

        "Claimed Items".draw(at: CGPoint(x: margin, y: currentY), withAttributes: sectionAttributes)
        currentY += 30

        // Draw table headers
        let headerAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 10),
            .foregroundColor: UIColor.label,
        ]

        let itemAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9),
            .foregroundColor: UIColor.label,
        ]

        let tableWidth = pageRect.width - (2 * margin)
        let columnWidths = [
            tableWidth * 0.4,  // Name
            tableWidth * 0.2,  // Category
            tableWidth * 0.2,  // Value
            tableWidth * 0.2,  // Status
        ]

        let headers = ["Item Name", "Category", "Value", "Status"]
        var xOffset = margin
        
        for (index, header) in headers.enumerated() {
            let headerRect = CGRect(x: xOffset, y: currentY, width: columnWidths[index], height: 20)
            header.draw(in: headerRect, withAttributes: headerAttributes)
            xOffset += columnWidths[index]
        }

        currentY += 25

        // Draw table rows
        let items = request.items
        let maxItems = min(items.count, 15) // Limit for page space
        for i in 0..<maxItems {
            let item = items[i]
            xOffset = margin
            let rowData = [
                item.name,
                item.category?.name ?? "N/A",
                ClaimDocumentHelpers.formatCurrency(item.purchasePrice),
                "Claimed"
            ]

            for (index, data) in rowData.enumerated() {
                let cellRect = CGRect(x: xOffset, y: currentY, width: columnWidths[index], height: 15)
                data.draw(in: cellRect, withAttributes: itemAttributes)
                xOffset += columnWidths[index]
            }
            currentY += 18
        }

        if items.count > maxItems {
            let remainingText = "... and \(items.count - maxItems) more items"
            remainingText.draw(at: CGPoint(x: margin, y: currentY), withAttributes: itemAttributes)
            currentY += 20
        }

        return currentY + 20
    }

    private func drawPhotosSection(
        in context: UIGraphicsPDFRendererContext,
        at yPosition: CGFloat,
        request: ClaimRequest
    ) -> CGFloat {
        var currentY = yPosition

        let sectionAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor: UIColor.label,
        ]

        "Supporting Photos".draw(at: CGPoint(x: margin, y: currentY), withAttributes: sectionAttributes)
        currentY += 30

        // Would implement photo rendering logic here
        let photoPlaceholderText = "Photos would be embedded here based on item selections"
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.italicSystemFont(ofSize: 12),
            .foregroundColor: UIColor.secondaryLabel,
        ]
        
        photoPlaceholderText.draw(at: CGPoint(x: margin, y: currentY), withAttributes: placeholderAttributes)
        
        return currentY + 40
    }

    private func drawSummarySection(
        in _: UIGraphicsPDFRendererContext,
        at yPosition: CGFloat,
        request: ClaimRequest
    ) -> CGFloat {
        var currentY = yPosition

        let sectionAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor: UIColor.label,
        ]

        let summaryAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.label,
        ]

        let totalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 14),
            .foregroundColor: UIColor.label,
        ]

        "Claim Summary".draw(at: CGPoint(x: margin, y: currentY), withAttributes: sectionAttributes)
        currentY += 25

        let selectedItems = request.items

        let itemCount = "Total Items: \(selectedItems.count)"
        let totalValue = "Total Claimed Value: \(ClaimDocumentHelpers.formatCurrency(ClaimDocumentHelpers.calculateTotalValue(for: selectedItems)))"

        itemCount.draw(at: CGPoint(x: margin, y: currentY), withAttributes: summaryAttributes)
        currentY += 20

        totalValue.draw(at: CGPoint(x: margin, y: currentY), withAttributes: totalAttributes)
        currentY += 30

        return currentY
    }

    private func drawSignatureSection(
        in _: UIGraphicsPDFRendererContext,
        at yPosition: CGFloat,
        template: ClaimTemplate
    ) {
        var currentY = yPosition

        let sectionAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor: UIColor.label,
        ]

        let labelAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.label,
        ]

        "Signature".draw(at: CGPoint(x: margin, y: currentY), withAttributes: sectionAttributes)
        currentY += 40

        // Signature line
        let signaturePath = UIBezierPath()
        let signatureY = currentY + 20
        signaturePath.move(to: CGPoint(x: margin, y: signatureY))
        signaturePath.addLine(to: CGPoint(x: pageRect.width - margin - 200, y: signatureY))
        UIColor.label.setStroke()
        signaturePath.stroke()

        "Signature".draw(at: CGPoint(x: margin, y: signatureY + 5), withAttributes: labelAttributes)
        
        // Date line
        let datePath = UIBezierPath()
        let dateX = pageRect.width - margin - 150
        datePath.move(to: CGPoint(x: dateX, y: signatureY))
        datePath.addLine(to: CGPoint(x: pageRect.width - margin, y: signatureY))
        datePath.stroke()
        
        "Date".draw(at: CGPoint(x: dateX, y: signatureY + 5), withAttributes: labelAttributes)
    }

    // MARK: - Helper Methods

    private func getItemById(_ id: UUID, from items: [Item]) -> Item? {
        items.first { $0.id == id }
    }
}