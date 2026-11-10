#!/bin/zsh
# Photographs each FlagDebugView story in light and dark into docs/images; run make screenshots.
# It needs Xcode and XcodeGen, and makes, then deletes, its own simulator.
set -euo pipefail

repo=${0:A:h:h:h}
demo=$repo/Examples/FlagDebugDemo
out=$repo/docs/images
device_type=com.apple.CoreSimulator.SimDeviceType.iPhone-17
bundle=com.example.FlagDebugDemo

# Each story's file name, then its name in the storybook.
stories=(
    flag-debug-catalog "FlagDebugView: catalog"
    flag-debug-forced "FlagDebugView: forced by launch argument"
    flag-debug-toggled "FlagDebugView: toggled on by the user"
    flag-debug-number "FlagDebugView: number edited"
    flag-debug-reset "FlagDebugView: Reset all confirmation"
)

# One tool drives a simulator at a time, so refuse to start while any is booted.
if xcrun simctl list devices booted | grep -q Booted; then
    echo "A simulator is already booted; wait until it is shut down, then run again." >&2
    exit 1
fi

runtime=$(xcrun simctl list runtimes | grep -o 'com.apple.CoreSimulator.SimRuntime.iOS-[0-9-]*' | tail -1)
udid=$(xcrun simctl create FlagDebugDemo-shots $device_type "$runtime")

cleanup() {
    xcrun simctl shutdown "$udid" >/dev/null 2>&1 || true
    xcrun simctl delete "$udid"
}
trap cleanup EXIT

xcodegen generate --quiet --spec "$demo/project.yml"
xcodebuild build -quiet -project "$demo/FlagDebugDemo.xcodeproj" -scheme FlagDebugDemo \
    -destination "id=$udid" -derivedDataPath "$demo/.build"
app=$demo/.build/Build/Products/Debug-iphonesimulator/FlagDebugDemo.app

xcrun simctl boot "$udid"
xcrun simctl bootstatus "$udid" >/dev/null
xcrun simctl install "$udid" "$app"
xcrun simctl status_bar "$udid" override --time 9:41 --batteryState charged --batteryLevel 100
mkdir -p "$out"

# Opens the story `$2` and saves the screen as docs/images/<$1>.png, scaled from 3x to 2x.
shoot() {
    xcrun simctl launch --terminate-running-process "$udid" $bundle --storybook "$2" >/dev/null
    sleep 4
    local file=$out/$1.png
    xcrun simctl io "$udid" screenshot --type=png "$file" >/dev/null
    local width=$(sips -g pixelWidth "$file" | awk '/pixelWidth/ { print $2 }')
    sips --resampleWidth $((width * 2 / 3)) "$file" >/dev/null
}

for file name in $stories; do
    shoot $file-light "$name"
    shoot $file-dark "$name, dark"
done
