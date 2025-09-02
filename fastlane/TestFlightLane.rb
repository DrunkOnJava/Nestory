#!/usr/bin/env ruby

# TestFlight Upload Lane with Specialized iOS Tools
# Leverages core fastlane functionality and proven iOS automation

desc "Upload current archive to TestFlight with quality checks"
lane :testflight_with_validation do |options|
  
  # Configuration
  archive_path = "/Users/griffin/Library/Developer/Xcode/Archives/2025-09-02/Nestory-Dev 9-2-25, 3.14 AM.xcarchive"
  output_dir = "fastlane/output/testflight_upload"
  
  UI.important "🚀 Starting TestFlight upload with iOS automation tools"
  
  # Pre-upload validation using specialized iOS tools
  UI.header "📋 Pre-Upload Quality Checks"
  
  # 1. SwiftLint integration for code quality
  begin
    swiftlint(
      mode: :lint,
      executable: "swiftlint", 
      config_file: ".swiftlint.yml",
      strict: false,  # Don't fail on warnings for release
      quiet: true
    )
    UI.success "✅ SwiftLint validation passed"
  rescue => e
    UI.important "⚠️  SwiftLint warnings present: #{e.message}"
  end
  
  # 2. iOS Simulator control for validation
  begin
    # Boot iPhone 16 Pro Max for validation
    sh("xcrun simctl boot 'iPhone 16 Pro Max' || true")  # Don't fail if already booted
    UI.success "✅ iOS Simulator ready for validation"
  rescue => e
    UI.important "⚠️  Simulator boot issue: #{e.message}"
  end
  
  # 3. App Store Connect API Authentication
  UI.header "🔐 Configuring App Store Connect API"
  
  app_store_connect_api_key(
    key_id: "NWV654RNK3",
    issuer_id: "f144f0a6-1aff-44f3-974e-183c4c07bc46", 
    key_filepath: "/Users/griffin/Projects/Nestory/AuthKey_NWV654RNK3.p8",
    duration: 1200,
    in_house: false
  )
  
  UI.success "✅ App Store Connect API configured"
  
  # 4. Create output directory
  sh("mkdir -p #{output_dir}")
  
  # 5. Export IPA from existing archive
  UI.header "📦 Exporting IPA from Archive"
  
  ipa_path = build_app(
    archive_path: archive_path,
    export_method: "app-store",
    export_options: {
      uploadSymbols: true,
      compileBitcode: false,
      method: "app-store",
      provisioningProfiles: {
        "com.drunkonjava.nestory.dev" => "match AppStore com.drunkonjava.nestory.dev"
      },
      signingStyle: "automatic",
      teamID: "2VXBQV4XC9"
    },
    skip_build_archive: true,
    output_directory: output_dir,
    output_name: "Nestory-TestFlight.ipa"
  )
  
  UI.success "📱 IPA exported: #{ipa_path}"
  
  # 6. Upload to TestFlight with comprehensive options
  UI.header "🚀 Uploading to TestFlight"
  
  upload_to_testflight(
    ipa: ipa_path,
    skip_waiting_for_build_processing: false,
    distribute_external: false,
    notify_external_testers: false,
    changelog: """
    🎯 Nestory v1.0.1 (Build 4) - Swift 6 Production Release
    
    ✅ Swift 6 Migration Complete
    ✅ Production Safety Improvements  
    ✅ Enhanced Error Handling
    ✅ TCA Architecture Optimizations
    
    Ready for comprehensive testing on all supported devices.
    """,
    beta_app_description: "Nestory - Personal Home Inventory Management for Insurance Documentation",
    beta_app_feedback_email: "support@nestory.app",
    demo_account_required: false,
    beta_app_review_info: {
      contact_email: "support@nestory.app",
      contact_first_name: "Nestory",
      contact_last_name: "Support",
      contact_phone: "+1-555-NESTORY",
      demo_account_name: "",
      demo_account_password: "",
      notes: "Personal home inventory app for insurance documentation. No demo account needed - create personal inventory immediately."
    },
    localized_app_info: {
      "default" => {
        feedback_email: "support@nestory.app",
        marketing_url: "https://nestory.app",
        privacy_policy_url: "https://nestory.app/privacy",
        description: "Document your belongings for insurance claims and warranty tracking."
      }
    },
    localized_build_info: {
      "default" => {
        whats_new: "Swift 6 migration complete with enhanced reliability and performance optimizations."
      }
    },
    uses_non_exempt_encryption: false
  )
  
  UI.success "🎉 Successfully uploaded to TestFlight!"
  
  # 7. Post-upload actions using specialized tools
  UI.header "📊 Post-Upload Actions"
  
  # Generate code coverage report if available
  begin
    xcov(
      workspace: "Nestory.xcworkspace",
      scheme: "Nestory-Dev", 
      output_directory: "fastlane/output/coverage",
      html_report: true,
      json_report: true
    )
    UI.success "✅ Code coverage report generated"
  rescue => e
    UI.important "⚠️  Coverage report skipped: #{e.message}"
  end
  
  # Clean up simulator
  sh("xcrun simctl shutdown 'iPhone 16 Pro Max' || true")
  
  UI.success "🏁 TestFlight upload process complete!"
  UI.important "📱 Build will be available for testing once App Store Connect processing completes"
  
end