//
// Layer: Services
// Module: InsuranceReport
// Purpose: Manage export and sharing of insurance reports
//

import Foundation
import UIKit

@MainActor
public struct ReportExportManager {
    public init() {}

    // MARK: - Export to File

    public func exportReport(
        _ data: Data,
        filename: String = "HomeInventory_Insurance_Report",
    ) throws -> URL {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
            .replacingOccurrences(of: "/", with: "-")

        let fileName = "\(filename)_\(timestamp).pdf"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        try data.write(to: tempURL)
        return tempURL
    }

    // MARK: - Share Report

    public func shareReport(_ url: URL) {
        let activityVC = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil,
        )

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController
        {
            // Handle iPad popover
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = rootVC.view
                popover.sourceRect = CGRect(
                    x: rootVC.view.bounds.midX,
                    y: rootVC.view.bounds.midY,
                    width: 0,
                    height: 0,
                )
                popover.permittedArrowDirections = []
            }

            rootVC.present(activityVC, animated: true)
        }
    }

    // MARK: - Save to Documents

    public func saveToDocuments(_ data: Data, filename: String) throws -> URL {
        let documentsPath = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask,
        )[0]

        let reportsFolder = documentsPath.appendingPathComponent("Insurance Reports")

        // Create folder if needed
        if !FileManager.default.fileExists(atPath: reportsFolder.path) {
            try FileManager.default.createDirectory(
                at: reportsFolder,
                withIntermediateDirectories: true,
            )
        }

        let fileURL = reportsFolder.appendingPathComponent(filename)
        try data.write(to: fileURL)

        return fileURL
    }

    // MARK: - Clean Up Old Reports

    public func cleanupOldReports(daysToKeep: Int = BusinessConstants.Insurance.reportRetentionDays) {
        let documentsPath = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask,
        )[0]

        let reportsFolder = documentsPath.appendingPathComponent("Insurance Reports")

        guard let files = try? FileManager.default.contentsOfDirectory(
            at: reportsFolder,
            includingPropertiesForKeys: [.creationDateKey],
        ) else { return }

        let cutoffDate = Date().addingTimeInterval(-Double(daysToKeep * BusinessConstants.Notifications.dayCalculationMultiplier))

        for file in files {
            if let attributes = try? FileManager.default.attributesOfItem(atPath: file.path),
               let creationDate = attributes[.creationDate] as? Date,
               creationDate < cutoffDate
            {
                try? FileManager.default.removeItem(at: file)
            }
        }
    }
}
