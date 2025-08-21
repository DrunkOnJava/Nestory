//
// Layer: Services
// Module: ClaimPackageExporter
// Purpose: Export and packaging operations for insurance claim packages
//

import Foundation
import SwiftData

@MainActor
public final class ClaimPackageExporter {
    // MARK: - Dependencies

    private let documentProcessor: ClaimDocumentProcessor
    private let contentGenerator: ClaimContentGenerator

    // MARK: - Initialization

    public init() {
        self.documentProcessor = ClaimDocumentProcessor()
        self.contentGenerator = ClaimContentGenerator()
    }

    // MARK: - Package Creation

    public func createFinalPackage(
        scenario: ClaimScenario,
        items: [Item],
        coverLetter: ClaimCoverLetter,
        documentation: [ItemDocumentation],
        forms: [ClaimForm],
        attestations: [Attestation],
        validation: PackageValidation,
        options: ClaimPackageOptions
    ) async throws -> ClaimPackage {
        // Create package directory structure
        let packageId = UUID()
        let timestamp = Date()
        let packageName = "ClaimPackage_\(packageId.uuidString.prefix(8))_\(ISO8601DateFormatter().string(from: timestamp))"

        let directories = try documentProcessor.createPackageDirectoryStructure(packageName: packageName)

        // Generate package summary PDF
        let summaryData = try await contentGenerator.generatePackageSummaryPDF(
            coverLetter: coverLetter,
            validation: validation,
            scenario: scenario
        )
        let summaryURL = directories.documentation.appendingPathComponent("ClaimSummary.pdf")
        try summaryData.write(to: summaryURL)

        // Copy forms
        let packageForms = try documentProcessor.copyFormsToDirectory(
            forms: forms,
            to: directories.forms
        )

        // Generate attestation documents
        try await documentProcessor.writeAttestationsToDirectory(
            attestations: attestations,
            to: directories.attestations,
            using: contentGenerator
        )

        // Copy item photos and documentation
        try documentProcessor.copyItemPhotosAndDocumentation(
            documentation: documentation,
            to: directories.photos
        )

        // Create README file
        let readmeURL = directories.root.appendingPathComponent("README.txt")
        try documentProcessor.createPackageReadme(
            scenario: scenario,
            validation: validation,
            options: options,
            at: readmeURL
        )

        return ClaimPackage(
            id: packageId,
            scenario: scenario,
            items: items,
            coverLetter: coverLetter,
            documentation: documentation,
            forms: packageForms,
            attestations: attestations,
            validation: validation,
            packageURL: directories.root,
            createdDate: timestamp,
            options: options
        )
    }

    // MARK: - Export Methods

    public func exportAsZIP(package: ClaimPackage) async throws -> URL {
        let zipURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("ClaimPackage_\(package.id.uuidString.prefix(8)).zip")

        // Create ZIP archive
        try await createZipArchive(sourceURL: package.packageURL, destinationURL: zipURL)

        return zipURL
    }

    public func exportAsPDF(package: ClaimPackage) async throws -> URL {
        // Generate comprehensive PDF with all documentation
        let pdfData = try await contentGenerator.generateComprehensivePDF(package: package)

        let pdfURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("ClaimPackage_\(package.id.uuidString.prefix(8)).pdf")

        try pdfData.write(to: pdfURL)
        return pdfURL
    }

    public func prepareForEmail(package: ClaimPackage) async throws -> EmailPackage {
        // Create email-ready package with size optimizations
        let compressedPhotos = try await compressPhotosForEmail(package: package)
        let summaryPDF = try await generateEmailSummaryPDF(package: package)

        return EmailPackage(
            summaryPDF: summaryPDF,
            compressedPhotos: compressedPhotos,
            attachmentSize: calculateTotalSize([summaryPDF] + compressedPhotos),
            recipientEmails: [],
            subject: generateEmailSubject(package: package),
            body: generateEmailBody(package: package)
        )
    }

    // MARK: - Helper Methods

    private func createZipArchive(sourceURL _: URL, destinationURL: URL) async throws {
        // Implementation would use NSFileCoordinator and Compression framework
        // For now, create a simple archive representation
        let data = "ZIP archive placeholder".data(using: .utf8)!
        try data.write(to: destinationURL)
    }

    private func compressPhotosForEmail(package _: ClaimPackage) async throws -> [URL] {
        // Compress photos to email-friendly sizes
        []
    }

    private func generateEmailSummaryPDF(package _: ClaimPackage) async throws -> URL {
        let summaryData = "Email summary PDF".data(using: .utf8)!
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("EmailSummary.pdf")
        try summaryData.write(to: url)
        return url
    }

    private func calculateTotalSize(_ urls: [URL]) -> Int {
        urls.compactMap { try? $0.resourceValues(forKeys: [.fileSizeKey]).fileSize }.reduce(0, +)
    }

    private func generateEmailSubject(package: ClaimPackage) -> String {
        "Insurance Claim Documentation - \(package.scenario.type.description) - \(package.items.count) items"
    }

    private func generateEmailBody(package: ClaimPackage) -> String {
        """
        Please find attached my insurance claim documentation package.

        Claim Details:
        - Type: \(package.scenario.type.description)
        - Items: \(package.items.count)
        - Total Value: $\(package.items.compactMap(\.purchasePrice).reduce(0, +))
        - Incident Date: \(DateFormatter.longStyle.string(from: package.scenario.incidentDate))

        The attached package includes all required documentation and forms.

        Thank you for your assistance with this claim.
        """
    }
}
