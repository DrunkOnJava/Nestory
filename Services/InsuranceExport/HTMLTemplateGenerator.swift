//
// Layer: Services
// Module: InsuranceExport
// Purpose: Generate HTML templates for insurance reports
//

import Foundation

public enum HTMLTemplateGenerator {
    public static func generateStyles() -> String {
        """
        <style>
            body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; margin: 20px; }
            .header { background: #f0f0f0; padding: 20px; margin-bottom: 30px; }
            .header h1 { margin: 0; color: #333; }
            .metadata { margin: 10px 0; color: #666; }
            .summary-box { background: #fff; border: 2px solid #007AFF; padding: 15px; margin: 20px 0; }
            .summary-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; }
            .summary-item { text-align: center; }
            .summary-value { font-size: 24px; font-weight: bold; color: #007AFF; }
            .summary-label { color: #666; font-size: 12px; }
            .section { margin: 30px 0; page-break-inside: avoid; }
            .section-title { font-size: 18px; font-weight: bold; border-bottom: 2px solid #007AFF; padding-bottom: 5px; margin-bottom: 15px; }
            .item-card { border: 1px solid #ddd; padding: 15px; margin: 15px 0; page-break-inside: avoid; }
            .item-header { display: flex; justify-content: space-between; margin-bottom: 10px; }
            .item-name { font-weight: bold; font-size: 16px; }
            .item-value { color: #007AFF; font-weight: bold; }
            .item-details { display: grid; grid-template-columns: repeat(2, 1fr); gap: 10px; margin: 10px 0; }
            .detail-row { font-size: 12px; }
            .detail-label { color: #666; }
            .photo-section { margin-top: 15px; }
            .photo-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 10px; }
            .photo-item { width: 100%; height: 150px; object-fit: cover; border: 1px solid #ddd; }
            .footer { margin-top: 50px; padding-top: 20px; border-top: 2px solid #ccc; color: #666; font-size: 12px; }
            .page-break { page-break-after: always; }
            @media print {
                .item-card { page-break-inside: avoid; }
                .section { page-break-inside: avoid; }
            }
        </style>
        """
    }

    public static func generateHeader(options: ExportOptions) -> String {
        """
        <div class="header">
            <h1>Home Inventory Insurance Documentation</h1>
            <div class="metadata">
                <div>Policy Holder: \(DataFormatHelpers.escapeHTML(options.policyHolderName ?? "Not Specified"))</div>
                <div>Policy Number: \(DataFormatHelpers.escapeHTML(options.policyNumber ?? "Not Specified"))</div>
                <div>Property Address: \(DataFormatHelpers.escapeHTML(options.propertyAddress ?? "Not Specified"))</div>
                <div>Report Date: \(Date().formatted(date: .complete, time: .omitted))</div>
            </div>
        </div>
        """
    }

    public static func generateSummarySection(items: [Item], rooms: [Room]) -> String {
        let totalValue = items.compactMap(\.purchasePrice).reduce(0, +)
        let itemsWithReceipts = items.count(where: { $0.receiptImageData != nil })
        let itemsWithSerialNumbers = items.count(where: { $0.serialNumber != nil })
        let itemsWithWarranty = items.count(where: { $0.warrantyExpirationDate != nil })

        return """
        <div class="summary-box">
            <h2>Inventory Summary</h2>
            <div class="summary-grid">
                <div class="summary-item">
                    <div class="summary-value">\(items.count)</div>
                    <div class="summary-label">Total Items</div>
                </div>
                <div class="summary-item">
                    <div class="summary-value">\(DataFormatHelpers.formatCurrency(totalValue))</div>
                    <div class="summary-label">Total Value</div>
                </div>
                <div class="summary-item">
                    <div class="summary-value">\(itemsWithReceipts)</div>
                    <div class="summary-label">Items with Receipts</div>
                </div>
                <div class="summary-item">
                    <div class="summary-value">\(itemsWithSerialNumbers)</div>
                    <div class="summary-label">Items with Serial #</div>
                </div>
                <div class="summary-item">
                    <div class="summary-value">\(itemsWithWarranty)</div>
                    <div class="summary-label">Under Warranty</div>
                </div>
                <div class="summary-item">
                    <div class="summary-value">\(rooms.count)</div>
                    <div class="summary-label">Rooms Documented</div>
                </div>
            </div>
        </div>
        """
    }

    public static func generateFooter(items: [Item]) -> String {
        let totalValue = items.compactMap(\.purchasePrice).reduce(0, +)

        return """
        <div class="footer">
            <p><strong>Important Notice:</strong> This inventory documentation is prepared for insurance purposes. 
            All values and descriptions are based on owner-provided information. 
            Professional appraisal may be required for high-value items.</p>
            <p>Generated by Nestory Home Inventory App on \(Date().formatted())</p>
            <p>This document contains \(items.count) items with a total declared value of \(DataFormatHelpers.formatCurrency(totalValue))</p>
        </div>
        """
    }
}
