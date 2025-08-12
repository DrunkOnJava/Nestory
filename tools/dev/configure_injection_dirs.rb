#!/usr/bin/env ruby

# Script to configure INJECTION_DIRECTORIES environment variable in Xcode project
# This ensures InjectionNext watches the correct directory for hot reload

require 'xcodeproj'

project_path = '../../Nestory.xcodeproj'
project_dir = '/Users/griffin/Projects/Nestory'

# Open the project
project = Xcodeproj::Project.open(project_path)

# Find the Nestory-Dev scheme
scheme_path = "#{project_path}/xcshareddata/xcschemes/Nestory-Dev.xcscheme"

if File.exist?(scheme_path)
  puts "✅ Found Nestory-Dev scheme"
  
  # Parse the scheme
  scheme = Xcodeproj::XCScheme.new(scheme_path)
  
  # Get or create launch action
  launch_action = scheme.launch_action
  
  # Add environment variable
  launch_action.environment_variables ||= {}
  launch_action.environment_variables['INJECTION_DIRECTORIES'] = project_dir
  launch_action.environment_variables['CLOUDKIT_CONTAINER'] = 'iCloud.com.nestory.app.dev'
  
  # Save the scheme
  scheme.save!
  
  puts "✅ Added INJECTION_DIRECTORIES = #{project_dir}"
  puts "✅ Scheme updated successfully!"
else
  puts "❌ Nestory-Dev scheme not found"
  puts "Looking for available schemes..."
  
  # List available schemes
  schemes_dir = "#{project_path}/xcshareddata/xcschemes"
  if Dir.exist?(schemes_dir)
    schemes = Dir.glob("#{schemes_dir}/*.xcscheme").map { |f| File.basename(f, '.xcscheme') }
    puts "Available schemes: #{schemes.join(', ')}"
  end
end

# Also update the project's build settings directly
project.targets.each do |target|
  if target.name == "Nestory"
    puts "\n📱 Configuring #{target.name} target..."
    
    target.build_configurations.each do |config|
      if config.name == "Debug"
        # We can't set env vars in build settings, but we can ensure other settings are correct
        puts "  ✅ Debug configuration found"
        
        # Verify -interposable flag is set
        other_ldflags = config.build_settings['OTHER_LDFLAGS'] || []
        if other_ldflags.is_a?(String)
          other_ldflags = other_ldflags.split(' ')
        end
        
        unless other_ldflags.include?('-interposable')
          other_ldflags << '-Xlinker'
          other_ldflags << '-interposable'
          config.build_settings['OTHER_LDFLAGS'] = other_ldflags
          puts "  ✅ Added -interposable linker flag"
        else
          puts "  ✅ -interposable flag already set"
        end
      end
    end
  end
end

# Save the project
project.save

puts "\n🎉 Configuration complete!"
puts "🔄 Please rebuild and run the app in Xcode"
puts "💉 InjectionNext will now watch: #{project_dir}"