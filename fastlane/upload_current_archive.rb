#!/usr/bin/env ruby

# TestFlight Upload Script for Current Archive
# Uploads the September 2025 Nestory archive to TestFlight using App Store Connect API

# Current archive path (September 2, 2025)
ARCHIVE_PATH = "/Users/griffin/Library/Developer/Xcode/Archives/2025-09-02/Nestory-Dev 9-2-25, 3.14 AM.xcarchive"

puts "📦 Using archive: #{ARCHIVE_PATH}"

# Verify archive exists
unless File.directory?(ARCHIVE_PATH)
  puts "❌ Error: Archive not found at #{ARCHIVE_PATH}"
  exit 1
end

puts "✅ Archive verified!"

# Create output directory
output_dir = "fastlane/output/current_build"
system("mkdir -p #{output_dir}")

puts "🚀 Starting fastlane upload process..."
exec("fastlane ios upload_current_archive")