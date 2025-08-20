#!/usr/bin/env ruby

# Direct TestFlight upload script
# Uploads the existing archive to TestFlight using App Store Connect API

require 'fastlane'

Fastlane.load_actions

# Configure App Store Connect API
app_store_connect_api_key(
  key_id: "NWV654RNK3",
  issuer_id: "f144f0a6-1aff-44f3-974e-183c4c07bc46",
  key_filepath: "/Users/griffin/Projects/Nestory/AuthKey_NWV654RNK3.p8",
  duration: 1200,
  in_house: false
)

# Get the most recent archive
archive_path = "/Users/griffin/Library/Developer/Xcode/Archives/2025-08-19/Nestory-Dev 2025-08-19 03.31.00.xcarchive"

puts "📦 Using archive: #{archive_path}"

# Export the IPA from archive
ipa_path = build_app(
  archive_path: archive_path,
  export_method: "app-store",
  export_options: {
    uploadSymbols: true,
    compileBitcode: false,
    provisioningProfiles: {
      ENV.fetch('PRODUCT_BUNDLE_IDENTIFIER', 'com.drunkonjava.nestory.dev') => "match AppStore #{ENV.fetch('PRODUCT_BUNDLE_IDENTIFIER', 'com.drunkonjava.nestory.dev')}"
    }
  },
  skip_build_archive: true,
  output_directory: "fastlane/output/build",
  output_name: "Nestory-Dev.ipa"
)

puts "📱 IPA exported to: #{ipa_path}"

# Upload to TestFlight
upload_to_testflight(
  ipa: ipa_path,
  skip_waiting_for_build_processing: false,
  distribute_external: false,
  changelog: "TestFlight build from command line",
  beta_app_description: "Nestory - Home Inventory Management for Insurance",
  beta_app_feedback_email: "support@nestory.app"
)

puts "✅ Successfully uploaded to TestFlight!"