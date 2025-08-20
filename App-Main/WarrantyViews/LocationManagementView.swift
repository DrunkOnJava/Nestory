//
// Layer: App-Main
// Module: WarrantyViews
// Purpose: Manage item location and room assignment
//

import SwiftData
import SwiftUI

struct LocationManagementView: View {
    @Bindable var item: Item
    @Query private var rooms: [Room]

    @State private var selectedRoom = ""
    @State private var specificLocation = ""
    @State private var showingNewRoomAlert = false
    @State private var newRoomName = ""

    var body: some View {
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
                        ) {
                            selectedRoom = room.name
                            saveChanges()
                        }
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
                    .onChange(of: specificLocation) { _, _ in
                        saveChanges()
                    }

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
        .alert("Add New Room", isPresented: $showingNewRoomAlert) {
            TextField("Room Name", text: $newRoomName)
            Button("Cancel", role: .cancel) {}
            Button("Add") {
                addNewRoom()
            }
        } message: {
            Text("Enter a name for the new room")
        }
        .onAppear {
            loadExistingData()
        }
    }

    private func loadExistingData() {
        selectedRoom = item.room ?? ""
        specificLocation = item.specificLocation ?? ""
    }

    private func saveChanges() {
        item.room = selectedRoom.isEmpty ? nil : selectedRoom
        item.specificLocation = specificLocation.isEmpty ? nil : specificLocation
        item.updatedAt = Date()
    }

    private func addNewRoom() {
        guard !newRoomName.isEmpty else { return }

        // Note: Room creation needs ModelContext injection
        // This is a simplified version - actual implementation
        // would inject ModelContext through environment
        _ = Room(name: newRoomName)
        selectedRoom = newRoomName
        newRoomName = ""
        saveChanges()
    }
}
