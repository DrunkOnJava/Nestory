# Enterprise Ruby-Based Xcode Configuration System

## Overview

This directory contains a comprehensive suite of Ruby scripts that provide enterprise-grade control over all aspects of the Nestory iOS project's Xcode configuration. These scripts work in conjunction with Fastlane to deliver programmatic, repeatable, and auditable Xcode project management.

## 🏗️ Architecture

### Core Components

1. **Configuration Scripts**: Direct Xcode project manipulation
2. **Validation Scripts**: Comprehensive configuration validation
3. **Environment Setup**: Automated development environment preparation
4. **Framework Management**: Dynamic linking and framework configuration

### Integration Points

- **Fastlane Integration**: Called from Fastlane lanes for automation
- **Makefile Integration**: Available through project build commands
- **CI/CD Integration**: Designed for GitHub Actions/CI systems
- **Manual Execution**: Each script can be run independently

## 📋 Available Scripts

### 1. `configure_ui_testing.rb`
**Purpose**: Configure Xcode project for enterprise UI testing framework

```bash
# Basic usage
ruby configure_ui_testing.rb --project Nestory.xcodeproj --scheme Nestory-UIWiring

# Full configuration
ruby configure_ui_testing.rb \
  --project Nestory.xcodeproj \
  --scheme Nestory-UIWiring \
  --enable-ui-testing \
  --configure-entitlements \
  --setup-test-targets
```

**Features**:
- ✅ Configures UI testing build settings
- ✅ Creates comprehensive test schemes
- ✅ Sets up entitlements for UI testing
- ✅ Configures framework search paths
- ✅ Adds UI test metrics collection

**Fastlane Integration**:
```ruby
lane :configure_xcode_for_ui_testing do
  sh("ruby fastlane/xcode_ruby_scripts/configure_ui_testing.rb --enable-ui-testing")
end
```

### 2. `update_build_settings.rb`
**Purpose**: Dynamic Xcode build settings management

```bash
# Update specific settings
ruby update_build_settings.rb \
  --target Nestory \
  --configuration Debug \
  --settings '{"SWIFT_VERSION": "6.0", "ENABLE_TESTABILITY": "YES"}' \
  --backup \
  --validate

# Use predefined templates
ruby update_build_settings.rb \
  --target Nestory \
  --configuration Debug \
  --template swift6_debug
```

**Available Templates**:
- `swift6_debug`: Swift 6.0 with debug optimizations
- `swift6_release`: Swift 6.0 with release optimizations  
- `ui_testing`: UI testing configuration
- `performance`: Performance optimizations
- `security`: Security-focused settings

**Fastlane Integration**:
```ruby
lane :update_build_settings do
  sh("ruby fastlane/xcode_ruby_scripts/update_build_settings.rb --template swift6_debug")
end
```

### 3. `validate_configuration.rb`
**Purpose**: Comprehensive Xcode project configuration validation

```bash
# Basic validation
ruby validate_configuration.rb --project Nestory.xcodeproj

# Comprehensive validation with JSON output
ruby validate_configuration.rb \
  --project Nestory.xcodeproj \
  --comprehensive-check \
  --output-format json
```

**Validation Categories**:
- ✅ Project structure and layer architecture
- ✅ Target configuration compliance
- ✅ Build settings validation
- ✅ Scheme configuration
- ✅ Entitlements verification
- ✅ Info.plist validation
- ✅ Framework dependencies

**Fastlane Integration**:
```ruby
lane :validate_xcode_config do
  sh("ruby fastlane/xcode_ruby_scripts/validate_configuration.rb --comprehensive-check")
end
```

### 4. `setup_environment.rb`
**Purpose**: Automated development environment setup

```bash
# Complete environment setup
ruby setup_environment.rb --all

# Selective setup
ruby setup_environment.rb \
  --install-dependencies \
  --configure-simulators \
  --setup-certificates \
  --configure-git-hooks
```

**Setup Categories**:
- 📦 Development dependencies (Homebrew packages, Ruby gems)
- 📱 iOS simulator configuration
- 🔑 Certificate and provisioning setup
- 📝 Git hooks configuration
- 🛠️ Development tools and aliases

**Fastlane Integration**:
```ruby
lane :setup_dev_environment do
  sh("ruby fastlane/xcode_ruby_scripts/setup_environment.rb --all")
end
```

### 5. `configure_frameworks.rb`
**Purpose**: Dynamic linking and framework configuration

```bash
# Basic framework configuration
ruby configure_frameworks.rb \
  --project Nestory.xcodeproj \
  --enable-dynamic-frameworks \
  --configure-rpath-settings

# Advanced configuration
ruby configure_frameworks.rb \
  --project Nestory.xcodeproj \
  --enable-dynamic-frameworks \
  --enable-bitcode \
  --framework-paths "/custom/frameworks:/another/path" \
  --configure-rpath-settings
```

**Features**:
- 🔗 Dynamic framework configuration
- 📚 Required framework management
- 🛤️ RPATH and linking optimization
- ⚡ Performance-optimized settings

**Fastlane Integration**:
```ruby
lane :configure_dynamic_frameworks do
  sh("ruby fastlane/xcode_ruby_scripts/configure_frameworks.rb --enable-dynamic-frameworks")
end
```

## 🚀 Quick Start Guide

### 1. Install Dependencies

```bash
# Install required Ruby gems
bundle install

# Setup development environment
ruby fastlane/xcode_ruby_scripts/setup_environment.rb --all
```

### 2. Configure Project for UI Testing

```bash
# Configure comprehensive UI testing
bundle exec fastlane configure_xcode_for_ui_testing
```

### 3. Validate Configuration

```bash
# Run comprehensive validation
bundle exec fastlane validate_xcode_config
```

