#!/usr/bin/env ruby

require 'json'
require 'net/http'
require 'uri'
require 'base64'
require 'openssl'
require 'jwt'

# Configuration
KEY_ID = ENV['ASC_KEY_ID'] || '1Q3C9RIHO6XC'
ISSUER_ID = ENV['ASC_ISSUER_ID'] || 'f144f0a6-1aff-44f3-974e-183c4c07bc46'
PRIVATE_KEY_PATH = ENV['ASC_KEY_PATH'] || '/Users/griffin/Projects/Nestory/AuthKey_NWV654RNK3.p8'
BUNDLE_ID = ENV['ASC_BUNDLE_ID'] || 'com.drunkonjava.nestory.dev'

# App metadata configuration
APP_CONFIG = {
  name: 'Nestory',
  subtitle: 'Home Inventory for Insurance',
  primary_category: 'PRODUCTIVITY',
  secondary_category: 'UTILITIES',
  
  # Age rating (all set to NONE for 4+ rating)
  age_rating: {
    alcoholTobaccoOrDrugUseOrReferences: 'NONE',
    gamblingSimulated: 'NONE', 
    horrorOrFearThemes: 'NONE',
    matureSuggestiveThemes: 'NONE',
    medicalTreatmentInformation: 'NONE',
    profanityOrCrudeHumor: 'NONE',
    sexualContentGraphicAndNudity: 'NONE',
    sexualContentOrNudity: 'NONE',
    violenceCartoonOrFantasy: 'NONE',
    violenceRealistic: 'NONE',
    violenceRealisticProlongedGraphicOrSadistic: 'NONE'
  },
  
  # Content rights
  uses_third_party_content: false,
  
  # URLs
  support_url: 'https://nestory.app/support',
  marketing_url: 'https://nestory.app',
  privacy_url: 'https://nestory.app/privacy'
}

class AppStoreConnectAPI
  BASE_URL = 'https://api.appstoreconnect.apple.com'
  
  def initialize(key_id, issuer_id, private_key_path)
    @key_id = key_id
    @issuer_id = issuer_id
    
    unless File.exist?(private_key_path)
      puts "❌ Private key not found at: #{private_key_path}"
      puts "Please ensure your .p8 key file is at this location"
      exit 1
    end
    
    @private_key = OpenSSL::PKey::EC.new(File.read(private_key_path))
  end
  
  def generate_token
    header = {
      'alg' => 'ES256',
      'kid' => @key_id,
      'typ' => 'JWT'
    }
    
    payload = {
      'iss' => @issuer_id,
      'iat' => Time.now.to_i,
      'exp' => Time.now.to_i + 20 * 60, # 20 minutes
      'aud' => 'appstoreconnect-v1'
    }
    
    JWT.encode(payload, @private_key, 'ES256', header)
  end
  
  def make_request(method, path, body = nil)
    uri = URI("#{BASE_URL}#{path}")
    
    case method
    when :get
      request = Net::HTTP::Get.new(uri)
    when :post
      request = Net::HTTP::Post.new(uri)
    when :patch
      request = Net::HTTP::Patch.new(uri)
    end
    
    request['Authorization'] = "Bearer #{generate_token}"
    request['Content-Type'] = 'application/json'
    
    if body
      request.body = body.to_json
    end
    
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end
    
    if response.code.to_i >= 400
      puts "❌ API Error: #{response.code}"
      puts response.body
      return nil
    end
    
    response.body.empty? ? {} : JSON.parse(response.body)
  end
  
  def find_app(bundle_id)
    response = make_request(:get, "/v1/apps?filter[bundleId]=#{bundle_id}")
    return nil unless response
    
    response['data']&.first
  end
  
  def update_app_categories(app_id, primary, secondary)
    body = {
      data: {
        type: 'apps',
        id: app_id,
        attributes: {
          primaryCategory: primary,
          secondaryCategory: secondary
        }
      }
    }
    
    make_request(:patch, "/v1/apps/#{app_id}", body)
  end
  
  def create_age_rating(app_id, ratings)
    body = {
      data: {
        type: 'ageRatingDeclarations',
        attributes: ratings,
        relationships: {
          app: {
            data: {
              type: 'apps',
              id: app_id
            }
          }
        }
      }
    }
    
    make_request(:post, '/v1/ageRatingDeclarations', body)
  end
end

# Main execution
puts "🚀 Configuring App Store Connect for Nestory"
puts "============================================"
puts ""
puts "Using credentials:"
puts "  Key ID: #{KEY_ID}"
puts "  Issuer ID: #{ISSUER_ID}"
puts "  Bundle ID: #{BUNDLE_ID}"
puts ""

# Check for private key
unless File.exist?(PRIVATE_KEY_PATH)
  puts "⚠️  Private key not found at: #{PRIVATE_KEY_PATH}"
  puts ""
  puts "Please do one of the following:"
  puts "1. Download your .p8 key from App Store Connect"
  puts "2. Place it at: ~/AuthKey_#{KEY_ID}.p8"
  puts "3. Or set ASC_KEY_PATH environment variable"
  puts ""
  puts "You can download your key from:"
  puts "https://appstoreconnect.apple.com/access/api"
  exit 1
end

api = AppStoreConnectAPI.new(KEY_ID, ISSUER_ID, PRIVATE_KEY_PATH)

puts "🔍 Finding app..."
app = api.find_app(BUNDLE_ID)

if app
  app_id = app['id']
  puts "✅ Found app: #{app['attributes']['name']} (#{app_id})"
  
  puts "📝 Updating categories..."
  if api.update_app_categories(app_id, APP_CONFIG[:primary_category], APP_CONFIG[:secondary_category])
    puts "✅ Categories updated"
  end
  
  puts "🎮 Setting age rating..."
  if api.create_age_rating(app_id, APP_CONFIG[:age_rating])
    puts "✅ Age rating configured (4+)"
  end
  
  puts ""
  puts "✅ App Store Connect configuration complete!"
  puts ""
  puts "Next steps:"
  puts "1. Build and upload your app: bundle exec fastlane build"
  puts "2. Upload to TestFlight: bundle exec fastlane beta"
  puts "3. Submit for review: bundle exec fastlane submit_for_review"
else
  puts "❌ App not found with bundle ID: #{BUNDLE_ID}"
  puts ""
  puts "Please ensure:"
  puts "1. The app exists in App Store Connect"
  puts "2. The bundle ID is correct"
  puts "3. Your API key has access to this app"
end