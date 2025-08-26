#!/usr/bin/env ruby

# =============================================================================
# ENTERPRISE FRAMEWORK CONFIGURATION SCRIPT
# Dynamic linking and framework management for Nestory's enterprise setup
# =============================================================================

require 'xcodeproj'
require 'optparse'
require 'json'
require 'pathname'

class FrameworkConfigurator
  attr_reader :project_path, :options
  
  def initialize(project_path, options = {})
    @project_path = project_path
    @options = options
    @project = nil
  end
  
  def configure_all_frameworks
    puts "🔗 Configuring dynamic frameworks and linking..."
    puts "Project: #{project_path}"
    puts "Options: #{options.keys.join(', ')}"
    puts
    
    load_project
    configure_dynamic_frameworks if options[:enable_dynamic_frameworks]
    configure_bitcode_settings if options[:enable_bitcode]
    configure_framework_search_paths
    configure_rpath_settings if options[:configure_rpath_settings]
    add_required_frameworks
    optimize_linking_settings
    save_project
    
    puts "✅ Framework configuration completed successfully"
  end
  
  private
  
  def load_project
    puts "📖 Loading Xcode project..."
    @project = Xcodeproj::Project.open(project_path)
    puts "   Loaded project: #{@project.root_object.name}"
  end
  
  def configure_dynamic_frameworks
    puts "🔗 Configuring dynamic frameworks..."
    
    @project.targets.each do |target|
      next unless target.product_type == 'com.apple.product-type.application'
      
      puts "   Configuring target: #{target.name}"
      
      target.build_configurations.each do |config|
        settings = config.build_settings
        
        # Enable dynamic framework support
        settings['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = 'YES'
        settings['DEFINES_MODULE'] = 'YES'
        settings['DYNAMIC_LIBRARY_INSTALL_NAME_BASE'] = '@rpath'
        
        # Configure module settings
        settings['MODULEMAP_FILE'] = ''
        settings['PRODUCT_MODULE_NAME'] = target.name
        
        # Framework versioning
        settings['VERSIONING_SYSTEM'] = 'apple-generic'
        settings['CURRENT_PROJECT_VERSION'] = '1'
        
        puts "     ✅ Dynamic frameworks configured for #{config.name}"
      end
    end
    
    puts "   ✅ Dynamic frameworks configuration completed"
  end
  
  def configure_bitcode_settings
    puts "📱 Configuring Bitcode settings..."
    
    @project.targets.each do |target|
      target.build_configurations.each do |config|
        settings = config.build_settings
        
        if options[:enable_bitcode]
          settings['ENABLE_BITCODE'] = 'YES'
          settings['BITCODE_GENERATION_MODE'] = config.name == 'Debug' ? 'marker' : 'bitcode'
          puts "     ✅ Bitcode enabled for #{target.name} #{config.name}"
        else
          settings['ENABLE_BITCODE'] = 'NO'
          puts "     ✅ Bitcode disabled for #{target.name} #{config.name}"
        end
      end
    end
    
    puts "   ✅ Bitcode configuration completed"
  end
  
  def configure_framework_search_paths
    puts "🔍 Configuring framework search paths..."
    
    # Parse framework paths from options
    custom_paths = if options[:framework_paths].is_a?(String)
      options[:framework_paths].split(':').reject(&:empty?)
    else
      options[:framework_paths] || []
    end
    
    @project.targets.each do |target|
      next unless target.product_type == 'com.apple.product-type.application'
      
      target.build_configurations.each do |config|
        settings = config.build_settings
        
        # Standard framework search paths
        framework_search_paths = [
          '$(inherited)',
          '$(PROJECT_DIR)',
          '$(PLATFORM_DIR)/Developer/Library/Frameworks'
        ]
        
        # Add custom paths
        framework_search_paths.concat(custom_paths)
        
        # Remove duplicates while preserving order
        framework_search_paths.uniq!
        
        settings['FRAMEWORK_SEARCH_PATHS'] = framework_search_paths
        
        puts "     ✅ Framework search paths configured for #{target.name} #{config.name}"
        puts "       Paths: #{framework_search_paths.join(', ')}"
      end
    end
    
    puts "   ✅ Framework search paths configuration completed"
  end
  
  def configure_rpath_settings
    puts "🛤️ Configuring RPATH settings..."
    
    @project.targets.each do |target|
      target.build_configurations.each do |config|
        settings = config.build_settings
        
        # Configure runpath search paths
        runpath_search_paths = [
          '$(inherited)',
          '@executable_path/Frameworks'
        ]
        
        # Add loader path for frameworks
        if target.product_type != 'com.apple.product-type.application'
          runpath_search_paths << '@loader_path/Frameworks'
        end
        
        settings['LD_RUNPATH_SEARCH_PATHS'] = runpath_search_paths
        
        # Configure install name for libraries
        if target.product_type.include?('library') || target.product_type.include?('framework')
          settings['INSTALL_PATH'] = '@rpath'
          settings['SKIP_INSTALL'] = 'YES'
        end
        
        puts "     ✅ RPATH configured for #{target.name} #{config.name}"
      end
    end
    
    puts "   ✅ RPATH configuration completed"
  end
  
  def add_required_frameworks
    puts "📚 Adding required frameworks..."
    
    # Define required frameworks for different target types
    framework_requirements = {
      main_app: [
        { name: 'SwiftData.framework', source_tree: 'SDKROOT' },
        { name: 'CloudKit.framework', source_tree: 'SDKROOT' },
        { name: 'UIKit.framework', source_tree: 'SDKROOT' },
        { name: 'Foundation.framework', source_tree: 'SDKROOT' },
        { name: 'SwiftUI.framework', source_tree: 'SDKROOT' },
        { name: 'Vision.framework', source_tree: 'SDKROOT' },
        { name: 'VisionKit.framework', source_tree: 'SDKROOT' },
        { name: 'AVFoundation.framework', source_tree: 'SDKROOT' },
        { name: 'PDFKit.framework', source_tree: 'SDKROOT' },
        { name: 'StoreKit.framework', source_tree: 'SDKROOT' }
      ],
      ui_tests: [
        { name: 'XCTest.framework', source_tree: 'SDKROOT' },
        { name: 'UIKit.framework', source_tree: 'SDKROOT' }
      ],
      unit_tests: [
        { name: 'XCTest.framework', source_tree: 'SDKROOT' }
      ]
    }
    
    @project.targets.each do |target|
      framework_list = determine_required_frameworks(target, framework_requirements)
      
      if framework_list&.any?
        add_frameworks_to_target(target, framework_list)
      end
    end
    
    puts "   ✅ Required frameworks added"
  end
  
  def determine_required_frameworks(target, requirements)
    case target.name
    when 'Nestory'
      requirements[:main_app]
    when /UITests$/
      requirements[:ui_tests]
    when /Tests$/
      requirements[:unit_tests]
    else
      nil
    end
  end
  
  def add_frameworks_to_target(target, frameworks)
    puts "   Adding frameworks to #{target.name}..."
    
    frameworks_group = @project.frameworks_group
    existing_frameworks = target.frameworks_build_phase.files.map { |f| f.file_ref&.name }.compact
    
    frameworks.each do |framework_config|
      framework_name = framework_config[:name]
      
      # Skip if framework already exists
      if existing_frameworks.include?(framework_name)
        puts "     ✅ #{framework_name} already linked"
        next
      end
      
      # Create framework reference
      framework_ref = frameworks_group.new_file(framework_name)
      framework_ref.source_tree = framework_config[:source_tree]
      
      # Add to frameworks build phase
      target.frameworks_build_phase.add_file_reference(framework_ref)
      
      puts "     ✅ Added #{framework_name}"
    end
  end
  
  def optimize_linking_settings
    puts "⚡ Optimizing linking settings..."
    
    @project.targets.each do |target|
      target.build_configurations.each do |config|
        settings = config.build_settings
        
        # Optimize linking for different configurations
        if config.name == 'Debug'
          configure_debug_linking(settings, target.name)
        elsif config.name == 'Release'
          configure_release_linking(settings, target.name)
        end
      end
    end
    
    puts "   ✅ Linking optimization completed"
  end
  
  def configure_debug_linking(settings, target_name)
    puts "     Optimizing debug linking for #{target_name}..."
    
    # Debug linking optimizations
    settings['GCC_OPTIMIZATION_LEVEL'] = '0'
    settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Onone'
    
    # Faster debug linking
    settings['LD_RUNPATH_SEARCH_PATHS'] = [
      '$(inherited)',
      '@executable_path/Frameworks',
      '@loader_path/Frameworks'
    ]
    
    # Debug symbol settings
    settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf'
    settings['GCC_GENERATE_DEBUGGING_SYMBOLS'] = 'YES'
    
    # Reduce link time in debug
    settings['DEAD_CODE_STRIPPING'] = 'NO'
    settings['PRESERVE_DEAD_CODE_INITS_AND_TERMS'] = 'YES'
  end
  
  def configure_release_linking(settings, target_name)
    puts "     Optimizing release linking for #{target_name}..."
    
    # Release linking optimizations
    settings['GCC_OPTIMIZATION_LEVEL'] = 's'  # Optimize for size
    settings['SWIFT_OPTIMIZATION_LEVEL'] = '-O'
    
    # Release symbol settings
    settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf-with-dsym'
    settings['GCC_GENERATE_DEBUGGING_SYMBOLS'] = 'YES'
    
    # Enable dead code stripping
    settings['DEAD_CODE_STRIPPING'] = 'YES'
    settings['PRESERVE_DEAD_CODE_INITS_AND_TERMS'] = 'NO'
    
    # Link-time optimizations
    settings['LLVM_LTO'] = 'YES_THIN'  # Thin LTO for faster builds
    settings['STRIP_INSTALLED_PRODUCT'] = 'YES'
    settings['STRIP_STYLE'] = 'all'
    
    # Symbol visibility
    settings['GCC_SYMBOLS_PRIVATE_EXTERN'] = 'YES'
    settings['GCC_INLINES_ARE_PRIVATE_EXTERN'] = 'YES'
  end
  
  def save_project
    puts "💾 Saving project changes..."
    @project.save
    puts "   ✅ Project saved"
  end
end

# =============================================================================
# FRAMEWORK VALIDATION UTILITIES
# =============================================================================

class FrameworkValidator
  def self.validate_frameworks(project_path)
    puts "🔍 Validating framework configuration..."
    
    project = Xcodeproj::Project.open(project_path)
    validation_results = {
      errors: [],
      warnings: [],
      info: []
    }
    
    project.targets.each do |target|
      validate_target_frameworks(target, validation_results)
    end
    
    display_validation_results(validation_results)
    validation_results[:errors].empty?
  end
  
  private
  
  def self.validate_target_frameworks(target, results)
    # Check for missing required frameworks
    required_frameworks = get_required_frameworks_for_target(target)
    linked_frameworks = get_linked_frameworks(target)
    
    missing_frameworks = required_frameworks - linked_frameworks
    missing_frameworks.each do |framework|
      results[:errors] << "#{target.name}: Missing required framework: #{framework}"
    end
    
    # Check for unnecessary frameworks
    unnecessary_frameworks = linked_frameworks - required_frameworks - get_optional_frameworks
    unnecessary_frameworks.each do |framework|
      results[:warnings] << "#{target.name}: Unnecessary framework linked: #{framework}"
    end
    
    # Validate framework search paths
    target.build_configurations.each do |config|
      framework_paths = config.build_settings['FRAMEWORK_SEARCH_PATHS']
      if framework_paths.nil? || framework_paths.empty?
        results[:warnings] << "#{target.name} #{config.name}: No framework search paths configured"
      end
    end
  end
  
  def self.get_required_frameworks_for_target(target)
    case target.name
    when 'Nestory'
      %w[SwiftData.framework CloudKit.framework UIKit.framework Foundation.framework]
    when /UITests$/
      %w[XCTest.framework UIKit.framework]
    when /Tests$/
      %w[XCTest.framework]
    else
      %w[Foundation.framework]
    end
  end
  
  def self.get_linked_frameworks(target)
    target.frameworks_build_phase.files.map { |f| f.file_ref&.name }.compact
  end
  
  def self.get_optional_frameworks
    %w[
      SwiftUI.framework
      Vision.framework
      VisionKit.framework
      AVFoundation.framework
      PDFKit.framework
      StoreKit.framework
    ]
  end
  
  def self.display_validation_results(results)
    puts
    
    if results[:errors].any?
      puts "❌ Framework Validation Errors:"
      results[:errors].each { |error| puts "   • #{error}" }
      puts
    end
    
    if results[:warnings].any?
      puts "⚠️ Framework Validation Warnings:"
      results[:warnings].each { |warning| puts "   • #{warning}" }
      puts
    end
    
    if results[:info].any?
      puts "ℹ️ Framework Information:"
      results[:info].each { |info| puts "   • #{info}" }
      puts
    end
    
    if results[:errors].empty? && results[:warnings].empty?
      puts "✅ Framework validation passed"
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
    
    opts.on("--enable-dynamic-frameworks", "Enable dynamic framework support") do
      options[:enable_dynamic_frameworks] = true
    end
    
    opts.on("--enable-bitcode", "Enable Bitcode") do
      options[:enable_bitcode] = true
    end
    
    opts.on("--framework-paths PATHS", "Colon-separated framework search paths") do |paths|
      options[:framework_paths] = paths
    end
    
    opts.on("--configure-rpath-settings", "Configure RPATH settings") do
      options[:configure_rpath_settings] = true
    end
    
    opts.on("--validate", "Validate framework configuration") do
      options[:validate] = true
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
    if options[:validate]
      success = FrameworkValidator.validate_frameworks(project_path)
      exit(success ? 0 : 1)
    else
      configurator = FrameworkConfigurator.new(project_path, options)
      configurator.configure_all_frameworks
      
      puts
      puts "🎉 Framework configuration completed successfully!"
      puts
      puts "Configuration applied:"
      puts "  Dynamic frameworks: #{options[:enable_dynamic_frameworks] ? 'Enabled' : 'Disabled'}"
      puts "  Bitcode: #{options[:enable_bitcode] ? 'Enabled' : 'Disabled'}"
      puts "  RPATH settings: #{options[:configure_rpath_settings] ? 'Configured' : 'Skipped'}"
      
      if options[:framework_paths]
        puts "  Custom framework paths: #{options[:framework_paths]}"
      end
    end
    
  rescue => error
    puts "❌ Framework configuration failed: #{error.message}"
    puts error.backtrace.join("\n") if ENV['DEBUG']
    exit 1
  end
end

main if __FILE__ == $0