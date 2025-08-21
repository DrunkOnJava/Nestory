//
// Layer: Services
// Module: InsuranceClaim/ClaimDocumentGenerator
// Purpose: HTML package generation for web-based claim documents with embedded assets
//

import Foundation

public struct ClaimHTMLGenerator {
    public init() {}

    // MARK: - HTML Generation

    public func generateHTML(
        request: InsuranceClaimService.ClaimRequest,
        template: ClaimTemplate
    ) throws -> Data {
        let htmlContent = buildHTMLDocument(request: request, template: template)
        
        guard let data = htmlContent.data(using: .utf8) else {
            throw ClaimDocumentCore.GenerationError.documentCreationFailed
        }
        
        return data
    }

    // MARK: - HTML Document Building

    private func buildHTMLDocument(
        request: InsuranceClaimService.ClaimRequest,
        template: ClaimTemplate
    ) -> String {
        return """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>\(request.insuranceCompany.rawValue) Insurance Claim</title>
            \(generateCSS())
        </head>
        <body>
            <div class="container">
                \(generateHeader(request: request, template: template))
                \(generateIncidentDetails(request: request))
                \(generateContactInformation(request: request))
                \(generateItemsTable(request: request))
                \(generateSummarySection(request: request))
                \(generateSignatureSection())
            </div>
            \(generateJavaScript())
        </body>
        </html>
        """
    }

    private func generateCSS() -> String {
        return """
        <style>
            body {
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                line-height: 1.6;
                color: #333;
                background-color: #f5f5f5;
                margin: 0;
                padding: 20px;
            }
            .container {
                max-width: 800px;
                margin: 0 auto;
                background: white;
                padding: 40px;
                border-radius: 8px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            }
            .header {
                display: flex;
                justify-content: space-between;
                align-items: flex-start;
                margin-bottom: 30px;
                padding-bottom: 20px;
                border-bottom: 2px solid #e0e0e0;
            }
            .logo-section {
                flex: 1;
            }
            .title-section {
                flex: 2;
                text-align: right;
            }
            .title {
                font-size: 24px;
                font-weight: bold;
                color: #2c3e50;
                margin-bottom: 10px;
            }
            .claim-info {
                background-color: #f8f9fa;
                padding: 15px;
                border-radius: 6px;
                margin-bottom: 20px;
            }
            .section {
                margin-bottom: 30px;
            }
            .section-title {
                font-size: 18px;
                font-weight: bold;
                color: #2c3e50;
                margin-bottom: 15px;
                padding-bottom: 8px;
                border-bottom: 1px solid #e0e0e0;
            }
            .items-table {
                width: 100%;
                border-collapse: collapse;
                margin-bottom: 20px;
            }
            .items-table th,
            .items-table td {
                padding: 12px;
                text-align: left;
                border-bottom: 1px solid #e0e0e0;
            }
            .items-table th {
                background-color: #f8f9fa;
                font-weight: bold;
            }
            .items-table tr:hover {
                background-color: #f8f9fa;
            }
            .summary-stats {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                gap: 15px;
                margin-bottom: 20px;
            }
            .stat-card {
                background-color: #f8f9fa;
                padding: 15px;
                border-radius: 6px;
                text-align: center;
            }
            .stat-value {
                font-size: 24px;
                font-weight: bold;
                color: #3498db;
            }
            .stat-label {
                color: #666;
                font-size: 14px;
            }
            .signature-section {
                display: flex;
                justify-content: space-between;
                margin-top: 40px;
                padding-top: 20px;
                border-top: 1px solid #e0e0e0;
            }
            .signature-line {
                width: 200px;
                border-bottom: 1px solid #333;
                padding-bottom: 5px;
                margin-bottom: 5px;
            }
            @media print {
                body { background: white; }
                .container { box-shadow: none; }
            }
        </style>
        """
    }

