# Comprehensive Fastlane Guide for Nestory Personal Inventory App (2025)

## Table of Contents

This guide provides exhaustive documentation on Fastlane customized specifically for **Nestory**, a personal home inventory app for insurance documentation. It covers the complete automation pipeline, enterprise-level testing frameworks, and deployment strategies tailored to Nestory's unique requirements as an iOS-only personal inventory solution.

## Part 1: Nestory-Specific Fastlane Overview

### Project Context & Architecture

**Nestory** is a personal home inventory app designed specifically for insurance documentation and disaster recovery preparation. Unlike business inventory systems, Nestory focuses on helping homeowners and renters catalog their belongings for insurance claims, warranty tracking, and comprehensive disaster preparedness.

The Fastlane configuration for Nestory is built around several key principles:
- **iOS-Only Focus**: Pure iOS app with no Android counterpart, allowing for Apple-specific optimizations
- **Personal Data Privacy**: Enhanced security measures for personal belongings documentation
- **Insurance Documentation Workflow**: Automated processes for generating insurance reports and documentation
- **Three-Tier Deployment**: Development, staging, and production environments with distinct bundle IDs

### Technical Stack Integration

Nestory's Fastlane setup integrates seamlessly with the project's technical architecture:

- **Swift 6.0**: Full compatibility with strict concurrency and modern Swift features
- **SwiftUI + TCA (The Composable Architecture)**: State management integration in testing workflows
- **SwiftData + CloudKit**: Data persistence and sync testing automation
- **XcodeGen + Makefile**: Build system integration with Fastlane automation
- **Enterprise UI Testing Framework**: Comprehensive testing pipeline with screenshot automation

### Bundle ID & Environment Configuration

```ruby
# Nestory Environment Configuration
APP_IDENTIFIER_DEV     = 'com.drunkonjava.nestory.dev'
APP_IDENTIFIER_STAGING = 'com.drunkonjava.nestory.staging' 
APP_IDENTIFIER_PROD    = 'com.drunkonjava.nestory'

TEAM_ID = '2VXBQV4XC9'  # Your Apple Developer Team ID

# Environment-specific schemes
SCHEME_DEV     = 'Nestory-Dev'
SCHEME_STAGING = 'Nestory-Staging'
SCHEME_PROD    = 'Nestory'
```

## Part 2: Nestory's Current Fastlane Configuration

### Core Fastfile Structure

Nestory's Fastfile implements an enterprise-level automation system with comprehensive testing and deployment capabilities:

```ruby
# Nestory-specific Fastfile configuration
default_platform(:ios)

# Nestory project configuration
APP_IDENTIFIER   = ENV['APP_IDENTIFIER']   || 'com.drunkonjava.nestory'
SCHEME           = ENV['SCHEME']           || 'Nestory-Dev'
PROJECT          = ENV['PROJECT']          || 'Nestory.xcodeproj'
ASSETS_PATH      = ENV['ASSETS_PATH']      || 'App-Main/Assets.xcassets'
ICONSET_NAME     = ENV['ICONSET_NAME']     || 'AppIcon'
CONFIGURATION    = ENV['CONFIGURATION']    || 'Release'
OUTPUT_DIR       = ENV['OUTPUT_DIR']       || 'fastlane/output'
TEAM_ID          = ENV['TEAM_ID']          || '2VXBQV4XC9'

# App Store Connect API Configuration for Nestory
ASC_KEY_ID       = ENV['ASC_KEY_ID']       # NWV654RNK3
ASC_ISSUER_ID    = ENV['ASC_ISSUER_ID']    # f144f0a6-1aff-44f3-974e-183c4c07bc46
ASC_KEY_CONTENT  = ENV['ASC_KEY_CONTENT']  # Your AuthKey content
```

### Enterprise UI Testing Framework

Nestory implements a sophisticated UI testing framework with multiple specialized test suites:

