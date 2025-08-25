//
// Layer: App-Main
// Module: DamageAssessment/DamageAssessmentReport/Actions
// Purpose: Report sharing, saving, and distribution actions
//

import SwiftUI
import Foundation

struct ReportActionsSection: View {
    let reportData: Data
    let onShare: () -> Void
    let onSaveToFiles: () -> Void
    let onEmail: () -> Void
    
    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {
                Label("Report Generated", systemImage: "checkmark.circle.fill")
                    .font(.headline)
                    .foregroundColor(.green)

                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "doc.richtext.fill")
                            .font(.title2)
                            .foregroundColor(.blue)

                        VStack(alignment: .leading) {
                            Text("Assessment Report.pdf")
                                .font(.body)
                                .fontWeight(.medium)
                            Text(ByteCountFormatter.string(fromByteCount: Int64(reportData.count), countStyle: .file))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)

                    // Action buttons
                    HStack(spacing: 12) {
                        Button(action: onShare) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                        }

                        Button(action: onSaveToFiles) {
                            HStack {
                                Image(systemName: "folder")
                                Text("Save to Files")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple.opacity(0.1))
                            .foregroundColor(.purple)
                            .cornerRadius(8)
                        }
                    }
                    
                    Button(action: onEmail) {
                        HStack {
                            Image(systemName: "envelope")
                            Text("Email Report")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .foregroundColor(.green)
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}