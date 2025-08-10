//
//  ConditionSelectionView.swift
//  Nestory
//
//  Condition selection grid with buttons
//

import SwiftUI
import SwiftData

struct ConditionSelectionView: View {
    @Binding var selectedCondition: ItemCondition
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Item Condition")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                ForEach(ItemCondition.allCases, id: \.self) { condition in
                    ConditionButton(
                        condition: condition,
                        isSelected: selectedCondition == condition,
                        action: {
                            withAnimation {
                                selectedCondition = condition
                            }
                        }
                    )
                }
            }
            
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                Text("Insurance Impact: \(selectedCondition.insuranceImpact)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
}

struct ConditionButton: View {
    let condition: ItemCondition
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: condition.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : Color(hex: condition.color))
                
                Text(condition.rawValue)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color(hex: condition.color) ?? .accentColor : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(hex: condition.color) ?? .accentColor, lineWidth: isSelected ? 0 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}