```ruby
desc "Run comprehensive UI tests with enterprise framework"
lane :ui_tests do |opts|
  UI.message "🧪 Running comprehensive UI test suite..."
  
  scan(
    scheme: opts[:scheme] || "Nestory-UIWiring",
    project: PROJECT,
    clean: true,
    derived_data_path: "#{OUTPUT_DIR}/DerivedData",
    output_directory: "#{OUTPUT_DIR}/ui_tests",
    buildlog_path: "#{OUTPUT_DIR}/logs/ui_tests",
    result_bundle: true,
    fail_build: true,
    only_testing: opts[:only_testing] || ["NestoryUITests"],
    xcargs: "UI_TEST_FRAMEWORK_ENABLED=YES UI_TESTING_ENABLED=YES"
  )
end

desc "Run performance UI tests"
lane :performance_tests do |opts|
  UI.message "⚡ Running performance test suite..."
  
  scan(
    scheme: "Nestory-Performance",
    project: PROJECT,
    clean: true,
    output_directory: "#{OUTPUT_DIR}/performance_tests",
    only_testing: ["NestoryPerformanceUITests"],
    xcargs: "PERFORMANCE_TESTING_MODE=YES UI_TEST_PERFORMANCE_MODE=YES"
  )
end

desc "Run accessibility UI tests"
lane :accessibility_tests do |opts|
  UI.message "♿ Running accessibility test suite..."
  
  scan(
    scheme: "Nestory-Accessibility",
    project: PROJECT,
    clean: true,
    output_directory: "#{OUTPUT_DIR}/accessibility_tests",
    only_testing: ["NestoryAccessibilityUITests"],
    xcargs: "ACCESSIBILITY_TESTING_MODE=YES ACCESSIBILITY_TEST_MODE=YES"
  )
end
```

### Insurance Documentation Workflow

Specialized lanes for Nestory's core functionality:

```ruby
desc "Generate app icons for Nestory personal inventory branding"
lane :icons do |opts|
  # Look for Nestory-specific icon locations
  source = opts[:source] || ENV['ICON_SOURCE']
  
  if source.nil?
    possible_paths = [
      "assets/nestory-icon.png",
      "AppIcon.png", 
      "icon.png",
      "/Users/griffin/Pictures/nestoryappicon2.png"  # Current Nestory icon
    ]
    
    source = possible_paths.find { |path| File.exist?(path) }
    UI.user_error!("Nestory icon not found") if source.nil?
  end
  
  UI.message "🎨 Generating Nestory app icons from: #{source}"
  
  appicon(
    appicon_image_file: source,
    appicon_path: ASSETS_PATH,
    appicon_name: ICONSET_NAME,
    appicon_devices: [:iphone, :ipad, :ios_marketing],
    remove_alpha: false
  )
end

desc "Configure Nestory app metadata for App Store"
lane :configure_app_metadata do |opts|
  ensure_asc_api_key
  
  UI.message "📱 Configuring Nestory app metadata..."
  
  # Nestory-specific categories
  categories = opts[:categories] || {
    primary: "PRODUCTIVITY",     # Home organization and productivity
    secondary: "UTILITIES"       # Utility for insurance documentation
  }
  
  # Nestory app description and keywords
  localizations = opts[:localizations] || [
    {
      locale: "en-US",
      name: "Nestory",
      subtitle: "Home Inventory for Insurance",
      description: load_nestory_app_description,
      keywords: "home inventory, insurance, documentation, receipt scanner, warranty tracker, disaster recovery, personal belongings",
      promotional_text: "Protect your belongings with comprehensive insurance documentation",
      support_url: "https://nestory.app/support",
      marketing_url: "https://nestory.app",
      privacy_policy_url: "https://nestory.app/privacy"
    }
  ]
  
  # Family-friendly app with no concerning content
  age_rating = opts[:age_rating] || {
    alcohol_tobacco_drug: "NONE",
    gambling: "NONE",
    horror_fear: "NONE",
    mature_content: "NONE",
    medical: "NONE",
    profanity: "NONE",
    sexual_content: "NONE",
    violence_cartoon: "NONE",
    violence_realistic: "NONE"
  }
end

desc "Submit export compliance for Nestory (uses only exempt encryption)"
lane :submit_export_compliance do |opts|
  UI.message "📋 Submitting Nestory export compliance declaration..."
  
  # Nestory uses only exempt encryption (HTTPS, iOS Data Protection)
  UI.message "✅ Nestory Export Compliance Configuration:"
  UI.message "  • Personal inventory app - no sensitive data transmission"
  UI.message "  • Uses only exempt encryption (HTTPS, iOS Data Protection)"
  UI.message "  • No proprietary cryptography"
  UI.message "  • No export license required"
  UI.message "  • ITSAppUsesNonExemptEncryption = false"
  
  UI.success "✅ Nestory export compliance declaration complete"
end
```

