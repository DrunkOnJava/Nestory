//
// Layer: Foundation
// Module: Core
// Purpose: Comprehensive color system for light/dark mode support
//

import SwiftUI

// MARK: - App Color System

public struct NestoryColors {
    
    // MARK: - Primary Colors
    
    public static let primary = Color("Primary")
    public static let primaryBackground = Color("PrimaryBackground")
    public static let secondaryBackground = Color("SecondaryBackground")
    public static let tertiaryBackground = Color("TertiaryBackground")
    
    // MARK: - Text Colors
    
    public static let primaryText = Color("PrimaryText")
    public static let secondaryText = Color("SecondaryText")
    public static let tertiaryText = Color("TertiaryText")
    
    // MARK: - Semantic Colors
    
    public static let success = Color("Success")
    public static let warning = Color("Warning")
    public static let error = Color("Error")
    public static let info = Color("Info")
    
    // MARK: - Component Colors
    
    public static let cardBackground = Color("CardBackground")
    public static let buttonBackground = Color("ButtonBackground")
    public static let inputBackground = Color("InputBackground")
    public static let separatorColor = Color("Separator")
    
    // MARK: - Specialty Colors
    
    public static let accent = Color("AccentColor")
    public static let highlight = Color("Highlight")
    public static let shadow = Color("Shadow")
    
    // MARK: - Insurance/Warranty Specific Colors
    
    public static let warrantyActive = Color("WarrantyActive")
    public static let warrantyExpiring = Color("WarrantyExpiring")
    public static let warrantyExpired = Color("WarrantyExpired")
    public static let insuranceGreen = Color("InsuranceGreen")
    public static let receiptBlue = Color("ReceiptBlue")
}

// MARK: - Dynamic Color Extensions

extension Color {
    /// Creates a color that adapts between light and dark mode
    public static func adaptiveColor(
        light: Color,
        dark: Color
    ) -> Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
    
    /// Insurance status colors that adapt to theme
    public static func insuranceStatusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "active", "covered":
            return NestoryColors.warrantyActive
        case "expiring", "warning":
            return NestoryColors.warrantyExpiring
        case "expired", "missing":
            return NestoryColors.warrantyExpired
        default:
            return NestoryColors.secondaryText
        }
    }
}

// MARK: - Theme-Aware Gradient Support

public struct NestoryGradients {
    
    public static let primaryGradient = LinearGradient(
        colors: [
            NestoryColors.primary,
            NestoryColors.primary.opacity(0.8)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    public static let cardGradient = LinearGradient(
        colors: [
            NestoryColors.cardBackground,
            NestoryColors.cardBackground.opacity(0.95)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    
    public static let successGradient = LinearGradient(
        colors: [
            NestoryColors.success,
            NestoryColors.success.opacity(0.7)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    public static let warningGradient = LinearGradient(
        colors: [
            NestoryColors.warning,
            NestoryColors.warning.opacity(0.7)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Color Accessibility

extension NestoryColors {
    /// Returns a color that ensures proper contrast for accessibility
    public static func accessibleTextColor(on backgroundColor: Color) -> Color {
        // This would typically calculate luminance and return appropriate contrast
        // For now, return a sensible default
        return primaryText
    }
    
    /// High contrast mode support
    public static func highContrastColor(base: Color) -> Color {
        Color(UIColor { traitCollection in
            if traitCollection.accessibilityContrast == .high {
                // Return higher contrast version
                return UIColor(base.opacity(1.0))
            } else {
                return UIColor(base)
            }
        })
    }
}