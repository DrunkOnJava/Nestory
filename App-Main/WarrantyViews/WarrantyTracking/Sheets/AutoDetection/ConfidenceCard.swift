//
// Layer: App-Main
// Module: WarrantyViews/WarrantyTracking/Sheets/AutoDetection
// Purpose: Detection confidence display card with visual indicators
//

import SwiftUI

public struct ConfidenceCard: View {
    public let detectionResult: WarrantyDetectionResult
    
    public init(detectionResult: WarrantyDetectionResult) {
        self.detectionResult = detectionResult
    }
    
    public var body: some View {
        GroupBox("Detection Quality") {
            VStack(spacing: 8) {
                HStack {
                    Text("Confidence")
                        .font(.caption)
                    
                    Spacer()
                    
                    Text("\(Int(detectionResult.confidence * 100))%")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(confidenceColor)
                }
                
                ProgressView(value: detectionResult.confidence)
                    .progressViewStyle(LinearProgressViewStyle(tint: confidenceColor))
                
                HStack {
                    Image(systemName: "info.circle")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Text("Source: \(detectionResult.extractedText ?? "Database lookup")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var confidenceColor: Color {
        if detectionResult.confidence >= 0.8 {
            return .green
        } else if detectionResult.confidence >= 0.6 {
            return .orange
        } else {
            return .red
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        ConfidenceCard(
            detectionResult: WarrantyDetectionResult.detected(
                duration: 12,
                provider: "Apple Inc.",
                confidence: 0.85,
                extractedText: "AppleCare+ for iPhone"
            )
        )
        
        ConfidenceCard(
            detectionResult: WarrantyDetectionResult.detected(
                duration: 24,
                provider: "Samsung",
                confidence: 0.65,
                extractedText: "Samsung Care+"
            )
        )
        
        ConfidenceCard(
            detectionResult: WarrantyDetectionResult.detected(
                duration: 12,
                provider: "Generic",
                confidence: 0.45,
                extractedText: nil
            )
        )
    }
    .padding()
}