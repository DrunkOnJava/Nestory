//
// Layer: App-Main
// Module: WarrantyViews/WarrantyTracking/Sheets/AutoDetection
// Purpose: Auto-detection results sheet with acceptance workflow and concurrency safety
//

import SwiftUI

public struct AutoDetectResultSheet: View {
    public let detectionResult: WarrantyDetectionResult
    public let onAccept: @Sendable () -> Void
    public let onReject: @Sendable () -> Void
    @Environment(\.dismiss) private var dismiss
    
    public init(
        detectionResult: WarrantyDetectionResult,
        onAccept: @escaping @Sendable () -> Void,
        onReject: @escaping @Sendable () -> Void
    ) {
        self.detectionResult = detectionResult
        self.onAccept = onAccept
        self.onReject = onReject
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    AutoDetectionHeader()
                    
                    DetectedInfoCard(detectionResult: detectionResult)
                    
                    ConfidenceCard(detectionResult: detectionResult)
                    
                    AutoDetectionActionButtons(
                        onAccept: {
                            onAccept()
                            Task { @MainActor in
                                dismiss()
                            }
                        },
                        onReject: {
                            onReject()
                            Task { @MainActor in
                                dismiss()
                            }
                        }
                    )
                }
                .padding()
            }
            .navigationTitle("Auto-Detection Results")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        onReject()
                        Task { @MainActor in
                            dismiss()
                        }
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    AutoDetectResultSheet(
        detectionResult: WarrantyDetectionResult.detected(
            duration: 12,
            provider: "Apple Inc.",
            confidence: 0.85,
            extractedText: "AppleCare+ for iPhone"
        ),
        onAccept: {},
        onReject: {}
    )
}