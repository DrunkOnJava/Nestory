//
//  SearchFilterView.swift
//  Nestory
//
//  Search filters sheet
//

import SwiftData
import SwiftUI

struct SearchFilterView: View {
    @Binding var filters: SearchFilters
    @Query private var categories: [Category]
    @Environment(\.dismiss) private var dismiss

    @State private var minPrice = "0"
    @State private var maxPrice = "10000"

    var body: some View {
        NavigationStack {
            formContent
                .navigationTitle("Filters")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") { dismiss() }
                    }
                }
        }
    }
    
    private var formContent: some View {
        Form {
            categoriesSection
            priceRangeSection
            documentationSection
            quantitySection
            resetSection
        }
    }
    
    private var categoriesSection: some View {
        Section("Categories") {
            ForEach(categories) { category in
                CategoryFilterRow(
                    category: category,
                    isSelected: filters.selectedCategories.contains(category.id)
                ) {
                    if filters.selectedCategories.contains(category.id) {
                        filters.selectedCategories.remove(category.id)
                    } else {
                        filters.selectedCategories.insert(category.id)
                    }
                }
            }
        }
    }
    
    private var priceRangeSection: some View {
        Section("Price Range") {
            VStack {
                HStack {
                    Text("$\(Int(filters.priceRange?.lowerBound ?? 0))")
                    Spacer()
                    Text("$\(Int(filters.priceRange?.upperBound ?? 10000))")
                }
                .font(.caption)

                RangeSlider(
                    value: Binding(
                        get: { filters.priceRange ?? 0...10000 },
                        set: { filters.priceRange = $0 }
                    ),
                    bounds: 0 ... 10000,
                    step: 100
                )
            }
        }
    }
    
    private var documentationSection: some View {
        Section("Documentation Status") {
            Toggle("Has Photo", isOn: Binding(
                get: { filters.hasPhoto ?? false },
                set: { filters.hasPhoto = $0 }
            ))
            Toggle("Has Receipt", isOn: Binding(
                get: { filters.hasReceipt ?? false },
                set: { filters.hasReceipt = $0 }
            ))
            Toggle("Has Warranty", isOn: Binding(
                get: { filters.hasWarranty ?? false },
                set: { filters.hasWarranty = $0 }
            ))
            Toggle("Has Serial Number", isOn: Binding(
                get: { filters.hasSerialNumber ?? false },
                set: { filters.hasSerialNumber = $0 }
            ))
        }
    }
    
    private var quantitySection: some View {
        Section("Quantity Range") {
            Stepper(
                "Min: \(filters.minQuantity)",
                value: $filters.minQuantity,
                in: 0 ... filters.maxQuantity
            )
            Stepper(
                "Max: \(filters.maxQuantity)",
                value: $filters.maxQuantity,
                in: filters.minQuantity ... 100
            )
        }
    }
    
    
    private var resetSection: some View {
        Section {
            Button(action: resetFilters) {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                        .accessibilityLabel("Reset")
                    Text("Reset All Filters")
                }
                .foregroundColor(.red)
            }
        }
    }
    
    private func resetFilters() {
        filters.selectedCategories = []
        filters.priceRange = 0...10000
        filters.hasPhoto = false
        filters.hasReceipt = false
        filters.hasWarranty = false
        filters.hasSerialNumber = false
        filters.minQuantity = 0
        filters.maxQuantity = 100
        filters.dateRange = nil
        filters.documentationCompleteOnly = false
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
                        height: 4,
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
                                    in: geometry.size.width,
                                )
                                let stepped = round(newValue / step) * step
                                let clamped = min(max(stepped, bounds.lowerBound), value.upperBound - step)
                                value = clamped ... value.upperBound
                            },
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
                                    in: geometry.size.width,
                                )
                                let stepped = round(newValue / step) * step
                                let clamped = max(min(stepped, bounds.upperBound), value.lowerBound + step)
                                value = value.lowerBound ... clamped
                            },
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

// MARK: - Helper Components

struct CategoryFilterRow: View {
    let category: Category
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        let categoryColor = Color(hex: category.colorHex) ?? .accentColor
        
        HStack {
            Label(category.name, systemImage: category.icon)
                .foregroundColor(categoryColor)
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.accentColor)
                    .accessibilityLabel("Selected")
            }
        }
        .contentShape(Rectangle())
        .accessibilityAddTraits(.isButton)
        .onTapGesture(perform: onTap)
    }
}


// MARK: - Preview

#Preview {
    SearchFilterView(
        filters: .constant(SearchFilters())
    )
}
