# screenshot_lanes.rb - Enhanced screenshot automation lanes

# Import into Fastfile with: import "./screenshot_lanes.rb"

platform :ios do
  
  # Enhanced screenshot capture with duplicate detection
  desc "Capture screenshots with duplicate detection"
  lane :screenshots_smart do |opts|
    UI.header "📸 Smart Screenshot Capture"
    
    # Capture screenshots
    capture_screenshots(
      devices: opts[:devices] || ["iPhone 16 Pro Max"],
      languages: opts[:languages] || ["en-US"],
      scheme: SCHEME,
      output_directory: "#{OUTPUT_DIR}/screenshots",
      clear_previous_screenshots: opts[:clear] || false,
      reinstall_app: opts[:reinstall] || true,
      stop_after_first_error: false,
      test_without_building: opts[:skip_build] || false,
      buildlog_path: "#{OUTPUT_DIR}/logs/snapshot"
    )
    
    # Detect and remove duplicates
    UI.message "🔍 Checking for duplicate screenshots..."
    duplicates = detect_duplicate_screenshots(path: "#{OUTPUT_DIR}/screenshots")
    
    if duplicates > 0
      UI.important "Found and removed #{duplicates} duplicate screenshots"
    else
      UI.success "No duplicate screenshots found"
    end
    
    # Generate report
    generate_screenshot_report(path: "#{OUTPUT_DIR}/screenshots")
  end
  
  # Compare screenshots against baseline
  desc "Compare screenshots with baseline"
  lane :screenshots_compare do |opts|
    baseline_path = opts[:baseline] || "#{OUTPUT_DIR}/screenshots_baseline"
    current_path = opts[:current] || "#{OUTPUT_DIR}/screenshots"
    
    UI.header "🔬 Screenshot Comparison"
    
    # Ensure paths exist
    UI.user_error!("Baseline not found at #{baseline_path}") unless Dir.exist?(baseline_path)
    UI.user_error!("Current screenshots not found at #{current_path}") unless Dir.exist?(current_path)
    
    # Compare screenshots
    differences = compare_screenshot_sets(
      baseline: baseline_path,
      current: current_path,
      output: "#{OUTPUT_DIR}/screenshot_diff"
    )
    
    if differences.empty?
      UI.success "✅ All screenshots match baseline"
    else
      UI.important "⚠️ Found #{differences.count} differences:"
      differences.each { |diff| UI.message "  - #{diff}" }
      
      # Open diff report
      sh "open #{OUTPUT_DIR}/screenshot_diff/report.html" if opts[:open]
    end
  end
  
  # Update baseline screenshots
  desc "Update baseline screenshots"
  lane :screenshots_baseline do |opts|
    UI.header "📋 Updating Baseline Screenshots"
    
    source = opts[:source] || "#{OUTPUT_DIR}/screenshots"
    destination = opts[:destination] || "#{OUTPUT_DIR}/screenshots_baseline"
    
    UI.user_error!("Source screenshots not found at #{source}") unless Dir.exist?(source)
    
    # Backup existing baseline
    if Dir.exist?(destination)
      backup_path = "#{destination}_backup_#{Time.now.strftime('%Y%m%d_%H%M%S')}"
      UI.message "Backing up existing baseline to #{backup_path}"
      sh "mv '#{destination}' '#{backup_path}'"
    end
    
    # Copy current to baseline
    sh "cp -R '#{source}' '#{destination}'"
    UI.success "✅ Baseline updated with #{Dir.glob("#{destination}/**/*.png").count} screenshots"
  end
  
  # Generate screenshot HTML report
  desc "Generate screenshot HTML report"
  lane :screenshots_report do |opts|
    path = opts[:path] || "#{OUTPUT_DIR}/screenshots"
    
    UI.header "📊 Generating Screenshot Report"
    
    # Count screenshots by device and language
    stats = analyze_screenshot_directory(path: path)
    
    # Generate HTML report
    html = generate_html_report(stats: stats, path: path)
    report_path = "#{path}/report.html"
    File.write(report_path, html)
    
    UI.success "Report generated at #{report_path}"
    sh "open '#{report_path}'" if opts[:open]
  end
  
  # CI-optimized screenshot capture
  desc "CI-optimized screenshot capture"
  lane :screenshots_ci do |opts|
    UI.header "🤖 CI Screenshot Capture"
    
    # Use minimal device set for CI
    devices = opts[:devices] || ["iPhone 16 Pro Max"]
    
    # Capture with CI optimizations
    capture_screenshots(
      devices: devices,
      languages: ["en-US"],
      scheme: SCHEME,
      output_directory: "#{OUTPUT_DIR}/screenshots",
      clear_previous_screenshots: true,
      reinstall_app: false,  # Faster in CI
      stop_after_first_error: true,  # Fail fast in CI
      test_without_building: true,  # Assume already built
      concurrent_simulators: false,  # More stable in CI
      buildlog_path: "#{OUTPUT_DIR}/logs/snapshot"
    )
    
    # Archive for artifacts
    sh "tar -czf #{OUTPUT_DIR}/screenshots.tar.gz -C #{OUTPUT_DIR} screenshots"
    UI.success "Screenshots archived to screenshots.tar.gz"
  end
  
  # Helper: Detect duplicate screenshots
  private_lane :detect_duplicate_screenshots do |opts|
    path = opts[:path]
    duplicates_removed = 0
    
    # Group files by hash
    hashes = {}
    Dir.glob("#{path}/**/*.png").each do |file|
      hash = Digest::SHA256.file(file).hexdigest
      hashes[hash] ||= []
      hashes[hash] << file
    end
    
    # Remove duplicates (keep first of each)
    hashes.each do |hash, files|
      if files.count > 1
        files[1..-1].each do |duplicate|
          File.delete(duplicate)
          duplicates_removed += 1
          UI.verbose "Removed duplicate: #{File.basename(duplicate)}"
        end
      end
    end
    
    duplicates_removed
  end
  
  # Helper: Compare screenshot sets
  private_lane :compare_screenshot_sets do |opts|
    baseline = opts[:baseline]
    current = opts[:current]
    output = opts[:output]
    
    differences = []
    
    # Create output directory
    FileUtils.mkdir_p(output)
    
    # Get file lists
    baseline_files = Dir.glob("#{baseline}/**/*.png").map { |f| f.sub(baseline, '') }
    current_files = Dir.glob("#{current}/**/*.png").map { |f| f.sub(current, '') }
    
    # Find missing/new files
    missing = baseline_files - current_files
    new_files = current_files - baseline_files
    
    missing.each { |f| differences << "Missing: #{f}" }
    new_files.each { |f| differences << "New: #{f}" }
    
    # Compare common files
    (baseline_files & current_files).each do |file|
      baseline_path = "#{baseline}#{file}"
      current_path = "#{current}#{file}"
      
      if Digest::SHA256.file(baseline_path) != Digest::SHA256.file(current_path)
        differences << "Changed: #{file}"
      end
    end
    
    differences
  end
  
  # Helper: Analyze screenshot directory
  private_lane :analyze_screenshot_directory do |opts|
    path = opts[:path]
    stats = {
      total: 0,
      by_device: {},
      by_language: {},
      by_screen: {}
    }
    
    Dir.glob("#{path}/**/*.png").each do |file|
      stats[:total] += 1
      
      # Parse filename for metadata
      basename = File.basename(file, '.png')
      parts = basename.split('-')
      
      # Assuming format: language-device-screen.png
      if parts.count >= 3
        language = parts[0]
        device = parts[1..-2].join('-')
        screen = parts[-1]
        
        stats[:by_language][language] = (stats[:by_language][language] || 0) + 1
        stats[:by_device][device] = (stats[:by_device][device] || 0) + 1
        stats[:by_screen][screen] = (stats[:by_screen][screen] || 0) + 1
      end
    end
    
    stats
  end
  
  # Helper: Generate HTML report
  private_lane :generate_html_report do |opts|
    stats = opts[:stats]
    path = opts[:path]
    
    html = <<-HTML
