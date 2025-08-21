//
// Layer: UI
// Module: Components
// Purpose: Reusable ML processing progress indicators
//
// 🎨 UI COMPONENT: Pure presentational progress tracking
// - Visual feedback for multi-stage ML processing workflows
// - Confidence indicators and capability displays
// - Reusable across Receipt OCR, Document Processing, and AI features
// - Foundation-only imports for maximum portability

import SwiftUI

struct MLProcessingProgressView: View {
    let stage: ReceiptOCRService.ProcessingStage
    let confidence: Double
    let isProcessing: Bool

    var body: some View {
        VStack(spacing: 16) {
            // Processing Stage Indicator
            HStack {
                if isProcessing {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: stageIcon)
                        .foregroundColor(stageColor)
                }

                Text(stage.description)
                    .font(.headline)
                    .foregroundColor(stageColor)

                Spacer()
            }

            // Progress Bar
            if isProcessing {
                ProgressView(value: stageProgress, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle())
                    .tint(.blue)
            }

            // Confidence Indicator (when processing is complete)
            if !isProcessing, stage == .completed {
                ConfidenceIndicatorView(confidence: confidence)
            }

            // Stage Details
            Text(stageDescription)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    // MARK: - Computed Properties

    private var stageIcon: String {
        switch stage {
        case .idle:
            "camera.fill"
        case .documentDetection:
            "doc.viewfinder"
        case .perspectiveCorrection:
            "perspective"
        case .ocrProcessing:
            "text.viewfinder"
        case .dataExtraction:
            "list.bullet.clipboard"
        case .categoryClassification:
            "tag.fill"
        case .confidenceCalculation:
            "chart.bar.fill"
        case .completed:
            "checkmark.circle.fill"
        case .failed:
            "exclamationmark.triangle.fill"
        }
    }

    private var stageColor: Color {
        switch stage {
        case .idle:
            .gray
        case .documentDetection, .perspectiveCorrection, .ocrProcessing,
             .dataExtraction, .categoryClassification, .confidenceCalculation:
            .blue
        case .completed:
            .green
        case .failed:
            .red
        }
    }

    private var stageProgress: Double {
        switch stage {
        case .idle: 0.0
        case .documentDetection: 0.15
        case .perspectiveCorrection: 0.3
        case .ocrProcessing: 0.5
        case .dataExtraction: 0.7
        case .categoryClassification: 0.85
        case .confidenceCalculation: 0.95
        case .completed: 1.0
        case .failed: 0.0
        }
    }

    private var stageDescription: String {
        switch stage {
        case .idle:
            "Ready to process receipt image"
        case .documentDetection:
            "Using Vision framework to detect document boundaries"
        case .perspectiveCorrection:
            "Applying perspective correction for optimal OCR"
        case .ocrProcessing:
            "Extracting text using enhanced OCR with machine learning"
        case .dataExtraction:
            "Parsing receipt data using intelligent pattern matching"
        case .categoryClassification:
            "Classifying receipt category using ML algorithms"
        case .confidenceCalculation:
            "Calculating processing confidence score"
        case .completed:
            "Receipt processing complete with ML enhancements"
        case .failed:
            "Processing failed - falling back to legacy methods"
        }
    }
}

// MARK: - Confidence Indicator

struct ConfidenceIndicatorView: View {
    let confidence: Double

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Processing Confidence")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text(confidenceText)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(confidenceColor)
            }

            // Confidence Progress Bar
            ProgressView(value: confidence, total: 1.0)
                .progressViewStyle(LinearProgressViewStyle())
                .tint(confidenceColor)

            // Confidence Explanation
            Text(confidenceExplanation)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
        }
        .padding(.vertical, 8)
    }

    private var confidenceText: String {
        "\(Int(confidence * 100))%"
    }

    private var confidenceColor: Color {
        switch confidence {
        case 0.9 ... 1.0: .green
        case 0.7 ..< 0.9: .blue
        case 0.5 ..< 0.7: .orange
        case 0.0 ..< 0.5: .red
        default: .gray
        }
    }

    private var confidenceExplanation: String {
        switch confidence {
        case 0.9 ... 1.0:
            "Excellent - All major receipt elements detected with high accuracy"
        case 0.7 ..< 0.9:
            "Good - Most receipt elements detected, minor manual verification may be needed"
        case 0.5 ..< 0.7:
            "Fair - Some receipt elements detected, please verify extracted data"
        case 0.0 ..< 0.5:
            "Poor - Limited data extracted, manual entry recommended"
        default:
            "Processing confidence unavailable"
        }
    }
}

// MARK: - Enhanced Processing Cards

struct MLFeatureCard: View {
    let title: String
    let description: String
    let icon: String
    let isActive: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isActive ? .blue : .gray)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isActive ? .primary : .secondary)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            if isActive {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
        .opacity(isActive ? 1.0 : 0.6)
    }
}

// MARK: - ML Capabilities Overview

struct MLCapabilitiesView: View {
    let mlAvailable: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AI-Enhanced Processing")
                .font(.headline)

            MLFeatureCard(
                title: "Document Detection",
                description: "Automatically detects receipt boundaries and corrects perspective",
                icon: "doc.viewfinder",
                isActive: mlAvailable
            )

            MLFeatureCard(
                title: "Enhanced OCR",
                description: "Superior text extraction with machine learning optimization",
                icon: "text.viewfinder",
                isActive: mlAvailable
            )

            MLFeatureCard(
                title: "Smart Data Extraction",
                description: "Intelligent pattern matching for vendor, date, and pricing",
                icon: "list.bullet.clipboard",
                isActive: mlAvailable
            )

            MLFeatureCard(
                title: "Category Classification",
                description: "Automatic receipt categorization using AI analysis",
                icon: "tag.fill",
                isActive: mlAvailable
            )

            if !mlAvailable {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(.orange)

                    Text("Using legacy processing mode. ML features unavailable.")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                .padding(.top, 8)
            }
        }
    }
}

// MARK: - Preview

struct MLProcessingProgressView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MLProcessingProgressView(
                stage: .ocrProcessing,
                confidence: 0.0,
                isProcessing: true
            )
            .previewDisplayName("Processing")

            MLProcessingProgressView(
                stage: .completed,
                confidence: 0.87,
                isProcessing: false
            )
            .previewDisplayName("Completed")

            MLCapabilitiesView(mlAvailable: true)
                .previewDisplayName("ML Available")

            MLCapabilitiesView(mlAvailable: false)
                .previewDisplayName("Legacy Mode")
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
