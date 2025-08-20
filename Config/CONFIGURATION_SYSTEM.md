# Centralized Configuration System

## Overview

Nestory uses a **single source of truth** configuration system where all project-wide values, scheme names, bundle identifiers, API endpoints, and environment settings are defined in one master file: `Config/ProjectConfiguration.json`.

## Architecture

```
ProjectConfiguration.json (MASTER)
├── project.yml (auto-generated)
├── Config/*.xcconfig (auto-generated) 
├── Config/MakefileConfig.mk (auto-generated)
├── Config/EnvironmentConfiguration.swift (reads master at runtime)
├── Config/Rings-Generated.md (auto-generated)
└── Makefile (includes generated config)
```

## Master Configuration File

**Location**: `Config/ProjectConfiguration.json`

This JSON file contains:
- Project metadata (name, version, team ID, etc.)
- Environment definitions (dev, staging, production)
- API endpoints and CloudKit containers
- Feature flags per environment  
- Build configurations and timeouts
- Deployment ring definitions

### Key Sections

#### Project Info
```json
{
  "project": {
    "name": "Nestory",
    "version": "1.0.1", 
    "teamId": "2VXBQV4XC9",
    "minIOSVersion": "17.0"
  }
}
```

#### Environments
```json
{
  "environments": {
    "development": {
      "bundleIdSuffix": ".dev",
      "productNameSuffix": " Dev", 
      "cloudKitContainer": "iCloud.com.drunkonjava.nestory.dev",
      "featureFlags": {
        "debugMenu": true,
        "analytics": false
      }
    }
  }
}
```

## How Values are Linked

### 1. Build-Time Generation
When you run `make generate-config`, the system:

1. **Reads** `ProjectConfiguration.json`
2. **Generates** all configuration files:
   - `project.yml` with schemes
   - `*.xcconfig` files with build settings
   - `MakefileConfig.mk` with scheme names
3. **Updates** Xcode project when you run `make gen`

### 2. Runtime Configuration Loading
`EnvironmentConfiguration.swift` loads the JSON at app startup:

```swift
// Loads master config at runtime
let config = ProjectConfigurationLoader.loadConfiguration()

// Uses environment-specific values
let cloudKitContainer = config.environments["development"].cloudKitContainer
```

### 3. Build System Integration
Makefile includes generated configuration:

```makefile
# Auto-includes all scheme names and timeouts
include Config/MakefileConfig.mk

# Uses generated variables
@xcodebuild -scheme $(SCHEME_DEV) -destination "$(DESTINATION)"
```

## Adding New Values

To add a new project-wide value:

### 1. Add to Master JSON
```json
{
  "environments": {
    "development": {
      "newApiEndpoint": "https://new-api-dev.nestory.app"
    }
  }
}
```

### 2. Update Generator Script
In `Scripts/generate-project-config.swift`:

```swift
// Add to EnvironmentConfig struct
struct EnvironmentConfig: Codable {
    let newApiEndpoint: String
}

// Add to xcconfig generation
API_NEW_ENDPOINT = \(env.newApiEndpoint)
```

### 3. Regenerate All Configs
```bash
make generate-config
make gen  # Update Xcode project
```

### 4. Use in Runtime Code
```swift
// Automatically available in EnvironmentConfiguration
let newEndpoint = EnvironmentConfiguration.shared.newApiEndpoint
```

## Workflow Commands

### Daily Development
```bash
# Use different schemes
make run-dev      # Development 
make run-staging  # Staging
make run-prod     # Production

# Or with explicit scheme selection
make run SCHEME_TARGET=staging
```

### Configuration Changes  
```bash
# 1. Edit Config/ProjectConfiguration.json
# 2. Regenerate all linked files
make generate-config

# 3. Apply to Xcode project
make gen

# 4. Verify everything works
make validate-config
make build
```

## File Responsibilities

| File | Purpose | Auto-Generated |
|------|---------|---------------|
| `ProjectConfiguration.json` | **Master source** | ❌ (edit manually) |
| `project.yml` | Xcode project definition | ✅ |
| `*.xcconfig` | Build settings | ✅ |  
| `MakefileConfig.mk` | Makefile variables | ✅ |
| `EnvironmentConfiguration.swift` | Runtime config loader | ✅ (struct) |
| `Rings-Generated.md` | Documentation | ✅ |

## Benefits

### ✅ Single Source of Truth
- Change bundle ID in one place → updates everywhere
- Change API endpoint → automatically propagates to all schemes

### ✅ Consistency Guaranteed  
- No more mismatched CloudKit containers
- No more forgotten scheme updates
- Build timeouts consistent across all tools

### ✅ Type Safety
- JSON schema validation
- Swift structs match JSON structure
- Compile-time errors for missing values

### ✅ Documentation Sync
- Deployment rings auto-generated from config
- Always matches actual implementation
- No stale documentation

## Troubleshooting

### Configuration Not Loading
```bash
# Check JSON is valid
make validate-config

# Ensure file is in bundle resources
grep -A 5 "resources:" project.yml
```

### Values Not Updating
```bash
# Regenerate everything
make generate-config
make gen

# Clean and rebuild
make clean-build
```

### Scheme Issues
```bash
# List available schemes
xcodebuild -list -project Nestory.xcodeproj

# Check generated config
cat Config/MakefileConfig.mk
```

## Migration Strategy

The system maintains backward compatibility:

1. **Environment variables** still override config values
2. **Hardcoded fallbacks** prevent crashes if JSON missing
3. **Gradual migration** - can move values one at a time

Eventually all hardcoded values will be removed, leaving only the master configuration file.

## Adding New Environments

To add a new environment (e.g., "preview"):

### 1. Update Master Config
```json
{
  "environments": {
    "preview": {
      "name": "preview",
      "displayName": "Preview",
      "bundleIdSuffix": ".preview",
      "cloudKitContainer": "iCloud.com.drunkonjava.nestory.preview"
    }
  },
  "derivedValues": {
    "schemes": {
      "preview": "Nestory-Preview"
    }
  }
}
```

### 2. Update Environment Enum
```swift
public enum Environment: String, CaseIterable {
    case preview = "preview"
}
```

### 3. Regenerate and Test
```bash
make generate-config
make gen
make run-preview  # Will be auto-generated
```

This ensures the new environment is automatically:
- Added to schemes
- Given proper xcconfig files  
- Available in Makefile commands
- Accessible at runtime

---

**Remember**: Always edit `ProjectConfiguration.json` first, then regenerate. Never edit the generated files directly - they will be overwritten!