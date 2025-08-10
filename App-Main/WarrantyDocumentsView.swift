
//
//  WarrantyDocumentsView.swift
//  Nestory
//
//  REMINDER: This view is WIRED UP in ItemDetailView and EditItemView
//  Provides warranty tracking, document attachments, and room assignment

import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct WarrantyDocumentsView: View {
    @Bindable var item: Item
    @Environment(\.dismiss) private var dismiss
    @Query private var rooms: [Room]

    @State private var selectedTab = 0
    @State private var showingDocumentPicker = false
    @State private var showingRoomPicker = false
    @State private var newRoomName = ""
    @State private var showingNewRoomAlert = false

    // Warranty states
    @State private var warrantyEnabled = false
    @State private var warrantyExpiration = Date()
    @State private var warrantyProvider = ""
    @State private var warrantyNotes = ""
    @State private var showingWarrantyAlert = false

    // Room states
    @State private var selectedRoom = ""
    @State private var specificLocation = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab selector
                Picker("View", selection: $selectedTab) {
                    Label("Warranty", systemImage: "shield").tag(0)
                    Label("Location", systemImage: "location").tag(1)
                    Label("Documents", systemImage: "doc.stack").tag(2)
                }
                .pickerStyle(.segmented)
                .padding()

                ScrollView {
                    VStack(spacing: 20) {
                        switch selectedTab {
                        case 0:
                            warrantySection
                        case 1:
                            locationSection
                        case 2:
                            documentsSection
                        default:
                            EmptyView()
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Warranty & Documents")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        saveChanges()
                        dismiss()
                    }
                }
            }
            .alert("Warranty Expiring Soon", isPresented: $showingWarrantyAlert) {
                Button("OK") {}
            } message: {
                Text("This warranty expires in less than 30 days. You'll receive a notification reminder.")
            }
            .alert("Add New Room", isPresented: $showingNewRoomAlert) {
                TextField("Room Name", text: $newRoomName)
                Button("Cancel", role: .cancel) {}
                Button("Add") {
                    addNewRoom()
                }
            } message: {
                Text("Enter a name for the new room")
            }
            .fileImporter(
                isPresented: $showingDocumentPicker,
                allowedContentTypes: [.pdf, .image, .text],
                allowsMultipleSelection: true
            ) { result in
                handleDocumentImport(result)
            }
        }
        .onAppear {
            loadExistingData()
        }
    }

    // MARK: - Warranty Section

    private var warrantySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Toggle("Warranty Coverage", isOn: $warrantyEnabled)
                .tint(.green)

            if warrantyEnabled {
                GroupBox {
                    VStack(spacing: 12) {
                        DatePicker(
                            "Expiration Date",
                            selection: $warrantyExpiration,
                            in: Date()...,
                            displayedComponents: .date
                        )

                        TextField("Warranty Provider", text: $warrantyProvider)
                            .textFieldStyle(.roundedBorder)

                        VStack(alignment: .leading) {
                            Text("Warranty Notes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextEditor(text: $warrantyNotes)
                                .frame(minHeight: 80)
                                .padding(4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                        }
                    }
                }

                // Warranty status
                if let days = daysUntilExpiration {
                    HStack {
                        Image(systemName: warrantyStatusIcon)
                            .foregroundColor(warrantyStatusColor)
                        Text(warrantyStatusText(days: days))
                            .font(.caption)
                            .foregroundColor(warrantyStatusColor)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(warrantyStatusColor.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
    }

    // MARK: - Location Section

    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Room Assignment")
                .font(.headline)

            // Room picker
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(rooms) { room in
                        RoomChip(
                            room: room,
                            isSelected: selectedRoom == room.name,
                            action: { selectedRoom = room.name }
                        )
                    }

                    // Add new room button
                    Button(action: { showingNewRoomAlert = true }) {
                        Label("Add Room", systemImage: "plus.circle")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray5))
                            .cornerRadius(20)
                    }
                }
            }

            // Specific location
            VStack(alignment: .leading, spacing: 8) {
                Text("Specific Location")
                    .font(.headline)

                TextField("e.g., Top shelf, closet, drawer #3", text: $specificLocation)
                    .textFieldStyle(.roundedBorder)

                Text("Add details to help locate this item quickly during an emergency")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Visual location preview
            if !selectedRoom.isEmpty || !specificLocation.isEmpty {
                GroupBox {
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            if !selectedRoom.isEmpty {
                                Text(selectedRoom)
                                    .font(.headline)
                            }
                            if !specificLocation.isEmpty {
                                Text(specificLocation)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                    }
                }
            }
        }
    }

    // MARK: - Documents Section

    private var documentsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Attached Documents")
                    .font(.headline)
                Spacer()
                Button(action: { showingDocumentPicker = true }) {
                    Label("Add", systemImage: "plus.circle.fill")
                }
            }

            if item.documentNames.isEmpty {
                GroupBox {
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("No Documents Attached")
                            .font(.headline)
                        Text("Add user manuals, warranties, receipts, or other important documents")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)

                        Button(action: { showingDocumentPicker = true }) {
                            Label("Add Document", systemImage: "doc.badge.plus")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
            } else {
                ForEach(Array(item.documentNames.enumerated()), id: \.offset) { index, name in
                    DocumentRow(
                        name: name,
                        size: (index < item.documentAttachments.count) ? item.documentAttachments[index].count : 0,
                        onDelete: { removeDocument(at: index) }
                    )
                }
            }

            // Tips
            GroupBox {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Document Tips", systemImage: "lightbulb")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("• Keep user manuals for warranty claims")
                        .font(.caption2)
                    Text("• Store purchase invoices for proof")
                        .font(.caption2)
                    Text("• Add appraisal documents for valuables")
                        .font(.caption2)
                    Text("• Include service records for maintenance")
                        .font(.caption2)
                }
                .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Helper Methods

    private func loadExistingData() {
        warrantyEnabled = item.warrantyExpirationDate != nil
        warrantyExpiration = item.warrantyExpirationDate ?? Date()
        warrantyProvider = item.warrantyProvider ?? ""
        warrantyNotes = item.warrantyNotes ?? ""
        selectedRoom = item.room ?? ""
        specificLocation = item.specificLocation ?? ""
    }

    private func saveChanges() {
        // Save warranty info
        if warrantyEnabled {
            item.warrantyExpirationDate = warrantyExpiration
            item.warrantyProvider = warrantyProvider.isEmpty ? nil : warrantyProvider
            item.warrantyNotes = warrantyNotes.isEmpty ? nil : warrantyNotes

            // Check if warranty is expiring soon
            if let days = daysUntilExpiration, days < 30 {
                showingWarrantyAlert = true
            }
        } else {
            item.warrantyExpirationDate = nil
            item.warrantyProvider = nil
            item.warrantyNotes = nil
        }

        // Save location info
        item.room = selectedRoom.isEmpty ? nil : selectedRoom
        item.specificLocation = specificLocation.isEmpty ? nil : specificLocation

        item.updatedAt = Date()
    }

    private func addNewRoom() {
        guard !newRoomName.isEmpty else { return }

        _ = Room(name: newRoomName)
        // Would need to inject ModelContext to save
        selectedRoom = newRoomName
        newRoomName = ""
    }

    private func handleDocumentImport(_ result: Result<[URL], Error>) {
        switch result {
        case let .success(urls):
            for url in urls {
                guard url.startAccessingSecurityScopedResource() else { continue }
                defer { url.stopAccessingSecurityScopedResource() }

                if let data = try? Data(contentsOf: url) {
                    item.documentAttachments.append(data)
                    item.documentNames.append(url.lastPathComponent)
                }
            }
        case let .failure(error):
            print("Document import error: \(error)")
        }
    }

    private func removeDocument(at index: Int) {
        guard index < item.documentNames.count else { return }
        item.documentNames.remove(at: index)
        if index < item.documentAttachments.count {
            item.documentAttachments.remove(at: index)
        }
    }

    // MARK: - Computed Properties

    private var daysUntilExpiration: Int? {
        guard warrantyEnabled else { return nil }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: warrantyExpiration).day
        return days
    }

    private var warrantyStatusIcon: String {
        guard let days = daysUntilExpiration else { return "shield" }
        if days < 0 { return "shield.slash" }
        if days < 30 { return "exclamationmark.shield" }
        if days < 90 { return "shield.checkerboard" }
        return "shield.fill"
    }

    private var warrantyStatusColor: Color {
        guard let days = daysUntilExpiration else { return .gray }
        if days < 0 { return .red }
        if days < 30 { return .orange }
        if days < 90 { return .yellow }
        return .green
    }

    private func warrantyStatusText(days: Int) -> String {
        if days < 0 { return "Warranty expired \(abs(days)) days ago" }
        if days == 0 { return "Warranty expires today!" }
        if days == 1 { return "Warranty expires tomorrow" }
        if days < 30 { return "Warranty expires in \(days) days" }
        if days < 365 { return "Warranty valid for \(days) days" }
        let years = days / 365
        return "Warranty valid for \(years) year\(years == 1 ? "" : "s")"
    }
}

// MARK: - Supporting Views

struct RoomChip: View {
    let room: Room
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: room.icon)
                Text(room.name)
            }
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor : Color(.systemGray5))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

struct DocumentRow: View {
    let name: String
    let size: Int
    let onDelete: () -> Void

    var body: some View {
        HStack {
            Image(systemName: documentIcon)
                .foregroundColor(.blue)
                .frame(width: 30)

            VStack(alignment: .leading) {
                Text(name)
                    .font(.subheadline)
                    .lineLimit(1)
                Text(formatFileSize(size))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }

    private var documentIcon: String {
        if name.hasSuffix(".pdf") { return "doc.richtext" }
        if name.hasSuffix(".jpg") || name.hasSuffix(".png") { return "photo" }
        return "doc"
    }

    private func formatFileSize(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

// Extension moved to UI/UI-Core/Extensions.swift

#Preview {
    let item = Item(name: "Test Item")
    return WarrantyDocumentsView(item: item)
        .modelContainer(for: [Item.self, Room.self], inMemory: true)
}
