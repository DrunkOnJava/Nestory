//
// Layer: App-Main
// Module: DamageAssessmentViews/DamageAssessmentReport/Utils
// Purpose: Utility class for managing report file operations and sharing
//

import Foundation
import UIKit
import UniformTypeIdentifiers

/// Manages file operations and sharing for damage assessment reports
public class ReportActionManager {
    private let workflow: DamageAssessmentWorkflow
    private let fileManager = FileManager.default
    
    public init(workflow: DamageAssessmentWorkflow) {
        self.workflow = workflow
    }
    
    // MARK: - File Operations
    
    /// Create a temporary URL for sharing the report
    public func createTemporaryReportURL(from reportData: Data) throws -> URL {
        let tempDirectory = fileManager.temporaryDirectory
        let fileName = generateReportFileName()
        let tempURL = tempDirectory.appendingPathComponent(fileName)
        
        try reportData.write(to: tempURL)
        return tempURL
    }
    
    /// Save report to the Documents directory
    public func saveReportToDocuments(reportData: Data) throws -> URL {
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, 
                                                       in: .userDomainMask).first else {
            throw ReportError.documentsDirectoryNotFound
        }
        
        let fileName = generateReportFileName()
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        try reportData.write(to: fileURL)
        return fileURL
    }
    
    /// Generate a unique filename for the report
    private func generateReportFileName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let timestamp = dateFormatter.string(from: Date())
        
        let itemName = workflow.assessment.itemId.uuidString.prefix(8)
        let damageType = workflow.damageType.rawValue.capitalized
        
        return "DamageReport_\(damageType)_\(itemName)_\(timestamp).pdf"
    }
    
    // MARK: - Cleanup
    
    /// Clean up temporary files (call after sharing is complete)
    public func cleanupTemporaryFiles() {
        let tempDirectory = fileManager.temporaryDirectory
        
        do {
            let contents = try fileManager.contentsOfDirectory(
                at: tempDirectory, 
                includingPropertiesForKeys: nil
            )
            
            for url in contents {
                if url.pathExtension == "pdf" && url.lastPathComponent.hasPrefix("DamageReport_") {
                    try fileManager.removeItem(at: url)
                }
            }
        } catch {
            // Silent cleanup failure - not critical
            print("Warning: Could not clean up temporary report files: \(error)")
        }
    }
}

// MARK: - Supporting Types

public enum ReportError: LocalizedError {
    case documentsDirectoryNotFound
    case fileWriteError(Error)
    case fileNotFound
    
    public var errorDescription: String? {
        switch self {
        case .documentsDirectoryNotFound:
            return "Documents directory not accessible"
        case .fileWriteError(let error):
            return "Failed to write report file: \(error.localizedDescription)"
        case .fileNotFound:
            return "Report file not found"
        }
    }
}