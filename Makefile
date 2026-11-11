# Repo tasks. Run: make hooks, make fitness, make format, make requirements, make demo, make demo-install DEVICE=<udid>
#
# How the requirement tests run: docs/architecture/04-code.md, Tests.

FITNESS_INSTALL = $(HOME)/.local/share/fitness/fitness-install

.PHONY: hooks fitness format requirements demo demo-install

# Use the org-synced hooks in .fitness-hooks (see .github/fitness-setup.md).
hooks:
	git config --local core.hooksPath .fitness-hooks

# Run the full fitness suite, as CI does.
fitness:
	"$(FITNESS_INSTALL)" --version latest

# Wrap and indent every Swift file with the toolchain's swift-format, per .swift-format.
format:
	swift format format --in-place --recursive --configuration .swift-format Sources Tests Examples Package.swift

# Build the package and run every requirement test on the Mac.
requirements:
	swift test

# Build the demo app for any iPhone without signing credentials, as a fresh clone would.
# The project signs with the owner's team; CODE_SIGNING_ALLOWED=NO on the command line turns that off.
demo:
	xcodegen generate --spec Examples/FlagDebugDemo/project.yml
	xcodebuild build -project Examples/FlagDebugDemo/FlagDebugDemo.xcodeproj -scheme FlagDebugDemo \
		-configuration Debug -destination generic/platform=iOS -derivedDataPath .build/demo CODE_SIGNING_ALLOWED=NO

# Sign the demo with the project's team, then install and launch it on one paired device,
# registering the device with the team when it is new. List devices with `xcrun devicectl list devices`.
DEMO_APP = .build/demo-device/Build/Products/Debug-iphoneos/FlagDebugDemo.app
demo-install:
	test -n "$(DEVICE)" || { echo "usage: make demo-install DEVICE=<udid>"; exit 2; }
	xcodegen generate --spec Examples/FlagDebugDemo/project.yml
	xcodebuild build -project Examples/FlagDebugDemo/FlagDebugDemo.xcodeproj -scheme FlagDebugDemo \
		-configuration Debug -destination id=$(DEVICE) -derivedDataPath .build/demo-device \
		-allowProvisioningUpdates -allowProvisioningDeviceRegistration
	xcrun devicectl device install app --device $(DEVICE) $(DEMO_APP)
	xcrun devicectl device process launch --device $(DEVICE) \
		"$$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' $(DEMO_APP)/Info.plist)"
