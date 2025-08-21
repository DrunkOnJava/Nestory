# Nestory Project Makefile
# This Makefile serves as the single source of truth for all project operations
# ensuring consistency across different chat sessions and context windows
#
# 🏗️ ARCHITECTURE DECISION: TCA MIGRATION (August 20, 2025)
# - Migrated from 4-layer to 6-layer TCA architecture 
# - Added ComposableArchitecture dependency for sophisticated state management
# - All future features MUST use TCA patterns (Reducers, Actions, Dependencies)
# - See ADR-0014 in DECISIONS.md for full rationale

# ============================================================================
# CONFIGURATION
# ============================================================================

# Include auto-generated configuration from master source
include Config/MakefileConfig.mk

# Fallback legacy values (will be removed once migration is complete)
SCHEME = $(PROJECT_NAME)

# Build Settings (not auto-generated)
CONFIGURATION = Debug
SDK = iphonesimulator
DERIVED_DATA_PATH = .build
BUILD_LOG = build.log
ARCH_VERIFY_TIMEOUT = 60

# Build optimization
PARALLEL_JOBS = $(shell sysctl -n hw.ncpu)
BUILD_FLAGS = -jobs $(PARALLEL_JOBS) -quiet

# Colors for output
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[1;33m
BLUE = \033[0;34m
NC = \033[0m # No Color

# ============================================================================
# DEFAULT TARGET
# ============================================================================

.DEFAULT_GOAL := help

# ============================================================================
# HELP & DOCUMENTATION
# ============================================================================

.PHONY: help
help: ## Show this help message
	@echo "$(BLUE)╔══════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║                   Nestory Project Makefile                   ║$(NC)"
	@echo "$(BLUE)║         Insurance-focused Home Inventory Management          ║$(NC)"
	@echo "$(BLUE)╚══════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(YELLOW)Primary Commands:$(NC)"
	@echo "  $(GREEN)make run$(NC)              - Build and run app in iPhone 16 Pro Max simulator"
	@echo "  $(GREEN)make build$(NC)            - Build the app (Debug configuration)"
	@echo "  $(GREEN)make fast-build$(NC)       - Parallel build with maximum speed ($(PARALLEL_JOBS) jobs)"
	@echo "  $(GREEN)make test$(NC)             - Run all tests"
	@echo "  $(GREEN)make check$(NC)            - Run all checks (build, test, lint, arch)"
	@echo ""
	@echo "$(YELLOW)Quick Shortcuts:$(NC)"
	@echo "  $(GREEN)make r$(NC)                - Shortcut for 'make run'"
	@echo "  $(GREEN)make b$(NC)                - Shortcut for 'make build'"
	@echo "  $(GREEN)make f$(NC)                - Shortcut for 'make fast-build'"
	@echo "  $(GREEN)make c$(NC)                - Shortcut for 'make check'"
	@echo "  $(GREEN)make d$(NC)                - Shortcut for 'make doctor'"
	@echo ""
	@echo "$(YELLOW)Development Workflow:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Project Guidelines:$(NC)"
	@echo "  • $(BLUE)ALWAYS$(NC) use iPhone 16 Pro Max simulator"
	@echo "  • $(BLUE)ALWAYS$(NC) wire up new features in UI"
	@echo "  • $(BLUE)NO$(NC) 'low stock' references (insurance focus)"
	@echo "  • $(BLUE)NO$(NC) orphaned code - everything must be accessible"
	@echo "  • $(RED)TCA REQUIRED$(NC) - All new features must use TCA patterns"
	@echo "  • $(RED)ARCHITECTURE$(NC) - App→Features→UI→Services→Infrastructure→Foundation"
	@echo ""
	@echo "$(RED)Remember:$(NC) This is for personal belongings insurance documentation!"

# ============================================================================
# PRIMARY COMMANDS (Keep backward compatibility)
# ============================================================================

.PHONY: run
run: build-for-simulator ## Build and run app in iPhone 16 Pro Max simulator
	@echo "$(YELLOW)🚀 Installing and launching Nestory on iPhone 16 Pro Max...$(NC)"
	@echo "Booting simulator..."
	@xcrun simctl boot "$(SIMULATOR_NAME)" 2>/dev/null || true
	@echo "Installing app..."
	@timeout $(BUILD_TIMEOUT) xcrun simctl install "$(SIMULATOR_NAME)" "$(DERIVED_DATA_PATH)/Build/Products/$(CONFIGURATION)-iphonesimulator/Nestory.app" || \
		{ echo "$(RED)❌ App installation failed or timed out!$(NC)"; exit 1; }
	@echo "Launching app..."
	@timeout 30 xcrun simctl launch "$(SIMULATOR_NAME)" com.drunkonjava.nestory || \
		{ echo "$(RED)❌ App launch failed or timed out!$(NC)"; exit 1; }
	@echo "$(GREEN)✅ App launched successfully!$(NC)"

.PHONY: build
build: gen check-tools clean-logs check-file-sizes ## Build the app (Debug configuration)
	@echo "$(YELLOW)🔨 Building Nestory for iPhone 16 Pro Max...$(NC)"
	@timeout $(BUILD_TIMEOUT) xcodebuild -scheme $(ACTIVE_SCHEME) \
		-destination '$(DESTINATION)' \
		-configuration $(CONFIGURATION) \
		$(BUILD_FLAGS) \
		build 2>&1 | tee $(BUILD_LOG) || \
		{ echo "$(RED)❌ Build failed or timed out after $(BUILD_TIMEOUT)s!$(NC)"; \
		  echo "$(YELLOW)Check $(BUILD_LOG) for details$(NC)"; exit 1; }
	@echo "$(GREEN)✅ Build completed successfully!$(NC)"
	@# Increment build counter and show tree every 3rd build
	@if [ ! -f .build_counter ]; then echo "0" > .build_counter; fi
	@COUNT=$$(cat .build_counter); \
	COUNT=$$((COUNT + 1)); \
	echo $$COUNT > .build_counter; \
	if [ $$((COUNT % 3)) -eq 0 ]; then \
		echo ""; \
		echo "$(BLUE)═══════════════════════════════════════════════════════════════$(NC)"; \
		echo "$(BLUE)  Build #$$COUNT - Auto-displaying project structure$(NC)"; \
		echo "$(BLUE)═══════════════════════════════════════════════════════════════$(NC)"; \
		echo ""; \
		$(MAKE) tree; \
	fi

.PHONY: build-for-simulator
build-for-simulator: gen check-tools clean-logs check-file-sizes ## Build specifically for simulator usage
	@echo "$(YELLOW)🔨 Building Nestory for Simulator...$(NC)"
	@timeout $(BUILD_TIMEOUT) xcodebuild -scheme $(ACTIVE_SCHEME) \
		-destination '$(DESTINATION)' \
		-configuration $(CONFIGURATION) \
		-derivedDataPath $(DERIVED_DATA_PATH) \
		$(BUILD_FLAGS) \
		build 2>&1 | tee $(BUILD_LOG) || \
		{ echo "$(RED)❌ Simulator build failed or timed out after $(BUILD_TIMEOUT)s!$(NC)"; \
		  echo "$(YELLOW)Check $(BUILD_LOG) for details$(NC)"; exit 1; }
	@echo "$(GREEN)✅ Simulator build completed successfully!$(NC)"

.PHONY: build-release
build-release: gen check-tools check-file-sizes ## Build the app (Release configuration)
	@echo "$(YELLOW)🔨 Building Nestory (Release)...$(NC)"
	@timeout $(BUILD_TIMEOUT) xcodebuild -scheme $(ACTIVE_SCHEME) \
		-configuration Release \
		-destination '$(DESTINATION)' \
		$(BUILD_FLAGS) \
		build 2>&1 | tee release-$(BUILD_LOG) || \
		{ echo "$(RED)❌ Release build failed or timed out after $(BUILD_TIMEOUT)s!$(NC)"; \
		  echo "$(YELLOW)Check release-$(BUILD_LOG) for details$(NC)"; exit 1; }
	@echo "$(GREEN)✅ Release build completed!$(NC)"

# ============================================================================
# PROJECT GENERATION
# ============================================================================

.PHONY: gen
gen: ## Generate Xcode project from project.yml
	@echo "$(YELLOW)🔧 Generating Xcode project...$(NC)"
	@if command -v xcodegen >/dev/null 2>&1; then \
		xcodegen generate; \
		echo "$(GREEN)✅ Project generated!$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  Using existing Xcode project (xcodegen not installed)$(NC)"; \
	fi

.PHONY: regenerate
regenerate: gen ## Alias for gen - regenerate Xcode project

.PHONY: clean-build
clean-build: clean gen build ## Clean, regenerate project, and build

# ============================================================================
# TESTING
# ============================================================================

.PHONY: test
test: check-tools ## Run all tests
	@echo "$(YELLOW)🧪 Running tests...$(NC)"
	@timeout $(TEST_TIMEOUT) swift test || \
		{ echo "$(RED)❌ Tests failed or timed out after $(TEST_TIMEOUT)s!$(NC)"; exit 1; }
	@echo "$(GREEN)✅ Tests completed!$(NC)"

.PHONY: test-xcode
test-xcode: gen ## Run tests via Xcode
	@echo "$(YELLOW)🧪 Running Xcode tests...$(NC)"
	@timeout $(TEST_TIMEOUT) xcodebuild test \
		-scheme $(SCHEME_DEV) \
		-destination '$(DESTINATION)' \
		$(BUILD_FLAGS) \
		2>&1 | tee test-$(BUILD_LOG) || \
		{ echo "$(RED)❌ Xcode tests failed or timed out after $(TEST_TIMEOUT)s!$(NC)"; \
		  echo "$(YELLOW)Check test-$(BUILD_LOG) for details$(NC)"; exit 1; }
	@echo "$(GREEN)✅ Xcode tests completed!$(NC)"

.PHONY: test-unit
test-unit: ## Run unit tests only
	@echo "$(YELLOW)🧪 Running unit tests...$(NC)"
	@timeout $(TEST_TIMEOUT) swift test --filter NestoryTests || \
		{ echo "$(RED)❌ Unit tests failed or timed out after $(TEST_TIMEOUT)s!$(NC)"; exit 1; }
	@echo "$(GREEN)✅ Unit tests completed!$(NC)"

.PHONY: test-ui
test-ui: gen ## Run UI tests only
	@echo "$(YELLOW)🧪 Running UI tests...$(NC)"
	@timeout $(TEST_TIMEOUT) xcodebuild test \
		-scheme $(SCHEME_DEV) \
		-destination '$(DESTINATION)' \
		-only-testing:NestoryUITests \
		$(BUILD_FLAGS) \
		2>&1 | tee ui-test-$(BUILD_LOG) || \
		{ echo "$(RED)❌ UI tests failed or timed out after $(TEST_TIMEOUT)s!$(NC)"; \
		  echo "$(YELLOW)Check ui-test-$(BUILD_LOG) for details$(NC)"; exit 1; }
	@echo "$(GREEN)✅ UI tests completed!$(NC)"

# ============================================================================
# CODE QUALITY & VERIFICATION
# ============================================================================

.PHONY: check
check: build test guard verify-wiring verify-no-stock tree ## Run all checks
	@echo "$(GREEN)✅ All checks passed!$(NC)"

.PHONY: guard
guard: ## Run guard suite (architecture checks)
	@echo "$(YELLOW)🛡️ Running guard suite...$(NC)"
	@timeout $(TEST_TIMEOUT) swift test || \
		{ echo "$(RED)❌ Swift tests in guard suite failed!$(NC)"; exit 1; }
	@if [ -f "./DevTools/nestoryctl/.build/release/nestoryctl" ]; then \
		timeout $(ARCH_VERIFY_TIMEOUT) ./DevTools/nestoryctl/.build/release/nestoryctl check || \
			{ echo "$(RED)❌ nestoryctl check failed or timed out!$(NC)"; exit 1; }; \
	else \
		echo "$(YELLOW)Building nestoryctl...$(NC)"; \
		(cd DevTools/nestoryctl && timeout $(BUILD_TIMEOUT) swift build -c release) || \
			{ echo "$(RED)❌ nestoryctl build failed!$(NC)"; exit 1; }; \
		timeout $(ARCH_VERIFY_TIMEOUT) ./DevTools/nestoryctl/.build/release/nestoryctl check || \
			{ echo "$(RED)❌ nestoryctl check failed or timed out!$(NC)"; exit 1; }; \
	fi
	@echo "$(GREEN)✅ Guard checks passed!$(NC)"

.PHONY: lint
lint: ## Run SwiftLint
	@echo "$(YELLOW)🔍 Running SwiftLint...$(NC)"
	@if command -v swiftlint >/dev/null 2>&1; then \
		timeout 120 swiftlint lint --strict || \
			{ echo "$(RED)❌ SwiftLint failed or timed out!$(NC)"; exit 1; }; \
	else \
		echo "$(YELLOW)⚠️  SwiftLint not installed. Install with: brew install swiftlint$(NC)"; \
	fi
	@echo "$(GREEN)✅ Lint completed!$(NC)"

.PHONY: format
format: ## Format code with SwiftFormat
	@echo "$(YELLOW)📐 Formatting code...$(NC)"
	@if command -v swiftformat >/dev/null 2>&1; then \
		timeout 120 swiftformat . --swiftversion 6.0 || \
			{ echo "$(RED)❌ SwiftFormat failed or timed out!$(NC)"; exit 1; }; \
		echo "$(GREEN)✅ Code formatted!$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  SwiftFormat not installed. Install with: brew install swiftformat$(NC)"; \
	fi

.PHONY: verify-arch
verify-arch: ## Verify architecture compliance
	@echo "$(YELLOW)🏗️  Verifying architecture...$(NC)"
	@echo "Checking layer dependencies..."
	@if [ -f "./DevTools/nestoryctl/.build/release/nestoryctl" ]; then \
		timeout $(ARCH_VERIFY_TIMEOUT) ./DevTools/nestoryctl/.build/release/nestoryctl arch-verify || \
			{ echo "$(RED)❌ Architecture verification failed or timed out!$(NC)"; exit 1; }; \
	else \
		echo "$(YELLOW)Building nestoryctl...$(NC)"; \
		(cd DevTools/nestoryctl && timeout $(BUILD_TIMEOUT) swift build -c release) || \
			{ echo "$(RED)❌ nestoryctl build failed!$(NC)"; exit 1; }; \
		timeout $(ARCH_VERIFY_TIMEOUT) ./DevTools/nestoryctl/.build/release/nestoryctl arch-verify || \
			{ echo "$(RED)❌ Architecture verification failed or timed out!$(NC)"; exit 1; }; \
	fi
	@echo "$(GREEN)✅ Architecture verified!$(NC)"

.PHONY: verify-wiring
verify-wiring: ## Verify all features are wired to UI
	@echo "$(YELLOW)🔌 Verifying feature wiring...$(NC)"
	@echo "Checking Services are accessible from UI..."
	@for service in Services/*.swift; do \
		if [ -f "$$service" ]; then \
			basename=$$(basename $$service .swift); \
			if [ "$$basename" = "CloudStorageServices" ]; then \
				if ! grep -r "CloudStorageManager" App-Main/ > /dev/null 2>&1; then \
					echo "$(RED)❌ $$basename not wired in UI!$(NC)"; \
					exit 1; \
				else \
					echo "$(GREEN)✓$(NC) $$basename is wired"; \
				fi \
			elif ! grep -r "$$basename" App-Main/ > /dev/null 2>&1; then \
				echo "$(RED)❌ $$basename not wired in UI!$(NC)"; \
				exit 1; \
			else \
				echo "$(GREEN)✓$(NC) $$basename is wired"; \
			fi \
		fi \
	done
	@echo "$(GREEN)✅ All services properly wired!$(NC)"

.PHONY: verify-no-stock
verify-no-stock: ## Verify no business inventory references
	@echo "$(YELLOW)🔍 Checking for inappropriate stock references...$(NC)"
	@if grep -r "low stock\|out of stock\|stock level\|inventory level" --include="*.swift" App-Main Services Features 2>/dev/null; then \
		echo "$(RED)❌ Found business inventory references! This is for insurance documentation!$(NC)"; \
		exit 1; \
	else \
		echo "$(GREEN)✅ No inappropriate stock references found$(NC)"; \
	fi

.PHONY: check-file-sizes
check-file-sizes: ## Check Swift file sizes and enforce limits (400/500/600 lines)
	@echo "$(YELLOW)📏 Checking file sizes...$(NC)"
	@timeout 30 ./scripts/check-file-sizes.sh || \
		(echo "$(RED)❌ Build blocked: Files exceeding 600 lines detected!$(NC)"; \
		 echo "$(YELLOW)Run 'make file-report' for details or 'make approve-large-file FILE=path/to/file.swift' to override$(NC)"; \
		 exit 1)

.PHONY: test-coverage
test-coverage: ## Run tests with coverage report
	@echo "$(YELLOW)🧪 Running tests with coverage...$(NC)"
	@timeout $(TEST_TIMEOUT) swift test --enable-code-coverage || \
		{ echo "$(RED)❌ Coverage tests failed or timed out!$(NC)"; exit 1; }
	@echo "$(YELLOW)📊 Generating coverage report...$(NC)"
	@if command -v xcov >/dev/null 2>&1; then \
		xcov --scheme $(SCHEME_DEV) --output_directory coverage_reports; \
		echo "$(GREEN)✅ Coverage report generated in coverage_reports/$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  xcov not installed. Install with: gem install xcov$(NC)"; \
		echo "$(BLUE)Coverage data available at: .build/debug/codecov/$(NC)"; \
	fi

.PHONY: clean-derived-data
clean-derived-data: ## Clean all Xcode derived data
	@echo "$(YELLOW)🧹 Cleaning all Xcode derived data...$(NC)"
	@rm -rf ~/Library/Developer/Xcode/DerivedData/*
	@rm -rf $(DERIVED_DATA_PATH)
	@rm -rf DerivedData
	@echo "$(GREEN)✅ Derived data cleaned!$(NC)"

.PHONY: fast-build
fast-build: clean-derived-data ## Fast parallel build with maximum optimization
	@echo "$(YELLOW)⚡ Fast parallel build ($(PARALLEL_JOBS) jobs)...$(NC)"
	@timeout $(BUILD_TIMEOUT) xcodebuild -scheme $(ACTIVE_SCHEME) \
		-destination '$(DESTINATION)' \
		-configuration $(CONFIGURATION) \
		-jobs $(PARALLEL_JOBS) \
		-quiet -hideShellScriptEnvironment \
		build 2>&1 | tee fast-$(BUILD_LOG) || \
		{ echo "$(RED)❌ Fast build failed or timed out!$(NC)"; \
		  echo "$(YELLOW)Check fast-$(BUILD_LOG) for details$(NC)"; exit 1; }
	@echo "$(GREEN)✅ Fast build completed in parallel!$(NC)"

.PHONY: file-report
file-report: ## Generate detailed report of file sizes
	@echo "$(BLUE)📊 File Size Report$(NC)"
	@./scripts/check-file-sizes.sh || true

.PHONY: approve-large-file
approve-large-file: ## Approve a large file override (usage: make approve-large-file FILE=path/to/file.swift)
	@if [ -z "$(FILE)" ]; then \
		echo "$(RED)Error: FILE parameter required. Usage: make approve-large-file FILE=path/to/file.swift$(NC)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)📝 Requesting approval for large file...$(NC)"
	@./scripts/manage-file-size-overrides.sh approve "$(FILE)"

.PHONY: revoke-large-file
revoke-large-file: ## Revoke a large file override (usage: make revoke-large-file FILE=path/to/file.swift)
	@if [ -z "$(FILE)" ]; then \
		echo "$(RED)Error: FILE parameter required. Usage: make revoke-large-file FILE=path/to/file.swift$(NC)"; \
		exit 1; \
	fi
	@./scripts/manage-file-size-overrides.sh revoke "$(FILE)"

.PHONY: list-overrides
list-overrides: ## List all approved large file overrides
	@./scripts/manage-file-size-overrides.sh list

.PHONY: audit-overrides
audit-overrides: ## Audit overrides to see which are still needed
	@./scripts/manage-file-size-overrides.sh audit

.PHONY: clean-overrides
clean-overrides: ## Remove unnecessary overrides (files now under threshold)
	@echo "$(YELLOW)🧹 Cleaning unnecessary overrides...$(NC)"
	@./scripts/manage-file-size-overrides.sh audit | grep "CAN REMOVE:" | cut -d':' -f2 | cut -d'(' -f1 | while read file; do \
		if [ ! -z "$$file" ]; then \
			./scripts/manage-file-size-overrides.sh revoke "$$file"; \
		fi \
	done
	@echo "$(GREEN)✅ Overrides cleaned!$(NC)"

# ============================================================================
# DEVELOPMENT TOOLS
# ============================================================================

.PHONY: new-feature
new-feature: ## Create a new feature (usage: make new-feature NAME=MyFeature)
	@if [ -z "$(NAME)" ]; then \
		echo "$(RED)Error: NAME parameter required. Usage: make new-feature NAME=MyFeature$(NC)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)📦 Creating new feature: $(NAME)...$(NC)"
	@mkdir -p Features/$(NAME)
	@echo "// $(NAME)Feature.swift" > Features/$(NAME)/$(NAME)Feature.swift
	@echo "// REMINDER: Wire this feature in UI!" >> Features/$(NAME)/$(NAME)Feature.swift
	@echo "$(GREEN)✅ Created Features/$(NAME)/$(NC)"
	@echo "$(YELLOW)⚠️  Remember to wire this in the UI!$(NC)"

.PHONY: new-service
new-service: ## Create a new service (usage: make new-service NAME=MyService)
	@if [ -z "$(NAME)" ]; then \
		echo "$(RED)Error: NAME parameter required. Usage: make new-service NAME=MyService$(NC)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)📦 Creating new service: $(NAME)...$(NC)"
	@echo "//" > Services/$(NAME).swift
	@echo "// Layer: Services" >> Services/$(NAME).swift
	@echo "// Module: $(NAME)" >> Services/$(NAME).swift
	@echo "// Purpose: [Add purpose here]" >> Services/$(NAME).swift
	@echo "//" >> Services/$(NAME).swift
	@echo "// REMINDER: This service MUST be wired up in the UI!" >> Services/$(NAME).swift
	@echo "" >> Services/$(NAME).swift
	@echo "import Foundation" >> Services/$(NAME).swift
	@echo "import SwiftData" >> Services/$(NAME).swift
	@echo "" >> Services/$(NAME).swift
	@echo "@MainActor" >> Services/$(NAME).swift
	@echo "public final class $(NAME): ObservableObject {" >> Services/$(NAME).swift
	@echo "    public init() {}" >> Services/$(NAME).swift
	@echo "    " >> Services/$(NAME).swift
	@echo "    // Add your service implementation here" >> Services/$(NAME).swift
	@echo "}" >> Services/$(NAME).swift
	@echo "$(GREEN)✅ Created Services/$(NAME).swift$(NC)"
	@echo "$(YELLOW)⚠️  Remember to wire this service in the UI!$(NC)"

.PHONY: screenshot
screenshot: gen ## Capture app screenshots
	@echo "$(YELLOW)📸 Capturing screenshots...$(NC)"
	@timeout $(TEST_TIMEOUT) xcodebuild test \
		-scheme $(SCHEME_DEV) \
		-destination '$(DESTINATION)' \
		-only-testing:NestoryUITests/NestoryScreenshotTests \
		$(BUILD_FLAGS) \
		2>&1 | tee screenshot-$(BUILD_LOG) || \
		{ echo "$(RED)❌ Screenshot capture failed or timed out!$(NC)"; \
		  echo "$(YELLOW)Check screenshot-$(BUILD_LOG) for details$(NC)"; exit 1; }
	@echo "$(GREEN)✅ Screenshots captured!$(NC)"

# ============================================================================
# PROJECT MAINTENANCE
# ============================================================================

.PHONY: clean
clean: ## Clean build artifacts
	@echo "$(YELLOW)🧹 Cleaning build artifacts...$(NC)"
	@rm -rf $(DERIVED_DATA_PATH)
	@rm -rf DerivedData
	@rm -rf ~/Library/Developer/Xcode/DerivedData/$(PROJECT_NAME)-*
	@if [ -f "$(PROJECT_FILE)/project.pbxproj" ]; then \
		xcodebuild clean 2>/dev/null || true; \
	fi
	@rm -f $(BUILD_LOG)
	@echo "$(GREEN)✅ Cleaned!$(NC)"

.PHONY: clean-logs
clean-logs: ## Clean build logs
	@rm -f $(BUILD_LOG)
	@rm -f *.log
	@rm -f *-$(BUILD_LOG)
	@rm -f test-*.log
	@rm -f ui-test-*.log
	@rm -f release-*.log
	@rm -f fast-*.log

.PHONY: clean-all
clean-all: ## Comprehensive cleanup of all build artifacts and system files
	@echo "$(YELLOW)🧹 Comprehensive project cleanup...$(NC)"
	@echo "  Removing build artifacts..."
	@rm -rf .build build */build
	@rm -rf DerivedData
	@rm -rf ~/Library/Developer/Xcode/DerivedData/$(PROJECT_NAME)-*
	@echo "  Removing system files..."
	@find . -name ".DS_Store" -delete 2>/dev/null || true
	@find . -name "*.log" -delete 2>/dev/null || true
	@find . -name "Thumbs.db" -delete 2>/dev/null || true
	@echo "  Cleaning cache directories..."
	@find . -type d -name "*cache*" -exec rm -rf {} + 2>/dev/null || true
	@echo "  Running git clean..."
	@git clean -fd 2>/dev/null || true
	@if [ -f "$(PROJECT_FILE)/project.pbxproj" ]; then \
		xcodebuild clean 2>/dev/null || true; \
	fi
	@echo "$(GREEN)✅ Comprehensive cleanup complete!$(NC)"

.PHONY: deep-clean
deep-clean: clean-all ## Deep clean including system-wide Xcode caches
	@echo "$(YELLOW)🔥 Deep cleaning system caches...$(NC)"
	@echo "  Removing global Xcode DerivedData..."
	@rm -rf ~/Library/Developer/Xcode/DerivedData
	@echo "  Removing Xcode caches..."
	@rm -rf ~/Library/Caches/com.apple.dt.Xcode
	@rm -rf ~/Library/Developer/CoreSimulator/Caches
	@echo "  Removing iOS Simulator cache..."
	@xcrun simctl shutdown all 2>/dev/null || true
	@echo "$(GREEN)✅ Deep clean complete!$(NC)"

.PHONY: reset-simulator
reset-simulator: ## Reset iPhone 16 Pro Max simulator
	@echo "$(YELLOW)🔄 Resetting iPhone 16 Pro Max simulator...$(NC)"
	@xcrun simctl shutdown "$(SIMULATOR_NAME)" 2>/dev/null || true
	@xcrun simctl erase "$(SIMULATOR_NAME)" 2>/dev/null || true
	@echo "$(GREEN)✅ Simulator reset!$(NC)"

.PHONY: install-hooks
install-hooks: ## Install git hooks
	@echo "$(YELLOW)🪝 Installing git hooks...$(NC)"
	@if [ -f "./DevTools/install_hooks.sh" ]; then \
		./DevTools/install_hooks.sh; \
	else \
		echo "$(YELLOW)⚠️  install_hooks.sh not found$(NC)"; \
	fi
	@echo "$(GREEN)✅ Git hooks installed!$(NC)"

.PHONY: setup
setup: check-tools install-hooks ## Initial project setup
	@echo "$(YELLOW)🚀 Setting up Nestory project...$(NC)"
	@echo "Installing dependencies..."
	@if command -v xcodegen >/dev/null 2>&1; then \
		echo "$(GREEN)✓$(NC) xcodegen installed"; \
	else \
		echo "$(YELLOW)Installing xcodegen...$(NC)"; \
		brew install xcodegen; \
	fi
	@echo "$(GREEN)✅ Project setup complete!$(NC)"

# ============================================================================
# DOCUMENTATION & REPORTS
# ============================================================================

.PHONY: tree
tree: ## Display and save clean project tree structure
	@if ! command -v tree &> /dev/null; then \
		echo "$(RED)Error: 'tree' command not found. Please install it:$(NC)"; \
		echo "  brew install tree"; \
		exit 1; \
	fi
	@echo "$(BLUE)╔══════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║                      Project Structure                       ║$(NC)"
	@echo "$(BLUE)╚══════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@tree --dirsfirst \
		-I 'build|*.xcuserdatad|*.xcworkspace|xcuserdata|*.xcbuilddata|DerivedData|*.build|Index|Logs|ModuleCache|SourcePackages|*.swiftpm|*.o|*.dylib|*.a|*.dSYM|*.ipa|*.xcarchive|.DS_Store|Thumbs.db|node_modules|*.pyc|__pycache__|.git|.svn|.hg|.bzr|*.orig|*.swp|*.swo|*~|*.bak|*.tmp|*.temp|*.log|*.cache|dist|target|out|bin|obj|*.class|*.jar|*.war|*.ear|.idea|*.iml|.vscode|*.code-workspace|.gradle|.sass-cache|.npm|.yarn|package-lock.json|yarn.lock|Pods|Carthage|.build|*.pid|*.seed|*.pid.lock|coverage|.nyc_output|.grunt|bower_components|jspm_packages|typings|lib-cov|*.cover|.hypothesis|.pytest_cache|htmlcov|.tox|.coverage|.coverage.*|.cache|nosetests.xml|coverage.xml|*.mo|*.pot|local_settings.py|db.sqlite3|instance|.webassets-cache|.scrapy|docs/_build|target|.ipynb_checkpoints|.python-version|.env|.venv|env|venv|ENV|env.bak|venv.bak|.spyderproject|.spyproject|.ropeproject|site|.mypy_cache|.dmypy.json|dmypy.json|.pyre|*.so|*.egg|*.egg-info|MANIFEST|attachments|XCBuildData|EagerLinkingTBDs|PackageFrameworks|*.swiftmodule|*.hmap|*.xcent|*.xcent.der|Objects-normal|*.resp|*FileList|*OutputFileMap.json|*.msgpack|build.db|UserInterfaceState.xcuserstate|.build_counter'
	@echo ""
	@DIR_COUNT=$$(find . -type d ! -path '*/\.*' ! -path '*/build/*' ! -path '*/node_modules/*' 2>/dev/null | wc -l | tr -d ' ')
	@FILE_COUNT=$$(find . -type f ! -path '*/\.*' ! -path '*/build/*' ! -path '*/node_modules/*' ! -name '*.xcuserdatad' 2>/dev/null | wc -l | tr -d ' ')
	@echo "$(YELLOW)📁 Directories: $$DIR_COUNT | 📄 Files: $$FILE_COUNT$(NC)"
	@echo ""
	@# Also save to TREE.md silently
	@echo "# Project Structure" > TREE.md
	@echo "" >> TREE.md
	@echo "_Last updated: $$(date '+%Y-%m-%d %H:%M:%S')_" >> TREE.md
	@echo "" >> TREE.md
	@echo '```' >> TREE.md
	@tree --dirsfirst \
		-I 'build|*.xcuserdatad|*.xcworkspace|xcuserdata|*.xcbuilddata|DerivedData|*.build|Index|Logs|ModuleCache|SourcePackages|*.swiftpm|*.o|*.dylib|*.a|*.dSYM|*.ipa|*.xcarchive|.DS_Store|Thumbs.db|node_modules|*.pyc|__pycache__|.git|.svn|.hg|.bzr|*.orig|*.swp|*.swo|*~|*.bak|*.tmp|*.temp|*.log|*.cache|dist|target|out|bin|obj|*.class|*.jar|*.war|*.ear|.idea|*.iml|.vscode|*.code-workspace|.gradle|.sass-cache|.npm|.yarn|package-lock.json|yarn.lock|Pods|Carthage|.build|*.pid|*.seed|*.pid.lock|coverage|.nyc_output|.grunt|bower_components|jspm_packages|typings|lib-cov|*.cover|.hypothesis|.pytest_cache|htmlcov|.tox|.coverage|.coverage.*|.cache|nosetests.xml|coverage.xml|*.mo|*.pot|local_settings.py|db.sqlite3|instance|.webassets-cache|.scrapy|docs/_build|target|.ipynb_checkpoints|.python-version|.env|.venv|env|venv|ENV|env.bak|venv.bak|.spyderproject|.spyproject|.ropeproject|site|.mypy_cache|.dmypy.json|dmypy.json|.pyre|*.so|*.egg|*.egg-info|MANIFEST|attachments|XCBuildData|EagerLinkingTBDs|PackageFrameworks|*.swiftmodule|*.hmap|*.xcent|*.xcent.der|Objects-normal|*.resp|*FileList|*OutputFileMap.json|*.msgpack|build.db|UserInterfaceState.xcuserstate|.build_counter' \
		>> TREE.md 2>/dev/null
	@echo '```' >> TREE.md
	@echo "" >> TREE.md
	@echo "_📁 Directories: $$DIR_COUNT | 📄 Files: $$FILE_COUNT_" >> TREE.md
	@echo "$(GREEN)✅ Tree also saved to TREE.md$(NC)"

.PHONY: doctor
doctor: ## Diagnose project setup issues
	@echo "$(BLUE)👨‍⚕️ Running project diagnostics...$(NC)"
	@echo ""
	@echo "$(YELLOW)Environment:$(NC)"
	@swift --version | head -1
	@xcodebuild -version | head -1
	@echo ""
	@echo "$(YELLOW)Tools:$(NC)"
	@command -v xcodebuild >/dev/null 2>&1 && echo "$(GREEN)✓$(NC) Xcode" || echo "$(RED)✗$(NC) Xcode"
	@command -v swift >/dev/null 2>&1 && echo "$(GREEN)✓$(NC) Swift" || echo "$(RED)✗$(NC) Swift"
	@command -v xcodegen >/dev/null 2>&1 && echo "$(GREEN)✓$(NC) xcodegen" || echo "$(YELLOW)⚠$(NC) xcodegen (optional)"
	@command -v swiftlint >/dev/null 2>&1 && echo "$(GREEN)✓$(NC) SwiftLint" || echo "$(YELLOW)⚠$(NC) SwiftLint (optional)"
	@command -v swiftformat >/dev/null 2>&1 && echo "$(GREEN)✓$(NC) SwiftFormat" || echo "$(YELLOW)⚠$(NC) SwiftFormat (optional)"
	@echo ""
	@echo "$(YELLOW)Project Structure:$(NC)"
	@[ -d "App-Main" ] && echo "$(GREEN)✓$(NC) App-Main directory" || echo "$(RED)✗$(NC) App-Main directory"
	@[ -d "Services" ] && echo "$(GREEN)✓$(NC) Services directory" || echo "$(RED)✗$(NC) Services directory"
	@[ -d "Foundation" ] && echo "$(GREEN)✓$(NC) Foundation directory" || echo "$(RED)✗$(NC) Foundation directory"
	@[ -d "Infrastructure" ] && echo "$(GREEN)✓$(NC) Infrastructure directory" || echo "$(RED)✗$(NC) Infrastructure directory"
	@[ -d "UI" ] && echo "$(GREEN)✓$(NC) UI directory" || echo "$(RED)✗$(NC) UI directory"
	@[ -f "$(PROJECT_FILE)/project.pbxproj" ] && echo "$(GREEN)✓$(NC) Xcode project" || echo "$(YELLOW)⚠$(NC) Xcode project (will be generated)"
	@[ -f "project.yml" ] && echo "$(GREEN)✓$(NC) project.yml" || echo "$(YELLOW)⚠$(NC) project.yml"
	@[ -f "CLAUDE.md" ] && echo "$(GREEN)✓$(NC) CLAUDE.md" || echo "$(RED)✗$(NC) CLAUDE.md"
	@echo ""
	@echo "$(YELLOW)Simulator:$(NC)"
	@xcrun simctl list devices | grep -q "$(SIMULATOR_NAME)" && \
		echo "$(GREEN)✓$(NC) iPhone 16 Pro Max simulator available" || \
		echo "$(RED)✗$(NC) iPhone 16 Pro Max simulator not found"
	@echo ""
	@echo "$(YELLOW)Services Wiring Status:$(NC)"
	@for service in Services/*.swift; do \
		if [ -f "$$service" ]; then \
			basename=$$(basename $$service .swift); \
			if grep -r "$$basename" App-Main/ > /dev/null 2>&1; then \
				echo "$(GREEN)✓$(NC) $$basename"; \
			else \
				echo "$(RED)✗$(NC) $$basename (not wired!)"; \
			fi \
		fi \
	done

.PHONY: stats
stats: ## Show project statistics
	@echo "$(BLUE)📊 Project Statistics$(NC)"
	@echo "────────────────────"
	@echo "Swift files: $$(find . -name "*.swift" -not -path "./.build/*" -not -path "./DerivedData/*" | wc -l)"
	@echo "Lines of code: $$(find . -name "*.swift" -not -path "./.build/*" -not -path "./DerivedData/*" -exec wc -l {} + | tail -1 | awk '{print $$1}')"
	@echo "Services: $$(ls -1 Services/*.swift 2>/dev/null | wc -l)"
	@echo "Views: $$(ls -1 App-Main/*View.swift 2>/dev/null | wc -l)"
	@echo "Models: $$(ls -1 Foundation/Models/*.swift 2>/dev/null | wc -l)"
	@echo "UI Components: $$(ls -1 UI/UI-Components/*.swift 2>/dev/null | wc -l)"
	@if [ -f .build_counter ]; then \
		echo "Build count: $$(cat .build_counter) (tree shown every 3rd build)"; \
	fi

.PHONY: build-count
build-count: ## Show or reset build counter
	@if [ -f .build_counter ]; then \
		COUNT=$$(cat .build_counter); \
		echo "$(BLUE)🔢 Current build count: $$COUNT$(NC)"; \
		NEXT_TREE=$$((3 - (COUNT % 3))); \
		if [ $$NEXT_TREE -eq 3 ]; then \
			echo "$(GREEN)🌳 Tree will be shown on next build!$(NC)"; \
		else \
			echo "$(YELLOW)🌳 Tree will be shown in $$NEXT_TREE more build(s)$(NC)"; \
		fi; \
	else \
		echo "$(YELLOW)No builds recorded yet$(NC)"; \
	fi

.PHONY: reset-build-count
reset-build-count: ## Reset the build counter
	@echo "0" > .build_counter
	@echo "$(GREEN)✅ Build counter reset to 0$(NC)"

.PHONY: todo
todo: ## List all TODOs in the project
	@echo "$(YELLOW)📝 TODOs in project:$(NC)"
	@grep -r "TODO\|FIXME\|REMINDER" --include="*.swift" --exclude-dir=.build --exclude-dir=DerivedData . | \
		grep -v "Binary file" | \
		sed 's/^/  /'

.PHONY: context
context: tree ## Generate context for new chat sessions
	@echo "$(BLUE)📋 Generating project context...$(NC)"
	@echo "# Nestory Project Context" > CURRENT_CONTEXT.md
	@echo "Generated: $$(date)" >> CURRENT_CONTEXT.md
	@echo "" >> CURRENT_CONTEXT.md
	@echo "## CRITICAL REMINDERS" >> CURRENT_CONTEXT.md
	@echo "- **App Type**: Personal home inventory for INSURANCE DOCUMENTATION" >> CURRENT_CONTEXT.md
	@echo "- **NOT**: Business inventory or stock management" >> CURRENT_CONTEXT.md
	@echo "- **Simulator**: ALWAYS use iPhone 16 Pro Max (per CLAUDE.md)" >> CURRENT_CONTEXT.md
	@echo "- **Architecture**: App → Services → Infrastructure → Foundation" >> CURRENT_CONTEXT.md
	@echo "- **Focus**: Insurance claims, warranties, receipts, disaster documentation" >> CURRENT_CONTEXT.md
	@echo "" >> CURRENT_CONTEXT.md
	@echo "## Build & Run Commands" >> CURRENT_CONTEXT.md
	@echo '```bash' >> CURRENT_CONTEXT.md
	@echo "make run          # Build and run on iPhone 16 Pro Max" >> CURRENT_CONTEXT.md
	@echo "make build        # Build only" >> CURRENT_CONTEXT.md
	@echo "make check        # Run all verification checks" >> CURRENT_CONTEXT.md
	@echo "make doctor       # Diagnose setup issues" >> CURRENT_CONTEXT.md
	@echo '```' >> CURRENT_CONTEXT.md
	@echo "" >> CURRENT_CONTEXT.md
	@echo "## Active Services" >> CURRENT_CONTEXT.md
	@ls -1 Services/*.swift 2>/dev/null | sed 's/Services\//- /' >> CURRENT_CONTEXT.md || echo "No services found" >> CURRENT_CONTEXT.md
	@echo "" >> CURRENT_CONTEXT.md
	@echo "## UI Views" >> CURRENT_CONTEXT.md
	@ls -1 App-Main/*View.swift 2>/dev/null | sed 's/App-Main\//- /' >> CURRENT_CONTEXT.md || echo "No views found" >> CURRENT_CONTEXT.md
	@echo "" >> CURRENT_CONTEXT.md
	@echo "## Models" >> CURRENT_CONTEXT.md
	@ls -1 Foundation/Models/*.swift 2>/dev/null | sed 's/Foundation\/Models\//- /' >> CURRENT_CONTEXT.md || echo "No models found" >> CURRENT_CONTEXT.md
	@echo "" >> CURRENT_CONTEXT.md
	@echo "## Wiring Status" >> CURRENT_CONTEXT.md
	@for service in Services/*.swift; do \
		if [ -f "$$service" ]; then \
			basename=$$(basename $$service .swift); \
			if grep -r "$$basename" App-Main/*.swift > /dev/null 2>&1; then \
				echo "✓ $$basename - wired" >> CURRENT_CONTEXT.md; \
			else \
				echo "✗ $$basename - NOT WIRED" >> CURRENT_CONTEXT.md; \
			fi \
		fi \
	done
	@echo "" >> CURRENT_CONTEXT.md
	@echo "## Key Project Rules" >> CURRENT_CONTEXT.md
	@echo "1. ALWAYS wire new features in UI (no orphaned code)" >> CURRENT_CONTEXT.md
	@echo "2. NO 'low stock' or business inventory references" >> CURRENT_CONTEXT.md
	@echo "3. Focus on insurance documentation features" >> CURRENT_CONTEXT.md
	@echo "4. Every service must be @MainActor and ObservableObject" >> CURRENT_CONTEXT.md
	@echo "5. Use SwiftData for persistence" >> CURRENT_CONTEXT.md
	@echo "6. Follow strict Swift 6 concurrency" >> CURRENT_CONTEXT.md
	@echo "" >> CURRENT_CONTEXT.md
	@echo "## Recent TODOs" >> CURRENT_CONTEXT.md
	@grep -r "TODO" --include="*.swift" --exclude-dir=.build . 2>/dev/null | head -5 >> CURRENT_CONTEXT.md || echo "No TODOs found" >> CURRENT_CONTEXT.md
	@echo "" >> CURRENT_CONTEXT.md
	@echo "## Git Status" >> CURRENT_CONTEXT.md
	@git status --short >> CURRENT_CONTEXT.md 2>/dev/null || echo "Not in git repo" >> CURRENT_CONTEXT.md
	@echo "" >> CURRENT_CONTEXT.md
	@echo "## Last Commit" >> CURRENT_CONTEXT.md
	@git log -1 --oneline >> CURRENT_CONTEXT.md 2>/dev/null || echo "No commits yet" >> CURRENT_CONTEXT.md
	@echo "$(GREEN)✅ Context saved to CURRENT_CONTEXT.md$(NC)"
	@echo "$(YELLOW)Share CURRENT_CONTEXT.md at the start of new chat sessions!$(NC)"

# ============================================================================
# UTILITIES
# ============================================================================

.PHONY: check-tools
check-tools: ## Check required tools are installed
	@command -v xcodebuild >/dev/null 2>&1 || { echo "$(RED)❌ xcodebuild not found. Install Xcode.$(NC)"; exit 1; }
	@command -v xcrun >/dev/null 2>&1 || { echo "$(RED)❌ xcrun not found. Install Xcode Command Line Tools.$(NC)"; exit 1; }
	@command -v swift >/dev/null 2>&1 || { echo "$(RED)❌ swift not found. Install Xcode.$(NC)"; exit 1; }

.PHONY: open
open: ## Open project in Xcode
	@echo "$(YELLOW)📱 Opening in Xcode...$(NC)"
	@if [ -f "$(PROJECT_FILE)/project.pbxproj" ]; then \
		open $(PROJECT_FILE); \
	else \
		echo "$(YELLOW)Generating project first...$(NC)"; \
		make gen; \
		open $(PROJECT_FILE); \
	fi

.PHONY: simulator
simulator: ## Open iOS Simulator with iPhone 16 Pro Max
	@echo "$(YELLOW)📱 Opening Simulator with iPhone 16 Pro Max...$(NC)"
	@open -a Simulator
	@xcrun simctl boot "$(SIMULATOR_NAME)" 2>/dev/null || true

# ============================================================================
# CI/CD COMMANDS
# ============================================================================

.PHONY: ci
ci: clean check ## Run CI pipeline
	@echo "$(GREEN)✅ CI pipeline completed successfully!$(NC)"

.PHONY: archive
archive: gen ## Create app archive
	@echo "$(YELLOW)📦 Creating archive...$(NC)"
	@timeout 600 xcodebuild archive \
		-scheme $(SCHEME_DEV) \
		-archivePath $(DERIVED_DATA_PATH)/$(PROJECT_NAME).xcarchive \
		$(BUILD_FLAGS) \
		2>&1 | tee archive-$(BUILD_LOG) || \
		{ echo "$(RED)❌ Archive creation failed or timed out!$(NC)"; \
		  echo "$(YELLOW)Check archive-$(BUILD_LOG) for details$(NC)"; exit 1; }
	@echo "$(GREEN)✅ Archive created at $(DERIVED_DATA_PATH)/$(PROJECT_NAME).xcarchive$(NC)"

# ============================================================================
# EMERGENCY COMMANDS
# ============================================================================

.PHONY: fix
fix: clean reset-simulator build ## Emergency fix - clean everything and rebuild
	@echo "$(GREEN)✅ Emergency fix completed!$(NC)"

.PHONY: nuke
nuke: ## Nuclear option - clean EVERYTHING (requires confirmation)
	@echo "$(RED)⚠️  WARNING: This will delete all build artifacts and reset simulators!$(NC)"
	@echo "Press Ctrl+C to cancel, or Enter to continue..."
	@read confirm
	@rm -rf $(DERIVED_DATA_PATH)
	@rm -rf DerivedData
	@rm -rf ~/Library/Developer/Xcode/DerivedData/*
	@xcrun simctl erase all
	@echo "$(GREEN)✅ Everything has been reset!$(NC)"

# ============================================================================
# SCHEME-SPECIFIC COMMANDS
# ============================================================================

.PHONY: run-dev run-staging run-prod
run-dev: ## Run with Development scheme (default)
	@$(MAKE) run SCHEME_TARGET=dev

run-staging: ## Run with Staging scheme
	@$(MAKE) run SCHEME_TARGET=staging

run-prod: ## Run with Production scheme
	@$(MAKE) run SCHEME_TARGET=prod

.PHONY: build-dev build-staging build-prod
build-dev: ## Build with Development scheme
	@$(MAKE) build SCHEME_TARGET=dev

build-staging: ## Build with Staging scheme
	@$(MAKE) build SCHEME_TARGET=staging

build-prod: ## Build with Production scheme
	@$(MAKE) build SCHEME_TARGET=prod

.PHONY: test-dev test-staging test-prod
test-dev: ## Test with Development scheme
	@$(MAKE) test SCHEME_TARGET=dev

test-staging: ## Test with Staging scheme
	@$(MAKE) test SCHEME_TARGET=staging

test-prod: ## Test with Production scheme
	@$(MAKE) test SCHEME_TARGET=prod

# ============================================================================
# CONFIGURATION MANAGEMENT
# ============================================================================

.PHONY: generate-config
generate-config: ## Regenerate all configurations from master ProjectConfiguration.json
	@echo "$(BLUE)🔧 Regenerating all project configurations...$(NC)"
	@swift Scripts/generate-project-config.swift
	@echo "$(GREEN)✅ All configurations updated from master source!$(NC)"
	@echo "$(YELLOW)📝 Run 'make gen' to apply changes to Xcode project$(NC)"

.PHONY: validate-config
validate-config: ## Validate master configuration file
	@echo "$(BLUE)🔍 Validating ProjectConfiguration.json...$(NC)"
	@swift -c "import Foundation; let data = try Data(contentsOf: URL(fileURLWithPath: \"Config/ProjectConfiguration.json\")); let _ = try JSONSerialization.jsonObject(with: data)" 2>/dev/null && echo "$(GREEN)✅ Configuration file is valid JSON$(NC)" || echo "$(RED)❌ Configuration file has JSON errors$(NC)"

# ============================================================================
# QUICK ACCESS COMMANDS
# ============================================================================

.PHONY: r
r: run ## Shortcut for 'make run'

.PHONY: b
b: build ## Shortcut for 'make build'

.PHONY: c
c: check ## Shortcut for 'make check'

.PHONY: d
d: doctor ## Shortcut for 'make doctor'

.PHONY: f
f: fast-build ## Shortcut for 'make fast-build'

# ============================================================================
# END OF MAKEFILE
# ============================================================================