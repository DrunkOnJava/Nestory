# Insurance Claim Module

This module contains the modularized components for the insurance claim generation feature, split from the original 577-line `InsuranceClaimView.swift` file.

## Architecture Overview

The insurance claim feature follows a **multi-step wizard pattern** with specialized components for each responsibility:

```
InsuranceClaimView (Main Coordinator)
├── Steps/
│   ├── ClaimTypeStep.swift          # Step 1: Claim type selection
│   ├── IncidentDetailsStep.swift    # Step 2: Incident information
│   ├── ContactInformationStep.swift # Step 3: Contact details
│   └── ReviewAndGenerateStep.swift  # Step 4: Review and generation
├── Components/
│   ├── ClaimTypeCard.swift          # Interactive claim type selector
│   └── SummaryRow.swift             # Summary information display
├── Logic/
│   ├── ClaimValidation.swift        # Form validation logic
│   ├── ClaimDataPersistence.swift   # UserDefaults persistence
│   └── ClaimGenerationCoordinator.swift # Service coordination
└── InsuranceClaimIndex.swift        # Module exports
```

## Component Responsibilities

### Step Components

- **ClaimTypeStep**: Handles claim type selection and insurance company picker
- **IncidentDetailsStep**: Collects incident details with documentation requirements
- **ContactInformationStep**: Manages contact information with persistence
- **ReviewAndGenerateStep**: Final review with claim generation and actions

### UI Components

- **ClaimTypeCard**: Reusable card for claim type selection
- **SummaryRow**: Standardized row component for displaying label-value pairs

### Logic Components

- **ClaimValidation**: Form validation and step progression rules
- **ClaimDataPersistence**: UserDefaults-based contact information storage
- **ClaimGenerationCoordinator**: Coordinates with ClaimService for generation

## Benefits of Modularization

### 🎯 **Single Responsibility Principle**
- Each component has one clear purpose
- Easier to understand and maintain
- Reduced cognitive load when making changes

### 🔄 **Reusability**
- Step components can be reused in different workflows
- UI components available for other claim-related features
- Logic components provide shared validation and persistence

### 🧪 **Testability**
- Individual components can be unit tested in isolation
- Logic components have clear inputs and outputs
- UI components can be tested with preview providers

### 🚀 **Performance**
- Smaller compilation units
- Better incremental builds
- Reduced memory usage during development

### 👥 **Team Development**
- Multiple developers can work on different components
- Reduced merge conflicts
- Clear ownership boundaries

## Integration Pattern

The main `InsuranceClaimView` now acts as a **coordinator** that:

1. **Manages State**: Holds `ClaimFormData` and navigation state
2. **Coordinates Flow**: Controls step progression and validation
3. **Delegates Work**: Passes specific concerns to specialized components
4. **Handles Integration**: Manages sheets, alerts, and service integration

## Usage Example

```swift
// Step component usage
ClaimTypeStep(
    selectedClaimType: $formData.selectedClaimType,
    selectedCompany: $formData.selectedCompany
)

// Validation usage
let canProceed = ClaimValidation.canProceedFromStep(currentStep, with: formData)

// Persistence usage
ClaimDataPersistence.saveContactInfo(formData)
```

## Future Enhancements

This modular structure enables:

- **A/B Testing**: Easy to swap step implementations
- **Progressive Enhancement**: Add features to individual steps
- **Accessibility**: Component-level accessibility improvements
- **Internationalization**: Localized step components
- **Analytics**: Step-specific tracking and metrics

## File Size Reduction

- **Original**: 577 lines in single file
- **Modularized**: 7 focused files (~80-150 lines each)
- **Maintainability**: ✅ Significant improvement
- **Readability**: ✅ Each file has clear purpose