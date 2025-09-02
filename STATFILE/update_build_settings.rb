#!/usr/bin/env ruby

# =============================================================================
# ENTERPRISE BUILD SETTINGS MANAGEMENT SCRIPT
# Dynamic Xcode build settings update for Nestory's enterprise configuration
# =============================================================================

require 'xcodeproj'
require 'optparse'
require 'json'
require 'pathname'

class BuildSettingsManager
  attr_reader :project_path, :target_name, :configuration, :settings, :options
  
  def initialize(project_path, target_name, configuration, settings, options = {})
    @project_path = project_path
    @target_name = target_name
    @configuration = configuration
    @settings = settings
    @options = options
    @project = nil
  end
  
  def update_all_settings
    puts "⚙️ Updating Xcode build settings..."
    puts "Project: #{project_path}"
    puts "Target: #{target_name}"
    puts "Configuration: #{configuration}"
    puts "Settings: #{settings.keys.count} items"
    puts
    
    load_project
    backup_current_settings if options[:backup]
    update_target_settings
    validate_settings if options[:validate]
    save_project
    
    puts "✅ Build settings updated successfully"
  end
  
  private
  
  def load_project
    puts "📖 Loading Xcode project..."
    @project = Xcodeproj::Project.open(project_path)
    puts "   Loaded project: #{@project.root_object.name}"
  end
  
  def backup_current_settings
    puts "💾 Backing up current build settings..."
    
    target = find_target
    backup_dir = "fastlane/backups/build_settings"
    FileUtils.mkdir_p(backup_dir)
    
    timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
    backup_file = File.join(backup_dir, "#{target_name}_#{configuration}_#{timestamp}.json")
    
    current_settings = {}
    target.build_configurations.each do |config|
      if configuration == 'all' || config.name == configuration
        current_settings[config.name] = config.build_settings.dup
      end
    end
    
    File.write(backup_file, JSON.pretty_generate(current_settings))
    puts "   ✅ Settings backed up to: #{backup_file}"
  end
  
  def update_target_settings
    puts "🔧 Updating target build settings..."
    
    target = find_target
    
    target.build_configurations.each do |config|
      next if configuration != 'all' && config.name != configuration
      
      puts "   Updating #{config.name} configuration..."
      apply_settings_to_configuration(config)
    end
    
    puts "   ✅ Target settings updated"
  end
  
  def find_target
    target = @project.targets.find { |t| t.name == target_name }
    raise "Target '#{target_name}' not found" unless target
    target
  end
  
  def apply_settings_to_configuration(config)
    config_settings = config.build_settings
    
    settings.each do |key, value|
      old_value = config_settings[key]
      
      # Handle different value types
      processed_value = process_setting_value(value)
      config_settings[key] = processed_value
      
      puts "     #{key}: #{old_value.inspect} → #{processed_value.inspect}"
    end
  end
  
  def process_setting_value(value)
    case value
    when Array
      value
    when String
      # Handle special string values
      case value.downcase
      when 'yes', 'true'
        'YES'
      when 'no', 'false'
        'NO'
      else
        value
      end
    when TrueClass
      'YES'
    when FalseClass
      'NO'
    when NilClass
      ''
    else
      value.to_s
    end
  end
  
  def validate_settings
    puts "🔍 Validating updated build settings..."
    
    target = find_target
    validation_errors = []
    validation_warnings = []
    
    target.build_configurations.each do |config|
      next if configuration != 'all' && config.name != configuration
      
      validate_configuration_settings(config, validation_errors, validation_warnings)
    end
    
    if validation_errors.any?
      puts "❌ Validation errors found:"
      validation_errors.each { |error| puts "   • #{error}" }
      raise "Build settings validation failed"
    end
    
    if validation_warnings.any?
      puts "⚠️ Validation warnings:"
      validation_warnings.each { |warning| puts "   • #{warning}" }
    end
    
    puts "   ✅ Settings validation passed"
  end
  
  def validate_configuration_settings(config, errors, warnings)
    config_settings = config.build_settings
    config_name = config.name
    
    # Validate Swift settings
    validate_swift_settings(config_settings, config_name, errors, warnings)
    
    # Validate code signing settings
    validate_code_signing_settings(config_settings, config_name, errors, warnings)
    
    # Validate deployment settings
    validate_deployment_settings(config_settings, config_name, errors, warnings)
    
    # Validate optimization settings
    validate_optimization_settings(config_settings, config_name, errors, warnings)
  end
  
  def validate_swift_settings(settings, config_name, errors, warnings)
    # Check Swift version compatibility
    swift_version = settings['SWIFT_VERSION']
    if swift_version && swift_version != '6.0'
      warnings << "#{config_name}: Swift version is #{swift_version}, expected 6.0"
    end
    
    # Check concurrency settings
    strict_concurrency = settings['SWIFT_STRICT_CONCURRENCY']
    if strict_concurrency == 'complete' && config_name == 'Debug'
      warnings << "#{config_name}: Strict concurrency may slow debug builds"
    end
    
    # Check optimization consistency
    compilation_mode = settings['SWIFT_COMPILATION_MODE']
    optimization_level = settings['SWIFT_OPTIMIZATION_LEVEL']
    
    if config_name == 'Release'
      if compilation_mode != 'wholemodule'
        warnings << "#{config_name}: Should use wholemodule compilation for Release"
      end
      if optimization_level != '-O'
        warnings << "#{config_name}: Should use -O optimization for Release"
      end
    end
  end
  
  def validate_code_signing_settings(settings, config_name, errors, warnings)
    code_sign_style = settings['CODE_SIGN_STYLE']
    if code_sign_style.nil?
      errors << "#{config_name}: CODE_SIGN_STYLE not set"
    end
    
    # Check for debug information format
    debug_format = settings['DEBUG_INFORMATION_FORMAT']
    if config_name == 'Release' && debug_format != 'dwarf-with-dsym'
      warnings << "#{config_name}: Should generate dSYM for Release builds"
    end
  end
  
  def validate_deployment_settings(settings, config_name, errors, warnings)
    deployment_target = settings['IPHONEOS_DEPLOYMENT_TARGET']
    if deployment_target && Gem::Version.new(deployment_target) < Gem::Version.new('17.0')
      warnings << "#{config_name}: Deployment target #{deployment_target} is below project minimum (17.0)"
    end
    
    # Check bitcode settings
    enable_bitcode = settings['ENABLE_BITCODE']
    if enable_bitcode == 'YES'
      warnings << "#{config_name}: Bitcode is deprecated and should be disabled"
    end
  end
  
  def validate_optimization_settings(settings, config_name, errors, warnings)
    # Check for conflicting optimization settings
    if config_name == 'Debug'
      gcc_optimization = settings['GCC_OPTIMIZATION_LEVEL']
      if gcc_optimization && gcc_optimization != '0'
        warnings << "#{config_name}: Debug builds should use optimization level 0"
      end
      
      only_active_arch = settings['ONLY_ACTIVE_ARCH']
      if only_active_arch != 'YES'
        warnings << "#{config_name}: Debug builds should build only active architecture"
      end
    end
    
    if config_name == 'Release'
      validate_product = settings['VALIDATE_PRODUCT']
      if validate_product != 'YES'
        warnings << "#{config_name}: Release builds should validate product"
      end
    end
  end
  
  def save_project
    puts "💾 Saving project changes..."
    @project.save
    puts "   ✅ Project saved"
  end
