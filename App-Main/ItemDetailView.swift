//
//  ItemDetailView.swift
//  Nestory
//
//  REMINDER: This view is where item-specific features get wired up:
//  - Edit Item (✓ Wired)
//  - Receipt OCR (✓ Wired)
//  - Photo Management
//  - Document Attachments
//  Always check if new item-related services should be accessible from here!

import SwiftData
import SwiftUI

struct ItemDetailView: View {
    @Bindable var item: Item
    @Environment(\.dismiss) private var dismiss
    @State private var isEditing = false
    @State private var showingReceiptCapture = false
    @State private var showingWarrantyDocuments = false
    @State private var showingConditionDocumentation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Item Image
                if let imageData = item.imageData,
                   let uiImage = UIImage(data: imageData)
                {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(12)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 200)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 50))
                                .foregroundColor(.gray),
                        )
                }

                VStack(alignment: .leading, spacing: 16) {
                    // Basic Info
                    GroupBox("Basic Information") {
                        VStack(alignment: .leading, spacing: 12) {
                            DetailRow(label: "Name", value: item.name)

                            if let description = item.itemDescription {
                                DetailRow(label: "Description", value: description)
                            }

                            DetailRow(label: "Quantity", value: "\(item.quantity)")

                            if let category = item.category {
                                HStack {
                                    Text("Category")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Label(category.name, systemImage: category.icon)
                                        .foregroundColor(Color(hex: category.colorHex) ?? .accentColor)
                                        .fontWeight(.medium)
                                }
                                .padding(.vertical, 2)
                            }
                        }
                    }

                    // Additional Details
                    if item.brand != nil || item.modelNumber != nil || item.serialNumber != nil {
                        GroupBox("Product Details") {
                            VStack(alignment: .leading, spacing: 12) {
                                if let brand = item.brand {
                                    DetailRow(label: "Brand", value: brand)
                                }
                                if let model = item.modelNumber {
                                    DetailRow(label: "Model", value: model)
                                }
                                if let serial = item.serialNumber {
                                    DetailRow(label: "Serial #", value: serial)
                                }
                            }
                        }
                    }

                    // Purchase Info
                    if item.purchasePrice != nil || item.purchaseDate != nil {
                        GroupBox("Purchase Information") {
                            VStack(alignment: .leading, spacing: 12) {
                                if let price = item.purchasePrice {
                                    DetailRow(label: "Price", value: "\(item.currency) \(price)")
                                }
                                if let date = item.purchaseDate {
                                    DetailRow(label: "Purchase Date", value: date.formatted(date: .abbreviated, time: .omitted))
                                }
                            }
                        }
                    }

                    // Condition Section - WIRED UP!
                    GroupBox("Condition Documentation") {
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: item.itemCondition.icon)
                                    .foregroundColor(Color(hex: item.itemCondition.color))
                                VStack(alignment: .leading) {
                                    Text("Condition: \(item.itemCondition.rawValue)")
                                        .font(.headline)
                                    Text(item.itemCondition.insuranceImpact)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }

                            if let notes = item.conditionNotes {
                                Text(notes)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            if !item.conditionPhotos.isEmpty {
                                HStack {
                                    Image(systemName: "photo.stack.fill")
                                        .foregroundColor(.orange)
                                    Text("\(item.conditionPhotos.count) condition photo\(item.conditionPhotos.count == 1 ? "" : "s")")
                                    Spacer()
                                }
                            }

                            Button(action: { showingConditionDocumentation = true }) {
                                Label("Update Condition", systemImage: "pencil.circle")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(.vertical, 4)
                    }

                    // Warranty & Location Section
                    GroupBox("Warranty & Location") {
                        VStack(spacing: 12) {
                            // Warranty status
                            if let warrantyDate = item.warrantyExpirationDate {
                                HStack {
                                    Image(systemName: "shield.fill")
                                        .foregroundColor(warrantyDate > Date() ? .green : .red)
                                    VStack(alignment: .leading) {
                                        Text("Warranty \(warrantyDate > Date() ? "Active" : "Expired")")
                                            .font(.headline)
                                        Text("Expires: \(warrantyDate.formatted(date: .abbreviated, time: .omitted))")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                }
                            }

                            // Location info
                            if let room = item.room {
                                HStack {
                                    Image(systemName: "location.fill")
                                        .foregroundColor(.blue)
                                    VStack(alignment: .leading) {
                                        Text(room)
                                            .font(.headline)
                                        if let location = item.specificLocation {
                                            Text(location)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    Spacer()
                                }
                            }

                            // Documents count
                            if !item.documentNames.isEmpty {
                                HStack {
                                    Image(systemName: "doc.stack.fill")
                                        .foregroundColor(.orange)
                                    Text("\(item.documentNames.count) document\(item.documentNames.count == 1 ? "" : "s") attached")
                                    Spacer()
                                }
                            }

                            // Action button
                            Button(action: { showingWarrantyDocuments = true }) {
                                Label("Manage Warranty & Documents", systemImage: "shield.checkerboard")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(.vertical, 4)
                    }

                    // Receipt Section
                    GroupBox("Receipt Documentation") {
                        VStack(spacing: 12) {
                            if let receiptData = item.receiptImageData,
                               let uiImage = UIImage(data: receiptData)
                            {
                                // Receipt exists
                                HStack {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 60, height: 60)
                                        .cornerRadius(8)

                                    VStack(alignment: .leading) {
                                        Text("Receipt Attached")
                                            .font(.headline)
                                        if item.extractedReceiptText != nil {
                                            Text("OCR data available")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }

                                    Spacer()

                                    Button("View/Edit") {
                                        showingReceiptCapture = true
                                    }
                                    .buttonStyle(.bordered)
                                }
                            } else {
                                // No receipt
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("No Receipt Attached")
                                            .foregroundColor(.secondary)
                                        Text("Add a receipt for insurance documentation")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }

                                    Spacer()

                                    Button(action: { showingReceiptCapture = true }) {
                                        Label("Add Receipt", systemImage: "doc.text.viewfinder")
                                    }
                                    .buttonStyle(.borderedProminent)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }

                    // Notes
                    if let notes = item.notes {
                        GroupBox("Notes") {
                            Text(notes)
                                .font(.body)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    // Metadata
                    GroupBox("Metadata") {
                        VStack(alignment: .leading, spacing: 12) {
                            DetailRow(label: "Added", value: item.createdAt.formatted(date: .abbreviated, time: .shortened))
                            DetailRow(label: "Updated", value: item.updatedAt.formatted(date: .abbreviated, time: .shortened))
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    isEditing = true
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            EditItemView(item: item)
        }
        .sheet(isPresented: $showingReceiptCapture) {
            ReceiptCaptureView(item: item)
        }
        .sheet(isPresented: $showingWarrantyDocuments) {
            WarrantyDocumentsView(item: item)
        }
        .sheet(isPresented: $showingConditionDocumentation) {
            ItemConditionView(item: item)
        }
    }
}

struct DetailRow: View {
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
        .padding(.vertical, 2)
    }
}

#Preview {
    NavigationStack {
        ItemDetailView(item: Item(name: "Sample Item", itemDescription: "A sample item for preview", quantity: 5))
            .modelContainer(for: [Item.self, Category.self], inMemory: true)
    }
}
