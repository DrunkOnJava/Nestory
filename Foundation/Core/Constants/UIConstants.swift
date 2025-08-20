//
// Layer: Foundation
// Module: Core/Constants
// Purpose: UI-related constants for consistent design system
//

import CoreGraphics

/// UI constants for consistent design patterns throughout the application
public enum UIConstants {
    /// Spacing values for consistent layout margins and padding
    public enum Spacing {
        /// Extra small spacing (8pt)
        public static let xs: CGFloat = 8

        /// Small spacing (12pt)
        public static let sm: CGFloat = 12

        /// Medium spacing (16pt)
        public static let md: CGFloat = 16

        /// Large spacing (20pt)
        public static let lg: CGFloat = 20

        /// Extra large spacing (24pt)
        public static let xl: CGFloat = 24

        /// Extra extra large spacing (30pt)
        public static let xxl: CGFloat = 30

        /// Standard component spacing (20pt)
        public static let component: CGFloat = 20

        /// Section spacing (30pt)
        public static let section: CGFloat = 30
    }

    /// Font sizes for typography scale
    public enum FontSize {
        /// Caption text (12pt)
        public static let caption: CGFloat = 12

        /// Body text (16pt)
        public static let body: CGFloat = 16

        /// Title text (24pt)
        public static let title: CGFloat = 24

        /// Large title (32pt)
        public static let largeTitle: CGFloat = 32

        /// Icon sizes for system images
        public static let iconLarge: CGFloat = 60

        /// Subtitle text (18pt)
        public static let subtitle: CGFloat = 18
    }

    /// Standard UI element dimensions
    public enum Size {
        /// Standard button maximum width
        public static let buttonMaxWidth: CGFloat = 200

        /// Standard thumbnail dimensions
        public static let thumbnailSize: CGFloat = 200

        /// Standard image height for lists
        public static let imageHeight: CGFloat = 150

        /// Standard corner radius
        public static let cornerRadius: CGFloat = 8

        /// Large corner radius
        public static let cornerRadiusLarge: CGFloat = 12
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
        public static let standard: CGFloat = 1

        /// Thick border width (2pt)
        public static let thick: CGFloat = 2

        /// Hair line border width (0.5pt)
        public static let hairline: CGFloat = 0.5
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
