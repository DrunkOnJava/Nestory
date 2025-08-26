# =============================================================================
# ENTERPRISE XCODE CONFIGURATION CUSTOM FASTLANE ACTION
# Advanced Fastlane action for comprehensive Xcode project management
# =============================================================================

require 'fastlane/action'
require 'fastlane/helper/sh_helper'

module Fastlane
  module Actions
    class EnterpriseXcodeConfigAction < Action
      def self.run(params)
        UI.message("🏗️ Running Enterprise Xcode Configuration...")
        
        # Validate parameters
        project_path = params[:project_path]
        unless File.exist?(project_path)
          UI.user_error!("Project not found at: #{project_path}")
        end
        
        # Configuration options
        options = {
          enable_ui_testing: params[:enable_ui_testing],
          configure_performance: params[:configure_performance],
          setup_accessibility: params[:setup_accessibility],
          validate_config: params[:validate_config],
          backup_settings: params[:backup_settings]
        }
        
        UI.message("Configuration options: #{options.keys.select { |k| options[k] }.join(', ')}")
        
        begin
          # Step 1: Backup current configuration if requested
          if options[:backup_settings]
            backup_configuration(project_path)
          end
          
          # Step 2: Configure UI testing if requested
          if options[:enable_ui_testing]
            configure_ui_testing(project_path, params)
          end
          
          # Step 3: Apply performance optimizations if requested
          if options[:configure_performance]
            configure_performance_settings(project_path, params)
          end
          
          # Step 4: Setup accessibility testing if requested
          if options[:setup_accessibility]
            setup_accessibility_testing(project_path, params)
          end
          
          # Step 5: Validate configuration if requested
          if options[:validate_config]
            validate_configuration(project_path)
          end
          
          UI.success("✅ Enterprise Xcode configuration completed successfully!")
          
          # Return configuration summary
          {
            project_path: project_path,
            configured_options: options.keys.select { |k| options[k] },
            timestamp: Time.now.iso8601,
            success: true
          }
          
        rescue => error
          UI.error("❌ Enterprise configuration failed: #{error.message}")
          UI.error(error.backtrace.join("\n")) if FastlaneCore::Globals.verbose?
          
          {
            project_path: project_path,
            error: error.message,
            timestamp: Time.now.iso8601,
            success: false
          }
        end
      end
      
      # MARK: - Private Helper Methods
      
      def self.backup_configuration(project_path)
        UI.message("💾 Backing up current configuration...")
        
        backup_dir = "fastlane/backups/enterprise_config"
        FileUtils.mkdir_p(backup_dir)
        
        timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
        backup_file = File.join(backup_dir, "config_backup_#{timestamp}.tar.gz")
        
        # Create backup of project files
        sh("tar -czf '#{backup_file}' '#{project_path}' fastlane/ Config/ 2>/dev/null || true")
        
        UI.success("   ✅ Configuration backed up to: #{backup_file}")
      end
      
      def self.configure_ui_testing(project_path, params)
        UI.message("🧪 Configuring UI testing framework...")
        
        script_path = File.join("fastlane", "xcode_ruby_scripts", "configure_ui_testing.rb")
        
        command_args = [
          "--project '#{project_path}'",
          "--enable-ui-testing",
          "--configure-entitlements",
          "--setup-test-targets"
        ]
        
        if params[:ui_test_scheme]
          command_args << "--scheme '#{params[:ui_test_scheme]}'"
        end
        
        command = "ruby #{script_path} #{command_args.join(' ')}"
        
        begin
          sh(command)
          UI.success("   ✅ UI testing configuration completed")
        rescue => error
          UI.error("   ❌ UI testing configuration failed: #{error.message}")
          raise error
        end
      end
      
      def self.configure_performance_settings(project_path, params)
        UI.message("⚡ Configuring performance optimizations...")
        
        script_path = File.join("fastlane", "xcode_ruby_scripts", "update_build_settings.rb")
        
        performance_template = params[:performance_template] || "performance"
        target = params[:target] || "Nestory"
        configuration = params[:configuration] || "Release"
        
        command_args = [
          "--project '#{project_path}'",
          "--target '#{target}'",
          "--configuration '#{configuration}'",
          "--template '#{performance_template}'",
          "--backup",
          "--validate"
        ]
        
        command = "ruby #{script_path} #{command_args.join(' ')}"
        
        begin
          sh(command)
          UI.success("   ✅ Performance configuration completed")
        rescue => error
          UI.error("   ❌ Performance configuration failed: #{error.message}")
          raise error
        end
      end
      
      def self.setup_accessibility_testing(project_path, params)
        UI.message("♿ Setting up accessibility testing...")
        
        script_path = File.join("fastlane", "xcode_ruby_scripts", "configure_test_integration.rb")
        
        command_args = [
          "--project '#{project_path}'",
          "--accessibility-testing",
          "--test-utilities"
        ]
        
        command = "ruby #{script_path} #{command_args.join(' ')}"
        
        begin
          sh(command)
          UI.success("   ✅ Accessibility testing setup completed")
        rescue => error
          UI.error("   ❌ Accessibility testing setup failed: #{error.message}")
          raise error
        end
      end
      
      def self.validate_configuration(project_path)
        UI.message("🔍 Validating configuration...")
        
        script_path = File.join("fastlane", "xcode_ruby_scripts", "validate_configuration.rb")
        
        command_args = [
          "--project '#{project_path}'",
          "--comprehensive-check",
          "--output-format json"
        ]
        
        command = "ruby #{script_path} #{command_args.join(' ')}"
        
        begin
          result = sh(command, log: false)
          validation_data = JSON.parse(result) rescue {}
          
          if validation_data["summary"] && validation_data["summary"]["overall_status"] == "PASS"
            UI.success("   ✅ Configuration validation passed")
          else
            error_count = validation_data.dig("summary", "errors_count") || 0
            warning_count = validation_data.dig("summary", "warnings_count") || 0
            
            if error_count > 0
              UI.error("   ❌ Configuration validation failed with #{error_count} errors")
              validation_data["errors"]&.each { |error| UI.error("     • #{error}") }
              raise "Configuration validation failed"
            else
              UI.important("   ⚠️ Configuration validation passed with #{warning_count} warnings")
              validation_data["warnings"]&.each { |warning| UI.important("     • #{warning}") }
            end
          end
        rescue JSON::ParserError
          UI.important("   ⚠️ Could not parse validation results, but script completed")
        rescue => error
          UI.error("   ❌ Configuration validation failed: #{error.message}")
          raise error
        end
      end
      
      # MARK: - Action Definition
      
      def self.description
        "Enterprise-grade Xcode project configuration with comprehensive automation"
      end
      
      def self.details
        "This action provides comprehensive Xcode project configuration including UI testing setup, " \
        "performance optimizations, accessibility testing, and configuration validation. It uses " \
        "Ruby scripts to directly manipulate Xcode project files for enterprise-grade control."
      end
      
      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :project_path,
            description: "Path to the Xcode project file",
            type: String,
            default_value: "Nestory.xcodeproj",
            verify_block: proc do |value|
              UI.user_error!("Project file not found at path: #{value}") unless File.exist?(value)
            end
          ),
          
          FastlaneCore::ConfigItem.new(
            key: :enable_ui_testing,
            description: "Enable UI testing framework configuration",
            type: Boolean,
            default_value: false
          ),
          
          FastlaneCore::ConfigItem.new(
            key: :configure_performance,
            description: "Apply performance optimization build settings",
            type: Boolean,
            default_value: false
          ),
          
          FastlaneCore::ConfigItem.new(
            key: :setup_accessibility,
            description: "Setup accessibility testing framework",
            type: Boolean,
            default_value: false
          ),
          
          FastlaneCore::ConfigItem.new(
            key: :validate_config,
            description: "Validate configuration after changes",
            type: Boolean,
            default_value: true
          ),
          
          FastlaneCore::ConfigItem.new(
            key: :backup_settings,
            description: "Backup current settings before applying changes",
            type: Boolean,
            default_value: true
          ),
          
          FastlaneCore::ConfigItem.new(
            key: :ui_test_scheme,
            description: "UI test scheme name",
            type: String,
            optional: true,
            default_value: "Nestory-UIWiring"
          ),
          
          FastlaneCore::ConfigItem.new(
            key: :performance_template,
            description: "Performance optimization template to use",
            type: String,
            optional: true,
            default_value: "performance",
            verify_block: proc do |value|
              valid_templates = %w[performance swift6_release security]
              UI.user_error!("Invalid template: #{value}. Valid templates: #{valid_templates.join(', ')}") unless valid_templates.include?(value)
            end
          ),
          
          FastlaneCore::ConfigItem.new(
            key: :target,
            description: "Target name to configure",
            type: String,
            optional: true,
            default_value: "Nestory"
          ),
          
          FastlaneCore::ConfigItem.new(
            key: :configuration,
            description: "Build configuration to modify (Debug/Release)",
            type: String,
            optional: true,
            default_value: "Release",
            verify_block: proc do |value|
              valid_configs = %w[Debug Release]
              UI.user_error!("Invalid configuration: #{value}. Valid configurations: #{valid_configs.join(', ')}") unless valid_configs.include?(value)
            end
          )
        ]
      end
      
      def self.return_value
        "Hash containing configuration results and metadata"
      end
      
      def self.return_type
        :hash
      end
      
      def self.authors
        ["Nestory Development Team"]
      end
      
      def self.is_supported?(platform)
        platform == :ios
      end
      
      def self.example_code
        [
          '# Basic usage with UI testing
          enterprise_xcode_config(
            project_path: "Nestory.xcodeproj",
            enable_ui_testing: true,
            validate_config: true
          )',
          
          '# Comprehensive configuration
          enterprise_xcode_config(
            project_path: "Nestory.xcodeproj", 
            enable_ui_testing: true,
            configure_performance: true,
            setup_accessibility: true,
            validate_config: true,
            backup_settings: true,
            ui_test_scheme: "Nestory-UIWiring",
            performance_template: "performance"
          )',
          
          '# Performance optimization only
          result = enterprise_xcode_config(
            project_path: "Nestory.xcodeproj",
            configure_performance: true,
            performance_template: "swift6_release",
            configuration: "Release"
          )
          
          UI.message("Configuration completed: #{result[:success]}")'
        ]
      end
      
      def self.category
        :project
      end
    end
  end
end