    private func generateHeader(
        request: InsuranceClaimService.ClaimRequest,
        template: ClaimTemplate
    ) -> String {
        return """
        <div class="header">
            <div class="logo-section">
                <!-- Logo would be inserted here -->
            </div>
            <div class="title-section">
                <div class="title">\(request.insuranceCompany.rawValue) Insurance Claim</div>
            </div>
        </div>
        
        <div class="claim-info">
            <strong>Claim Type:</strong> \(request.claimType.rawValue)<br>
            <strong>Incident Date:</strong> \(ClaimDocumentHelpers.formatDate(request.incidentDate))<br>
            <strong>Claim ID:</strong> \(String(request.id.uuidString.prefix(8)))<br>
            <strong>Generated:</strong> \(ClaimDocumentHelpers.formatDate(request.createdAt))
            \(request.policyNumber.map { "<br><strong>Policy Number:</strong> \($0)" } ?? "")
        </div>
        """
    }

    private func generateIncidentDetails(request: InsuranceClaimService.ClaimRequest) -> String {
        return """
        <div class="section">
            <h2 class="section-title">Incident Details</h2>
            <p>\(request.incidentDescription ?? "No description provided")</p>
        </div>
        """
    }

    private func generateContactInformation(request: InsuranceClaimService.ClaimRequest) -> String {
        return """
        <div class="section">
            <h2 class="section-title">Contact Information</h2>
            <p>
                <strong>Phone:</strong> \(request.contactPhone ?? "Not provided")<br>
                <strong>Email:</strong> \(request.contactEmail ?? "Not provided")<br>
                <strong>Address:</strong> \(request.contactAddress ?? "Not provided")
            </p>
        </div>
        """
    }

    private func generateItemsTable(request: InsuranceClaimService.ClaimRequest) -> String {
        let selectedItems = request.selectedItemIds.compactMap { id in
            request.allItems.first { $0.id == id }
        }

        let tableRows = selectedItems.map { item in
            """
            <tr>
                <td>\(item.name)</td>
                <td>\(item.category?.name ?? "N/A")</td>
                <td>\(ClaimDocumentHelpers.formatCurrency(item.purchasePrice))</td>
                <td>\(item.condition?.rawValue ?? "N/A")</td>
                <td>\(item.room?.name ?? "N/A")</td>
            </tr>
            """
        }.joined()

        return """
        <div class="section">
            <h2 class="section-title">Claimed Items</h2>
            <table class="items-table">
                <thead>
                    <tr>
                        <th>Item Name</th>
                        <th>Category</th>
                        <th>Value</th>
                        <th>Condition</th>
                        <th>Location</th>
                    </tr>
                </thead>
                <tbody>
                    \(tableRows)
                </tbody>
            </table>
        </div>
        """
    }

    private func generateSummarySection(request: InsuranceClaimService.ClaimRequest) -> String {
        let selectedItems = request.selectedItemIds.compactMap { id in
            request.allItems.first { $0.id == id }
        }

        let totalValue = ClaimDocumentHelpers.calculateTotalValue(for: selectedItems)
        let itemCount = selectedItems.count

        return """
        <div class="section">
            <h2 class="section-title">Claim Summary</h2>
            <div class="summary-stats">
                <div class="stat-card">
                    <div class="stat-value">\(itemCount)</div>
                    <div class="stat-label">Total Items</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value">\(ClaimDocumentHelpers.formatCurrency(totalValue))</div>
                    <div class="stat-label">Total Claimed Value</div>
                </div>
            </div>
        </div>
        """
    }

    private func generateSignatureSection() -> String {
        return """
        <div class="signature-section">
            <div>
                <div class="signature-line"></div>
                <div>Signature</div>
            </div>
            <div>
                <div class="signature-line"></div>
                <div>Date</div>
            </div>
        </div>
        """
    }

    private func generateJavaScript() -> String {
        return """
        <script>
            // Add print functionality
            window.addEventListener('load', function() {
                // Add print button if needed
                console.log('Claim document loaded');
            });
        </script>
        """
    }
}