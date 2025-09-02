# CI-aware build number validation for Nestory iOS project
# Uses existing fastlane-plugin-versioning's ci_build_number action

desc "Set CI-aware build number using versioning plugin"
lane :ci_buildnum do
  UI.message("🔢 Testing CI-aware build numbering...")
  
  begin
    # versioning's ci_build_number reads common CI env vars 
    # (e.g. GITHUB_RUN_NUMBER, CIRCLE_BUILD_NUM, BUILD_NUMBER)
    new_bn = ci_build_number
    UI.message("✅ CI build number detected: #{new_bn}")
    
    # Apply the CI build number to the project
    increment_build_number_in_xcodeproj(
      build_number: new_bn,
      xcodeproj: "Nestory.xcodeproj"
    )
    
    # Verify the change was applied
    current_bn = get_build_number_from_xcodeproj(xcodeproj: "Nestory.xcodeproj")
    UI.success("🎉 Build number successfully set to: #{current_bn}")
    
    UI.message("📋 Available CI environment variables:")
    ci_vars = ["GITHUB_RUN_NUMBER", "CIRCLE_BUILD_NUM", "BUILD_NUMBER", "CI_PIPELINE_ID", "BUILDKITE_BUILD_NUMBER"]
    ci_vars.each do |var|
      value = ENV[var]
      if value
        UI.message("  #{var}: #{value}")
      else
        UI.message("  #{var}: (not set)")
      end
    end
    
  rescue => e
    UI.error("❌ CI build number validation failed: #{e.message}")
    UI.message("ℹ️  This is expected when not running in a CI environment")
    UI.message("ℹ️  In CI, this action will automatically detect build numbers from:")
    UI.message("   • GitHub Actions: GITHUB_RUN_NUMBER")
    UI.message("   • CircleCI: CIRCLE_BUILD_NUM") 
    UI.message("   • Jenkins: BUILD_NUMBER")
    UI.message("   • GitLab CI: CI_PIPELINE_ID")
    UI.message("   • Buildkite: BUILDKITE_BUILD_NUMBER")
    raise e
  end
end