//
// Layer: App-Main
// Module: WarrantyViews/WarrantyTracking/Sheets/AutoDetection
// Purpose: Detected warranty information display card
//

import SwiftUI

public struct DetectedInfoCard: View {
    public let detectionResult: WarrantyDetectionResult
    
    public init(detectionResult: WarrantyDetectionResult) {
        self.detectionResult = detectionResult
    }
    
    public var body: some View {
        GroupBox("Detected Warranty Information") {
            VStack(spacing: 12) {
                InfoRow(label: "Provider", value: detectionResult.suggestedProvider ?? "Unknown")
                
                InfoRow(label: "Duration", value: "\(detectionResult.suggestedDuration ?? 12) months")
                
                InfoRow(label: "Confidence", value: String(format: "%.1f%%", detectionResult.confidence * 100))
                
                if let extractedText = detectionResult.extractedText {
                    InfoRow(label: "Source", value: extractedText)
                }
                
                // Future enhancement: Registration requirement detection
                if shouldShowRegistrationWarning {
                    RegistrationRequiredWarning()
                }
            }
        }
    }
    
    // MARK: - Future Enhancement Placeholder
    
    private var shouldShowRegistrationWarning: Bool {
        // Placeholder for future registration detection logic
        false
    }
}

private struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
        }
    }
}

private struct RegistrationRequiredWarning: View {
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            
            Text("Registration Required")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.orange)
            
            Spacer()
        }
    }
}

#Preview {
    DetectedInfoCard(
        detectionResult: WarrantyDetectionResult.detected(
            duration: 12,
            provider: "Apple Inc.",
            confidence: 0.85,
            extractedText: "AppleCare+ for iPhone"
        )
    )
    .padding()
}