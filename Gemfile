source "https://rubygems.org"

# Essential gems for fastlane snapshot functionality
gem "fastlane", "~> 2.220"

# Essential plugins (only real ones that exist)
plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)

# Basic functionality gems that exist
gem "xcodeproj", "~> 1.25"
gem "plist", "~> 3.7"