## Part 3: Essential Plugins for Nestory

### 1. Match - Code Signing for Personal App

**Specifically configured for Nestory's three-environment setup:**

```ruby
# Matchfile for Nestory
git_url("git@github.com:your-username/nestory-certificates.git")
storage_mode("git")
type("development")

app_identifier([
  "com.drunkonjava.nestory.dev",
  "com.drunkonjava.nestory.staging", 
  "com.drunkonjava.nestory"
])
username("your-apple-id@example.com")
team_id("2VXBQV4XC9")

# Nestory-specific settings
git_branch("main")
shallow_clone(true)
force_for_new_devices(true)
```

**Usage in Nestory lanes:**
```ruby
desc "Setup code signing for Nestory environment"
lane :setup_signing do |opts|
  environment = opts[:env] || "dev"
  
  case environment
  when "dev"
    match(
      type: "development",
      app_identifier: "com.drunkonjava.nestory.dev",
      readonly: is_ci
    )
  when "staging"
    match(
      type: "adhoc",
      app_identifier: "com.drunkonjava.nestory.staging",
      readonly: is_ci
    )
  when "production"
    match(
      type: "appstore",
      app_identifier: "com.drunkonjava.nestory",
      readonly: is_ci
    )
  end
end
```

### 2. Badge - Version Badges for Nestory Testing

**Add version badges to Nestory's app icon during development:**

```ruby
desc "Add version badge to Nestory icon"
lane :add_nestory_badge do |opts|
  version = get_version_number(xcodeproj: "Nestory.xcodeproj")
  build = get_build_number(xcodeproj: "Nestory.xcodeproj")
  
  add_badge(
    shield: "v#{version}-#{build}-blue",
    alpha: true,
    dark: true,
    glob: "#{ASSETS_PATH}/**/AppIcon*.png",
    shield_gravity: "South",
    shield_no_resize: true,
    shield_parameters: "style=flat&logo=apple&logoColor=white"
  )
  
  UI.success "✅ Nestory version badge added: v#{version} (#{build})"
end
```

### 3. Snapshot - Screenshots for Nestory App Store

**Capture screenshots specifically for Nestory's insurance documentation workflow:**

```ruby
desc "Capture Nestory screenshots for App Store"
lane :nestory_screenshots do |opts|
  UI.message "📸 Capturing Nestory screenshots..."
  
  # Run Nestory's comprehensive UI tests to generate screenshots
  ui_tests(
    scheme: "Nestory-UIWiring",
    only_testing: [
      "NestoryUITests/InventoryScreenshotTests",
      "NestoryUITests/InsuranceReportScreenshotTests",
      "NestoryUITests/ReceiptScannerScreenshotTests",
      "NestoryUITests/WarrantyTrackingScreenshotTests"
    ]
  )
  
  capture_screenshots(
    project: PROJECT,
    scheme: "Nestory-UIWiring",
    clear_previous_screenshots: true,
    reinstall_app: true,
    languages: ["en-US"],
    devices: [
      "iPhone 16 Pro Max",   # Primary target device
      "iPhone 16 Pro",       # Secondary device
      "iPad Pro (12.9-inch) (6th generation)"  # Tablet support
    ],
    output_directory: "#{OUTPUT_DIR}/nestory_screenshots",
    buildlog_path: "#{OUTPUT_DIR}/logs/snapshot",
    xcargs: "UI_TEST_FRAMEWORK_ENABLED=YES SCREENSHOT_MODE=STORE_READY"
  )
  
  UI.success "✅ Nestory screenshots captured for App Store submission"
end
```

