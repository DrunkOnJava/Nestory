//
// Layer: UI
// Module: Components
// Purpose: Placeholder view for upcoming features
//
// 🏗️ UI LAYER PATTERN: Pure SwiftUI View Component
// - NO business logic or state management (that belongs in Features layer)
// - NO direct service calls (use TCA dependency injection in Features)
// - ONLY imports Foundation (architectural rule from SPEC.json)
// - Reusable component focused on presentation only
//
// 🎯 USAGE: Temporary placeholder during TCA migration
// - Replace with actual TCA-driven views as Features are migrated
// - Used by RootView.swift during transition period
// - Will be removed once all features use TCA patterns
//
// 📱 DESIGN STANDARDS:
// - Follows iOS Human Interface Guidelines
// - Supports Dynamic Type and accessibility
// - Uses system colors for proper dark mode support
// - Consistent spacing using Apple's standard grid (8pt base)
//

import SwiftUI
import Foundation

struct ComingSoonView: View {
    // 📋 VIEW PROPERTIES: Simple data inputs for presentation
    let title: String // Feature name for display
    let message: String // Description or status message

    var body: some View {
        VStack(spacing: 24) { // 📱 Using 24pt spacing (3x base grid)
            // 🔨 CONSTRUCTION ICON: Universal "work in progress" symbol
            Image(systemName: "hammer.fill")
                .font(.system(size: 64))
                .foregroundColor(.secondary) // Adapts to light/dark mode

            VStack(spacing: 8) { // 📱 Using 8pt spacing (1x base grid)
                // 📰 TITLE: Primary feature identification
                Text(title)
                    .font(.title2) // Semantic font sizing
                    .fontWeight(.semibold) // Subtle emphasis

                // 📝 MESSAGE: Additional context or status
                Text(message)
                    .font(.body) // Standard body text
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center) // Centered for placeholder aesthetics
            }
        }
        .padding() // Standard padding for comfortable spacing
        .navigationTitle(title) // Consistent navigation experience
    }
}

#if DEBUG
    struct ComingSoonView_Previews: PreviewProvider {
        static var previews: some View {
            ComingSoonView(
                title: "Feature",
                message: "This feature is coming soon"
            )
        }
    }
#endif
