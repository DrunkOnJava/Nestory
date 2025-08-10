//
// Layer: App-Main
// Module: WarrantyViews
// Purpose: Calculate warranty status and provide visual indicators
//

import Foundation
import SwiftUI

enum WarrantyStatusCalculator {
    struct StatusInfo {
        let daysRemaining: Int
        let icon: String
        let color: Color
        let text: String
    }

    static func calculate(expirationDate: Date) -> StatusInfo? {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: expirationDate).day ?? 0

        let icon: String
        let color: Color
        let text: String

        if days < 0 {
            icon = "shield.slash"
            color = .red
            text = "Warranty expired \(abs(days)) days ago"
        } else if days == 0 {
            icon = "exclamationmark.shield"
            color = .red
            text = "Warranty expires today!"
        } else if days == 1 {
            icon = "exclamationmark.shield"
            color = .orange
            text = "Warranty expires tomorrow"
        } else if days < 30 {
            icon = "exclamationmark.shield"
            color = .orange
            text = "Warranty expires in \(days) days"
        } else if days < 90 {
            icon = "shield.checkerboard"
            color = .yellow
            text = "Warranty valid for \(days) days"
        } else if days < 365 {
            icon = "shield.fill"
            color = .green
            text = "Warranty valid for \(days) days"
        } else {
            let years = days / 365
            icon = "shield.fill"
            color = .green
            text = "Warranty valid for \(years) year\(years == 1 ? "" : "s")"
        }

        return StatusInfo(
            daysRemaining: days,
            icon: icon,
            color: color,
            text: text,
        )
    }
}