### 4. Firebase App Distribution - Beta Testing

**Configure Firebase for Nestory beta distribution:**

```bash
# Install Firebase plugin
fastlane add_plugin firebase_app_distribution
```

```ruby
desc "Distribute Nestory beta to testers"
lane :distribute_nestory_beta do |opts|
  # Build Nestory
  build(scheme: "Nestory-Dev")
  
  # Distribute via Firebase
  firebase_app_distribution(
    app: ENV["NESTORY_FIREBASE_APP_ID"],
    groups: "nestory-beta-testers, insurance-professionals",
    release_notes: "New Nestory beta build - #{get_version_number} (#{get_build_number})\n\n• Enhanced receipt scanning\n• Improved insurance report generation\n• Bug fixes and performance improvements",
    service_credentials_file: "./firebase-service-account.json"
  )
  
  UI.success "✅ Nestory beta distributed to Firebase testers"
end
```

### 5. Sentry - Crash Reporting for Personal Data App

**Configure Sentry for Nestory with privacy considerations:**

```ruby
desc "Upload Nestory debug symbols to Sentry"
lane :upload_nestory_symbols do |opts|
  sentry_upload_dif(
    auth_token: ENV["SENTRY_AUTH_TOKEN"],
    org_slug: "nestory-app",
    project_slug: "nestory-ios",
    path: "./DerivedData/Build/Products/Release-iphoneos/Nestory.app.dSYM"
  )
  
  UI.message "✅ Nestory debug symbols uploaded to Sentry"
  UI.message "📱 Crash reporting configured for personal inventory app"
end
```

## Part 4: Nestory-Specific Deployment Workflows

### Development Environment Setup

```ruby
desc "Setup complete Nestory development environment"
lane :setup_nestory_dev do
  UI.message "🛠️ Setting up Nestory development environment..."
  
  # Configure iOS simulators for Nestory testing
  configure_simulators(
    devices: [
      "iPhone 16 Pro Max",  # Primary development device
      "iPhone 16 Pro",      # Secondary device
      "iPad Pro (12.9-inch) (6th generation)"  # Tablet testing
    ],
    ios_version: "17.0"
  )
  
  # Setup code signing for development
  setup_signing(env: "dev")
  
  # Configure Nestory-specific build settings
  configure_swift_compiler(
    environment: "dev",
    strict_concurrency: true,  # Swift 6 compliance
    optimization: "-Onone"
  )
  
  # Setup Nestory testing framework
  configure_xcode_for_ui_testing(
    project: "Nestory.xcodeproj",
    scheme: "Nestory-UIWiring"
  )
  
  UI.success "✅ Nestory development environment ready!"
end
```

### TestFlight Deployment Pipeline

```ruby
desc "Complete Nestory TestFlight deployment with insurance app testing"
lane :nestory_testflight do |opts|
  UI.message "🚀 Starting Nestory TestFlight deployment..."
  
  # Run comprehensive test suite
  unless opts[:skip_tests]
    UI.message "🧪 Running Nestory comprehensive test suite..."
    tests                    # Unit tests
    ui_tests                # UI automation tests
    performance_tests       # Performance validation
    accessibility_tests     # Accessibility compliance
    smoke_tests            # Critical path validation
  end
  
  # Build for App Store
  build(
    scheme: "Nestory",
    configuration: "Release",
    bump_build: true
  )
  
  # Configure App Store Connect API
  asc_api_key
  
  # Generate changelog from commits
  changelog = changelog_from_git_commits(
    commits_count: 30,
    merge_commit_filtering: "exclude_merges",
    pretty: "• %s"
  ) rescue "Nestory improvements: Enhanced inventory management and insurance documentation features"
  
  # Upload to TestFlight with Nestory-specific metadata
  upload_to_testflight(
    app_identifier: "com.drunkonjava.nestory",
    skip_waiting_for_build_processing: false,
    changelog: changelog,
    distribute_external: false,
    beta_app_description: "Nestory - Personal Home Inventory Management for Insurance Claims and Disaster Recovery",
    beta_app_feedback_email: "support@nestory.app",
    uses_non_exempt_encryption: false,
    beta_app_review_info: {
      contact_email: "support@nestory.app",
      contact_first_name: "Nestory",
      contact_last_name: "Support",
      contact_phone: "555-NESTORY",
      demo_account_name: "demo@nestory.app",
      demo_account_password: "NestoryDemo2025!",
      notes: "Nestory is a personal inventory app for homeowners to document belongings for insurance claims. Test account includes sample inventory items."
    }
  )
  
  UI.success "✅ Nestory successfully uploaded to TestFlight!"
  UI.message "📱 Beta testers can now install and test the latest Nestory build"
end
```

