#!/usr/bin/env ruby

# =============================================================================
# ENTERPRISE UI TESTING CONFIGURATION SCRIPT
# Comprehensive Xcode project configuration for Nestory's UI testing framework
# =============================================================================

require 'xcodeproj'
require 'optparse'
require 'json'
require 'plist'
require 'pathname'

class UITestingConfigurator
  attr_reader :project_path, :scheme_name, :options
  
  def initialize(project_path, scheme_name, options = {})
    @project_path = project_path
    @scheme_name = scheme_name
    @options = options
    @project = nil
  end
  
  def configure_all
    puts "🔧 Configuring Xcode project for enterprise UI testing..."
    puts "Project: #{project_path}"
    puts "Scheme: #{scheme_name}"
    puts
    
    load_project
    configure_ui_testing_settings
    setup_test_targets if options[:setup_test_targets]
    configure_entitlements if options[:configure_entitlements]
    setup_schemes
    configure_build_phases
    save_project
    
    puts "✅ UI testing configuration completed successfully"
  end
  
  private
  
  def load_project
    puts "📖 Loading Xcode project..."
    @project = Xcodeproj::Project.open(project_path)
    puts "   Loaded project: #{@project.root_object.name}"
  end
  
  def configure_ui_testing_settings
    puts "⚙️ Configuring UI testing build settings..."
    
    main_target = find_main_target
    ui_test_target = find_or_create_ui_test_target
    
    # Configure main target for UI testing
    configure_main_target_for_testing(main_target)
    
    # Configure UI test target
    configure_ui_test_target(ui_test_target)
    
    puts "   ✅ Build settings configured"
  end
  
  def find_main_target
    main_target = @project.targets.find { |t| t.name == "Nestory" }
    raise "Main target 'Nestory' not found" unless main_target
    main_target
  end
  
  def find_or_create_ui_test_target
    ui_test_target = @project.targets.find { |t| t.name == "NestoryUITests" }
    
    unless ui_test_target
      puts "   Creating NestoryUITests target..."
      ui_test_target = @project.new_target(:ui_test_bundle, "NestoryUITests", :ios, "17.0")
    end
    
    ui_test_target
  end
  
  def configure_main_target_for_testing(target)
    puts "   Configuring main target: #{target.name}"
    
    target.build_configurations.each do |config|
      settings = config.build_settings
      
      # Enable UI testing support
      settings['ENABLE_TESTABILITY'] = 'YES'
      settings['UI_TEST_FRAMEWORK_ENABLED'] = 'YES'
      settings['ENABLE_TESTING_SEARCH_PATHS'] = 'YES'
      
      # Swift 6.0 with UI testing compatibility
      settings['SWIFT_VERSION'] = '6.0'
      settings['SWIFT_STRICT_CONCURRENCY'] = 'minimal' # Reduced for UI tests
      settings['SWIFT_TREAT_WARNINGS_AS_ERRORS'] = 'NO'
      
      # Framework search paths for UI testing
      framework_search_paths = [
        '$(inherited)',
        '$(PLATFORM_DIR)/Developer/Library/Frameworks'
      ]
      settings['FRAMEWORK_SEARCH_PATHS'] = framework_search_paths
      
      # Runpath search paths
      runpath_search_paths = [
        '$(inherited)',
        '@executable_path/Frameworks',
        '@loader_path/Frameworks'
      ]
      settings['LD_RUNPATH_SEARCH_PATHS'] = runpath_search_paths
      
      # Performance and debugging settings for UI testing
      if config.name == 'Debug'
        settings['SWIFT_COMPILATION_MODE'] = 'singlefile'
        settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Onone'
        settings['GCC_OPTIMIZATION_LEVEL'] = '0'
        settings['ONLY_ACTIVE_ARCH'] = 'YES'
      end
    end
  end
  
  def configure_ui_test_target(target)
    puts "   Configuring UI test target: #{target.name}"
    
    target.build_configurations.each do |config|
      settings = config.build_settings
      
      # Basic UI test configuration
      settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.drunkonjava.nestory.UITests'
      settings['TEST_TARGET_NAME'] = 'Nestory'
      settings['GENERATE_INFOPLIST_FILE'] = 'YES'
      
      # Swift configuration for UI tests
      settings['SWIFT_VERSION'] = '6.0'
      settings['SWIFT_STRICT_CONCURRENCY'] = 'minimal'
      settings['SWIFT_TREAT_WARNINGS_AS_ERRORS'] = 'NO'
      
      # UI testing framework settings
      settings['UI_TEST_BUNDLE_ID'] = 'com.drunkonjava.nestory.UITests'
      settings['UI_TEST_FRAMEWORK_ENABLED'] = 'YES'
      settings['ENABLE_TESTING_SEARCH_PATHS'] = 'YES'
      
      # Test host configuration
      settings['TEST_HOST'] = '$(BUILT_PRODUCTS_DIR)/Nestory.app/Nestory'
      settings['BUNDLE_LOADER'] = '$(TEST_HOST)'
      
      # Framework and library paths
      framework_search_paths = [
        '$(inherited)',
        '$(PLATFORM_DIR)/Developer/Library/Frameworks'
      ]
      settings['FRAMEWORK_SEARCH_PATHS'] = framework_search_paths
      
      runpath_search_paths = [
        '$(inherited)',
        '@executable_path/Frameworks',
        '@loader_path/Frameworks'
      ]
      settings['LD_RUNPATH_SEARCH_PATHS'] = runpath_search_paths
      
      # Linker flags for bundle loading
      other_ldflags = [
        '-Xlinker',
        '-bundle_loader',
        '-Xlinker',
        '$(TEST_HOST)'
      ]
      settings['OTHER_LDFLAGS'] = other_ldflags
    end
    
    # Add framework dependencies
    add_ui_test_frameworks(target)
  end
  
  def add_ui_test_frameworks(target)
    puts "   Adding UI testing frameworks..."
    
    frameworks = [
      'XCTest.framework',
      'Foundation.framework',
      'UIKit.framework'
    ]
    
    frameworks_group = @project.frameworks_group
    
    frameworks.each do |framework_name|
      # Skip if framework already exists
      next if target.frameworks_build_phase.files.any? { |file| 
        file.file_ref&.name == framework_name 
      }
      
      framework_ref = frameworks_group.new_file(framework_name)
      framework_ref.source_tree = 'SDKROOT'
      target.frameworks_build_phase.add_file_reference(framework_ref)
    end
  end
  
  def configure_entitlements
    puts "🔐 Configuring entitlements for UI testing..."
    
    # Main app entitlements
    configure_main_entitlements
    
    # UI test entitlements
    configure_ui_test_entitlements
    
    puts "   ✅ Entitlements configured"
  end
  
  def configure_main_entitlements
    entitlements_path = "App-Main/Nestory.entitlements"
    
    if File.exist?(entitlements_path)
      entitlements = Plist.parse_xml(entitlements_path)
    else
      entitlements = {}
    end
    
    # Add UI testing entitlements
    entitlements['com.apple.developer.system.logging'] = true
    entitlements['com.apple.developer.kernel.extended-virtual-addressing'] = true
    
    # CloudKit entitlements for testing
    entitlements['com.apple.developer.icloud-container-identifiers'] = [
      'iCloud.com.drunkonjava.nestory.dev'
    ]
    entitlements['com.apple.developer.icloud-services'] = [
      'CloudKit'
    ]
    
    File.write(entitlements_path, entitlements.to_plist)
  end
  
  def configure_ui_test_entitlements
    entitlements_path = "NestoryUITests/NestoryUITests.entitlements"
    
    # Create directory if it doesn't exist
    FileUtils.mkdir_p(File.dirname(entitlements_path))
    
    entitlements = {
      'com.apple.developer.system.logging' => true,
      'com.apple.security.automation.apple-events' => true,
      'com.apple.developer.kernel.extended-virtual-addressing' => true
    }
    
    File.write(entitlements_path, entitlements.to_plist)
    
    # Add entitlements file to UI test target
    ui_test_target = find_or_create_ui_test_target
    ui_test_target.build_configurations.each do |config|
      config.build_settings['CODE_SIGN_ENTITLEMENTS'] = entitlements_path
    end
  end
  
  def setup_schemes
    puts "📋 Setting up UI testing schemes..."
    
    schemes_dir = File.join(@project.path, 'xcshareddata', 'xcschemes')
    FileUtils.mkdir_p(schemes_dir)
    
    create_ui_wiring_scheme(schemes_dir)
    create_performance_scheme(schemes_dir)
    create_accessibility_scheme(schemes_dir)
    create_smoke_scheme(schemes_dir)
    
    puts "   ✅ Schemes configured"
  end
  
  def create_ui_wiring_scheme(schemes_dir)
    scheme_path = File.join(schemes_dir, 'Nestory-UIWiring.xcscheme')
    
    scheme_content = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <Scheme
         LastUpgradeVersion = "1500"
         version = "1.3">
         <BuildAction
            parallelizeBuildables = "YES"
            buildImplicitDependencies = "YES">
            <BuildActionEntries>
               <BuildActionEntry
                  buildForTesting = "YES"
                  buildForRunning = "YES"
                  buildForProfiling = "YES"
                  buildForArchiving = "YES"
                  buildForAnalyzing = "YES">
                  <BuildableReference
                     BuildableIdentifier = "primary"
                     BlueprintIdentifier = "#{find_main_target.uuid}"
                     BuildableName = "Nestory.app"
                     BlueprintName = "Nestory"
                     ReferencedContainer = "container:Nestory.xcodeproj">
                  </BuildableReference>
               </BuildActionEntry>
               <BuildActionEntry
                  buildForTesting = "YES"
                  buildForRunning = "NO"
                  buildForProfiling = "NO"
                  buildForArchiving = "NO"
                  buildForAnalyzing = "NO">
                  <BuildableReference
                     BuildableIdentifier = "primary"
                     BlueprintIdentifier = "#{find_or_create_ui_test_target.uuid}"
                     BuildableName = "NestoryUITests.xctest"
                     BlueprintName = "NestoryUITests"
                     ReferencedContainer = "container:Nestory.xcodeproj">
                  </BuildableReference>
               </BuildActionEntry>
            </BuildActionEntries>
         </BuildAction>
         <TestAction
            buildConfiguration = "Debug"
            selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
            selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
            shouldUseLaunchSchemeArgsEnv = "YES"
            codeCoverageEnabled = "YES">
            <Testables>
               <TestableReference
                  skipped = "NO"
                  parallelizable = "NO"
                  testExecutionOrdering = "random">
                  <BuildableReference
                     BuildableIdentifier = "primary"
                     BlueprintIdentifier = "#{find_or_create_ui_test_target.uuid}"
                     BuildableName = "NestoryUITests.xctest"
                     BlueprintName = "NestoryUITests"
                     ReferencedContainer = "container:Nestory.xcodeproj">
                  </BuildableReference>
                  <SkippedTests>
                  </SkippedTests>
               </TestableReference>
            </Testables>
            <MacroExpansion>
               <BuildableReference
                  BuildableIdentifier = "primary"
                  BlueprintIdentifier = "#{find_main_target.uuid}"
                  BuildableName = "Nestory.app"
                  BlueprintName = "Nestory"
                  ReferencedContainer = "container:Nestory.xcodeproj">
               </BuildableReference>
            </MacroExpansion>
            <CommandLineArguments>
               <CommandLineArgument
                  argument = "--ui-testing"
                  isEnabled = "YES">
               </CommandLineArgument>
               <CommandLineArgument
                  argument = "--demo-data"
                  isEnabled = "YES">
               </CommandLineArgument>
               <CommandLineArgument
                  argument = "--comprehensive-testing"
                  isEnabled = "YES">
               </CommandLineArgument>
               <CommandLineArgument
                  argument = "--wiring-validation"
                  isEnabled = "YES">
               </CommandLineArgument>
               <CommandLineArgument
                  argument = "--framework-validation"
                  isEnabled = "YES">
               </CommandLineArgument>
            </CommandLineArguments>
            <EnvironmentVariables>
               <EnvironmentVariable
                  key = "UI_WIRING_TEST_MODE"
                  value = "true"
                  isEnabled = "YES">
               </EnvironmentVariable>
               <EnvironmentVariable
                  key = "UI_TEST_FRAMEWORK_ENABLED"
                  value = "true"
                  isEnabled = "YES">
               </EnvironmentVariable>
               <EnvironmentVariable
                  key = "UI_TEST_SCREENSHOT_DIR"
                  value = "~/Desktop/NestoryUIWiringScreenshots"
                  isEnabled = "YES">
               </EnvironmentVariable>
               <EnvironmentVariable
                  key = "UI_TEST_ENABLE_VALIDATION"
                  value = "true"
                  isEnabled = "YES">
               </EnvironmentVariable>
               <EnvironmentVariable
                  key = "UI_TEST_FRAMEWORK_MODE"
                  value = "comprehensive"
                  isEnabled = "YES">
               </EnvironmentVariable>
               <EnvironmentVariable
                  key = "TEST_EXECUTION_TIMEOUT"
                  value = "300"
                  isEnabled = "YES">
               </EnvironmentVariable>
            </EnvironmentVariables>
         </TestAction>
         <LaunchAction
            buildConfiguration = "Debug"
            selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
            selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
            launchStyle = "0"
            useCustomWorkingDirectory = "NO"
            ignoresPersistentStateOnLaunch = "NO"
            debugDocumentVersioning = "YES"
            debugServiceExtension = "internal"
            allowLocationSimulation = "YES">
            <BuildableProductRunnable
               runnableDebuggingMode = "0">
               <BuildableReference
                  BuildableIdentifier = "primary"
                  BlueprintIdentifier = "#{find_main_target.uuid}"
                  BuildableName = "Nestory.app"
                  BlueprintName = "Nestory"
                  ReferencedContainer = "container:Nestory.xcodeproj">
               </BuildableReference>
            </BuildableProductRunnable>
            <EnvironmentVariables>
               <EnvironmentVariable
                  key = "CLOUDKIT_CONTAINER"
                  value = "iCloud.com.drunkonjava.nestory.dev"
                  isEnabled = "YES">
               </EnvironmentVariable>
               <EnvironmentVariable
                  key = "NESTORY_ENVIRONMENT"
                  value = "development"
                  isEnabled = "YES">
               </EnvironmentVariable>
               <EnvironmentVariable
                  key = "API_BASE_URL"
                  value = "https://api-dev.nestory.app"
                  isEnabled = "YES">
               </EnvironmentVariable>
               <EnvironmentVariable
                  key = "FX_API_ENDPOINT"
                  value = "https://fx-dev.nestory.app"
                  isEnabled = "YES">
               </EnvironmentVariable>
            </EnvironmentVariables>
         </LaunchAction>
      </Scheme>
    XML
    
    File.write(scheme_path, scheme_content)
  end
  
  def create_performance_scheme(schemes_dir)
    # Performance testing scheme with Release configuration
    scheme_path = File.join(schemes_dir, 'Nestory-Performance.xcscheme')
    
    scheme_content = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <Scheme
         LastUpgradeVersion = "1500"
         version = "1.3">
         <TestAction
            buildConfiguration = "Release"
            selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
            selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
            shouldUseLaunchSchemeArgsEnv = "YES"
            codeCoverageEnabled = "NO">
            <CommandLineArguments>
               <CommandLineArgument
                  argument = "--performance-testing"
                  isEnabled = "YES">
               </CommandLineArgument>
               <CommandLineArgument
                  argument = "--load-testing"
                  isEnabled = "YES">
               </CommandLineArgument>
               <CommandLineArgument
                  argument = "--memory-profiling"
                  isEnabled = "YES">
               </CommandLineArgument>
            </CommandLineArguments>
            <EnvironmentVariables>
               <EnvironmentVariable
                  key = "PERFORMANCE_TESTING_MODE"
                  value = "true"
                  isEnabled = "YES">
               </EnvironmentVariable>
               <EnvironmentVariable
                  key = "PERFORMANCE_TEST_TIMEOUT"
                  value = "300"
                  isEnabled = "YES">
               </EnvironmentVariable>
               <EnvironmentVariable
                  key = "MEMORY_TEST_THRESHOLD"
                  value = "100MB"
                  isEnabled = "YES">
               </EnvironmentVariable>
               <EnvironmentVariable
                  key = "CPU_TEST_THRESHOLD"
                  value = "80%"
                  isEnabled = "YES">
               </EnvironmentVariable>
            </EnvironmentVariables>
         </TestAction>
      </Scheme>
    XML
    
    File.write(scheme_path, scheme_content)
  end
  
  def create_accessibility_scheme(schemes_dir)
    scheme_path = File.join(schemes_dir, 'Nestory-Accessibility.xcscheme')
    
    scheme_content = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <Scheme
         LastUpgradeVersion = "1500"
         version = "1.3">
         <TestAction
            buildConfiguration = "Debug"
            selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
            selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
            shouldUseLaunchSchemeArgsEnv = "YES"
            codeCoverageEnabled = "YES">
            <CommandLineArguments>
               <CommandLineArgument
                  argument = "--accessibility-testing"
                  isEnabled = "YES">
               </CommandLineArgument>
               <CommandLineArgument
                  argument = "--voice-over-testing"
                  isEnabled = "YES">
               </CommandLineArgument>
               <CommandLineArgument
                  argument = "--contrast-testing"
                  isEnabled = "YES">
               </CommandLineArgument>
            </CommandLineArguments>
            <EnvironmentVariables>
               <EnvironmentVariable
                  key = "ACCESSIBILITY_TESTING_MODE"
                  value = "true"
                  isEnabled = "YES">
               </EnvironmentVariable>
               <EnvironmentVariable
                  key = "ACCESSIBILITY_TEST_MODE"
                  value = "comprehensive"
                  isEnabled = "YES">
               </EnvironmentVariable>
               <EnvironmentVariable
                  key = "VOICE_OVER_ENABLED"
                  value = "true"
                  isEnabled = "YES">
               </EnvironmentVariable>
               <EnvironmentVariable
                  key = "CONTRAST_TESTING_ENABLED"
                  value = "true"
                  isEnabled = "YES">
               </EnvironmentVariable>
            </EnvironmentVariables>
         </TestAction>
      </Scheme>
    XML
    
    File.write(scheme_path, scheme_content)
  end
  
  def create_smoke_scheme(schemes_dir)
    scheme_path = File.join(schemes_dir, 'Nestory-Smoke.xcscheme')
    
    scheme_content = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <Scheme
         LastUpgradeVersion = "1500"
         version = "1.3">
         <TestAction
            buildConfiguration = "Debug"
            selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
            selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
            shouldUseLaunchSchemeArgsEnv = "YES"
            codeCoverageEnabled = "NO">
            <CommandLineArguments>
               <CommandLineArgument
                  argument = "--smoke-testing"
                  isEnabled = "YES">
               </CommandLineArgument>
               <CommandLineArgument
                  argument = "--quick-validation"
                  isEnabled = "YES">
               </CommandLineArgument>
            </CommandLineArguments>
            <EnvironmentVariables>
               <EnvironmentVariable
                  key = "SMOKE_TESTING_MODE"
                  value = "true"
                  isEnabled = "YES">
               </EnvironmentVariable>
               <EnvironmentVariable
                  key = "SMOKE_TEST_TIMEOUT"
                  value = "60"
                  isEnabled = "YES">
               </EnvironmentVariable>
               <EnvironmentVariable
                  key = "QUICK_VALIDATION_MODE"
                  value = "true"
                  isEnabled = "YES">
               </EnvironmentVariable>
            </EnvironmentVariables>
         </TestAction>
      </Scheme>
    XML
    
    File.write(scheme_path, scheme_content)
  end
  
  def configure_build_phases
    puts "🔨 Configuring build phases for UI testing..."
    
    main_target = find_main_target
    ui_test_target = find_or_create_ui_test_target
    
    # Add build phase to collect UI test metrics
    add_ui_test_metrics_phase(main_target)
    
    puts "   ✅ Build phases configured"
  end
  
  def add_ui_test_metrics_phase(target)
    # Check if metrics phase already exists
    existing_phase = target.shell_script_build_phases.find do |phase|
      phase.name == "📊 Collect UI Test Metrics"
    end
    
    return if existing_phase
    
    metrics_phase = target.new_shell_script_build_phase("📊 Collect UI Test Metrics")
    metrics_phase.shell_script = <<~SCRIPT
      # Collect UI test execution metrics
      if [[ "$UI_TEST_FRAMEWORK_ENABLED" == "YES" ]]; then
          echo "Collecting UI test metrics..."
          
          # Create metrics directory
          METRICS_DIR="$BUILT_PRODUCTS_DIR/UITestMetrics"
          mkdir -p "$METRICS_DIR"
          
          # Capture test environment info
          cat > "$METRICS_DIR/test_environment.json" << EOF
      {
        "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
        "xcode_version": "$(xcodebuild -version | head -1)",
        "swift_version": "$SWIFT_VERSION",
        "configuration": "$CONFIGURATION",
        "scheme": "$SCHEME_NAME",
        "ui_test_framework_enabled": "$UI_TEST_FRAMEWORK_ENABLED"
      }
      EOF
          
          echo "UI test metrics collected at: $METRICS_DIR"
      fi
    SCRIPT
    
    metrics_phase.run_only_for_deployment_postprocessing = false
  end
  
  def save_project
    puts "💾 Saving project changes..."
    @project.save
    puts "   ✅ Project saved"
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
    
    opts.on("--scheme NAME", "Scheme name") do |name|
      options[:scheme] = name
    end
    
    opts.on("--enable-ui-testing", "Enable UI testing configuration") do
      options[:enable_ui_testing] = true
    end
    
    opts.on("--configure-entitlements", "Configure entitlements") do
      options[:configure_entitlements] = true
    end
    
    opts.on("--setup-test-targets", "Setup test targets") do
      options[:setup_test_targets] = true
    end
    
    opts.on("-h", "--help", "Show this help") do
      puts opts
      exit
    end
  end.parse!
  
  project_path = options[:project] || "Nestory.xcodeproj"
  scheme_name = options[:scheme] || "Nestory-UIWiring"
  
  unless File.exist?(project_path)
    puts "❌ Project not found: #{project_path}"
    exit 1
  end
  
  begin
    configurator = UITestingConfigurator.new(project_path, scheme_name, options)
    configurator.configure_all
    
    puts
    puts "🎉 UI testing configuration completed successfully!"
    puts
    puts "Next steps:"
    puts "1. Run: xcodegen generate (if using XcodeGen)"
    puts "2. Build project: xcodebuild -scheme #{scheme_name}"
    puts "3. Run UI tests: xcodebuild test -scheme #{scheme_name}"
    
  rescue => error
    puts "❌ Configuration failed: #{error.message}"
    puts error.backtrace.join("\n") if ENV['DEBUG']
    exit 1
  end
end

main if __FILE__ == $0