source "https://rubygems.org"

# =============================================================================
# ENTERPRISE RUBY-BASED XCODE CONFIGURATION SYSTEM
# Comprehensive Xcode project manipulation and automation for Nestory iOS
# =============================================================================

# Core Fastlane for iOS automation
gem "fastlane", "~> 2.220"

# Essential Fastlane plugins
plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)

# =============================================================================
# XCODE PROJECT MANIPULATION & CONFIGURATION
# =============================================================================

# Direct Xcode project file manipulation
gem "xcodeproj", "~> 1.25"              # Direct pbxproj manipulation
gem "plist", "~> 3.7"                   # Info.plist and configuration files
gem "xcconfig", "~> 1.0"                # Xcode configuration file handling

# Build settings and scheme management
gem "xcode-install", "~> 2.8"           # Xcode version management
gem "simctl", "~> 1.6"                  # iOS Simulator control
gem "gym", require: false               # Building (part of fastlane, explicit for clarity)

# Code signing and provisioning profiles
gem "sigh", "~> 2.220", require: false  # Provisioning profile management
gem "match", "~> 2.220", require: false # Certificate and profile synchronization
gem "cert", "~> 2.220", require: false  # Certificate management

# =============================================================================
# TESTING AND QUALITY ASSURANCE FRAMEWORKS
# =============================================================================

# Test execution and reporting
gem "xcpretty", "~> 0.3"                # Beautiful test output formatting
gem "xcpretty-json-formatter", "~> 0.1" # JSON output for test results
gem "trainer", "~> 0.10"                # Convert xcodebuild output to JUnit
gem "scan", require: false              # Testing (part of fastlane)

# Code coverage and quality metrics
gem "slather", "~> 2.8"                 # Code coverage reporting
gem "xcov", "~> 1.8"                    # Comprehensive coverage reports
gem "danger", "~> 9.4"                  # Automated code review
gem "danger-xcov", "~> 0.5"             # Coverage reporting in PRs
gem "danger-swiftlint", "~> 0.35"       # SwiftLint integration for PR reviews

# Performance and monitoring
gem "benchmark-ips", "~> 2.12"          # Performance benchmarking for scripts
gem "memory_profiler", "~> 1.0"         # Memory usage profiling

# =============================================================================
# APP STORE CONNECT API & METADATA MANAGEMENT
# =============================================================================

# App Store Connect API integration
gem "spaceship", "~> 2.220"             # App Store Connect API wrapper
gem "deliver", "~> 2.220", require: false # Metadata and screenshot uploads
gem "pilot", "~> 2.220", require: false # TestFlight management
gem "precheck", require: false          # App Store validation

# JWT and API authentication
gem "jwt", "~> 2.7"                     # JWT token generation for App Store Connect
gem "faraday", "~> 2.7"                 # HTTP client for API calls
gem "faraday-retry", "~> 2.2"           # Request retry middleware

# =============================================================================
# ENTERPRISE AUTOMATION & ORCHESTRATION
# =============================================================================

# System integration and automation
gem "rake", "~> 13.1"                   # Task automation and build scripts
gem "thor", "~> 1.3"                    # Command-line interface framework
gem "claide", "~> 1.1"                  # Command-line argument parsing
gem "commander", "~> 4.6"               # Advanced CLI command structure

# File and directory manipulation
gem "fileutils", require: false         # Enhanced file operations (stdlib but explicit)
gem "pathname", require: false          # Path manipulation utilities
gem "tmpdir", require: false            # Temporary directory management

# Configuration and settings management
gem "dotenv", "~> 2.8"                  # Environment variable management
gem "settingslogic", "~> 2.0"           # Configuration management
gem "dry-configurable", "~> 1.1"        # Advanced configuration patterns

# =============================================================================
# DATA PROCESSING & VALIDATION
# =============================================================================

# JSON and data processing
gem "json", require: false              # JSON processing (stdlib but explicit)
gem "oj", "~> 3.16"                     # High-performance JSON processing
gem "yajl-ruby", "~> 1.4"               # Streaming JSON parser

# XML and plist processing
gem "nokogiri", "~> 1.15"               # XML parsing for Xcode project files
gem "rexml", require: false             # XML processing (stdlib)

# Data validation and transformation
gem "dry-validation", "~> 1.10"         # Data validation framework
gem "dry-transformer", "~> 1.0"         # Data transformation utilities
gem "hashie", "~> 5.0"                  # Hash extensions and utilities