end

# =============================================================================
# PREDEFINED BUILD SETTING TEMPLATES
# =============================================================================

class BuildSettingsTemplates
  SWIFT_6_BASE = {
    'SWIFT_VERSION' => '6.0',
    'SWIFT_UPCOMING_FEATURE_CONCURRENCY' => 'YES',
    'SWIFT_UPCOMING_FEATURE_EXISTENTIAL_ANY' => 'YES'
  }.freeze
  
  DEBUG_OPTIMIZATIONS = {
    'SWIFT_COMPILATION_MODE' => 'singlefile',
    'SWIFT_OPTIMIZATION_LEVEL' => '-Onone',
    'GCC_OPTIMIZATION_LEVEL' => '0',
    'ONLY_ACTIVE_ARCH' => 'YES',
    'ENABLE_TESTABILITY' => 'YES'
  }.freeze
  
  RELEASE_OPTIMIZATIONS = {
    'SWIFT_COMPILATION_MODE' => 'wholemodule',
    'SWIFT_OPTIMIZATION_LEVEL' => '-O',
    'GCC_OPTIMIZATION_LEVEL' => 's',
    'ENABLE_TESTABILITY' => 'NO',
    'VALIDATE_PRODUCT' => 'YES'
  }.freeze
  
  UI_TESTING_SETTINGS = {
    'UI_TEST_FRAMEWORK_ENABLED' => 'YES',
    'ENABLE_TESTING_SEARCH_PATHS' => 'YES',
    'SWIFT_STRICT_CONCURRENCY' => 'minimal'
  }.freeze
  
  SECURITY_SETTINGS = {
    'CLANG_ENABLE_OBJC_ARC' => 'YES',
    'GCC_GENERATE_DEBUGGING_SYMBOLS' => 'YES',
    'DEBUG_INFORMATION_FORMAT' => 'dwarf-with-dsym',
    'ENABLE_STRICT_OBJC_MSGSEND' => 'YES',
    'GCC_ENABLE_SSP_BUFFER_OVERFLOW_CHECK' => 'YES'
  }.freeze
  
  PERFORMANCE_SETTINGS = {
    'SWIFT_ENABLE_BATCH_MODE' => 'YES',
    'SWIFT_ENABLE_INCREMENTAL_COMPILATION' => 'YES',
    'ENABLE_MODULE_VERIFIER' => 'NO', # Disabled for debug builds
    'ASSETCATALOG_COMPILER_OPTIMIZATION' => 'time'
  }.freeze
  
  def self.for_template(template_name)
    case template_name.to_sym
    when :swift6_debug
      SWIFT_6_BASE.merge(DEBUG_OPTIMIZATIONS).merge(UI_TESTING_SETTINGS)
    when :swift6_release
      SWIFT_6_BASE.merge(RELEASE_OPTIMIZATIONS).merge(SECURITY_SETTINGS)
    when :ui_testing
      SWIFT_6_BASE.merge(DEBUG_OPTIMIZATIONS).merge(UI_TESTING_SETTINGS)
    when :performance
      SWIFT_6_BASE.merge(PERFORMANCE_SETTINGS)
    when :security
      SECURITY_SETTINGS
    else
      {}
    end
  end