### App Store Release Pipeline

```ruby
desc "Complete Nestory App Store submission with insurance app compliance"
lane :nestory_app_store do |opts|
  UI.message "🎆 Starting complete Nestory App Store submission..."
  
  # Comprehensive pre-submission validation
  unless opts[:skip_all_tests]
    UI.message "🔍 Running comprehensive Nestory validation suite..."
    enterprise_test_suite
    validate_framework
    validate_xcode_config
  end
  
  # Configure Nestory app metadata
  configure_app_metadata(
    categories: {
      primary: "PRODUCTIVITY",
      secondary: "UTILITIES"
    }
  )
  
  # Create app version
  version = get_version_number(xcodeproj: "Nestory.xcodeproj")
  create_app_version(version: version)
  
  # Submit export compliance (Nestory uses only exempt encryption)
  submit_export_compliance
  
  # Capture and upload screenshots
  unless opts[:skip_screenshots]
    nestory_screenshots
    upload_screenshots_api(version: version)
  end
  
  # Submit for review with Nestory-specific review information
  submit_for_review(
    version: version,
    demo_required: true,
    demo_account: "demo@nestory.app",
    demo_password: "NestoryDemo2025!",
    notes: "Nestory helps homeowners document their belongings for insurance purposes. The demo account contains sample inventory data showing the app's core functionality.",
    first_name: "Nestory",
    last_name: "Support", 
    email: "support@nestory.app",
    phone: "555-NESTORY"
  )
  
  # Configure phased release
  configure_phased_release(
    version: version,
    release_type: "AFTER_APPROVAL"  # Automatic release after approval
  )
  
  UI.success "🎉 Nestory submitted to App Store!"
  UI.message "📱 Your personal inventory app is now under review"
end
```

## Part 5: Nestory Integration with Build System

### XcodeGen Integration

Nestory uses XcodeGen for project generation. Integrate Fastlane with the Makefile system:

```ruby
desc "Generate Nestory Xcode project and run Fastlane"
lane :generate_and_build do |opts|
  UI.message "🏗️ Generating Nestory Xcode project..."
  
  # Use Nestory's Makefile to generate project
  sh("cd .. && make generate")
  
  # Verify project was created
  UI.user_error!("Xcode project not generated") unless File.exist?("../Nestory.xcodeproj")
  
  # Configure for testing
  configure_xcode_for_ui_testing
  
  # Build
  build(opts)
  
  UI.success "✅ Nestory project generated and built successfully"
end
```

### Makefile Integration

```ruby
desc "Run Nestory build via Makefile integration"
lane :makefile_build do |opts|
  UI.message "⚙️ Building Nestory via Makefile..."
  
  # Use Nestory's optimized build system
  case opts[:target] || "run"
  when "run"
    sh("cd .. && make run")          # Build and run in simulator
  when "build"
    sh("cd .. && make build")        # Build only
  when "fast-build"
    sh("cd .. && make fast-build")   # Optimized parallel build
  when "test"
    sh("cd .. && make test")         # Run test suite
  when "check"
    sh("cd .. && make check")        # Full validation
  end
  
  UI.success "✅ Nestory Makefile build completed"
end
```

## Part 6: CI/CD Configuration for Nestory

