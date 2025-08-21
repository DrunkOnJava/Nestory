# Architecture Migration Notes

## 🏗️ TCA Migration Decision (August 20, 2025)

### What Changed
- **From**: 4-layer architecture (App-Main → Services → Infrastructure → Foundation)
- **To**: 6-layer TCA architecture (App → Features → UI → Services → Infrastructure → Foundation)

### Why TCA?
1. **Apple Framework Integration**: 84+ planned integrations (AppIntents, WidgetKit, Core Spotlight)
2. **Complex State Management**: Warranty tracking, insurance claims, multi-device sync
3. **Testing Excellence**: TCA's reducer testing for complex workflows
4. **Industry Validation**: Used by Adidas, Crypto.com, The Browser Company

### Implementation Strategy
- **Part 1**: TCA foundation + Inventory feature migration
- **Part 2**: Analytics, Settings, Search features  
- **Part 3**: Apple Framework integration using TCA state

### Key Files Updated
- `project.yml`: Added TCA dependency and notes
- `Makefile`: TCA guidance and architecture reminders
- `CLAUDE.md`: New TCA patterns and import rules
- `SPEC.json`: Updated with TCA state management
- `DECISIONS.md`: ADR-0014 documenting full rationale

### Developer Guidelines
- **All new features**: MUST use TCA patterns
- **Device target**: iPhone 16 Pro Max (consistency)
- **Imports**: Features can import ComposableArchitecture
- **Testing**: Use TCA reducer testing patterns

### See Also
- `ADR-0014` in DECISIONS.md for complete rationale
- `CLAUDE.md` for TCA implementation patterns
- `TODO.md` for TCA-aligned feature roadmap