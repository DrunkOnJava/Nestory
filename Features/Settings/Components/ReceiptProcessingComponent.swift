//
// Layer: Features
// Module: Settings/Components
// Purpose: Receipt processing settings and configuration component
//

import SwiftUI
import ComposableArchitecture
import Foundation

struct ReceiptProcessingComponent: View {
    @State private var isOCREnabled = true
    @State private var autoProcessReceipts = false
    @State private var saveOriginalImages = true
    @State private var ocrConfidenceThreshold = 0.8
    
    var body: some View {
        Section("Receipt Processing") {
            Toggle("Enable OCR (Text Recognition)", isOn: $isOCREnabled)
            
            if isOCREnabled {
                Toggle("Auto-process new receipts", isOn: $autoProcessReceipts)
                    .padding(.leading)
                
                Toggle("Save original images", isOn: $saveOriginalImages)
                    .padding(.leading)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("OCR Confidence Threshold")
                        Spacer()
                        Text("\(Int(ocrConfidenceThreshold * 100))%")
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(value: $ocrConfidenceThreshold, in: 0.5...1.0, step: 0.05)
                        .padding(.leading)
                }
                
                Button("Test OCR Service") {
                    testOCRService()
                }
                .padding(.leading)
            }
            
            NavigationLink("Manage Receipt Templates") {
                ReceiptTemplatesView()
            }
            
            NavigationLink("Processing History") {
                ProcessingHistoryView()
            }
        }
        
        Section("Storage") {
            HStack {
                Text("Receipt Storage Used")
                Spacer()
                Text("248 MB")
                    .foregroundColor(.secondary)
            }
            
            Button("Clean Up Processed Receipts") {
                cleanUpReceipts()
            }
            .foregroundColor(.red)
        }
    }
    
    private func testOCRService() {
        // Test OCR functionality
        print("Testing OCR service...")
    }
    
    private func cleanUpReceipts() {
        // Clean up old processed receipts
        print("Cleaning up receipts...")
    }
}

private struct ReceiptTemplatesView: View {
    @State private var templates: [ReceiptTemplate] = [
        ReceiptTemplate(name: "Generic Receipt", pattern: "default"),
        ReceiptTemplate(name: "Amazon", pattern: "amazon"),
        ReceiptTemplate(name: "Target", pattern: "target"),
        ReceiptTemplate(name: "Home Depot", pattern: "homedepot")
    ]
    
    var body: some View {
        List {
            ForEach(templates) { template in
                HStack {
                    VStack(alignment: .leading) {
                        Text(template.name)
                            .font(.headline)
                        Text("Pattern: \(template.pattern)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: .constant(true))
                        .labelsHidden()
                }
            }
            
            Button("Add Custom Template") {
                // Add new template
            }
            .foregroundColor(.blue)
        }
        .navigationTitle("Receipt Templates")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
    }
}

private struct ProcessingHistoryView: View {
    @State private var processingHistory: [ProcessingRecord] = [
        ProcessingRecord(date: Date(), filename: "receipt_001.jpg", status: .success, itemsExtracted: 3),
        ProcessingRecord(date: Date().addingTimeInterval(-3600), filename: "receipt_002.jpg", status: .partialSuccess, itemsExtracted: 1),
        ProcessingRecord(date: Date().addingTimeInterval(-7200), filename: "receipt_003.jpg", status: .failed, itemsExtracted: 0)
    ]
    
    var body: some View {
        List(processingHistory) { record in
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(record.filename)
                        .font(.headline)
                    
                    Spacer()
                    
                    StatusBadge(status: record.status)
                }
                
                HStack {
                    Text(record.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if record.itemsExtracted > 0 {
                        Text("\(record.itemsExtracted) items extracted")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Processing History")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Clear All") {
                    processingHistory.removeAll()
                }
            }
        }
    }
}

private struct StatusBadge: View {
    let status: ProcessingStatus
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.iconName)
            Text(status.title)
        }
        .font(.caption)
        .padding(.horizontal, 8)
        .padding(.vertical, 2)
        .background(status.backgroundColor)
        .foregroundColor(status.textColor)
        .clipShape(Capsule())
    }
}

private struct ReceiptTemplate: Identifiable {
    let id = UUID()
    let name: String
    let pattern: String
}

private struct ProcessingRecord: Identifiable {
    let id = UUID()
    let date: Date
    let filename: String
    let status: ProcessingStatus
    let itemsExtracted: Int
}

private enum ProcessingStatus {
    case success, partialSuccess, failed
    
    var title: String {
        switch self {
        case .success: return "Success"
        case .partialSuccess: return "Partial"
        case .failed: return "Failed"
        }
    }
    
    var iconName: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .partialSuccess: return "exclamationmark.triangle.fill"
        case .failed: return "xmark.circle.fill"
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .success: return .green.opacity(0.2)
        case .partialSuccess: return .orange.opacity(0.2)
        case .failed: return .red.opacity(0.2)
        }
    }
    
    var textColor: Color {
        switch self {
        case .success: return .green
        case .partialSuccess: return .orange
        case .failed: return .red
        }
    }
}

#Preview {
    NavigationView {
        List {
            ReceiptProcessingComponent()
        }
        .navigationTitle("Settings")
    }
}