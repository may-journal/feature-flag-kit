# Repo tasks. Run: make hooks, make fitness, make format, make requirements, make screenshots
#
# How the requirement tests run: docs/architecture/04-code.md, Tests.

FITNESS_INSTALL = $(HOME)/.local/share/fitness/fitness-install

.PHONY: hooks fitness format requirements screenshots

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

# Photograph the debug screen on a fresh iOS simulator into docs/images; see the script.
screenshots:
	Examples/FlagDebugDemo/screenshots.sh