<!DOCTYPE html>
<html>
<head>
  <title>Screenshot Report</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; margin: 40px; }
    h1 { color: #333; }
    .stats { background: #f5f5f5; padding: 20px; border-radius: 8px; margin: 20px 0; }
    .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 20px; }
    .screenshot { border: 1px solid #ddd; border-radius: 8px; overflow: hidden; }
    .screenshot img { width: 100%; display: block; }
    .screenshot .caption { padding: 10px; background: #fafafa; font-size: 12px; }
  </style>
</head>
<body>
  <h1>📸 Screenshot Report</h1>
  
  <div class="stats">
    <h2>Statistics</h2>
    <p>Total Screenshots: #{stats[:total]}</p>
    <h3>By Device:</h3>
    <ul>
      #{stats[:by_device].map { |k,v| "<li>#{k}: #{v}</li>" }.join}
    </ul>
    <h3>By Language:</h3>
    <ul>
      #{stats[:by_language].map { |k,v| "<li>#{k}: #{v}</li>" }.join}
    </ul>
  </div>
  
  <h2>Screenshots</h2>
  <div class="grid">
    #{Dir.glob("#{path}/**/*.png").map { |f|
      relative = f.sub("#{path}/", '')
      "<div class='screenshot'>
        <img src='#{relative}' />
        <div class='caption'>#{File.basename(f)}</div>
      </div>"
    }.join}
  </div>
</body>
</html>
    HTML
    
    html
  end
end