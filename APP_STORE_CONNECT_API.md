# App Store Connect API Integration

## Overview

Nestory includes comprehensive App Store Connect API integration for automating app submission, metadata management, and release workflows. This integration uses JWT authentication and provides both Swift services and Fastlane lanes for maximum flexibility.

## Features

- 🔐 **Secure JWT Authentication** - Private keys stored in macOS Keychain
- 📱 **Complete App Management** - Create versions, update metadata, manage builds
- 📸 **Media Upload** - Screenshots and preview videos via API
- 🚀 **Automated Submission** - Complete workflow from build to review
- ♻️ **Smart Retry Logic** - Exponential backoff and rate limit handling
- 🔄 **Fastlane Integration** - Use via CLI or programmatically

## Quick Start

### 1. Setup Credentials

Run the interactive setup script to store your App Store Connect API credentials securely:

```bash
./scripts/setup_asc_credentials.sh
```

You'll need:
- **Key ID**: From App Store Connect → Users and Access → Keys
- **Issuer ID**: Your team's UUID
- **Private Key**: The .p8 file content

### 2. Verify Configuration

Check that credentials are properly stored:

```bash
./scripts/setup_asc_credentials.sh --check
```

### 3. Use via Fastlane

#### Complete Submission Workflow

Submit your app with a single command:

```bash
bundle exec fastlane complete_submission \
  version:1.0.2 \
  skip_screenshots:false \
  release_type:AFTER_APPROVAL
```

#### Individual Operations

```bash
# Configure app metadata
bundle exec fastlane configure_app_metadata

# Create new version
bundle exec fastlane create_app_version version:1.0.2

# Upload screenshots
bundle exec fastlane upload_screenshots_api version:1.0.2

# Submit for review
bundle exec fastlane submit_for_review version:1.0.2

# Configure phased release
bundle exec fastlane configure_phased_release \
  version:1.0.2 \
  release_type:SCHEDULED \
  release_date:2025-09-01
```

## Swift API Usage

### Basic Setup

```swift
import Services

// Initialize configuration
let config = AppStoreConnectConfiguration()

// Create API client
let client = try config.createClient()

// Initialize services
let metadataService = AppMetadataService(client: client)
let versionService = AppVersionService(client: client)
let mediaService = MediaUploadService(client: client)
```

### Complete Submission

```swift
// Use the orchestrator for complete workflows
let orchestrator = try AppStoreConnectOrchestrator()

let submission = AppStoreConnectOrchestrator.AppSubmission(
    version: "1.0.2",
    buildNumber: "10",
    releaseNotes: "Bug fixes and improvements",
    screenshots: nil, // Optional
    metadata: .init(
        name: "Nestory",
        subtitle: "Home Inventory for Insurance",
        description: "Your complete home inventory solution...",
        keywords: "home,inventory,insurance",
        primaryCategory: .productivity,
        secondaryCategory: .utilities,
        supportURL: "https://nestory.app/support",
        marketingURL: "https://nestory.app",
        privacyPolicyURL: "https://nestory.app/privacy"
    ),
    reviewInfo: .init(
        demoRequired: false,
        demoAccount: nil,
        demoPassword: nil,
        notes: "No special instructions",
        contactFirstName: "John",
        contactLastName: "Doe",
        contactEmail: "john@example.com",
        contactPhone: "+1234567890"
    ),
    releaseStrategy: .afterApproval
)

// Validate before submission
let issues = try await orchestrator.validateSubmission(submission)
if issues.isEmpty {
    try await orchestrator.submitApp(submission)
}
```

### Individual Operations

```swift
// Fetch app information
let appInfo = try await metadataService.fetchApp(
    bundleId: "com.drunkonjava.nestory"
)

// Create new version
let version = try await versionService.createVersion(
    appId: appInfo.id,
    versionString: "1.0.2"
)

// Update metadata
try await metadataService.updateCategories(
    appId: appInfo.id,
    categories: AppMetadataService.AppCategories(
        primaryCategory: .productivity,
        secondaryCategory: .utilities
    )
)

// Upload screenshots
let screenshotSets = [
    MediaUploadService.ScreenshotSet(
        locale: "en-US",
        screenshotType: .iPhone65,
        screenshots: [/* ... */]
    )
]

try await mediaService.uploadScreenshots(
    versionId: version.id,
    screenshotSets: screenshotSets
)
```

