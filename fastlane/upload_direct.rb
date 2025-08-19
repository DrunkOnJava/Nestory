#!/usr/bin/env ruby

# Direct upload script
require 'fastlane'

# Set up the lane
lane :upload_direct do
  # Configure App Store Connect API
  app_store_connect_api_key(
    key_id: "NWV654RNK3",
    issuer_id: "f144f0a6-1aff-44f3-974e-183c4c07bc46",
    key_filepath: "/Users/griffin/Projects/Nestory/AuthKey_NWV654RNK3.p8",
    duration: 1200,
    in_house: false
  )
  
  # Upload the existing IPA
  upload_to_testflight(
    ipa: "/Users/griffin/Projects/Nestory/fastlane/output/build/Nestory.ipa",
    skip_waiting_for_build_processing: true,
    changelog: "Initial TestFlight build with export compliance configuration",
    beta_app_description: "Nestory - Home Inventory Management for Insurance",
    beta_app_feedback_email: "support@nestory.app",
    distribute_external: false,
    uses_non_exempt_encryption: false
  )
end

# Run the lane
upload_direct