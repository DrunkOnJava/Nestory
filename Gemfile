# Minimal Gemfile for Nestory fastlane automation
source "https://rubygems.org"

ruby ">= 3.2.2"

# Core fastlane with verified plugins
gem "fastlane", "~> 2.228"

# Load verified plugins from Pluginfile
plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)

# Coverage via real gem (not plugin)
gem "xcov", "~> 1.8"

# Essential Xcode project manipulation
gem "xcodeproj", "~> 1.25"
gem "plist", "~> 3.7"