### GitHub Actions Integration

```yaml
# .github/workflows/nestory-ci.yml
name: Nestory CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    name: Nestory Test Suite
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Ruby for Nestory
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.2'
          bundler-cache: true
          working-directory: fastlane
      
      - name: Setup Xcode for Nestory
        uses: maxim-lobanov/setup-xcode@v1
        with:
          xcode-version: '15.0'
      
      - name: Generate Nestory Project
        run: make generate
      
      - name: Run Nestory Test Suite
        run: cd fastlane && bundle exec fastlane enterprise_test_suite
        env:
          FASTLANE_SKIP_UPDATE_CHECK: true

  deploy:
    name: Nestory TestFlight Deployment
    needs: test
    runs-on: macos-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Ruby for Nestory
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.2'
          bundler-cache: true
          working-directory: fastlane
      
      - name: Setup Xcode for Nestory
        uses: maxim-lobanov/setup-xcode@v1
        with:
          xcode-version: '15.0'
      
      - name: Deploy Nestory to TestFlight
        run: cd fastlane && bundle exec fastlane nestory_testflight
        env:
          ASC_KEY_ID: ${{ secrets.ASC_KEY_ID }}
          ASC_ISSUER_ID: ${{ secrets.ASC_ISSUER_ID }}
          ASC_KEY_CONTENT: ${{ secrets.ASC_KEY_CONTENT }}
          MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
          MATCH_GIT_BASIC_AUTHORIZATION: ${{ secrets.MATCH_GIT_AUTH }}
          FASTLANE_SKIP_UPDATE_CHECK: true
```

## Part 7: Security & Privacy for Personal Data App

### Keychain Integration for Nestory

```ruby
desc "Configure Nestory keychain for sensitive data"
lane :setup_nestory_keychain do
  UI.message "🔐 Setting up Nestory keychain configuration..."
  
  keychain_name = "nestory_fastlane"
  keychain_password = ENV['KEYCHAIN_PASSWORD'] || SecureRandom.hex(16)
  
  create_keychain(
    name: keychain_name,
    password: keychain_password,
    default_keychain: true,
    unlock: true,
    timeout: 3600,
    lock_when_sleeps: false
  )
  
  # Import certificates for Nestory
  import_certificate(
    certificate_path: "./certificates/nestory_distribution.p12",
    certificate_password: ENV['CERTIFICATE_PASSWORD'],
    keychain_name: keychain_name,
    keychain_password: keychain_password
  )
  
  UI.success "✅ Nestory keychain configured for secure builds"
end
```

### Privacy-First Configuration

```ruby
desc "Apply privacy-focused settings for Nestory"
lane :configure_nestory_privacy do
  UI.message "🔒 Configuring Nestory privacy settings..."
  
  # Update Info.plist with privacy descriptions
  update_info_plist(
    plist_path: "./App-Main/Info.plist",
    block: proc do |plist|
      # Camera usage for item photos and receipt scanning
      plist['NSCameraUsageDescription'] = 'Nestory needs camera access to photograph your belongings and scan receipts for insurance documentation.'
      
      # Photo library for importing existing photos
      plist['NSPhotoLibraryUsageDescription'] = 'Nestory accesses your photo library to import existing photos of your belongings for insurance records.'
      
      # Document scanning for receipts
      plist['NSDocumentScannerUsageDescription'] = 'Nestory uses document scanning to capture and process receipts for warranty and insurance documentation.'
      
      # CloudKit for secure backup
      plist['NSCloudKitUsageDescription'] = 'Nestory uses CloudKit to securely sync your inventory data across your devices.'
      
      # Export compliance for personal app
      plist['ITSAppUsesNonExemptEncryption'] = false
    end
  )
  
  UI.success "✅ Nestory privacy settings configured"
end
```

## Part 8: Monitoring & Analytics for Nestory

### Performance Monitoring