# =============================================================================
# LOGGING, MONITORING & DEBUGGING
# =============================================================================

# Structured logging
gem "logger", require: false            # Enhanced logging (stdlib but explicit)
gem "semantic_logger", "~> 4.15"        # Structured logging framework
gem "awesome_print", "~> 1.9"           # Pretty printing for debugging

# Debugging and development tools
gem "pry", "~> 0.14"                    # Better Ruby debugging
gem "pry-byebug", "~> 3.10"             # Debugger integration
gem "pry-doc", "~> 1.4"                 # Documentation integration

# Code quality and style
gem "rubocop", "~> 1.60", require: false # Ruby style guide
gem "rubocop-performance", "~> 1.20", require: false # Performance cops
gem "rubocop-rake", "~> 0.6", require: false # Rake task cops

# =============================================================================
# SECURITY & CREDENTIAL MANAGEMENT
# =============================================================================

# Credential and secret management
gem "keychain", "~> 0.3"                # macOS Keychain integration
gem "highline", "~> 2.1"                # Secure password prompting
gem "bcrypt", "~> 3.1"                  # Password hashing

# =============================================================================
# NETWORKING & HTTP UTILITIES
# =============================================================================

# HTTP clients and utilities
gem "net-http", require: false          # HTTP client (stdlib but explicit)
gem "uri", require: false               # URI processing (stdlib)
gem "open-uri", require: false          # Simple HTTP fetching (stdlib)
gem "addressable", "~> 2.8"             # Advanced URI handling

# =============================================================================
# PARALLEL PROCESSING & CONCURRENCY
# =============================================================================

# Concurrency and parallel processing
gem "concurrent-ruby", "~> 1.2"         # Modern concurrency utilities
gem "parallel", "~> 1.24"               # Parallel processing framework

# =============================================================================
# VERSION MANAGEMENT & COMPATIBILITY
# =============================================================================

# Version constraints for enterprise stability
gem "bundler", "~> 2.5"                 # Bundle management
gem "rbenv", require: false             # Ruby version management integration
gem "version", "~> 1.1"                 # Version comparison utilities

# =============================================================================
# TESTING FRAMEWORK INTEGRATION
# =============================================================================

# Testing frameworks for Ruby scripts
gem "rspec", "~> 3.12", require: false  # Behavior-driven testing
gem "minitest", "~> 5.20", require: false # Unit testing framework
gem "test-unit", "~> 3.6", require: false # Extended testing utilities

# =============================================================================
# ENTERPRISE DEPLOYMENT & CI/CD INTEGRATION
# =============================================================================

# CI/CD and deployment utilities
gem "octokit", "~> 6.1"                 # GitHub API integration
gem "gitlab", "~> 4.19"                 # GitLab API integration
gem "jenkins_api_client", "~> 1.5"      # Jenkins integration

# =============================================================================
# PERFORMANCE OPTIMIZATION
# =============================================================================

# Performance monitoring and optimization
gem "ruby-prof", "~> 1.6", require: false # Ruby profiling
gem "stackprof", "~> 0.2", require: false # Sampling call stack profiler

# =============================================================================
# DEVELOPMENT AND UTILITY GEMS
# =============================================================================

# Development utilities
gem "listen", "~> 3.8"                  # File system change notifications
gem "guard", "~> 2.18"                  # File watching and automation
gem "terminal-notifier", "~> 2.0"       # macOS notification integration

# String and text processing
gem "colorize", "~> 0.8"                # Terminal color output
gem "rainbow", "~> 3.1"                 # Advanced terminal coloring
gem "tty-prompt", "~> 0.23"             # Interactive command-line prompts
gem "tty-spinner", "~> 0.9"             # Terminal spinners and progress indicators

# =============================================================================
# DEVELOPMENT GROUPS
# =============================================================================

group :development do
  gem "guard-rspec", require: false     # Automatic test running
  gem "guard-rubocop", require: false   # Automatic style checking
end

group :test do
  gem "webmock", "~> 3.19"              # HTTP request stubbing
  gem "vcr", "~> 6.2"                   # HTTP interaction recording
  gem "timecop", "~> 0.9"               # Time mocking for tests
end

group :development, :test do
  gem "factory_bot", "~> 6.4"           # Test data generation
  gem "faker", "~> 3.2"                 # Fake data generation
end