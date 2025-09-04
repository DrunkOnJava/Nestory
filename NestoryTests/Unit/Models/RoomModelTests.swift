//
// Layer: Unit/Models
// Module: RoomModelTests
// Purpose: Comprehensive tests for Room model, location tracking, and item relationships
//

import XCTest
import SwiftData
@testable import Nestory

/// Comprehensive test suite for Room model covering initialization, relationships, and location-based insurance scenarios
final class RoomModelTests: XCTestCase {
    
    // MARK: - Test Infrastructure
    
    private var modelContext: ModelContext!
    private var container: ModelContainer!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Create in-memory model context for testing
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Room.self, Item.self, configurations: configuration)
        modelContext = ModelContext(container)
    }
    
    override func tearDown() async throws {
        modelContext = nil
        container = nil
        try await super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testBasicInitialization() {
        let room = Room(name: "Living Room")
        
        // Test required properties
        XCTAssertEqual(room.name, "Living Room")
        XCTAssertNotNil(room.id)
        
        // Test default values
        XCTAssertEqual(room.icon, "door.left.hand.open")
        XCTAssertNil(room.roomDescription)
        XCTAssertNil(room.floor)
    }
    
    func testFullInitialization() {
        let room = Room(
            name: "Master Bedroom",
            icon: "bed.double.fill",
            roomDescription: "Large bedroom with ensuite bathroom",
            floor: "Second Floor"
        )
        
        XCTAssertEqual(room.name, "Master Bedroom")
        XCTAssertEqual(room.icon, "bed.double.fill")
        XCTAssertEqual(room.roomDescription, "Large bedroom with ensuite bathroom")
        XCTAssertEqual(room.floor, "Second Floor")
    }
    
    func testUniqueIdentifiers() {
        let room1 = Room(name: "Room 1")
        let room2 = Room(name: "Room 2")
        
        XCTAssertNotEqual(room1.id, room2.id)
    }
    
    // MARK: - Property Tests
    
    func testNameProperty() {
        let room = Room(name: "Kitchen")
        
        XCTAssertEqual(room.name, "Kitchen")
        
        // Test name modification
        room.name = "Modern Kitchen"
        XCTAssertEqual(room.name, "Modern Kitchen")
        
        // Test empty name
        room.name = ""
        XCTAssertEqual(room.name, "")
    }
    
    func testIconProperty() {
        let room = Room(name: "Office")
        
        // Test default icon
        XCTAssertEqual(room.icon, "door.left.hand.open")
        
        // Test custom icons
        let officeIcons = ["desktopcomputer", "laptopcomputer", "printer.fill", "book.fill"]
        for icon in officeIcons {
            room.icon = icon
            XCTAssertEqual(room.icon, icon)
        }
    }
    
    func testRoomDescriptionProperty() {
        let room = Room(name: "Basement")
        
        // Test nil description
        XCTAssertNil(room.roomDescription)
        
        // Test setting description
        room.roomDescription = "Finished basement with home theater"
        XCTAssertEqual(room.roomDescription, "Finished basement with home theater")
        
        // Test clearing description
        room.roomDescription = nil
        XCTAssertNil(room.roomDescription)
    }
    
    func testFloorProperty() {
        let room = Room(name: "Bedroom")
        
        // Test nil floor
        XCTAssertNil(room.floor)
        
        // Test setting floor
        room.floor = "Third Floor"
        XCTAssertEqual(room.floor, "Third Floor")
        
        // Test various floor formats
        let floorFormats = ["1st Floor", "Ground Floor", "Upper Level", "Lower Level", "Mezzanine"]
        for floor in floorFormats {
            room.floor = floor
            XCTAssertEqual(room.floor, floor)
        }
    }
    
    // MARK: - Default Rooms Tests
    
    func testCreateDefaultRooms() {
        let defaultRooms = Room.createDefaultRooms()
        
        // Test that we get the expected number of rooms
        XCTAssertEqual(defaultRooms.count, 12)
        
        // Test that all rooms have names
        for room in defaultRooms {
            XCTAssertFalse(room.name.isEmpty)
            XCTAssertFalse(room.icon.isEmpty)
            XCTAssertNotNil(room.id)
        }
        
        // Test specific expected rooms
        let roomNames = defaultRooms.map { $0.name }
        XCTAssertTrue(roomNames.contains("Living Room"))
        XCTAssertTrue(roomNames.contains("Kitchen"))
        XCTAssertTrue(roomNames.contains("Master Bedroom"))
        XCTAssertTrue(roomNames.contains("Garage"))
        XCTAssertTrue(roomNames.contains("Home Office"))
    }
    
    func testDefaultRoomIcons() {
        let defaultRooms = Room.createDefaultRooms()
        
        // Test that specific rooms have appropriate icons
        let roomIconMapping = [
            "Living Room": "sofa",
            "Kitchen": "refrigerator",
            "Master Bedroom": "bed.double",
            "Bathroom": "shower",
            "Home Office": "desktopcomputer",
            "Garage": "car"
        ]
        
        for room in defaultRooms {
            if let expectedIcon = roomIconMapping[room.name] {
                XCTAssertEqual(room.icon, expectedIcon, "Room '\(room.name)' should have icon '\(expectedIcon)'")
            }
        }
    }
    
    func testDefaultRoomsUniqueIds() {
        let defaultRooms = Room.createDefaultRooms()
        let ids = defaultRooms.map { $0.id }
        let uniqueIds = Set(ids)
        
        XCTAssertEqual(ids.count, uniqueIds.count, "All default rooms should have unique IDs")
    }
    
    // MARK: - Relationship Tests with Items
    
    func testItemLocationRelationship() throws {
        let livingRoom = Room(name: "Living Room", icon: "sofa")
        let item1 = Item(name: "TV")
        let item2 = Item(name: "Coffee Table")
        
        // Set room for items
        item1.room = livingRoom.name
        item2.room = livingRoom.name
        
        modelContext.insert(livingRoom)
        modelContext.insert(item1)
        modelContext.insert(item2)
        
        try modelContext.save()
        
        // Verify items are associated with room by name
        XCTAssertEqual(item1.room, "Living Room")
        XCTAssertEqual(item2.room, "Living Room")
    }
    
    func testItemLocationWithSpecificLocation() {
        let room = Room(name: "Kitchen", icon: "refrigerator")
        let item = Item(name: "Microwave")
        
        item.room = room.name
        item.specificLocation = "Counter next to refrigerator"
        
        XCTAssertEqual(item.room, "Kitchen")
        XCTAssertEqual(item.specificLocation, "Counter next to refrigerator")
        XCTAssertEqual(item.location, "Kitchen - Counter next to refrigerator")
    }
    
    func testMultipleItemsInDifferentRooms() throws {
        let bedroom = Room(name: "Master Bedroom")
        let kitchen = Room(name: "Kitchen")
        
        let bedroomItems = [
            Item(name: "Dresser"),
            Item(name: "Nightstand"),
            Item(name: "Alarm Clock")
        ]
        
        let kitchenItems = [
            Item(name: "Blender"),
            Item(name: "Coffee Maker"),
            Item(name: "Toaster")
        ]
        
        // Assign items to rooms
        for item in bedroomItems {
            item.room = bedroom.name
        }
        
        for item in kitchenItems {
            item.room = kitchen.name
        }
        
        modelContext.insert(bedroom)
        modelContext.insert(kitchen)
        for item in bedroomItems + kitchenItems {
            modelContext.insert(item)
        }
        
        try modelContext.save()
        
        // Verify room assignments
        for item in bedroomItems {
            XCTAssertEqual(item.room, "Master Bedroom")
        }
        
        for item in kitchenItems {
            XCTAssertEqual(item.room, "Kitchen")
        }
    }
    
    // MARK: - Insurance Documentation Tests
    
    func testRoomForInsuranceMapping() {
        // Test rooms commonly needed for insurance claims
        let insuranceRelevantRooms = [
            Room(name: "Living Room", icon: "sofa", roomDescription: "Main living area with entertainment center"),
            Room(name: "Kitchen", icon: "refrigerator", roomDescription: "Modern kitchen with stainless steel appliances"),
            Room(name: "Master Bedroom", icon: "bed.double", roomDescription: "Primary bedroom with walk-in closet"),
            Room(name: "Home Office", icon: "desktopcomputer", roomDescription: "Dedicated workspace with built-in shelving"),
            Room(name: "Garage", icon: "car", roomDescription: "Two-car attached garage with workshop area")
        ]
        
        for room in insuranceRelevantRooms {
            XCTAssertFalse(room.name.isEmpty, "Insurance rooms must have clear names")
            XCTAssertFalse(room.icon.isEmpty, "Insurance rooms should have identifiable icons")
            XCTAssertNotNil(room.roomDescription, "Insurance rooms should have descriptions for claim context")
        }
    }
    
    func testFloodDamageScenario() throws {
        // Test room organization for flood damage insurance claim
        let affectedRooms = [
            Room(name: "Basement", icon: "stairs", roomDescription: "Finished basement with carpet and furniture", floor: "Lower Level"),
            Room(name: "Laundry Room", icon: "washer", roomDescription: "Basement laundry area", floor: "Lower Level"),
            Room(name: "Living Room", icon: "sofa", roomDescription: "Ground floor living area", floor: "First Floor"),
            Room(name: "Kitchen", icon: "refrigerator", roomDescription: "Main kitchen area", floor: "First Floor")
        ]
        
        // Create damaged items for each room
        let damagedItems = [
            (room: "Basement", items: ["Sectional Sofa", "Coffee Table", "TV Stand", "Area Rug"]),
            (room: "Laundry Room", items: ["Washer", "Dryer", "Storage Shelves"]),
            (room: "Living Room", items: ["Hardwood Flooring", "Baseboards"]),
            (room: "Kitchen", items: ["Lower Cabinets", "Dishwasher"])
        ]
        
        for room in affectedRooms {
            modelContext.insert(room)
        }
        
        for roomData in damagedItems {
            for itemName in roomData.items {
                let item = TestDataFactory.createDamagedItem()
                item.name = itemName
                item.room = roomData.room
                item.itemCondition = .damaged
                modelContext.insert(item)
            }
        }
        
        try modelContext.save()
        
        // Verify proper organization for insurance claim
        for room in affectedRooms {
            XCTAssertNotNil(room.floor, "Flood damage claims require floor information")
            XCTAssertNotNil(room.roomDescription, "Room descriptions help insurance adjusters")
        }
    }
    
    func testFireDamageScenario() throws {
        // Test room-based fire damage documentation
        let fireAffectedRooms = [
            Room(name: "Kitchen", icon: "refrigerator", roomDescription: "Origin of fire - electrical appliance malfunction", floor: "First Floor"),
            Room(name: "Dining Room", icon: "fork.knife", roomDescription: "Adjacent room with smoke and heat damage", floor: "First Floor"),
            Room(name: "Living Room", icon: "sofa", roomDescription: "Smoke damage throughout", floor: "First Floor"),
            Room(name: "Master Bedroom", icon: "bed.double", roomDescription: "Smoke damage, no direct fire exposure", floor: "Second Floor")
        ]
        
        // Create items with varying damage levels
        let damageScenarios = [
            (room: "Kitchen", condition: ItemCondition.damaged, items: ["Stove", "Microwave", "Cabinets"]),
            (room: "Dining Room", condition: ItemCondition.poor, items: ["Dining Table", "Chairs"]),
            (room: "Living Room", condition: ItemCondition.fair, items: ["Sofa", "TV", "Curtains"]),
            (room: "Master Bedroom", condition: ItemCondition.good, items: ["Bed Frame", "Dresser"])
        ]
        
        for room in fireAffectedRooms {
            modelContext.insert(room)
        }
        
        for scenario in damageScenarios {
            for itemName in scenario.items {
                let item = Item(name: itemName)
                item.room = scenario.room
                item.itemCondition = scenario.condition
                item.conditionNotes = "Fire damage assessment - \(scenario.condition.rawValue.lowercased()) condition"
                modelContext.insert(item)
            }
        }
        
        try modelContext.save()
        
        // Verify fire damage documentation structure
        XCTAssertEqual(fireAffectedRooms.count, 4)
        for room in fireAffectedRooms {
            XCTAssertTrue(room.roomDescription?.contains("damage") == true, "Fire damage rooms should document damage type")
        }
    }
    
    // MARK: - Codable Tests
    
    func testCodableEncoding() throws {
        let room = Room(
            name: "Study",
            icon: "book.fill",
            roomDescription: "Quiet reading room with built-in bookshelves",
            floor: "Second Floor"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(room)
        
        XCTAssertGreaterThan(data.count, 0)
        
        // Verify JSON structure
        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        XCTAssertNotNil(json)
        XCTAssertEqual(json?["name"] as? String, "Study")
        XCTAssertEqual(json?["icon"] as? String, "book.fill")
        XCTAssertEqual(json?["roomDescription"] as? String, "Quiet reading room with built-in bookshelves")
        XCTAssertEqual(json?["floor"] as? String, "Second Floor")
    }
    
    func testCodableDecoding() throws {
        let jsonString = """
        {
            "id": "123e4567-e89b-12d3-a456-426614174000",
            "name": "Library",
            "icon": "books.vertical.fill",
            "roomDescription": "Home library with antique furniture",
            "floor": "First Floor"
        }
        """
        
        let data = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        let room = try decoder.decode(Room.self, from: data)
        
        XCTAssertEqual(room.name, "Library")
        XCTAssertEqual(room.icon, "books.vertical.fill")
        XCTAssertEqual(room.roomDescription, "Home library with antique furniture")
        XCTAssertEqual(room.floor, "First Floor")
        XCTAssertEqual(room.id.uuidString.uppercased(), "123E4567-E89B-12D3-A456-426614174000")
    }
    
    func testCodableRoundTrip() throws {
        let originalRoom = Room(
            name: "Sunroom",
            icon: "sun.max.fill",
            roomDescription: "Bright room with panoramic windows",
            floor: "First Floor"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalRoom)
        
        let decoder = JSONDecoder()
        let decodedRoom = try decoder.decode(Room.self, from: data)
        
        XCTAssertEqual(originalRoom.name, decodedRoom.name)
        XCTAssertEqual(originalRoom.icon, decodedRoom.icon)
        XCTAssertEqual(originalRoom.roomDescription, decodedRoom.roomDescription)
        XCTAssertEqual(originalRoom.floor, decodedRoom.floor)
        XCTAssertEqual(originalRoom.id, decodedRoom.id)
    }
    
    // MARK: - Equality Tests
    
    func testEquality() {
        let room1 = Room(name: "Bedroom")
        let room2 = Room(name: "Bedroom")
        
        // Different rooms with same name should not be equal (different IDs)
        XCTAssertNotEqual(room1, room2)
        
        // Same room should be equal to itself
        XCTAssertEqual(room1, room1)
        
        // Test with same ID (simulate loaded from database)
        room2.id = room1.id
        XCTAssertEqual(room1, room2)
    }
    
    // MARK: - Performance Tests
    
    func testRoomCreationPerformance() {
        measure {
            for i in 0..<1000 {
                let room = Room(
                    name: "Room \(i)",
                    icon: "door.left.hand.open",
                    roomDescription: "Test room number \(i)",
                    floor: "Floor \(i % 3 + 1)"
                )
                _ = room.id // Force lazy initialization
            }
        }
    }
    
    func testDefaultRoomsCreationPerformance() {
        measure {
            for _ in 0..<100 {
                let _ = Room.createDefaultRooms()
            }
        }
    }
    
    func testCodablePerformance() throws {
        let rooms = (0..<100).map { i in
            Room(
                name: "Room \(i)",
                icon: "door.left.hand.open",
                roomDescription: "Performance test room \(i)",
                floor: "Floor \(i % 4 + 1)"
            )
        }
        
        measure {
            let encoder = JSONEncoder()
            for room in rooms {
                do {
                    let _ = try encoder.encode(room)
                } catch {
                    XCTFail("Encoding failed: \(error)")
                }
            }
        }
    }
    
    // MARK: - Edge Cases
    
    func testEmptyStringProperties() {
        let room = Room(name: "")
        
        XCTAssertEqual(room.name, "")
        
        room.icon = ""
        room.roomDescription = ""
        room.floor = ""
        
        XCTAssertEqual(room.icon, "")
        XCTAssertEqual(room.roomDescription, "")
        XCTAssertEqual(room.floor, "")
    }
    
    func testVeryLongRoomName() {
        let longName = String(repeating: "A", count: 1000)
        let room = Room(name: longName)
        
        XCTAssertEqual(room.name.count, 1000)
        XCTAssertEqual(room.name, longName)
    }
    
    func testSpecialCharactersInRoomName() {
        let specialNames = [
            "Master Bedroom & Bath",
            "Guest Room/Office",
            "Mother-in-Law Suite",
            "Living Room (Main)",
            "Kitchen & Breakfast Nook",
            "Café Corner",
            "Naïve Room Name",
            "Room with emoji 🏠"
        ]
        
        for name in specialNames {
            let room = Room(name: name)
            XCTAssertEqual(room.name, name)
        }
    }
    
    func testMultilingualRoomNames() {
        let multilingualNames = [
            "Sala de estar",  // Spanish
            "Chambre à coucher",  // French
            "Schlafzimmer",  // German
            "客厅",  // Chinese
            "リビングルーム",  // Japanese
            "Гостиная",  // Russian
            "غرفة المعيشة"  // Arabic
        ]
        
        for name in multilingualNames {
            let room = Room(name: name)
            XCTAssertEqual(room.name, name)
        }
    }
    
    // MARK: - Real-world Home Layout Tests
    
    func testTypicalSingleStoryHomeLayout() throws {
        let singleStoryRooms = [
            Room(name: "Front Porch", icon: "door.garage.open", floor: "Ground Level"),
            Room(name: "Entry Foyer", icon: "door.left.hand.open", floor: "Ground Level"),
            Room(name: "Living Room", icon: "sofa", floor: "Ground Level"),
            Room(name: "Dining Room", icon: "fork.knife", floor: "Ground Level"),
            Room(name: "Kitchen", icon: "refrigerator", floor: "Ground Level"),
            Room(name: "Master Bedroom", icon: "bed.double", floor: "Ground Level"),
            Room(name: "Master Bathroom", icon: "bathtub", floor: "Ground Level"),
            Room(name: "Guest Bedroom", icon: "bed.double", floor: "Ground Level"),
            Room(name: "Guest Bathroom", icon: "shower", floor: "Ground Level"),
            Room(name: "Laundry Room", icon: "washer", floor: "Ground Level"),
            Room(name: "Garage", icon: "car.2", floor: "Ground Level")
        ]
        
        for room in singleStoryRooms {
            modelContext.insert(room)
            XCTAssertEqual(room.floor, "Ground Level")
            XCTAssertFalse(room.name.isEmpty)
            XCTAssertFalse(room.icon.isEmpty)
        }
        
        try modelContext.save()
        XCTAssertEqual(singleStoryRooms.count, 11)
    }
    
    func testMultiStoryHomeLayout() throws {
        let multiStoryRooms = [
            // First Floor
            Room(name: "Living Room", icon: "sofa", floor: "First Floor"),
            Room(name: "Kitchen", icon: "refrigerator", floor: "First Floor"),
            Room(name: "Dining Room", icon: "fork.knife", floor: "First Floor"),
            Room(name: "Powder Room", icon: "toilet", floor: "First Floor"),
            Room(name: "Family Room", icon: "tv", floor: "First Floor"),
            
            // Second Floor
            Room(name: "Master Bedroom", icon: "bed.double", floor: "Second Floor"),
            Room(name: "Master Bathroom", icon: "bathtub", floor: "Second Floor"),
            Room(name: "Bedroom 2", icon: "bed.double", floor: "Second Floor"),
            Room(name: "Bedroom 3", icon: "bed.double", floor: "Second Floor"),
            Room(name: "Hall Bathroom", icon: "shower", floor: "Second Floor"),
            Room(name: "Linen Closet", icon: "cabinet", floor: "Second Floor"),
            
            // Basement
            Room(name: "Recreation Room", icon: "gamecontroller", floor: "Basement"),
            Room(name: "Storage Room", icon: "shippingbox", floor: "Basement"),
            Room(name: "Utility Room", icon: "wrench.and.screwdriver", floor: "Basement")
        ]
        
        let floorCounts = Dictionary(grouping: multiStoryRooms, by: { $0.floor! })
        
        XCTAssertEqual(floorCounts["First Floor"]?.count, 5)
        XCTAssertEqual(floorCounts["Second Floor"]?.count, 6)
        XCTAssertEqual(floorCounts["Basement"]?.count, 3)
        
        for room in multiStoryRooms {
            modelContext.insert(room)
        }
        
        try modelContext.save()
        XCTAssertEqual(multiStoryRooms.count, 14)
    }
    
    func testApartmentLayout() throws {
        let apartmentRooms = [
            Room(name: "Living/Dining Room", icon: "sofa", roomDescription: "Open concept living and dining area"),
            Room(name: "Kitchen", icon: "refrigerator", roomDescription: "Galley kitchen with breakfast bar"),
            Room(name: "Master Bedroom", icon: "bed.double", roomDescription: "Spacious bedroom with walk-in closet"),
            Room(name: "Master Bathroom", icon: "bathtub", roomDescription: "Full bathroom with shower/tub combo"),
            Room(name: "Guest Bedroom/Office", icon: "bed.double", roomDescription: "Flexible space for guests or work"),
            Room(name: "Powder Room", icon: "toilet", roomDescription: "Half bath near entry"),
            Room(name: "Balcony", icon: "sun.max", roomDescription: "Outdoor space with city view"),
            Room(name: "Storage Closet", icon: "cabinet", roomDescription: "Additional storage space")
        ]
        
        for room in apartmentRooms {
            modelContext.insert(room)
            XCTAssertNotNil(room.roomDescription, "Apartment rooms should have descriptions for insurance")
        }
        
        try modelContext.save()
        XCTAssertEqual(apartmentRooms.count, 8)
    }
}