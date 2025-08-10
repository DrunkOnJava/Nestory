// Layer: Foundation
// Module: Foundation/Models
// Purpose: Share group model for family/group sharing

import Foundation
import SwiftData

/// Share group for family or team sharing
@Model
public final class ShareGroup {
    // MARK: - Properties

    @Attribute(.unique)
    public var id: UUID

    public var name: String
    public var groupDescription: String?
    public var members: Data // JSON array of member info
    public var ownerUserId: String
    public var shareScope: String // "full", "category", "location"
    public var permissions: Data // JSON permissions object
    public var inviteCode: String?
    public var isActive: Bool

    // Timestamps
    public var createdAt: Date
    public var updatedAt: Date

    // MARK: - Initialization

    public init(
        name: String,
        ownerUserId: String,
        scope: ShareScope = .full
    ) {
        id = UUID()
        self.name = name
        self.ownerUserId = ownerUserId
        shareScope = scope.rawValue
        members = try! JSONEncoder().encode([Member]())
        permissions = try! JSONEncoder().encode(Permissions())
        isActive = true
        createdAt = Date()
        updatedAt = Date()
    }

    // MARK: - Computed Properties

    /// Share scope enum
    public var scope: ShareScope {
        get { ShareScope(rawValue: shareScope) ?? .full }
        set {
            shareScope = newValue.rawValue
            updatedAt = Date()
        }
    }

    /// Get members array
    public var membersList: [Member] {
        get {
            guard let members = try? JSONDecoder().decode([Member].self, from: members) else {
                return []
            }
            return members
        }
        set {
            members = try! JSONEncoder().encode(newValue)
            updatedAt = Date()
        }
    }

    /// Get permissions object
    public var permissionsSettings: Permissions {
        get {
            guard let perms = try? JSONDecoder().decode(Permissions.self, from: permissions) else {
                return Permissions()
            }
            return perms
        }
        set {
            permissions = try! JSONEncoder().encode(newValue)
            updatedAt = Date()
        }
    }

    /// Number of members
    public var memberCount: Int {
        membersList.count
    }

    /// Check if user is owner
    public func isOwner(userId: String) -> Bool {
        ownerUserId == userId
    }

    /// Check if user is member
    public func isMember(userId: String) -> Bool {
        membersList.contains { $0.userId == userId }
    }

    /// Get member by user ID
    public func member(for userId: String) -> Member? {
        membersList.first { $0.userId == userId }
    }

    // MARK: - Methods

    /// Add a member to the group
    public func addMember(_ member: Member) {
        var members = membersList
        if !members.contains(where: { $0.userId == member.userId }) {
            members.append(member)
            membersList = members
        }
    }

    /// Remove a member from the group
    public func removeMember(userId: String) {
        var members = membersList
        members.removeAll { $0.userId == userId }
        membersList = members
    }

    /// Update member role
    public func updateMemberRole(userId: String, role: MemberRole) {
        var members = membersList
        if let index = members.firstIndex(where: { $0.userId == userId }) {
            members[index].role = role.rawValue
            membersList = members
        }
    }

    /// Generate new invite code
    public func generateInviteCode() {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let code = (0 ..< 8).map { _ in
            characters.randomElement()!
        }.map { String($0) }.joined()

        inviteCode = code
        updatedAt = Date()
    }

    /// Revoke invite code
    public func revokeInviteCode() {
        inviteCode = nil
        updatedAt = Date()
    }

    /// Update group properties
    public func update(
        name: String? = nil,
        description: String? = nil,
        scope: ShareScope? = nil
    ) {
        if let name {
            self.name = name
        }
        if let description {
            groupDescription = description
        }
        if let scope {
            self.scope = scope
        }
        updatedAt = Date()
    }
}

// MARK: - Supporting Types

/// Member of a share group
public struct Member: Codable {
    public let userId: String
    public var name: String
    public var email: String
    public var role: String // "owner", "editor", "viewer"
    public var joinedAt: Date

    public init(userId: String, name: String, email: String, role: MemberRole) {
        self.userId = userId
        self.name = name
        self.email = email
        self.role = role.rawValue
        joinedAt = Date()
    }

    public var memberRole: MemberRole {
        MemberRole(rawValue: role) ?? .viewer
    }
}

/// Permissions for share group
public struct Permissions: Codable {
    public var canAddItems: Bool
    public var canEditItems: Bool
    public var canDeleteItems: Bool
    public var canAddMembers: Bool
    public var canRemoveMembers: Bool
    public var canEditCategories: Bool
    public var canEditLocations: Bool
    public var canExport: Bool

    public init(
        canAddItems: Bool = true,
        canEditItems: Bool = true,
        canDeleteItems: Bool = false,
        canAddMembers: Bool = false,
        canRemoveMembers: Bool = false,
        canEditCategories: Bool = false,
        canEditLocations: Bool = false,
        canExport: Bool = true
    ) {
        self.canAddItems = canAddItems
        self.canEditItems = canEditItems
        self.canDeleteItems = canDeleteItems
        self.canAddMembers = canAddMembers
        self.canRemoveMembers = canRemoveMembers
        self.canEditCategories = canEditCategories
        self.canEditLocations = canEditLocations
        self.canExport = canExport
    }
}

/// Share scope
public enum ShareScope: String, CaseIterable, Codable {
    case full
    case category
    case location

    public var displayName: String {
        switch self {
        case .full: "Full Inventory"
        case .category: "Specific Categories"
        case .location: "Specific Locations"
        }
    }
}

/// Member role
public enum MemberRole: String, CaseIterable, Codable {
    case owner
    case editor
    case viewer

    public var displayName: String {
        switch self {
        case .owner: "Owner"
        case .editor: "Editor"
        case .viewer: "Viewer"
        }
    }

    public var permissions: Permissions {
        switch self {
        case .owner:
            Permissions(
                canAddItems: true,
                canEditItems: true,
                canDeleteItems: true,
                canAddMembers: true,
                canRemoveMembers: true,
                canEditCategories: true,
                canEditLocations: true,
                canExport: true
            )
        case .editor:
            Permissions(
                canAddItems: true,
                canEditItems: true,
                canDeleteItems: false,
                canAddMembers: false,
                canRemoveMembers: false,
                canEditCategories: true,
                canEditLocations: true,
                canExport: true
            )
        case .viewer:
            Permissions(
                canAddItems: false,
                canEditItems: false,
                canDeleteItems: false,
                canAddMembers: false,
                canRemoveMembers: false,
                canEditCategories: false,
                canEditLocations: false,
                canExport: true
            )
        }
    }
}
