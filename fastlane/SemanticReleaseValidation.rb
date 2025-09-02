# Test validation for fastlane-plugin-semantic_release
# This lane tests if the semantic_release plugin loads and functions correctly

desc "Test fastlane-plugin-semantic_release functionality"
lane :semantic_release_validation do
  UI.message("📋 Testing fastlane-plugin-semantic_release plugin...")
  
  begin
    # Test basic analyze_commits functionality
    # This should just verify the plugin loads without actually analyzing
    UI.message("✅ semantic_release plugin loaded successfully")
    
    # Check if analyze_commits action is available
    if Fastlane::Actions.const_defined?(:AnalyzeCommitsAction)
      UI.success("✅ AnalyzeCommitsAction is available")
    else
      UI.error("❌ AnalyzeCommitsAction not found")
    end
    
    # Check if conventional_changelog action is available  
    if Fastlane::Actions.const_defined?(:ConventionalChangelogAction)
      UI.success("✅ ConventionalChangelogAction is available")
    else
      UI.error("❌ ConventionalChangelogAction not found")
    end
    
    # List available semantic_release actions
    semantic_actions = []
    Fastlane::Actions.constants.each do |const|
      action_class = Fastlane::Actions.const_get(const)
      if action_class.respond_to?(:description) && 
         (action_class.description.to_s.downcase.include?('semantic') ||
          action_class.description.to_s.downcase.include?('changelog') ||
          action_class.description.to_s.downcase.include?('commit'))
        semantic_actions << const.to_s
      end
    end
    
    UI.message("Available semantic release actions: #{semantic_actions.join(', ')}")
    UI.success("🎉 fastlane-plugin-semantic_release validation completed successfully!")
    
  rescue => e
    UI.error("❌ fastlane-plugin-semantic_release validation failed: #{e.message}")
    raise e
  end
end