## Environment Configuration

### Development

Store credentials in Keychain for local development:

```bash
./scripts/setup_asc_credentials.sh
```

### CI/CD

Set environment variables in your CI/CD pipeline:

```yaml
env:
  ASC_KEY_ID: ${{ secrets.ASC_KEY_ID }}
  ASC_ISSUER_ID: ${{ secrets.ASC_ISSUER_ID }}
  ASC_KEY_CONTENT: ${{ secrets.ASC_KEY_CONTENT }}
```

### Fastlane .env File

Create `fastlane/.env.local` (git ignored):

```bash
# App Store Connect API
ASC_KEY_ID=XXXXXXXXXX
ASC_ISSUER_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
ASC_KEY_CONTENT=<base64-encoded-p8-key>
ASC_API_ENABLED=true
ASC_BUNDLE_ID=com.drunkonjava.nestory

# Review Contact
ASC_CONTACT_FIRST_NAME=John
ASC_CONTACT_LAST_NAME=Doe
ASC_CONTACT_EMAIL=john@example.com
ASC_CONTACT_PHONE=+1234567890
```

## Architecture

### Service Layer Structure

```
Services/AppStoreConnect/
├── AppStoreConnectClient.swift          # JWT auth & API client
├── AppStoreConnectConfiguration.swift   # Secure config management
├── AppMetadataService.swift            # App metadata operations
├── AppVersionService.swift             # Version & build management
├── MediaUploadService.swift            # Screenshot/video uploads
└── AppStoreConnectOrchestrator.swift   # High-level workflows
```

### Security Features

- **Keychain Storage**: API keys stored securely in macOS Keychain
- **JWT Token Caching**: Reduces unnecessary token generation
- **Environment Isolation**: Separate configs for dev/staging/prod
- **Credential Validation**: Validates P8 key format before use

### Error Handling

- **Exponential Backoff**: Automatic retry with increasing delays
- **Rate Limit Handling**: Respects API rate limits
- **Detailed Error Messages**: Clear, actionable error descriptions
- **Progress Tracking**: Real-time progress for long operations

## API Endpoints Used

The integration uses these App Store Connect API endpoints:

- `/v1/apps` - App information and updates
- `/v1/appStoreVersions` - Version management
- `/v1/builds` - Build selection
- `/v1/appScreenshotSets` - Screenshot management
- `/v1/appStoreVersionSubmissions` - Review submission
- `/v1/appInfoLocalizations` - Metadata localization
- `/v1/ageRatingDeclarations` - Age ratings

## Troubleshooting

### Common Issues

1. **"Missing credentials" error**
   - Run `./scripts/setup_asc_credentials.sh --check`
   - Ensure all three values are present

2. **"Invalid private key" error**
   - Verify key includes `-----BEGIN PRIVATE KEY-----` headers
   - Check key hasn't expired in App Store Connect

3. **"Rate limit exceeded" error**
   - API has 3600 requests/hour limit
   - Implementation includes automatic retry with backoff

4. **"Build not found" error**
   - Ensure build is uploaded to TestFlight first
   - Wait for processing to complete (can take 10-30 minutes)

### Debug Mode

Enable verbose logging:

```swift
// In Swift
let client = AppStoreConnectClient(configuration: config)
client.enableDebugLogging = true

// In Fastlane
bundle exec fastlane complete_submission --verbose
```

## Best Practices

1. **Always validate before submission**
   ```swift
   let issues = try await orchestrator.validateSubmission(submission)
   ```

2. **Use phased releases for major updates**
   ```swift
   releaseStrategy: .phased(daysPerPhase: 7)
   ```

3. **Cache app information**
   - App ID rarely changes, cache it locally
   - Reduces API calls and improves performance

4. **Batch operations when possible**
   - Upload all screenshots in one session
   - Update all metadata together

5. **Monitor API usage**
   - Track request count to avoid rate limits
   - Implement circuit breakers for production

## Support

For issues or questions:
1. Check credentials: `./scripts/setup_asc_credentials.sh --check`
2. Review Fastlane logs: `fastlane/output/logs/`
3. Enable debug mode for detailed API traces
4. Consult Apple's [App Store Connect API documentation](https://developer.apple.com/documentation/appstoreconnectapi)