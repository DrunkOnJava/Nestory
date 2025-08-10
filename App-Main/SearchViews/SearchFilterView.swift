//
//  SearchFilterView.swift
//  Nestory
//
//  Search filters sheet
//

import SwiftUI
import SwiftData

struct SearchFilterView: View {
    @Binding var filters: SearchFilters
    @Query private var categories: [Category]
    @Query private var rooms: [Room]
    @Environment(\.dismiss) private var dismiss
    
    @State private var minPrice: String = "0"
    @State private var maxPrice: String = "10000"
    
    var body: some View {
        NavigationStack {
            Form {
                // Categories Section
                Section("Categories") {
                    ForEach(categories) { category in
                        let isSelected = filters.selectedCategories.contains(category.id)
                        let categoryColor = Color(hex: category.colorHex) ?? .accentColor
                        
                        HStack {
                            Label(category.name, systemImage: category.icon)
                                .foregroundColor(categoryColor)
                            
                            Spacer()
                            
                            if isSelected {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if isSelected {
                                filters.selectedCategories.remove(category.id)
                            } else {
                                filters.selectedCategories.insert(category.id)
                            }
                        }
                    }
                }
                
                // Price Range Section
                Section("Price Range") {
                    VStack {
                        HStack {
                            Text("$\(Int(filters.priceRange.lowerBound))")
                            Spacer()
                            Text("$\(Int(filters.priceRange.upperBound))")
                        }
                        .font(.caption)
                        
                        RangeSlider(
                            value: Binding(
                                get: { filters.priceRange },
                                set: { filters.priceRange = $0 }
                            ),
                            bounds: 0...10000,
                            step: 100
                        )
                    }
                }
                
                // Documentation Status Section
                Section("Documentation Status") {
                    Toggle("Has Photo", isOn: $filters.hasPhoto)
                    Toggle("Has Receipt", isOn: $filters.hasReceipt)
                    Toggle("Has Warranty", isOn: $filters.hasWarranty)
                    Toggle("Has Serial Number", isOn: $filters.hasSerialNumber)
                }
                
                // Quantity Section
                Section("Quantity Range") {
                    Stepper("Min: \(filters.minQuantity)", value: $filters.minQuantity, in: 0...filters.maxQuantity)
                    Stepper("Max: \(filters.maxQuantity)", value: $filters.maxQuantity, in: filters.minQuantity...100)
                }
                
                // Rooms Section
                if !rooms.isEmpty {
                    Section("Rooms") {
                        ForEach(rooms) { room in
                            let isSelected = filters.rooms.contains(room.name)
                            
                            HStack {
                                Label(room.name, systemImage: room.icon)
                                
                                Spacer()
                                
                                if isSelected {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if isSelected {
                                    filters.rooms.remove(room.name)
                                } else {
                                    filters.rooms.insert(room.name)
                                }
                            }
                        }
                    }
                }
                
                // Reset Section
                Section {
                    Button(action: { filters.reset() }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset All Filters")
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            })
        }
    }
}

// MARK: - Range Slider Component

struct RangeSlider: View {
    @Binding var value: ClosedRange<Double>
    let bounds: ClosedRange<Double>
    let step: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Track
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(.systemGray5))
                    .frame(height: 4)
                
                // Selected range
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.accentColor)
                    .frame(
                        width: rangeWidth(in: geometry.size.width),
                        height: 4
                    )
                    .offset(x: lowerOffset(in: geometry.size.width))
                
                // Lower thumb
                Circle()
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
                    .shadow(radius: 2)
                    .offset(x: lowerOffset(in: geometry.size.width) - 10)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                let newValue = valueForOffset(
                                    gesture.location.x,
                                    in: geometry.size.width
                                )
                                let stepped = round(newValue / step) * step
                                let clamped = min(max(stepped, bounds.lowerBound), value.upperBound - step)
                                value = clamped...value.upperBound
                            }
                    )
                
                // Upper thumb
                Circle()
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
                    .shadow(radius: 2)
                    .offset(x: upperOffset(in: geometry.size.width) - 10)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                let newValue = valueForOffset(
                                    gesture.location.x,
                                    in: geometry.size.width
                                )
                                let stepped = round(newValue / step) * step
                                let clamped = max(min(stepped, bounds.upperBound), value.lowerBound + step)
                                value = value.lowerBound...clamped
                            }
                    )
            }
        }
        .frame(height: 20)
    }
    
    private func rangeWidth(in totalWidth: CGFloat) -> CGFloat {
        let range = bounds.upperBound - bounds.lowerBound
        let selectedRange = value.upperBound - value.lowerBound
        return (selectedRange / range) * totalWidth
    }
    
    private func lowerOffset(in totalWidth: CGFloat) -> CGFloat {
        let range = bounds.upperBound - bounds.lowerBound
        let offset = value.lowerBound - bounds.lowerBound
        return (offset / range) * totalWidth
    }
    
    private func upperOffset(in totalWidth: CGFloat) -> CGFloat {
        let range = bounds.upperBound - bounds.lowerBound
        let offset = value.upperBound - bounds.lowerBound
        return (offset / range) * totalWidth
    }
    
    private func valueForOffset(_ offset: CGFloat, in totalWidth: CGFloat) -> Double {
        let range = bounds.upperBound - bounds.lowerBound
        let ratio = offset / totalWidth
        return bounds.lowerBound + (ratio * range)
    }
}