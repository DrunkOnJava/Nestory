//
// Layer: Services
// Module: InsuranceClaim/ClaimDocumentGenerator
// Purpose: Structured JSON generation for claim documents and data exchange
//

import Foundation

public struct ClaimJSONGenerator {
    public init() {}

    // MARK: - JSON Generation

    public func generateJSON(
        request: ClaimRequest,
        template: ClaimTemplate
    ) throws -> Data {
        let claimData = ClaimJSONStructure(
            claim: ClaimJSONStructure.ClaimInfo(
                id: request.id.uuidString,
                type: request.claimType.rawValue,
                insuranceCompany: request.insuranceCompany.rawValue,
                policyNumber: request.policyNumber,
                incidentDate: ClaimDocumentHelpers.formatDate(request.incidentDate),
                incidentDescription: request.incidentDescription,
                createdAt: ClaimDocumentHelpers.formatDate(request.createdAt),
                format: request.format.rawValue
            ),
            contact: ClaimJSONStructure.ContactInfo(
                email: request.contactEmail,
                phone: request.contactPhone,
                address: request.contactAddress
            ),
            items: buildItemsJSON(request),
            summary: buildSummaryJSON(request),
            metadata: ClaimJSONStructure.Metadata(
                version: "1.0",
                generator: "Nestory",
                templateId: template.id.uuidString
            )
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        return try encoder.encode(claimData)
    }

    // MARK: - JSON Structure Builders

    private func buildItemsJSON(_ request: ClaimRequest) -> [ClaimJSONStructure.ClaimItem] {
        return request.selectedItemIds.compactMap { itemId in
            guard let item = request.allItems.first(where: { $0.id == itemId }) else {
                return nil
            }

            return ClaimJSONStructure.ClaimItem(
                id: item.id.uuidString,
                name: item.name,
                category: item.category?.name,
                description: item.itemDescription,
                purchasePrice: item.purchasePrice?.description,
                purchaseDate: ClaimDocumentHelpers.formatDate(item.purchaseDate),
                brand: item.brand,
                model: item.model,
                serialNumber: item.serialNumber,
                condition: item.condition?.rawValue,
                location: item.room?.name,
                photos: item.photos?.map { photo in
                    ClaimJSONStructure.PhotoInfo(
                        id: photo.id?.uuidString,
                        filename: photo.filename,
                        url: photo.url,
                        caption: photo.caption,
                        timestamp: ClaimDocumentHelpers.formatDate(photo.timestamp)
                    )
                } ?? [],
                documents: item.documents?.compactMap { doc in
                    ClaimJSONStructure.DocumentInfo(
                        id: doc.id?.uuidString,
                        type: doc.type?.rawValue,
                        filename: doc.filename,
                        url: doc.url
                    )
                } ?? []
            )
        }
    }

    private func buildSummaryJSON(_ request: ClaimRequest) -> ClaimJSONStructure.Summary {
        let selectedItems = request.selectedItemIds.compactMap { id in
            request.allItems.first { $0.id == id }
        }

        return ClaimJSONStructure.Summary(
            totalItems: selectedItems.count,
            totalClaimedValue: ClaimDocumentHelpers.calculateTotalValue(for: selectedItems).description,
            itemsByCategory: buildCategorySummary(selectedItems),
            averageItemValue: calculateAverageValue(selectedItems).description,
            oldestItem: findOldestItem(selectedItems)?.name,
            newestItem: findNewestItem(selectedItems)?.name,
            highestValueItem: findHighestValueItem(selectedItems)?.name
        )
    }

    // MARK: - Helper Methods

    private func buildCategorySummary(_ items: [Item]) -> [String: Int] {
        var categoryCounts: [String: Int] = [:]
        
        for item in items {
            let categoryName = item.category?.name ?? "Uncategorized"
            categoryCounts[categoryName, default: 0] += 1
        }
        
        return categoryCounts
    }

    private func calculateAverageValue(_ items: [Item]) -> Decimal {
        let prices = items.compactMap { $0.purchasePrice }
        guard !prices.isEmpty else { return 0 }
        
        let total = prices.reduce(0, +)
        return total / Decimal(prices.count)
    }

    private func findOldestItem(_ items: [Item]) -> Item? {
        items.min { item1, item2 in
            (item1.purchaseDate ?? Date.distantFuture) < (item2.purchaseDate ?? Date.distantFuture)
        }
    }

    private func findNewestItem(_ items: [Item]) -> Item? {
        items.max { item1, item2 in
            (item1.purchaseDate ?? Date.distantPast) < (item2.purchaseDate ?? Date.distantPast)
        }
    }

    private func findHighestValueItem(_ items: [Item]) -> Item? {
        items.max { item1, item2 in
            (item1.purchasePrice ?? 0) < (item2.purchasePrice ?? 0)
        }
    }
}

// MARK: - JSON Structures

public struct ClaimJSONStructure: Codable {
    let claim: ClaimInfo
    let contact: ContactInfo
    let items: [ClaimItem]
    let summary: Summary
    let metadata: Metadata

    struct ClaimInfo: Codable {
        let id: String
        let type: String
        let insuranceCompany: String
        let policyNumber: String?
        let incidentDate: String?
        let incidentDescription: String?
        let createdAt: String?
        let format: String
    }

    struct ContactInfo: Codable {
        let email: String?
        let phone: String?
        let address: String?
    }

    struct ClaimItem: Codable {
        let id: String
        let name: String
        let category: String?
        let description: String?
        let purchasePrice: String?
        let purchaseDate: String?
        let brand: String?
        let model: String?
        let serialNumber: String?
        let condition: String?
        let location: String?
        let photos: [PhotoInfo]
        let documents: [DocumentInfo]
    }

    struct PhotoInfo: Codable {
        let id: String?
        let filename: String?
        let url: String?
        let caption: String?
        let timestamp: String?
    }

    struct DocumentInfo: Codable {
        let id: String?
        let type: String?
        let filename: String?
        let url: String?
    }

    struct Summary: Codable {
        let totalItems: Int
        let totalClaimedValue: String
        let itemsByCategory: [String: Int]
        let averageItemValue: String
        let oldestItem: String?
        let newestItem: String?
        let highestValueItem: String?
    }

    struct Metadata: Codable {
        let version: String
        let generator: String
        let templateId: String
    }
}