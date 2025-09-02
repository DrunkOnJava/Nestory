#!/usr/bin/env ruby

# =============================================================================
# ENTERPRISE ENVIRONMENT SETUP SCRIPT  
# Comprehensive development environment configuration for Nestory
# =============================================================================

require 'optparse'
require 'json'
require 'fileutils'
require 'pathname'

class EnvironmentSetup
  attr_reader :options
  
  def initialize(options = {})
    @options = options
  end
  
  def setup_all
    puts "🛠️ Setting up comprehensive development environment..."
    puts "Options: #{options.keys.join(', ')}"
    puts
    
    validate_prerequisites
    install_dependencies if options[:install_dependencies]
    configure_simulators if options[:configure_simulators] 
    setup_certificates if options[:setup_certificates]
    configure_git_hooks if options[:configure_git_hooks]
    validate_xcode_installation if options[:validate_xcode_installation]
    setup_ruby_environment
    configure_development_tools
    
    puts "✅ Environment setup completed successfully"
  end
  
  private
  
  def validate_prerequisites
    puts "🔍 Validating prerequisites..."
    
    # Check Xcode installation
    validate_xcode
    
    # Check Ruby installation
    validate_ruby
    
    # Check Homebrew installation
    validate_homebrew
    
    puts "   ✅ Prerequisites validation completed"
  end
  
  def validate_xcode
    xcode_path = `xcode-select -p 2>/dev/null`.strip
    
    if xcode_path.empty?
      raise "Xcode command line tools not installed. Run: xcode-select --install"
    end
    
    xcode_version = `xcodebuild -version 2>/dev/null | head -1`.strip
    puts "   ✅ Xcode found: #{xcode_version} at #{xcode_path}"
    
    # Check minimum Xcode version
    version_match = xcode_version.match(/Xcode (\d+\.\d+)/)
    if version_match && version_match[1].to_f < 15.0
      puts "   ⚠️ Xcode #{version_match[1]} detected, Xcode 15.0+ recommended"
    end
  end
  
  def validate_ruby
    ruby_version = RUBY_VERSION
    puts "   ✅ Ruby found: #{ruby_version}"
    
    if Gem::Version.new(ruby_version) < Gem::Version.new('3.0.0')
      puts "   ⚠️ Ruby #{ruby_version} detected, Ruby 3.0+ recommended"
    end
    
    # Check Bundler
    bundler_version = `bundle --version 2>/dev/null`.strip
    if bundler_version.empty?
      puts "   Installing Bundler..."
      system('gem install bundler')
    else
      puts "   ✅ #{bundler_version}"
    end
  end
  
  def validate_homebrew
    brew_path = `which brew 2>/dev/null`.strip
    
    if brew_path.empty?
      puts "   ⚠️ Homebrew not found. Installing..."
      install_homebrew
    else
      puts "   ✅ Homebrew found at: #{brew_path}"
    end
  end
  
  def install_homebrew
    puts "📦 Installing Homebrew..."
    install_script = '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    system(install_script)
  end
  
  def install_dependencies
    puts "📦 Installing development dependencies..."
    
    # Homebrew packages for iOS development
    homebrew_packages = [
      'cocoapods',        # Dependency management
      'carthage',         # Alternative dependency management  
      'swiftlint',        # Swift linting
      'swiftformat',      # Swift code formatting
      'xcpretty',         # Pretty Xcode output
      'imagemagick',      # Image processing for app icons
      'libpng',          # PNG processing
      'jpeg',            # JPEG processing
      'ffmpeg',          # Video processing for app previews
      'wget',            # File downloading
      'jq',              # JSON processing
      'plistbuddy',      # Plist manipulation
      'ios-sim',         # iOS Simulator control
      'ideviceinstaller' # Device installation utilities
    ]
    
    puts "   Installing Homebrew packages..."
    homebrew_packages.each do |package|
      if system("brew list #{package} > /dev/null 2>&1")
        puts "     ✅ #{package} already installed"
      else
        puts "     📦 Installing #{package}..."
        system("brew install #{package}")
      end
    end
    
    # Ruby gems for development
    install_ruby_gems
    
    # Install iOS development utilities
    install_ios_utilities
    
    puts "   ✅ Dependencies installation completed"
  end
  
  def install_ruby_gems
    puts "   Installing Ruby gems..."
    
    development_gems = [
      'xcodeproj',       # Xcode project manipulation
      'plist',           # Plist file handling
      'simctl',          # iOS Simulator control
      'cfpropertylist',  # Core Foundation property lists
      'nokogiri',        # XML processing
      'rubyzip',         # ZIP file handling
      'jwt',             # JWT token handling
      'faraday',         # HTTP client
      'terminal-notifier' # macOS notifications
    ]
    
    development_gems.each do |gem_name|
      if system("gem list -i #{gem_name} > /dev/null 2>&1")
        puts "     ✅ #{gem_name} already installed"
      else  
        puts "     💎 Installing #{gem_name}..."
        system("gem install #{gem_name}")
      end
    end
  end
  
  def install_ios_utilities
    puts "   Installing iOS development utilities..."
    
    # Install iOS App Signer for development
    app_signer_url = "https://github.com/DanTheMan827/ios-app-signer/releases/latest/download/iOS.App.Signer.app.zip"
    utilities_dir = File.expand_path("~/Developer/Utilities")
    FileUtils.mkdir_p(utilities_dir)
    
    app_signer_path = File.join(utilities_dir, "iOS App Signer.app")
    unless Dir.exist?(app_signer_path)
      puts "     📱 Installing iOS App Signer..."
      system("cd '#{utilities_dir}' && wget -q '#{app_signer_url}' -O ios-app-signer.zip && unzip -q ios-app-signer.zip && rm ios-app-signer.zip")
    end
    
    # Create useful development scripts
    create_development_scripts
  end
  
  def create_development_scripts
    scripts_dir = File.expand_path("~/Developer/Scripts")
    FileUtils.mkdir_p(scripts_dir)
    
    # Create simulator reset script
    simulator_reset_script = File.join(scripts_dir, "reset-simulators.sh")
    File.write(simulator_reset_script, <<~SCRIPT)
      #!/bin/bash
      # Reset all iOS simulators
      echo "🔄 Resetting all iOS simulators..."
      xcrun simctl shutdown all
      xcrun simctl erase all
      echo "✅ Simulators reset completed"
    SCRIPT
    FileUtils.chmod(0755, simulator_reset_script)
    
    # Create clean build script  
    clean_build_script = File.join(scripts_dir, "clean-build.sh")
    File.write(clean_build_script, <<~SCRIPT)
      #!/bin/bash
      # Clean Xcode build artifacts
      echo "🧹 Cleaning Xcode build artifacts..."
      rm -rf ~/Library/Developer/Xcode/DerivedData/*
      rm -rf build/
      echo "✅ Clean completed"
    SCRIPT
    FileUtils.chmod(0755, clean_build_script)
    
    puts "     ✅ Development scripts created in #{scripts_dir}"
  end
  
  def configure_simulators
    puts "📱 Configuring iOS simulators..."
    
    # Install required iOS runtimes
    install_ios_runtimes
    
    # Create required simulator devices
    create_simulator_devices
    
    # Configure simulator settings
    configure_simulator_settings
    
    puts "   ✅ Simulator configuration completed"
  end
  
  def install_ios_runtimes
    puts "   Checking iOS runtimes..."
    
    # Get available runtimes
    runtimes_json = `xcrun simctl list runtimes -j 2>/dev/null`
    runtimes = JSON.parse(runtimes_json)['runtimes'] rescue []
    
    required_ios_versions = ['17.0', '17.1', '17.2']
    
    required_ios_versions.each do |version|
      runtime_found = runtimes.any? do |runtime|
        runtime['name'].include?('iOS') && runtime['version'].start_with?(version)
      end
      
      if runtime_found
        puts "     ✅ iOS #{version} runtime available"
      else
        puts "     📱 iOS #{version} runtime not found"
        # Note: Automatic runtime installation requires additional setup
        puts "     ℹ️ Install iOS #{version} runtime through Xcode > Settings > Platforms"
      end
    end
  end
  
  def create_simulator_devices
    puts "   Creating required simulator devices..."
    
    # Device configurations for testing
    required_devices = [
      {
        name: "Nestory iPhone 16 Pro Max",
        device_type: "com.apple.CoreSimulator.SimDeviceType.iPhone-16-Pro-Max",
        runtime: "com.apple.CoreSimulator.SimRuntime.iOS-17-0"
      },
      {
        name: "Nestory iPhone 16 Pro", 
        device_type: "com.apple.CoreSimulator.SimDeviceType.iPhone-16-Pro",
        runtime: "com.apple.CoreSimulator.SimRuntime.iOS-17-0"
      },
      {
        name: "Nestory iPad Pro 12.9",
        device_type: "com.apple.CoreSimulator.SimDeviceType.iPad-Pro-12point9-inch-6th-generation",
        runtime: "com.apple.CoreSimulator.SimRuntime.iOS-17-0"
      }
    ]
    
    required_devices.each do |device_config|
      # Check if device already exists
      existing_device = find_simulator_device(device_config[:name])
      
      if existing_device
        puts "     ✅ Device exists: #{device_config[:name]}"
      else
        puts "     📱 Creating device: #{device_config[:name]}"
        create_result = `xcrun simctl create "#{device_config[:name]}" "#{device_config[:device_type]}" "#{device_config[:runtime]}" 2>/dev/null`
        
        if $?.success?
          puts "     ✅ Created device: #{device_config[:name]}"
        else
          puts "     ⚠️ Failed to create device: #{device_config[:name]}"
        end
      end
    end
  end
  
  def find_simulator_device(device_name)
    devices_json = `xcrun simctl list devices -j 2>/dev/null`
    devices_data = JSON.parse(devices_json) rescue { 'devices' => {} }
    
    devices_data['devices'].each do |runtime, devices|
      device = devices.find { |d| d['name'] == device_name }
      return device if device
    end
    
    nil
  end
  
  def configure_simulator_settings
    puts "   Configuring simulator settings..."
    
    # Configure global simulator settings
    simulator_prefs = File.expand_path("~/Library/Preferences/com.apple.iphonesimulator.plist")
    
    if File.exist?(simulator_prefs)
      puts "     ⚙️ Configuring simulator preferences..."
      
      # Use PlistBuddy to modify simulator settings
      system("/usr/libexec/PlistBuddy -c 'Set :ShowChrome true' '#{simulator_prefs}' 2>/dev/null")
      system("/usr/libexec/PlistBuddy -c 'Set :ConnectHardwareKeyboard false' '#{simulator_prefs}' 2>/dev/null")
      
      puts "     ✅ Simulator preferences configured"
    end
  end
  
  def setup_certificates
    puts "🔑 Setting up certificates and provisioning profiles..."
    
    # Create certificates directory
    certs_dir = File.expand_path("~/Developer/Certificates")
    FileUtils.mkdir_p(certs_dir)
    
    # Check for existing certificates
    check_existing_certificates
    
    # Set up development certificates
    setup_development_certificates
    
    puts "   ✅ Certificate setup completed"
  end
  
  def check_existing_certificates
    puts "   Checking existing certificates..."
    
    # List iOS development certificates
    certs_output = `security find-identity -v -p codesigning 2>/dev/null`
    
    if certs_output.include?('iPhone Developer')
      puts "     ✅ iOS Development certificate found"
    else
      puts "     ⚠️ No iOS Development certificate found"
      puts "     ℹ️ Generate certificates through Apple Developer Portal"
    end
    
    # List provisioning profiles
    profiles_dir = File.expand_path("~/Library/MobileDevice/Provisioning Profiles")
    if Dir.exist?(profiles_dir)
      profile_count = Dir.glob("#{profiles_dir}/*.mobileprovision").count
      puts "     ℹ️ #{profile_count} provisioning profiles found"
    else
      puts "     ℹ️ No provisioning profiles directory found"
    end
  end
  
  def setup_development_certificates
    puts "   Setting up development certificate environment..."
    
    # Create certificate management script
    cert_script = File.expand_path("~/Developer/Scripts/manage-certificates.sh")
    File.write(cert_script, <<~SCRIPT)
      #!/bin/bash
      # Certificate management script for Nestory development
      
      echo "📱 Nestory Certificate Management"
      echo "================================"
      echo
      
      echo "Available commands:"
      echo "  list    - List installed certificates"
      echo "  clean   - Clean expired certificates"
      echo "  info    - Show certificate information"
      echo
      
      case "$1" in
        list)
          security find-identity -v -p codesigning
          ;;
        clean)
          echo "Cleaning expired certificates..."
          # Add certificate cleanup logic here
          ;;
        info)
          security find-identity -v -p codesigning | grep -E "(iPhone|Mac) Developer"
          ;;
        *)
          echo "Usage: $0 {list|clean|info}"
          ;;
      esac
    SCRIPT
    FileUtils.chmod(0755, cert_script)
    
    puts "     ✅ Certificate management script created"
  end
  
  def configure_git_hooks
    puts "📝 Configuring Git hooks..."
    
    hooks_dir = ".git/hooks"
    unless Dir.exist?(hooks_dir)
      puts "     ⚠️ Not in a Git repository"
      return
    end
    
    # Create pre-commit hook
    create_pre_commit_hook(hooks_dir)
    
    # Create pre-push hook
    create_pre_push_hook(hooks_dir)
    
    puts "   ✅ Git hooks configured"
  end
  
  def create_pre_commit_hook(hooks_dir)
    pre_commit_hook = File.join(hooks_dir, "pre-commit")
    
    File.write(pre_commit_hook, <<~SCRIPT)
      #!/bin/bash
      # Pre-commit hook for Nestory
      
      echo "🔍 Running pre-commit checks..."
      
      # Run SwiftLint
      if which swiftlint >/dev/null; then
        echo "Running SwiftLint..."
        swiftlint
      else
        echo "⚠️ SwiftLint not installed"
      fi
      
      # Check for TODO and FIXME comments in staged files
      if git diff --cached --name-only | xargs grep -l "TODO\\|FIXME" 2>/dev/null; then
        echo "⚠️ Found TODO or FIXME comments in staged files"
        echo "Consider addressing them before committing"
      fi
      
      # Check for debugging code
      if git diff --cached --name-only | xargs grep -l "print(\\|NSLog" 2>/dev/null; then
        echo "⚠️ Found debugging code in staged files"
        echo "Consider removing debugging statements before committing"
      fi
      
      echo "✅ Pre-commit checks completed"
    SCRIPT
    
    FileUtils.chmod(0755, pre_commit_hook)
    puts "     ✅ Pre-commit hook created"
  end
  
  def create_pre_push_hook(hooks_dir)
    pre_push_hook = File.join(hooks_dir, "pre-push")
    
    File.write(pre_push_hook, <<~SCRIPT)
      #!/bin/bash
      # Pre-push hook for Nestory
      
      echo "🚀 Running pre-push checks..."
      
      # Run tests before push
      echo "Running tests..."
      if make test 2>/dev/null; then
        echo "✅ Tests passed"
      else
        echo "❌ Tests failed"
        echo "Fix test failures before pushing"
        exit 1
      fi
      
      # Check build health
      echo "Checking build health..."
      if make build 2>/dev/null; then
        echo "✅ Build successful"
      else
        echo "❌ Build failed"
        echo "Fix build issues before pushing"
        exit 1
      fi
      
      echo "✅ Pre-push checks completed"
    SCRIPT
    
    FileUtils.chmod(0755, pre_push_hook)
    puts "     ✅ Pre-push hook created"
  end
  
  def validate_xcode_installation
    puts "🔍 Validating Xcode installation..."
    
    # Check Xcode version
    validate_xcode_version
    
    # Check iOS SDK availability
    validate_ios_sdks
    
    # Check simulator runtimes
    validate_simulator_runtimes
    
    # Check command line tools
    validate_command_line_tools
    
    puts "   ✅ Xcode validation completed"
  end
  
  def validate_xcode_version
    puts "   Checking Xcode version..."
    
    xcode_version_output = `xcodebuild -version 2>/dev/null`
    version_lines = xcode_version_output.split("\n")
    
    if version_lines.length >= 2
      xcode_version = version_lines[0]
      build_version = version_lines[1]
      puts "     ✅ #{xcode_version} (#{build_version})"
    else
      puts "     ❌ Could not determine Xcode version"
    end
  end
  
  def validate_ios_sdks
    puts "   Checking iOS SDKs..."
    
    sdks_output = `xcodebuild -showsdks | grep -E '^\\s*iOS' 2>/dev/null`
    
    if sdks_output.empty?
      puts "     ❌ No iOS SDKs found"
    else
      sdks = sdks_output.strip.split("\n")
      puts "     ✅ #{sdks.length} iOS SDK(s) found:"
      sdks.each { |sdk| puts "       #{sdk.strip}" }
    end
  end
  
  def validate_simulator_runtimes
    puts "   Checking simulator runtimes..."
    
    runtimes_json = `xcrun simctl list runtimes -j 2>/dev/null`
    runtimes_data = JSON.parse(runtimes_json) rescue { 'runtimes' => [] }
    
    ios_runtimes = runtimes_data['runtimes'].select { |r| r['name'].include?('iOS') }
    
    if ios_runtimes.empty?
      puts "     ❌ No iOS runtimes found"
    else
      puts "     ✅ #{ios_runtimes.length} iOS runtime(s) found:"
      ios_runtimes.each do |runtime|
        puts "       iOS #{runtime['version']} (#{runtime['identifier']})"
      end
    end
  end
  
  def validate_command_line_tools
    puts "   Checking command line tools..."
    
    # Check essential tools
    essential_tools = %w[xcodebuild xcrun xcode-select git]
    
    essential_tools.each do |tool|
      if system("which #{tool} > /dev/null 2>&1")
        puts "     ✅ #{tool} available"
      else
        puts "     ❌ #{tool} not found"
      end
    end
  end
  
  def setup_ruby_environment
    puts "💎 Setting up Ruby environment..."
    
    # Install Bundler if not present
    unless system("which bundle > /dev/null 2>&1")
      puts "   Installing Bundler..."
      system("gem install bundler")
    end
    
    # Install project dependencies
    if File.exist?('Gemfile')
      puts "   Installing Ruby dependencies..."
      system("bundle install --quiet")
      puts "     ✅ Ruby dependencies installed"
    end
    
    puts "   ✅ Ruby environment setup completed"
  end
  
  def configure_development_tools
    puts "🛠️ Configuring development tools..."
    
    # Create development aliases
    create_development_aliases
    
    # Configure shell environment
    configure_shell_environment
    
    puts "   ✅ Development tools configured"
  end
  
  def create_development_aliases
    aliases_file = File.expand_path("~/.nestory_aliases")
    
    File.write(aliases_file, <<~ALIASES)
      # Nestory Development Aliases
      # Source this file in your shell configuration
      
      # Build shortcuts
      alias nb='make build'
      alias nr='make run' 
      alias nt='make test'
      alias nc='make clean'
      
      # Fastlane shortcuts
      alias fl='bundle exec fastlane'
      alias flt='bundle exec fastlane tests'
      alias flu='bundle exec fastlane ui_tests'
      alias flb='bundle exec fastlane build'
      
      # Simulator shortcuts
      alias sim-reset='xcrun simctl shutdown all && xcrun simctl erase all'
      alias sim-list='xcrun simctl list devices'
      
      # Xcode shortcuts  
      alias xc-clean='rm -rf ~/Library/Developer/Xcode/DerivedData/*'
      alias xc-reset='rm -rf build/ && xc-clean'
      
      # Development shortcuts
      alias nestory-env='ruby fastlane/xcode_ruby_scripts/setup_environment.rb'
      alias nestory-validate='ruby fastlane/xcode_ruby_scripts/validate_configuration.rb'
    ALIASES
    
    puts "     ✅ Development aliases created at #{aliases_file}"
    puts "     ℹ️ Add 'source #{aliases_file}' to your shell configuration"
  end
  
  def configure_shell_environment
    # Create environment configuration
    env_config = File.expand_path("~/.nestory_env")
    
    File.write(env_config, <<~ENV_CONFIG)
      # Nestory Development Environment Configuration
      
      # iOS Development
      export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
      export XCODE_VERSION="15.0"
      
      # Fastlane
      export FASTLANE_OPT_OUT_USAGE="1"
      export FASTLANE_SKIP_UPDATE_CHECK="1"
      
      # Ruby/Bundler
      export BUNDLE_USER_CONFIG="#{Dir.home}/.bundle"
      export BUNDLE_USER_CACHE="#{Dir.home}/.bundle/cache"
      export BUNDLE_USER_PLUGIN="#{Dir.home}/.bundle/plugin"
      
      # iOS Simulator
      export SIMULATOR_STARTUP_TIMEOUT="240"
      
      # Development paths
      export PATH="#{Dir.home}/Developer/Scripts:$PATH"
    ENV_CONFIG
    
    puts "     ✅ Environment configuration created at #{env_config}"
    puts "     ℹ️ Add 'source #{env_config}' to your shell configuration"
  end
end

# =============================================================================
# COMMAND LINE INTERFACE
# =============================================================================

def main
  options = {}
  
  OptionParser.new do |opts|
    opts.banner = "Usage: #{$0} [options]"
    
    opts.on("--install-dependencies", "Install development dependencies") do
      options[:install_dependencies] = true
    end
    
    opts.on("--configure-simulators", "Configure iOS simulators") do
      options[:configure_simulators] = true
    end
    
    opts.on("--setup-certificates", "Setup certificates and provisioning") do
      options[:setup_certificates] = true
    end
    
    opts.on("--configure-git-hooks", "Configure Git hooks") do
      options[:configure_git_hooks] = true
    end
    
    opts.on("--validate-xcode-installation", "Validate Xcode installation") do
      options[:validate_xcode_installation] = true
    end
    
    opts.on("--all", "Run all setup tasks") do
      options[:install_dependencies] = true
      options[:configure_simulators] = true
      options[:setup_certificates] = true
      options[:configure_git_hooks] = true
      options[:validate_xcode_installation] = true
    end
    
    opts.on("-h", "--help", "Show this help") do
      puts opts
      exit
    end
  end.parse!
  
  if options.empty?
    puts "❌ No setup options specified. Use --help for options or --all for complete setup."
    exit 1
  end
  
  begin
    setup = EnvironmentSetup.new(options)
    setup.setup_all
    
    puts
    puts "🎉 Environment setup completed successfully!"
    puts
    puts "Next steps:"
    puts "1. Restart your terminal or source the new environment files"
    puts "2. Run: bundle exec fastlane validate_environment"
    puts "3. Build project: make build"
    
  rescue => error
    puts "❌ Environment setup failed: #{error.message}"
    puts error.backtrace.join("\n") if ENV['DEBUG']
    exit 1
  end
end

main if __FILE__ == $0