end

# =============================================================================
# COMMAND LINE INTERFACE
# =============================================================================

def main
  options = {}
  
  OptionParser.new do |opts|
    opts.banner = "Usage: #{$0} [options]"
    
    opts.on("--project PATH", "Path to Xcode project") do |path|
      options[:project] = path
    end
    
    opts.on("--target TARGET", "Target name") do |name|
      options[:target] = name
    end
    
    opts.on("--configuration CONFIG", "Configuration (Debug/Release/all)") do |config|
      options[:configuration] = config
    end
    
    opts.on("--settings JSON", "Settings as JSON string") do |json|
      options[:settings] = JSON.parse(json)
    end
    
    opts.on("--template TEMPLATE", "Use predefined template") do |template|
      options[:template] = template
    end
    
    opts.on("--backup", "Backup current settings") do
      options[:backup] = true
    end
    
    opts.on("--validate", "Validate settings after update") do
      options[:validate] = true
    end
    
    opts.on("-h", "--help", "Show this help") do
      puts opts
      puts
      puts "Available templates:"
      puts "  swift6_debug    - Swift 6.0 with debug optimizations"
      puts "  swift6_release  - Swift 6.0 with release optimizations"
      puts "  ui_testing      - UI testing configuration"
      puts "  performance     - Performance optimizations"
      puts "  security        - Security-focused settings"
      exit
    end
  end.parse!
  
  project_path = options[:project] || "Nestory.xcodeproj"
  target_name = options[:target] || "Nestory"
  configuration = options[:configuration] || "Debug"
  
  # Determine settings to apply
  settings = if options[:template]
    BuildSettingsTemplates.for_template(options[:template])
  elsif options[:settings]
    options[:settings]
  else
    puts "❌ Either --settings or --template must be provided"
    exit 1
  end
  
  unless File.exist?(project_path)
    puts "❌ Project not found: #{project_path}"
    exit 1
  end
  
  if settings.empty?
    puts "❌ No settings to apply"
    exit 1
  end
  
  begin
    manager = BuildSettingsManager.new(
      project_path, 
      target_name, 
      configuration, 
      settings, 
      {
        backup: options[:backup] || true,
        validate: options[:validate] || true
      }
    )
    
    manager.update_all_settings
    
    puts
    puts "🎉 Build settings updated successfully!"
    puts
    puts "Applied settings:"
    settings.each do |key, value|
      puts "  #{key} = #{value}"
    end
    
  rescue => error
    puts "❌ Build settings update failed: #{error.message}"
    puts error.backtrace.join("\n") if ENV['DEBUG']
    exit 1
  end
end

main if __FILE__ == $0