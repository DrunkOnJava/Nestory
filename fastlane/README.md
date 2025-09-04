fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios tests

```sh
[bundle exec] fastlane ios tests
```

Run unit/UI tests with comprehensive framework

### ios ui_tests

```sh
[bundle exec] fastlane ios ui_tests
```

Run comprehensive UI tests with enterprise framework

### ios performance_tests

```sh
[bundle exec] fastlane ios performance_tests
```

Run performance UI tests

### ios accessibility_tests

```sh
[bundle exec] fastlane ios accessibility_tests
```

Run accessibility UI tests

### ios smoke_tests

```sh
[bundle exec] fastlane ios smoke_tests
```

Run smoke tests

### ios build

```sh
[bundle exec] fastlane ios build
```

Build archive for distribution

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Build and upload to TestFlight with comprehensive testing

### ios release

```sh
[bundle exec] fastlane ios release
```

Submit to App Store (metadata + binary)

### ios screenshots

```sh
[bundle exec] fastlane ios screenshots
```

Capture comprehensive screenshots with UI testing framework

### ios open_screenshots

```sh
[bundle exec] fastlane ios open_screenshots
```

Open screenshots in Finder

### ios clear_screenshots

```sh
[bundle exec] fastlane ios clear_screenshots
```

Clear all screenshot data

### ios fix_validation

```sh
[bundle exec] fastlane ios fix_validation
```

Fix all validation issues for App Store submission

### ios icons

```sh
[bundle exec] fastlane ios icons
```

Generate full iOS AppIcon set from a source PNG

### ios configure_app_metadata

```sh
[bundle exec] fastlane ios configure_app_metadata
```

Configure app metadata via App Store Connect API

### ios create_app_version

```sh
[bundle exec] fastlane ios create_app_version
```

Create new app version

### ios upload_screenshots_api

```sh
[bundle exec] fastlane ios upload_screenshots_api
```

Upload screenshots via API

### ios submit_for_review

```sh
[bundle exec] fastlane ios submit_for_review
```

Submit version for review

### ios configure_phased_release

```sh
[bundle exec] fastlane ios configure_phased_release
```

Set phased release for version

### ios submit_export_compliance

```sh
[bundle exec] fastlane ios submit_export_compliance
```

Submit export compliance declaration

### ios complete_submission

```sh
[bundle exec] fastlane ios complete_submission
```

Complete App Store submission workflow with comprehensive testing

### ios enterprise_test_suite

```sh
[bundle exec] fastlane ios enterprise_test_suite
```

Run complete enterprise test suite

### ios generate_test_report

```sh
[bundle exec] fastlane ios generate_test_report
```

Generate comprehensive test report

### ios validate_framework

```sh
[bundle exec] fastlane ios validate_framework
```

Validate UI testing framework configuration

### ios configure_xcode_for_ui_testing

```sh
[bundle exec] fastlane ios configure_xcode_for_ui_testing
```

Configure Xcode project for UI testing with enterprise framework

### ios update_build_settings

```sh
[bundle exec] fastlane ios update_build_settings
```

Update Xcode build settings dynamically

### ios setup_test_schemes

```sh
[bundle exec] fastlane ios setup_test_schemes
```

Setup comprehensive test schemes

### ios configure_entitlements

```sh
[bundle exec] fastlane ios configure_entitlements
```

Configure entitlements automatically

### ios update_info_plists

```sh
[bundle exec] fastlane ios update_info_plists
```

Update Info.plist files dynamically

### ios setup_provisioning

```sh
[bundle exec] fastlane ios setup_provisioning
```

Setup provisioning profiles automatically

### ios generate_xcode_config

```sh
[bundle exec] fastlane ios generate_xcode_config
```

Generate comprehensive Xcode configuration

### ios validate_xcode_config

```sh
[bundle exec] fastlane ios validate_xcode_config
```

Validate Xcode project configuration

### ios reset_xcode_config

```sh
[bundle exec] fastlane ios reset_xcode_config
```

Reset and clean Xcode configuration

### ios configure_swift_compiler

```sh
[bundle exec] fastlane ios configure_swift_compiler
```

Configure Swift compiler settings for different environments

### ios configure_dynamic_frameworks

```sh
[bundle exec] fastlane ios configure_dynamic_frameworks
```

Setup dynamic linking and framework configuration

### ios apply_performance_optimizations

```sh
[bundle exec] fastlane ios apply_performance_optimizations
```

Apply performance optimization build settings

### ios configure_security_settings

```sh
[bundle exec] fastlane ios configure_security_settings
```

Configure security-focused build settings

### ios setup_dev_environment

```sh
[bundle exec] fastlane ios setup_dev_environment
```

Setup complete development environment

### ios configure_simulators

```sh
[bundle exec] fastlane ios configure_simulators
```

Configure iOS simulators for testing

### ios install_certificates

```sh
[bundle exec] fastlane ios install_certificates
```

Install and configure certificates automatically

### ios validate_environment

```sh
[bundle exec] fastlane ios validate_environment
```

Validate complete environment setup

### ios upload_direct

```sh
[bundle exec] fastlane ios upload_direct
```

Direct upload to TestFlight with existing IPA

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
