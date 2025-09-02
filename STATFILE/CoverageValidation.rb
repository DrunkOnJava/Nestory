desc "Run tests and generate a coverage report"
lane :coverage_validation do
  UI.message("🧪 Running tests and generating coverage report…")
  
  # Run tests first to generate fresh coverage data
  run_tests(
    scheme: "Nestory-Dev",
    result_bundle: true,
    code_coverage: true,
    output_directory: "fastlane/test_output",
    output_types: "xcresult",
    xcbeautify: true
  )
  
  # Generate coverage report with fresh data
  xcov(
    scheme: "Nestory-Dev",
    output_directory: "fastlane/coverage",
    minimum_coverage_percentage: 0.0,  # Float!
    xccov_file_direct_path: "fastlane/test_output"
  )
  
  UI.success("✅ Coverage validation completed!")
  UI.message("📊 Coverage report generated in fastlane/coverage/")
end