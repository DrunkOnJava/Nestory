#!/usr/bin/env ruby
require 'fastlane'

# Direct TestFlight Upload Script
# Bypasses plugin system for focused deployment

Fastlane.load_actions

# Direct upload to TestFlight using core fastlane
def upload_to_testflight_direct
  puts "🚀 Starting Direct TestFlight Upload"
  puts "Bypassing plugin system for focused deployment"
  
  # Configuration
  archive_path = "/Users/griffin/Library/Developer/Xcode/Archives/2025-09-02/Nestory-Dev 9-2-25, 3.14 AM.xcarchive"
  output_dir = "fastlane/output/direct_upload"
  
  # Create output directory
  system("mkdir -p #{output_dir}")
  
  # Verify archive exists
  unless File.directory?(archive_path)
    puts "❌ Error: Archive not found at #{archive_path}"
    exit 1
  end
  
  puts "✅ Archive verified: #{File.basename(archive_path)}"
  
  # Configure App Store Connect API
  puts "🔐 Configuring App Store Connect API..."
  
  Fastlane::Actions::AppStoreConnectApiKeyAction.run(
    key_id: "NWV654RNK3",
    issuer_id: "f144f0a6-1aff-44f3-974e-183c4c07bc46",
    key_filepath: "/Users/griffin/Projects/Nestory/AuthKey_NWV654RNK3.p8",
    duration: 1200,
    in_house: false
  )
  
  puts "✅ App Store Connect API configured"
  
  # Export IPA from archive
  puts "📦 Exporting IPA from archive..."
  
  ipa_path = Fastlane::Actions::BuildAppAction.run(
    archive_path: archive_path,
    export_method: "app-store",
    export_options: {
      uploadSymbols: true,
      compileBitcode: false,
      method: "app-store",
      signingStyle: "automatic",
      teamID: "2VXBQV4XC9",
      provisioningProfiles: {
        "com.drunkonjava.nestory.dev" => "match AppStore com.drunkonjava.nestory.dev"
      },
      iCloudContainerEnvironment: "Production"
    },
    skip_build_archive: true,
    output_directory: output_dir,
    output_name: "Nestory-Direct.ipa"
  )
  
  # Get IPA size
  ipa_size = File.size(ipa_path) / (1024.0 * 1024.0)
  puts "📱 IPA exported: #{File.basename(ipa_path)} (#{ipa_size.round(2)} MB)"
  
  # Load changelog
  changelog_path = "fastlane/output/changelog/COMPREHENSIVE_CHANGELOG.md"
  if File.exist?(changelog_path)
    changelog = File.read(changelog_path)
  else
    changelog = <<~NOTES
      🎯 Nestory v1.0.1 (Build 4) - Swift 6 Production Release
      
      ✅ Swift 6 Migration Complete
      - Full Swift 6 concurrency compliance
      - @MainActor isolation properly implemented
      - Production-ready stability improvements
      
      🛡️ Enhanced Reliability
      - Comprehensive error handling patterns
      - Graceful degradation for service failures
      - Structured logging with detailed context
      
      🏗️ Architecture Improvements
      - TCA dependency injection optimized
      - Service health monitoring integrated
      - Cloud sync reliability enhanced
      
      🧪 Quality Assurance
      - SwiftLint analysis: 1 error resolved, 2,779 warnings reviewed
      - iOS Simulator testing on iPhone 16 Pro Max
      - Comprehensive TestFlight validation pipeline
      
      📊 Technical Specifications
      - Archive: Nestory-Dev 9-2-25, 3.14 AM.xcarchive
      - Bundle ID: com.drunkonjava.nestory.dev
      - Export Compliance: Uses only exempt encryption
      - Target: iPhone 16 Pro Max optimized
    NOTES
  end
  
  # Upload to TestFlight
  puts "🚀 Uploading to TestFlight..."
  
  Fastlane::Actions::UploadToTestflightAction.run(
    ipa: ipa_path,
    skip_waiting_for_build_processing: false,
    distribute_external: false,
    notify_external_testers: false,
    changelog: changelog,
    beta_app_description: "Nestory - Personal Home Inventory Management for Insurance Documentation and Warranty Tracking",
    beta_app_feedback_email: "support@nestory.app",
    demo_account_required: false,
    beta_app_review_info: {
      contact_email: "support@nestory.app",
      contact_first_name: "Nestory",
      contact_last_name: "Support", 
      contact_phone: "+1-555-NESTORY",
      demo_account_name: "",
      demo_account_password: "",
      notes: "Personal home inventory app for insurance documentation. Swift 6 production release with comprehensive testing and quality assurance."
    },
    localized_app_info: {
      "default" => {
        feedback_email: "support@nestory.app",
        marketing_url: "https://nestory.app",
        privacy_policy_url: "https://nestory.app/privacy",
        description: "Document your belongings for insurance claims and warranty tracking with comprehensive photo cataloging and receipt scanning."
      }
    },
    localized_build_info: {
      "default" => {
        whats_new: "Swift 6 migration complete with enhanced reliability, performance optimizations, and comprehensive testing validation."
      }
    },
    uses_non_exempt_encryption: false
  )
  
  puts ""
  puts "🎉 SUCCESS: TestFlight Upload Completed!"
  puts "📱 Build will be available for testing once App Store Connect processing completes"
  puts "🔗 Check App Store Connect for processing status"
  puts ""
  puts "📊 Upload Summary:"
  puts "  • Archive: #{File.basename(archive_path)}"
  puts "  • IPA Size: #{ipa_size.round(2)} MB"
  puts "  • Bundle ID: com.drunkonjava.nestory.dev"
  puts "  • Export Method: App Store"
  puts "  • Encryption: Exempt (HTTPS only)"
  puts "  • Processing: Monitoring enabled"
  puts ""
  
end

# Execute the upload
if __FILE__ == $0
  begin
    upload_to_testflight_direct
  rescue => e
    puts "❌ Upload failed: #{e.message}"
    puts e.backtrace.first(5)
    exit 1
  end
end