### 4. Generate Complete Configuration

```bash
# Generate enterprise-grade configuration
bundle exec fastlane generate_xcode_config
```

## 📊 Configuration Templates

### Swift 6.0 Debug Template
```json
{
  "SWIFT_VERSION": "6.0",
  "SWIFT_COMPILATION_MODE": "singlefile",
  "SWIFT_OPTIMIZATION_LEVEL": "-Onone",
  "SWIFT_STRICT_CONCURRENCY": "minimal",
  "SWIFT_UPCOMING_FEATURE_CONCURRENCY": "YES",
  "ENABLE_TESTABILITY": "YES",
  "UI_TEST_FRAMEWORK_ENABLED": "YES"
}
```

### Swift 6.0 Release Template
```json
{
  "SWIFT_VERSION": "6.0",
  "SWIFT_COMPILATION_MODE": "wholemodule", 
  "SWIFT_OPTIMIZATION_LEVEL": "-O",
  "SWIFT_STRICT_CONCURRENCY": "complete",
  "VALIDATE_PRODUCT": "YES",
  "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym"
}
```

### UI Testing Template
```json
{
  "UI_TEST_FRAMEWORK_ENABLED": "YES",
  "ENABLE_TESTING_SEARCH_PATHS": "YES",
  "SWIFT_STRICT_CONCURRENCY": "minimal",
  "FRAMEWORK_SEARCH_PATHS": [
    "$(inherited)",
    "$(PLATFORM_DIR)/Developer/Library/Frameworks"
  ]
}
```

## 🔧 Advanced Usage

### Custom Configuration Pipelines

```bash
#!/bin/bash
# Custom configuration pipeline

echo "🔧 Applying enterprise Xcode configuration..."

# 1. Environment setup
ruby fastlane/xcode_ruby_scripts/setup_environment.rb --validate-xcode-installation

# 2. UI testing configuration
ruby fastlane/xcode_ruby_scripts/configure_ui_testing.rb --enable-ui-testing --configure-entitlements

# 3. Build settings optimization
ruby fastlane/xcode_ruby_scripts/update_build_settings.rb --template swift6_debug --backup

# 4. Framework configuration
ruby fastlane/xcode_ruby_scripts/configure_frameworks.rb --enable-dynamic-frameworks --configure-rpath-settings

# 5. Comprehensive validation
ruby fastlane/xcode_ruby_scripts/validate_configuration.rb --comprehensive-check

echo "✅ Enterprise configuration completed"
```

### Integration with Fastlane Workflows

```ruby
# In Fastfile
desc "Complete enterprise configuration workflow"
lane :enterprise_config do
  # Setup environment
  setup_dev_environment
  
  # Configure for UI testing
  configure_xcode_for_ui_testing
  
  # Apply performance optimizations
  apply_performance_optimizations
  
  # Configure security settings
  configure_security_settings
  
  # Validate everything
  validate_xcode_config
  
  UI.success("✅ Enterprise configuration completed")
end
```

## 📈 Monitoring and Validation

### Continuous Validation

```bash
# Set up continuous validation
watch -n 30 'ruby fastlane/xcode_ruby_scripts/validate_configuration.rb --quiet'
```

### Configuration Drift Detection

```bash
# Detect configuration changes
git diff --name-only HEAD~1 | grep -E '\.(xcodeproj|xcconfig|plist|entitlements)$' | \
  xargs ruby fastlane/xcode_ruby_scripts/validate_configuration.rb --project
```

### Performance Monitoring

```bash
# Monitor build performance impact
time ruby fastlane/xcode_ruby_scripts/update_build_settings.rb --template performance
time xcodebuild -project Nestory.xcodeproj -scheme Nestory-Dev build
```

## 🔒 Security Considerations

### Credential Management
- All scripts use environment variables for sensitive data
- Integration with macOS Keychain for certificate storage
- No hardcoded secrets or API keys
- Secure handling of provisioning profiles

### Validation Requirements
- All configuration changes are validated before application
- Backup creation before destructive operations  
- Rollback capabilities for failed configurations
- Comprehensive error handling and reporting

## 🛠️ Troubleshooting

### Common Issues

1. **Script Permission Errors**
   ```bash
   chmod +x fastlane/xcode_ruby_scripts/*.rb
   ```

2. **Missing Ruby Dependencies**
   ```bash
   bundle install
   gem install xcodeproj plist
   ```

3. **Xcode Project Corruption**
   ```bash
   # Restore from backup
   git checkout HEAD -- Nestory.xcodeproj/
   ```

4. **Validation Failures**
   ```bash
   # Run validation with debug output
   DEBUG=1 ruby fastlane/xcode_ruby_scripts/validate_configuration.rb --comprehensive-check
   ```

### Debug Mode

```bash
# Enable debug mode for detailed output
export DEBUG=1
ruby fastlane/xcode_ruby_scripts/configure_ui_testing.rb --enable-ui-testing
```

## 📚 Additional Resources

- [Xcodeproj Documentation](https://github.com/CocoaPods/Xcodeproj)
- [Fastlane Documentation](https://docs.fastlane.tools/)
- [Xcode Build Settings Reference](https://help.apple.com/xcode/mac/current/#/itcaec37c2a6)
- [iOS Code Signing Guide](https://developer.apple.com/library/archive/documentation/Security/Conceptual/CodeSigningGuide/)

## 📞 Support

For issues related to the Ruby-based Xcode configuration system:

1. Check script logs and error messages
2. Validate prerequisites are installed
3. Run validation scripts for diagnostic information
4. Review Fastlane logs for integration issues

---

**Note**: This system is designed for enterprise-grade iOS development with comprehensive automation, validation, and monitoring capabilities. All scripts are idempotent and can be safely re-run.