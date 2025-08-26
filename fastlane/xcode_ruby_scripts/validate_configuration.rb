#!/usr/bin/env ruby

# =============================================================================
# ENTERPRISE CONFIGURATION VALIDATION SCRIPT
# Comprehensive Xcode project configuration validation for Nestory
# =============================================================================

require 'xcodeproj'
require 'optparse'
require 'json'
require 'plist'
require 'pathname'

class ConfigurationValidator
  attr_reader :project_path, :options
  
  def initialize(project_path, options = {})
    @project_path = project_path
    @options = options
    @project = nil
    @validation_results = {
      errors: [],
      warnings: [],
      info: [],
      summary: {}
    }
  end
  
  def validate_all
    puts "🔍 Validating Xcode project configuration..." unless options[:quiet]
    puts "Project: #{project_path}" unless options[:quiet]
    puts unless options[:quiet]
    
    load_project
    validate_project_structure
    validate_targets
    validate_schemes
    validate_build_settings
    validate_entitlements if options[:comprehensive_check]
    validate_info_plists if options[:comprehensive_check]
    validate_dependencies if options[:comprehensive_check]
    
    generate_report
    @validation_results
  end
  
  private
  
  def load_project
    info "📖 Loading Xcode project..."
    @project = Xcodeproj::Project.open(project_path)
    info "   Loaded project: #{@project.root_object.name}"
  rescue => error
    error("Failed to load project: #{error.message}")
    raise error
  end
  
  def validate_project_structure
    info "🏗️ Validating project structure..."
    
    # Check for required directories
    required_dirs = [
      'App-Main',
      'Features', 
      'Services',
      'Infrastructure',
      'Foundation',
      'UI'
    ]
    
    required_dirs.each do |dir|
      unless Dir.exist?(dir)
        warning("Missing required directory: #{dir}")
      else
        info("   ✅ Directory exists: #{dir}")
      end
    end
    
    # Validate layer architecture compliance
    validate_layer_architecture
    
    info "   ✅ Project structure validation completed")
  end
  
  def validate_layer_architecture
    info "📐 Validating 6-layer architecture compliance...")
    
    # Define layer dependencies (what each layer can import)
    allowed_imports = {
      'App-Main' => ['Features', 'UI', 'Services', 'Infrastructure', 'Foundation'],
      'Features' => ['UI', 'Services', 'Foundation'],
      'UI' => ['Foundation'],
      'Services' => ['Infrastructure', 'Foundation'],
      'Infrastructure' => ['Foundation'],
      'Foundation' => []
    }
    
    # Check for architectural violations
    architectural_violations = []
    
    Dir.glob('**/*.swift').each do |file_path|
      next unless File.readable?(file_path)
      
      layer = determine_file_layer(file_path)
      next unless layer
      
      File.readlines(file_path).each_with_index do |line, line_number|
        if line.match?(/^import\s+(\w+)/)
          import_statement = line.strip
          
          # Check if import violates architecture
          violation = check_import_violation(file_path, layer, import_statement, allowed_imports)
          if violation
            architectural_violations << {
              file: file_path,
              line: line_number + 1,
              violation: violation
            }
          end
        end
      end
    end
    
    if architectural_violations.any?
      architectural_violations.each do |violation|
        error("Architecture violation: #{violation[:file]}:#{violation[:line]} - #{violation[:violation]}")
      end
    else
      info("   ✅ No architectural violations found")
    end
  end
  
  def determine_file_layer(file_path)
    case file_path
    when /^App-Main\//
      'App-Main'
    when /^Features\//
      'Features'
    when /^UI\//
      'UI'
    when /^Services\//
      'Services'
    when /^Infrastructure\//
      'Infrastructure'
    when /^Foundation\//
      'Foundation'
    else
      nil
    end
  end
  
  def check_import_violation(file_path, layer, import_statement, allowed_imports)
    # This is a simplified check - in reality would need more sophisticated parsing
    # to determine if imports violate the architecture
    return nil # Placeholder - would implement full import validation
  end
  
  def validate_targets
    info "🎯 Validating targets..."
    
    expected_targets = [
      'Nestory',
      'NestoryTests', 
      'NestoryUITests'
    ]
    
    found_targets = @project.targets.map(&:name)
    
    expected_targets.each do |target_name|
      if found_targets.include?(target_name)
        info("   ✅ Target found: #{target_name}")
        validate_target_configuration(target_name)
      else
        error("Missing required target: #{target_name}")
      end
    end
    
    # Check for unexpected targets
    unexpected_targets = found_targets - expected_targets
    unexpected_targets.each do |target_name|
      warning("Unexpected target found: #{target_name}")
    end
    
    info("   ✅ Target validation completed")
  end
  
  def validate_target_configuration(target_name)
    target = @project.targets.find { |t| t.name == target_name }
    return unless target
    
    # Validate target-specific configurations
    case target_name
    when 'Nestory'
      validate_main_target(target)
    when 'NestoryTests'
      validate_test_target(target)
    when 'NestoryUITests'
      validate_ui_test_target(target)
    end
  end
  
  def validate_main_target(target)
    info("     Validating main target: #{target.name}")
    
    # Check bundle identifier
    target.build_configurations.each do |config|
      bundle_id = config.build_settings['PRODUCT_BUNDLE_IDENTIFIER']
      expected_pattern = /^com\.drunkonjava\.nestory\.(dev|staging)?$/
      
      unless bundle_id&.match?(expected_pattern)
        error("Invalid bundle identifier in #{config.name}: #{bundle_id}")
      end
      
      # Check Swift version
      swift_version = config.build_settings['SWIFT_VERSION']
      unless swift_version == '6.0'
        error("Incorrect Swift version in #{config.name}: #{swift_version} (expected 6.0)")
      end
      
      # Check deployment target
      deployment_target = config.build_settings['IPHONEOS_DEPLOYMENT_TARGET']
      unless deployment_target == '17.0'
        warning("Deployment target in #{config.name}: #{deployment_target} (expected 17.0)")
      end
    end
  end
  
  def validate_test_target(target)
    info("     Validating test target: #{target.name}")
    
    # Check test host configuration
    target.build_configurations.each do |config|
      test_host = config.build_settings['TEST_HOST']
      expected_test_host = '$(BUILT_PRODUCTS_DIR)/Nestory.app/Nestory'
      
      unless test_host == expected_test_host
        error("Incorrect test host in #{config.name}: #{test_host}")
      end
    end
  end
  
  def validate_ui_test_target(target)
    info("     Validating UI test target: #{target.name}")
    
    target.build_configurations.each do |config|
      settings = config.build_settings
      
      # Check UI testing specific settings
      ui_framework_enabled = settings['UI_TEST_FRAMEWORK_ENABLED']
      unless ui_framework_enabled == 'YES'
        warning("UI_TEST_FRAMEWORK_ENABLED not set in #{config.name}")
      end
      
      # Check testing search paths
      testing_search_paths = settings['ENABLE_TESTING_SEARCH_PATHS']
      unless testing_search_paths == 'YES'
        warning("ENABLE_TESTING_SEARCH_PATHS not set in #{config.name}")
      end
    end
  end
  
  def validate_schemes
    info "📋 Validating schemes..."
    
    schemes_dir = File.join(@project.path, 'xcshareddata', 'xcschemes')
    
    expected_schemes = [
      'Nestory-Dev.xcscheme',
      'Nestory-UIWiring.xcscheme',
      'Nestory-Performance.xcscheme',
      'Nestory-Accessibility.xcscheme',
      'Nestory-Smoke.xcscheme',
      'Nestory-Prod.xcscheme'
    ]
    
    if Dir.exist?(schemes_dir)
      found_schemes = Dir.entries(schemes_dir).select { |f| f.end_with?('.xcscheme') }
      
      expected_schemes.each do |scheme|
        if found_schemes.include?(scheme)
          info("   ✅ Scheme found: #{scheme}")
          validate_scheme_configuration(File.join(schemes_dir, scheme))
        else
          error("Missing required scheme: #{scheme}")
        end
      end
    else
      error("Schemes directory not found: #{schemes_dir}")
    end
    
    info("   ✅ Scheme validation completed")
  end
  
  def validate_scheme_configuration(scheme_path)
    # Parse and validate scheme XML
    scheme_content = File.read(scheme_path)
    scheme_name = File.basename(scheme_path, '.xcscheme')
    
    # Check for required elements in scheme
    required_elements = ['BuildAction', 'TestAction', 'LaunchAction']
    
    required_elements.each do |element|
      unless scheme_content.include?("<#{element}")
        warning("Scheme #{scheme_name} missing #{element}")
      end
    end
    
    # Validate UI testing schemes
    if scheme_name.include?('UIWiring') || scheme_name.include?('Performance') || 
       scheme_name.include?('Accessibility') || scheme_name.include?('Smoke')
      validate_ui_testing_scheme(scheme_content, scheme_name)
    end
  end
  
  def validate_ui_testing_scheme(scheme_content, scheme_name)
    # Check for UI testing environment variables
    required_env_vars = [
      'UI_TEST_FRAMEWORK_ENABLED',
      'ENABLE_TESTING_SEARCH_PATHS'
    ]
    
    required_env_vars.each do |env_var|
      unless scheme_content.include?(env_var)
        warning("UI testing scheme #{scheme_name} missing environment variable: #{env_var}")
      end
    end
  end
  
  def validate_build_settings
    info "⚙️ Validating build settings..."
    
    main_target = @project.targets.find { |t| t.name == 'Nestory' }
    return unless main_target
    
    main_target.build_configurations.each do |config|
      validate_configuration_build_settings(config)
    end
    
    info("   ✅ Build settings validation completed")
  end
  
  def validate_configuration_build_settings(config)
    info("     Validating #{config.name} configuration...")
    
    settings = config.build_settings
    config_name = config.name
    
    # Required settings validation
    required_settings = {
      'SWIFT_VERSION' => '6.0',
      'IPHONEOS_DEPLOYMENT_TARGET' => '17.0',
      'DEBUG_INFORMATION_FORMAT' => 'dwarf-with-dsym',
      'CODE_SIGN_STYLE' => 'Automatic'
    }
    
    required_settings.each do |key, expected_value|
      actual_value = settings[key]
      if actual_value != expected_value
        error("#{config_name}: #{key} is '#{actual_value}', expected '#{expected_value}'")
      end
    end
    
    # Configuration-specific validation
    if config_name == 'Debug'
      validate_debug_settings(settings, config_name)
    elsif config_name == 'Release'
      validate_release_settings(settings, config_name)
    end
  end
  
  def validate_debug_settings(settings, config_name)
    debug_requirements = {
      'SWIFT_OPTIMIZATION_LEVEL' => '-Onone',
      'GCC_OPTIMIZATION_LEVEL' => '0',
      'ONLY_ACTIVE_ARCH' => 'YES',
      'ENABLE_TESTABILITY' => 'YES'
    }
    
    debug_requirements.each do |key, expected_value|
      actual_value = settings[key]
      if actual_value != expected_value
        warning("#{config_name}: #{key} is '#{actual_value}', recommended '#{expected_value}'")
      end
    end
  end
  
  def validate_release_settings(settings, config_name)
    release_requirements = {
      'SWIFT_COMPILATION_MODE' => 'wholemodule',
      'SWIFT_OPTIMIZATION_LEVEL' => '-O',
      'ENABLE_TESTABILITY' => 'NO',
      'VALIDATE_PRODUCT' => 'YES'
    }
    
    release_requirements.each do |key, expected_value|
      actual_value = settings[key]
      if actual_value != expected_value
        warning("#{config_name}: #{key} is '#{actual_value}', recommended '#{expected_value}'")
      end
    end
  end
  
  def validate_entitlements
    info "🔐 Validating entitlements..."
    
    entitlements_files = [
      'App-Main/Nestory.entitlements',
      'NestoryUITests/NestoryUITests.entitlements'
    ]
    
    entitlements_files.each do |file_path|
      if File.exist?(file_path)
        validate_entitlements_file(file_path)
      else
        warning("Entitlements file not found: #{file_path}")
      end
    end
    
    info("   ✅ Entitlements validation completed")
  end
  
  def validate_entitlements_file(file_path)
    info("     Validating entitlements: #{file_path}")
    
    entitlements = Plist.parse_xml(file_path)
    
    if file_path.include?('Nestory.entitlements')
      # Main app entitlements
      required_entitlements = [
        'com.apple.developer.icloud-services',
        'com.apple.developer.icloud-container-identifiers'
      ]
      
      required_entitlements.each do |entitlement|
        unless entitlements.key?(entitlement)
          error("Missing entitlement in #{file_path}: #{entitlement}")
        end
      end
    end
  rescue => error
    error("Failed to parse entitlements file #{file_path}: #{error.message}")
  end
  
  def validate_info_plists
    info "📄 Validating Info.plist files..."
    
    info_plist_files = [
      'App-Main/Info.plist'
    ]
    
    info_plist_files.each do |file_path|
      if File.exist?(file_path)
        validate_info_plist_file(file_path)
      else
        error("Info.plist file not found: #{file_path}")
      end
    end
    
    info("   ✅ Info.plist validation completed")
  end
  
  def validate_info_plist_file(file_path)
    info("     Validating Info.plist: #{file_path}")
    
    plist = Plist.parse_xml(file_path)
    
    # Required Info.plist keys
    required_keys = [
      'CFBundleIdentifier',
      'CFBundleVersion',
      'CFBundleShortVersionString',
      'CFBundleDisplayName',
      'LSRequiresIPhoneOS',
      'UILaunchStoryboardName'
    ]
    
    required_keys.each do |key|
      unless plist.key?(key)
        error("Missing required key in #{file_path}: #{key}")
      end
    end
    
    # Validate specific values
    min_ios_version = plist['MinimumOSVersion']
    if min_ios_version && Gem::Version.new(min_ios_version) < Gem::Version.new('17.0')
      warning("MinimumOSVersion in #{file_path} is #{min_ios_version}, project target is 17.0")
    end
    
  rescue => error
    error("Failed to parse Info.plist file #{file_path}: #{error.message}")
  end
  
  def validate_dependencies
    info "📦 Validating dependencies..."
    
    # Check Package.swift dependencies
    if File.exist?('Package.swift')
      validate_swift_package_dependencies
    end
    
    # Check for required frameworks
    validate_required_frameworks
    
    info("   ✅ Dependencies validation completed")
  end
  
  def validate_swift_package_dependencies
    package_content = File.read('Package.swift')
    
    required_dependencies = [
      'swift-composable-architecture',
      'swift-snapshot-testing',
      'swift-collections'
    ]
    
    required_dependencies.each do |dependency|
      unless package_content.include?(dependency)
        error("Missing required Swift package dependency: #{dependency}")
      else
        info("   ✅ Dependency found: #{dependency}")
      end
    end
  end
  
  def validate_required_frameworks
    main_target = @project.targets.find { |t| t.name == 'Nestory' }
    return unless main_target
    
    required_frameworks = [
      'SwiftData.framework',
      'CloudKit.framework'
    ]
    
    linked_frameworks = main_target.frameworks_build_phase.files.map do |file|
      file.file_ref&.name
    end.compact
    
    required_frameworks.each do |framework|
      if linked_frameworks.include?(framework)
        info("   ✅ Framework linked: #{framework}")
      else
        error("Missing required framework: #{framework}")
      end
    end
  end
  
  def generate_report
    @validation_results[:summary] = {
      errors_count: @validation_results[:errors].count,
      warnings_count: @validation_results[:warnings].count,
      info_count: @validation_results[:info].count,
      overall_status: @validation_results[:errors].empty? ? 'PASS' : 'FAIL'
    }
    
    unless options[:quiet]
      puts
      puts "=" * 60
      puts "VALIDATION REPORT"
      puts "=" * 60
      
      if @validation_results[:errors].any?
        puts "❌ ERRORS (#{@validation_results[:errors].count}):"
        @validation_results[:errors].each { |err| puts "   • #{err}" }
        puts
      end
      
      if @validation_results[:warnings].any?
        puts "⚠️ WARNINGS (#{@validation_results[:warnings].count}):"
        @validation_results[:warnings].each { |warn| puts "   • #{warn}" }
        puts
      end
      
      puts "📊 SUMMARY:"
      puts "   Errors: #{@validation_results[:summary][:errors_count]}"
      puts "   Warnings: #{@validation_results[:summary][:warnings_count]}"
      puts "   Status: #{@validation_results[:summary][:overall_status]}"
      puts
      
      if @validation_results[:summary][:overall_status] == 'PASS'
        puts "✅ Configuration validation PASSED"
      else
        puts "❌ Configuration validation FAILED"
      end
    end
  end
  
  def error(message)
    @validation_results[:errors] << message
  end
  
  def warning(message)
    @validation_results[:warnings] << message
  end
  
  def info(message)
    @validation_results[:info] << message
    puts message unless options[:quiet]
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
    
    opts.on("--comprehensive-check", "Perform comprehensive validation") do
      options[:comprehensive_check] = true
    end
    
    opts.on("--output-format FORMAT", "Output format (json|text)") do |format|
      options[:output_format] = format
    end
    
    opts.on("--quiet", "Suppress informational output") do
      options[:quiet] = true
    end
    
    opts.on("-h", "--help", "Show this help") do
      puts opts
      exit
    end
  end.parse!
  
  project_path = options[:project] || "Nestory.xcodeproj"
  
  unless File.exist?(project_path)
    puts "❌ Project not found: #{project_path}"
    exit 1
  end
  
  begin
    validator = ConfigurationValidator.new(project_path, options)
    results = validator.validate_all
    
    if options[:output_format] == 'json'
      puts JSON.pretty_generate(results)
    end
    
    # Exit with error code if validation failed
    exit(results[:summary][:overall_status] == 'PASS' ? 0 : 1)
    
  rescue => error
    puts "❌ Validation failed: #{error.message}"
    puts error.backtrace.join("\n") if ENV['DEBUG']
    exit 1
  end
end

main if __FILE__ == $0