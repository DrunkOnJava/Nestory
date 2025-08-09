.PHONY: doctor gen build test guard install-hooks clean

doctor:
	@echo "🏥 Checking environment..."
	@swift --version
	@xcodebuild -version
	@which xcodegen

gen:
	@echo "🔧 Generating Xcode project..."
	@xcodegen generate

build: gen
	@echo "🔨 Building..."
	@xcodebuild -scheme Nestory -destination "platform=iOS Simulator,name=iPhone 15" build

test:
	@echo "🧪 Running tests..."
	@swift test

guard:
	@echo "🛡️ Running guard suite..."
	@swift test
	@./DevTools/nestoryctl/.build/release/nestoryctl check

install-hooks:
	@echo "🪝 Installing git hooks..."
	@./DevTools/install_hooks.sh

clean:
	@echo "🧹 Cleaning..."
	@rm -rf .build
	@rm -rf DerivedData
	@xcodebuild clean