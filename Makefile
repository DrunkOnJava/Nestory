.PHONY: all guard install-hooks spec-verify spec-commit arch-verify spm-audit licenses clean test build

# Default target
all: guard

# Run all guard checks
guard:
	@echo "🔍 Running guard suite..."
	@swift test --filter ArchitectureTests
	@swift build -c release --package-path DevTools/nestoryctl
	@./DevTools/nestoryctl/.build/release/nestoryctl check

# Install git hooks
install-hooks:
	@echo "📦 Installing git hooks..."
	@./DevTools/install_hooks.sh

# Verify SPEC.json hash
spec-verify:
	@swift build -c release --package-path DevTools/nestoryctl
	@./DevTools/nestoryctl/.build/release/nestoryctl spec-verify

# Update SPEC.lock with new hash
spec-commit:
	@swift build -c release --package-path DevTools/nestoryctl
	@./DevTools/nestoryctl/.build/release/nestoryctl spec-commit

# Verify architecture conformance
arch-verify:
	@swift build -c release --package-path DevTools/nestoryctl
	@./DevTools/nestoryctl/.build/release/nestoryctl arch-verify

# Audit SPM dependencies
spm-audit:
	@swift build -c release --package-path DevTools/nestoryctl
	@./DevTools/nestoryctl/.build/release/nestoryctl spm-audit

# Update license file
licenses:
	@swift build -c release --package-path DevTools/nestoryctl
	@./DevTools/nestoryctl/.build/release/nestoryctl licenses

# Run tests
test:
	@echo "🧪 Running tests..."
	@swift test

# Build the project
build:
	@echo "🔨 Building project..."
	@swift build

# Build nestoryctl
build-cli:
	@echo "🔨 Building nestoryctl..."
	@swift build -c release --package-path DevTools/nestoryctl

# Clean build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	@swift package clean
	@rm -rf .build
	@rm -rf DevTools/nestoryctl/.build

# Help
help:
	@echo "Nestory Guard Rails - Makefile Targets"
	@echo ""
	@echo "  make guard         - Run all guard checks (default)"
	@echo "  make install-hooks - Install git pre-commit hooks"
	@echo "  make spec-verify   - Verify SPEC.json hash matches SPEC.lock"
	@echo "  make spec-commit   - Update SPEC.lock with new hash"
	@echo "  make arch-verify   - Verify architecture conformance"
	@echo "  make spm-audit     - Audit SPM dependencies are pinned"
	@echo "  make licenses      - Update third-party licenses"
	@echo "  make test          - Run all tests"
	@echo "  make build         - Build the project"
	@echo "  make build-cli     - Build nestoryctl CLI"
	@echo "  make clean         - Clean build artifacts"
	@echo "  make help          - Show this help message"