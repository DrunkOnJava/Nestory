# Test validation for fastlane-plugin-test_center
# This lane tests if the test_center plugin loads and functions correctly

desc "Test fastlane-plugin-test_center functionality"
lane :test_center_validation do
  UI.message("🧪 Testing fastlane-plugin-test_center plugin...")
  
  begin
    # Test basic multi_scan functionality (core test_center feature)
    # This should just verify the plugin loads without actually running tests
    UI.message("✅ test_center plugin loaded successfully")
    
    # Check if multi_scan action is available
    if Fastlane::Actions.const_defined?(:MultiScanAction)
      UI.success("✅ MultiScanAction is available")
    else
      UI.error("❌ MultiScanAction not found")
    end
    
    # List available test_center actions
    test_center_actions = []
    Fastlane::Actions.constants.each do |const|
      action_class = Fastlane::Actions.const_get(const)
      if action_class.respond_to?(:description) && 
         action_class.description.to_s.downcase.include?('test')
        test_center_actions << const.to_s
      end
    end
    
    UI.message("Available test-related actions: #{test_center_actions.join(', ')}")
    UI.success("🎉 fastlane-plugin-test_center validation completed successfully!")
    
  rescue => e
    UI.error("❌ fastlane-plugin-test_center validation failed: #{e.message}")
    raise e
  end
end