//
// Layer: Foundation
// Module: Core/Constants
// Purpose: UI-related constants for consistent design system
//

import Foundation

/// UI constants for consistent design patterns throughout the application
/// Note: Values are Double - cast to CGFloat in upper layers that import CoreGraphics
public enum UIConstants {
    /// Spacing values for consistent layout margins and padding
    public enum Spacing {
        /// Extra small spacing (8pt)
        public static let xs: Double = 8

        /// Small spacing (12pt)
        public static let sm: Double = 12

        /// Medium spacing (16pt)
        public static let md: Double = 16

        /// Large spacing (20pt)
        public static let lg: Double = 20

        /// Extra large spacing (24pt)
        public static let xl: Double = 24

        /// Extra extra large spacing (30pt)
        public static let xxl: Double = 30

        /// Standard component spacing (20pt)
        public static let component: Double = 20

        /// Section spacing (30pt)
        public static let section: Double = 30
    }

    /// Font sizes for typography scale
    public enum FontSize {
        /// Caption text (12pt)
        public static let caption: Double = 12

        /// Body text (16pt)
        public static let body: Double = 16

        /// Title text (24pt)
        public static let title: Double = 24

        /// Large title (32pt)
        public static let largeTitle: Double = 32

        /// Icon sizes for system images
        public static let iconLarge: Double = 60

        /// Subtitle text (18pt)
        public static let subtitle: Double = 18
    }

    /// Standard UI element dimensions
    public enum Size {
        /// Standard button maximum width
        public static let buttonMaxWidth: Double = 200

        /// Standard thumbnail dimensions
        public static let thumbnailSize: Double = 200

        /// Standard image height for lists
        public static let imageHeight: Double = 150

        /// Standard corner radius
        public static let cornerRadius: Double = 8

        /// Large corner radius
        public static let cornerRadiusLarge: Double = 12
    }

    /// Animation and interaction timing
    public enum Animation {
        /// Standard animation duration (0.25s)
        public static let standard = 0.25

        /// Quick animation duration (0.15s)
        public static let quick = 0.15

        /// Slow animation duration (0.4s)
        public static let slow = 0.4

        /// Spring animation damping
        public static let springDamping = 0.8
    }

    /// Border and stroke widths
    public enum Border {
        /// Standard border width (1pt)
        public static let standard: Double = 1

        /// Thick border width (2pt)
        public static let thick: Double = 2

        /// Hair line border width (0.5pt)
        public static let hairline = 0.5
    }

    /// Alpha values for transparency effects
    public enum Alpha {
        /// Disabled state alpha
        public static let disabled = 0.6

        /// Secondary content alpha
        public static let secondary = 0.7

        /// Overlay background alpha
        public static let overlay = 0.4

        /// Hover effect alpha
        public static let hover = 0.05
    }
}
