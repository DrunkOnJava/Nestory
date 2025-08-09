// Layer: Foundation

import Foundation
import SwiftData

@Model
public final class ShareGroup {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var shareDescription: String?
    public var members: [ShareMember]
    public var inviteCode: String?
    public var isActive: Bool

    @Relationship(deleteRule: .nullify)
    public var sharedItems: [Item]?

    public var createdAt: Date
    public var updatedAt: Date

    public init(
        name: String,
        description: String? = nil
    ) throws {
        id = UUID()
        self.name = name
        shareDescription = description
        members = []
        inviteCode = ShareGroup.generateInviteCode()
        isActive = true
        sharedItems = []
        createdAt = Date()
        updatedAt = Date()
    }

    public func addMember(
        userId: String,
        name: String,
        role: ShareRole = .viewer
    ) throws {
        guard !members.contains(where: { $0.userId == userId }) else {
            throw AppError.conflict(resource: "ShareGroup", reason: "Member already exists")
        }

        let member = ShareMember(
            userId: userId,
            name: name,
            role: role
        )
        members.append(member)
        updatedAt = Date()
    }

    public func removeMember(userId: String) throws {
        guard members.contains(where: { $0.userId == userId }) else {
            throw AppError.notFound(resource: "ShareMember", id: userId)
        }

        members.removeAll { $0.userId == userId }
        updatedAt = Date()
    }

    public func updateMemberRole(userId: String, role: ShareRole) throws {
        guard let index = members.firstIndex(where: { $0.userId == userId }) else {
            throw AppError.notFound(resource: "ShareMember", id: userId)
        }

        members[index].role = role
        updatedAt = Date()
    }

    public func regenerateInviteCode() {
        inviteCode = ShareGroup.generateInviteCode()
        updatedAt = Date()
    }

    private static func generateInviteCode() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0 ..< 8).map { _ in letters.randomElement()! })
    }

    public var memberCount: Int {
        members.count
    }

    public var sharedItemCount: Int {
        sharedItems?.count ?? 0
    }
}

public struct ShareMember: Codable {
    public let id: UUID
    public let userId: String
    public let name: String
    public var role: ShareRole
    public let joinedAt: Date

    public init(userId: String, name: String, role: ShareRole) {
        id = UUID()
        self.userId = userId
        self.name = name
        self.role = role
        joinedAt = Date()
    }
}

public enum ShareRole: String, Codable, CaseIterable {
    case owner
    case admin
    case editor
    case viewer

    public var displayName: String {
        switch self {
        case .owner: "Owner"
        case .admin: "Admin"
        case .editor: "Editor"
        case .viewer: "Viewer"
        }
    }

    public var canEdit: Bool {
        switch self {
        case .owner, .admin, .editor: true
        case .viewer: false
        }
    }

    public var canManageMembers: Bool {
        switch self {
        case .owner, .admin: true
        case .editor, .viewer: false
        }
    }

    public var canDelete: Bool {
        self == .owner
    }
}
