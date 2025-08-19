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

Run unit/UI tests with scan

### ios build

```sh
[bundle exec] fastlane ios build
```

Build archive for distribution

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Build and upload to TestFlight

### ios release

```sh
[bundle exec] fastlane ios release
```

Submit to App Store (metadata + binary)

### ios screenshots

```sh
[bundle exec] fastlane ios screenshots
```

Capture localized screenshots

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

Complete App Store submission workflow

### ios upload_direct

```sh
[bundle exec] fastlane ios upload_direct
```

Direct upload to TestFlight with existing IPA

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
