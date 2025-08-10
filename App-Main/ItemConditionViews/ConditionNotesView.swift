//
//  ConditionNotesView.swift
//  Nestory
//
//  Notes and details for condition documentation
//

import SwiftUI

struct ConditionNotesView: View {
    @Binding var conditionNotes: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Condition Details")
                .font(.headline)
            
            TextEditor(text: $conditionNotes)
                .frame(minHeight: 100)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
            
            Text("Describe any damage, wear, or special conditions")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}