//
// Layer: Services
// Module: InsuranceExport
// Purpose: Export inventory data in industry-standard XML format
//

import Foundation

public enum XMLExporter {
    @MainActor
    public static func exportToXML(items: [Item], options: ExportOptions) async -> Data {
        var xmlContent = """
        <?xml version="1.0" encoding="UTF-8"?>
        <HomeInventory xmlns="http://insurance.standards.org/inventory/2.0">
            <PolicyInformation>
                <PolicyHolder>\(DataFormatHelpers.escapeXML(options.policyHolderName ?? ""))</PolicyHolder>
                <PolicyNumber>\(DataFormatHelpers.escapeXML(options.policyNumber ?? ""))</PolicyNumber>
                <PropertyAddress>\(DataFormatHelpers.escapeXML(options.propertyAddress ?? ""))</PropertyAddress>
                <ReportDate>\(Date().ISO8601Format())</ReportDate>
            </PolicyInformation>
            <Items>
        """

        for item in items {
            xmlContent += generateItemXML(item)
        }

        xmlContent += """
            </Items>
            <Summary>
                <TotalItems>\(items.count)</TotalItems>
                <TotalValue>\(items.compactMap(\.purchasePrice).reduce(0, +))</TotalValue>
                <ItemsWithPhotos>\(items.count { $0.imageData != nil })</ItemsWithPhotos>
                <ItemsWithReceipts>\(items.count { $0.receiptImageData != nil })</ItemsWithReceipts>
            </Summary>
        </HomeInventory>
        """

        guard let xmlData = xmlContent.data(using: .utf8) else {
            // This should never fail as we're using valid UTF-8 strings
            return Data()
        }
        return xmlData
    }

    private static func generateItemXML(_ item: Item) -> String {
        """
            <Item id="\(item.id.uuidString)">
                <Name>\(DataFormatHelpers.escapeXML(item.name))</Name>
                <Description>\(DataFormatHelpers.escapeXML(item.itemDescription ?? ""))</Description>
                <Category>\(DataFormatHelpers.escapeXML(item.category?.name ?? ""))</Category>
                <Location>
                    <Room>\(DataFormatHelpers.escapeXML(item.room ?? ""))</Room>
                    <SpecificLocation>\(DataFormatHelpers.escapeXML(item.specificLocation ?? ""))</SpecificLocation>
                </Location>
                <Identification>
                    <Brand>\(DataFormatHelpers.escapeXML(item.brand ?? ""))</Brand>
                    <Model>\(DataFormatHelpers.escapeXML(item.modelNumber ?? ""))</Model>
                    <SerialNumber>\(DataFormatHelpers.escapeXML(item.serialNumber ?? ""))</SerialNumber>
                </Identification>
                <Financial>
                    <PurchaseDate>\(item.purchaseDate?.ISO8601Format() ?? "")</PurchaseDate>
                    <PurchasePrice currency="\(item.currency)">\(item.purchasePrice ?? 0)</PurchasePrice>
                </Financial>
                <Warranty>
                    <ExpirationDate>\(item.warrantyExpirationDate?.ISO8601Format() ?? "")</ExpirationDate>
                    <Provider>\(DataFormatHelpers.escapeXML(item.warrantyProvider ?? ""))</Provider>
                </Warranty>
                <Documentation>
                    <HasPhoto>\(item.imageData != nil)</HasPhoto>
                    <HasReceipt>\(item.receiptImageData != nil)</HasReceipt>
                    <DocumentCount>\(item.documentNames.count)</DocumentCount>
                </Documentation>
            </Item>
        """
    }

    public static func generateFileName() -> String {
        "Insurance_Inventory_\(Date().timeIntervalSince1970).xml"
    }
}
