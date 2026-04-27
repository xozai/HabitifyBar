APP_NAME     = HabitifyBar
INSTALL_DIR  = $(HOME)/Applications
BUILD_DIR    = .build/arm64-apple-macosx/release
APP_BUNDLE   = $(APP_NAME).app
CONTENTS     = $(APP_BUNDLE)/Contents
MACOS_DIR    = $(CONTENTS)/MacOS

.PHONY: all build bundle sign install uninstall clean

all: bundle sign

build:
	swift build -c release --arch arm64

bundle: build
	@rm -rf "$(APP_BUNDLE)"
	@mkdir -p "$(MACOS_DIR)"
	@cp "$(BUILD_DIR)/$(APP_NAME)" "$(MACOS_DIR)/$(APP_NAME)"
	@cp Sources/Info.plist "$(CONTENTS)/Info.plist"

sign: bundle
	codesign --force --deep --sign - \
	  --entitlements Sources/$(APP_NAME).entitlements \
	  --options runtime "$(APP_BUNDLE)"

install: sign
	@mkdir -p "$(INSTALL_DIR)"
	@rm -rf "$(INSTALL_DIR)/$(APP_BUNDLE)"
	@cp -R "$(APP_BUNDLE)" "$(INSTALL_DIR)/$(APP_BUNDLE)"
	@echo "Installed. Launch with:"
	@echo "  open $(INSTALL_DIR)/$(APP_BUNDLE)"

uninstall:
	rm -rf "$(INSTALL_DIR)/$(APP_BUNDLE)"

clean:
	rm -rf "$(APP_BUNDLE)"
	swift package clean
