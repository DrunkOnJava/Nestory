source "https://rubygems.org"

# Core Fastlane for iOS automation
gem "fastlane", "~> 2.220"

# Essential Fastlane plugins
plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)

# Testing and CI/CD tools
gem "xcpretty", "~> 0.3"                # Beautiful test output formatting
gem "xcpretty-json-formatter", "~> 0.1" # JSON output for test results
gem "slather", "~> 2.8"                 # Code coverage reporting
gem "danger", "~> 9.4"                  # Automated code review
gem "danger-xcov", "~> 0.5"             # Coverage reporting in PRs

# Debugging and development
gem "pry", "~> 0.14"                    # Better Ruby debugging
gem "rubocop", "~> 1.60", require: false # Ruby style guide

# Bundle management
gem "bundler", "~> 2.5"