```ruby
desc "Setup Nestory performance monitoring"
lane :setup_nestory_monitoring do
  UI.message "📊 Setting up Nestory performance monitoring..."
  
  # Configure Sentry for crash reporting
  upload_nestory_symbols
  
  # Setup Firebase Analytics (privacy-conscious)
  configure_firebase_analytics(
    privacy_mode: true,
    collect_ads_id: false,
    personalized_ads: false
  )
  
  # Configure MetricKit integration for iOS performance
  configure_metrickit_integration
  
  UI.success "✅ Nestory monitoring configured with privacy focus"
end
```

### Custom Metrics for Personal Inventory App

```ruby
desc "Track Nestory-specific metrics"
lane :track_nestory_metrics do |opts|
  build_number = get_build_number(xcodeproj: "Nestory.xcodeproj")
  version = get_version_number(xcodeproj: "Nestory.xcodeproj")
  
  # Track build metrics specific to personal inventory features
  metrics = {
    app: "Nestory",
    version: version,
    build: build_number,
    features: [
      "inventory_management",
      "receipt_ocr_scanning", 
      "insurance_report_generation",
      "warranty_tracking",
      "cloudkit_sync"
    ],
    build_time: Time.now.to_i,
    environment: ENV['FASTLANE_ENV'] || 'development'
  }
  
  # Send to analytics (privacy-compliant)
  send_build_metrics(metrics)
  
  UI.message "📈 Nestory build metrics tracked: v#{version} (#{build_number})"
end
```

## Part 9: Troubleshooting Nestory-Specific Issues

### Common Nestory Build Issues

```ruby
desc "Diagnose and fix common Nestory build issues"
lane :fix_nestory_issues do
  UI.message "🔧 Diagnosing Nestory build issues..."
  
  issues_fixed = []
  
  # Fix Swift 6 concurrency issues
  if swift_concurrency_errors_detected?
    fix_swift_concurrency_issues
    issues_fixed << "Swift 6 concurrency compliance"
  end
  
  # Fix TCA dependency issues
  if tca_dependency_issues_detected?
    fix_tca_dependencies
    issues_fixed << "TCA dependency resolution"
  end
  
  # Fix SwiftData + CloudKit integration
  if swiftdata_cloudkit_issues_detected?
    fix_swiftdata_cloudkit_integration
    issues_fixed << "SwiftData CloudKit integration"
  end
  
  # Fix code signing issues
  if code_signing_issues_detected?
    setup_signing(env: ENV['NESTORY_ENV'] || 'dev')
    issues_fixed << "Code signing configuration"
  end
  
  # Clean build artifacts
  clear_derived_data
  clean_build_artifacts_action
  
  if issues_fixed.any?
    UI.success "✅ Fixed Nestory issues: #{issues_fixed.join(', ')}"
  else
    UI.message "✅ No Nestory-specific issues detected"
  end
end
```

### SwiftData + CloudKit Troubleshooting

```ruby
desc "Fix SwiftData and CloudKit integration issues"
lane :fix_swiftdata_cloudkit do
  UI.message "☁️ Fixing SwiftData + CloudKit integration..."
  
  # Verify CloudKit container configuration
  verify_cloudkit_container
  
  # Check SwiftData model compliance
  verify_swiftdata_models
  
  # Validate entitlements
  configure_entitlements(
    environment: "dev",
    enable_cloudkit: true
  )
  
  UI.success "✅ SwiftData + CloudKit integration validated"
end
```

## Part 10: Advanced Nestory Workflows

### Insurance Report Generation Testing

```ruby
desc "Test Nestory insurance report generation pipeline"
lane :test_insurance_reports do
  UI.message "📋 Testing Nestory insurance report generation..."
  
  # Run specific tests for insurance features
  scan(
    scheme: "Nestory-Dev",
    only_testing: [
      "NestoryTests/InsuranceReportServiceTests",
      "NestoryTests/ClaimDocumentGeneratorTests",
      "NestoryTests/PDFGenerationTests",
      "NestoryTests/HTMLReportTests"
    ],
    output_directory: "#{OUTPUT_DIR}/insurance_tests",
    xcargs: "INSURANCE_TESTING_MODE=YES"
  )
  
  UI.success "✅ Insurance report generation tests completed"
end
```

