# Auto-generated scheme configuration from ProjectConfiguration.json
# DO NOT EDIT MANUALLY - Run 'make generate-config' to update

# Project Settings
PROJECT_NAME = Nestory
SCHEME_DEV = Nestory-Dev
SCHEME_STAGING = Nestory-Staging
SCHEME_PROD = Nestory-Prod
WORKSPACE = Nestory.xcworkspace
PROJECT_FILE = Nestory.xcodeproj

# CRITICAL: Always use iPhone 16 Plus for consistency
SIMULATOR_NAME = iPhone 16 Plus
SIMULATOR_OS = iOS Simulator
DESTINATION = platform=iOS Simulator,name=iPhone 16 Plus

# Build Timeouts
BUILD_TIMEOUT = 300
TEST_TIMEOUT = 180
ARCHIVE_TIMEOUT = 600

# Scheme Selection (default to Dev, can be overridden)
# Usage: make run SCHEME_TARGET=staging
SCHEME_TARGET ?= dev
ifeq ($(SCHEME_TARGET),staging)
    ACTIVE_SCHEME = $(SCHEME_STAGING)
    ACTIVE_CONFIG = Release
else ifeq ($(SCHEME_TARGET),prod)
    ACTIVE_SCHEME = $(SCHEME_PROD)
    ACTIVE_CONFIG = Release
else
    ACTIVE_SCHEME = $(SCHEME_DEV)
    ACTIVE_CONFIG = Debug
endif