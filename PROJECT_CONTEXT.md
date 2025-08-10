# Nestory — Working Context

## Today's Focus
- [x] Phase 0: Guardrails - Complete
- [x] Phase A: Foundation - Complete
- [x] Phase B: Infrastructure - Partial (Network, Storage done)
- [x] Phase C: Services - Partial (Protocols defined)
- [x] Phase C.5: UI Components - Complete
- [x] Phase D: Inventory - Complete
- [ ] Phase E: Capture - Not started
- [ ] Phase F: Analytics - Not started
- [ ] Phase G: Sharing - Not started
- [ ] Phase H: Monetization - Not started

## Completed Phases
- [x] Phase 0: Guardrails (SPEC.json, architecture tests, nestoryctl)
- [x] Phase A: Foundation (Core types, Models, Utils)
- [x] Phase B: Infrastructure (50% - Network, Storage)  
- [x] Phase C: Services (50% - DependencyKeys and protocols defined)
- [x] Phase C.5: UI Components (Theme, Typography, Buttons, Cards, EmptyState)
- [x] Phase D: Inventory (TCA Feature with list, detail, edit views)
- [ ] Phase E: Capture
- [ ] Phase F: Analytics
- [ ] Phase G: Sharing
- [ ] Phase H: Monetization

## API Inventory
### Foundation Types
- `AppError` - Core error type with recovery suggestions
- `Identifier` protocols - Type-safe IDs (ItemID, CategoryID, etc.)
- `Money` - Currency value object with deterministic rounding
- `NonEmptyString` - Guaranteed non-empty strings
- `Slug` - URL-safe identifiers

### Foundation Models (SwiftData)
- `Item` - Core inventory item with full relationships
- `Category` - Hierarchical categorization
- `Location` - Hierarchical physical locations
- `PhotoAsset` - Image attachments with perceptual hashing
- `Receipt` - Purchase documentation with OCR support
- `Warranty` - Coverage tracking
- `MaintenanceTask` - Scheduled maintenance
- `ShareGroup` - Family/team sharing
- `CurrencyRate` - Exchange rate tracking

### Infrastructure APIs
- `NetworkClient` - Actor-based network layer with retry logic
- `SecureStorage` - Encrypted storage with keychain integration
- `KeychainWrapper` - Keychain operations wrapper

### Service Protocols
- `AuthService` - Authentication (protocol defined, implementation pending)
- `InventoryService` - Inventory CRUD (protocol defined, implementation pending)
- `PhotoIntegrationService` - Photo capture/processing (protocol defined, implementation pending)
- `ExportService` - Export functionality (protocol defined, implementation pending)
- `SyncService` - CloudKit sync (protocol defined, implementation pending)
- `AnalyticsService` - Analytics (protocol defined, implementation pending)
- `CurrencyService` - Currency conversion (protocol defined, implementation pending)

### TCA Dependencies
- All service dependency keys defined in `Services/DependencyKeys.swift`
- Mock implementations provided for testing
- Live implementations pending

## Open Decisions
- CloudKit container identifier needed
- API keys for currency service (FX_API_KEY)
- Barcode scanning API selection
- OCR service provider selection

## Blockers
- Need to implement live service implementations
- CloudKit schema definition pending
- StoreKit configuration for monetization

## Next Steps
- Complete Infrastructure layer (Monitoring, Security, Caching)
- Implement live service implementations
- Create UI components library
- Set up CloudKit schema
- Configure CI/CD pipelines