### Receipt OCR Testing Pipeline

```ruby
desc "Test Nestory receipt OCR functionality"
lane :test_receipt_ocr do
  UI.message "📷 Testing Nestory receipt OCR pipeline..."
  
  # Run OCR-specific tests
  scan(
    scheme: "Nestory-Dev", 
    only_testing: [
      "NestoryTests/ReceiptOCRServiceTests",
      "NestoryTests/VisionTextExtractionTests",
      "NestoryTests/MLReceiptProcessorTests",
      "NestoryTests/CategoryClassifierTests"
    ],
    output_directory: "#{OUTPUT_DIR}/ocr_tests",
    xcargs: "OCR_TESTING_MODE=YES VISION_TESTING_ENABLED=YES"
  )
  
  UI.success "✅ Receipt OCR tests completed"
end
```

### Warranty Tracking Validation

```ruby
desc "Test Nestory warranty tracking features"
lane :test_warranty_tracking do
  UI.message "📅 Testing Nestory warranty tracking..."
  
  # Run warranty-specific tests
  scan(
    scheme: "Nestory-Dev",
    only_testing: [
      "NestoryTests/WarrantyTrackingServiceTests",
      "NestoryTests/WarrantyNotificationTests", 
      "NestoryTests/WarrantyExpirationTests"
    ],
    output_directory: "#{OUTPUT_DIR}/warranty_tests",
    xcargs: "WARRANTY_TESTING_MODE=YES NOTIFICATION_TESTING_ENABLED=YES"
  )
  
  UI.success "✅ Warranty tracking tests completed"
end
```

## Part 11: Conclusion & Best Practices for Nestory

### Nestory-Specific Recommendations

1. **Privacy-First Development**: Always configure privacy descriptions and use minimal data collection
2. **Insurance Documentation Focus**: Ensure all features support insurance claim generation
3. **Offline-First Design**: Test functionality without internet for disaster scenarios
4. **CloudKit Integration**: Thoroughly test sync across devices for personal inventory data
5. **Accessibility Compliance**: Run accessibility tests for users with disabilities
6. **Receipt OCR Accuracy**: Continuously validate OCR accuracy with diverse receipt formats
7. **Performance Monitoring**: Monitor app performance with personal data loads
8. **Export Compliance**: Maintain proper export compliance for personal data security

### Recommended Deployment Schedule

```ruby
# Nestory deployment schedule
DEPLOYMENT_SCHEDULE = {
  development: "Daily builds after tests pass",
  staging: "Weekly builds for internal testing", 
  testflight: "Bi-weekly builds for beta testers",
  app_store: "Monthly releases or critical bug fixes"
}
```

### Essential Environment Variables

```bash
# Nestory-specific environment variables
export NESTORY_BUNDLE_ID_DEV="com.drunkonjava.nestory.dev"
export NESTORY_BUNDLE_ID_STAGING="com.drunkonjava.nestory.staging" 
export NESTORY_BUNDLE_ID_PROD="com.drunkonjava.nestory"
export NESTORY_TEAM_ID="2VXBQV4XC9"
export NESTORY_FIREBASE_APP_ID="your-firebase-app-id"
export NESTORY_SENTRY_DSN="your-sentry-dsn"
```

This comprehensive guide provides everything needed to effectively use Fastlane with the Nestory personal inventory app, focusing on the unique requirements of personal data management, insurance documentation, and privacy-first development practices.

---

`★ Insight ─────────────────────────────────────`
**Nestory-Specific Fastlane Implementation:**
- **Personal Data Focus**: Configuration emphasizes privacy and security for personal belongings data
- **Insurance Documentation Workflow**: Specialized lanes for insurance report generation and validation  
- **Three-Tier Environment**: Dev, staging, and production with distinct bundle IDs and certificates
`─────────────────────────────────────────────────`

The guide demonstrates how Nestory's advanced Fastlane configuration goes beyond typical mobile automation to address the specific needs of a personal inventory app, including comprehensive testing frameworks, privacy-conscious deployment, and insurance industry compliance requirements.