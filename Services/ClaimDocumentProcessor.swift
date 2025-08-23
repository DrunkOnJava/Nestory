//
// Layer: Services
// Module: ClaimDocumentProcessor
// Purpose: Document collection and file management for insurance claim packages
//

import Foundation
import SwiftData

@MainActor
public final class ClaimDocumentProcessor {
    // MARK: - Document Collection

    public func collectDocumentation(
        items: [Item],
        options _: ClaimPackageOptions
    ) async throws -> [ItemDocumentation] {
        var documentation: [ItemDocumentation] = []

        for item in items {
            let itemDocs = ItemDocumentation(
                item: item,
                photos: collectItemPhotos(item: item),
                receipts: collectItemReceipts(item: item),
                warranties: collectItemWarranties(item: item),
                manuals: collectItemManuals(item: item),
                conditionPhotos: item.conditionPhotos
            )
            documentation.append(itemDocs)
        }

        return documentation
    }

    // MARK: - Item-Specific Collection Methods

    public func collectItemPhotos(item: Item) -> [Data] {
        var photos: [Data] = []
        if let imageData = item.imageData {
            photos.append(imageData)
        }
        photos.append(contentsOf: item.conditionPhotos)
        return photos
    }

    public func collectItemReceipts(item: Item) -> [Data] {
        var receipts: [Data] = []
        if let receiptData = item.receiptImageData {
            receipts.append(receiptData)
        }
        // Add receipt data from Receipt model relationships
        if let itemReceipts = item.receipts {
            for receipt in itemReceipts {
                if let imageData = receipt.imageData {
                    receipts.append(imageData)
                }
            }
        }
        return receipts
    }

    public func collectItemWarranties(item: Item) -> [Data] {
        // Collect warranty documents
        var warranties: [Data] = []
        if let warranty = item.warranty {
            // Add warranty document data if available
        }
        return warranties
    }

    public func collectItemManuals(item: Item) -> [Data] {
        var manuals: [Data] = []
        if let manualData = item.manualPDFData {
            manuals.append(manualData)
        }
        manuals.append(contentsOf: item.documentAttachments)
        return manuals
    }

    // MARK: - File System Operations

    public func createPackageDirectoryStructure(packageName: String) throws -> PackageDirectories {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(packageName)

        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        // Create subdirectories
        let docsDir = tempDir.appendingPathComponent("Documentation")
        let formsDir = tempDir.appendingPathComponent("Forms")
        let attestationsDir = tempDir.appendingPathComponent("Attestations")
        let photosDir = tempDir.appendingPathComponent("Photos")

        try FileManager.default.createDirectory(at: docsDir, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: formsDir, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: attestationsDir, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: photosDir, withIntermediateDirectories: true)

        return PackageDirectories(
            root: tempDir,
            documentation: docsDir,
            forms: formsDir,
            attestations: attestationsDir,
            photos: photosDir
        )
    }

    public func copyItemPhotosAndDocumentation(
        documentation: [ItemDocumentation],
        to photosDir: URL
    ) throws {
        for itemDoc in documentation {
            let itemDir = photosDir.appendingPathComponent(sanitizeFileName(itemDoc.item.name))
            try FileManager.default.createDirectory(at: itemDir, withIntermediateDirectories: true)

            // Copy main photo
            if let imageData = itemDoc.item.imageData {
                let photoURL = itemDir.appendingPathComponent("main_photo.jpg")
                try imageData.write(to: photoURL)
            }

            // Copy condition photos
            for (index, photoData) in itemDoc.conditionPhotos.enumerated() {
                let photoURL = itemDir.appendingPathComponent("condition_photo_\(index + 1).jpg")
                try photoData.write(to: photoURL)
            }

            // Copy receipts
            if let receiptData = itemDoc.item.receiptImageData {
                let receiptURL = itemDir.appendingPathComponent("receipt.jpg")
                try receiptData.write(to: receiptURL)
            }
        }
    }

    public func copyFormsToDirectory(
        forms: [ClaimForm],
        to formsDir: URL
    ) throws -> [ClaimForm] {
        var packageForms: [ClaimForm] = []

        for form in forms {
            if let fileURL = form.fileURL {
                let destinationURL = formsDir.appendingPathComponent(form.name + ".pdf")
                try FileManager.default.copyItem(at: fileURL, to: destinationURL)
                var updatedForm = form
                updatedForm.fileURL = destinationURL
                packageForms.append(updatedForm)
            } else {
                packageForms.append(form)
            }
        }

        return packageForms
    }

    @MainActor
    public func writeAttestationsToDirectory(
        attestations: [Attestation],
        to attestationsDir: URL,
        using contentGenerator: ClaimContentGenerator
    ) async throws {
        for attestation in attestations {
            let attestationData = try await contentGenerator.generateAttestationPDF(attestation: attestation)
            let attestationURL = attestationsDir.appendingPathComponent("\(attestation.title).pdf")
            try attestationData.write(to: attestationURL)
        }
    }

    public func createPackageReadme(
        scenario: ClaimScenario,
        validation: PackageValidation,
        options: ClaimPackageOptions,
        at readmeURL: URL
    ) throws {
        let readmeContent = generatePackageReadmeContent(
            scenario: scenario,
            validation: validation,
            options: options
        )
        try readmeContent.write(to: readmeURL, atomically: true, encoding: .utf8)
    }

    // MARK: - Helper Methods

    public func sanitizeFileName(_ name: String) -> String {
        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: ".-_"))
        return name.components(separatedBy: allowedCharacters.inverted).joined(separator: "_")
    }

    private func generatePackageReadmeContent(
        scenario _: ClaimScenario,
        validation: PackageValidation,
        options: ClaimPackageOptions
    ) -> String {
        """
        CLAIM PACKAGE CONTENTS
        Generated: \(DateFormatter.longStyle.string(from: Date()))

        PACKAGE ORGANIZATION:

        /Documentation/
            - ClaimSummary.pdf: Comprehensive claim summary and cover letter

        /Forms/
            - Standard Insurance Inventory Form: Official insurance company format
            - Detailed Item Spreadsheet: Complete item details in spreadsheet format

        /Attestations/
            - Ownership attestation
            - Value attestation
            - Incident-specific declarations

        /Photos/
            - [ItemName]/: Folder for each item containing:
                - main_photo.jpg: Primary item photo
                - condition_photo_*.jpg: Condition documentation
                - receipt.jpg: Purchase receipt (if available)

        PACKAGE VALIDATION SUMMARY:
        Total Items: \(validation.totalItems)
        Items with Photos: \(validation.documentedItems)
        Total Value: $\(validation.totalValue)
        Package Valid: \(validation.isValid ? "YES" : "NO")

        \(validation.issues.isEmpty ? "No documentation issues found." : "Documentation Issues:")
        \(validation.issues.map { "- \($0.itemName): \($0.issues.joined(separator: ", "))" }.joined(separator: "\n"))

        For questions about this claim package, please contact:
        \(options.policyHolder ?? "[Policy Holder]")
        \(options.contactEmail ?? "[Email Address]")
        \(options.contactPhone ?? "[Phone Number]")
        """
    }
}

// MARK: - Supporting Types

public struct PackageDirectories {
    public let root: URL
    public let documentation: URL
    public let forms: URL
    public let attestations: URL
    public let photos: URL
}

// MARK: - Extensions

extension DateFormatter {
    static let longStyle: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()
}
