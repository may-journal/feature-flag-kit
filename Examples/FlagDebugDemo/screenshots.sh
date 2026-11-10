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

# Saves the screen as `$1` once two captures a second apart match, so the story has drawn.
# The first capture waits two seconds, past the launch screen, which also holds still.
settle() {
    local previous=$1.previous.png
    sleep 2
    xcrun simctl io "$udid" screenshot --type=png "$previous" >/dev/null 2>&1
    for attempt in {1..30}; do
        sleep 1
        xcrun simctl io "$udid" screenshot --type=png "$1" >/dev/null 2>&1
        if cmp -s "$1" "$previous"; then
            rm -f "$previous"
            return
        fi
        mv "$1" "$previous"
    done
    rm -f "$previous"
    echo "The story never stopped changing on screen: $1" >&2
    exit 1
}

# Opens the story `$2` and saves the screen as docs/images/<$1>.png, scaled from 3x to 2x.
shoot() {
    xcrun simctl launch --terminate-running-process "$udid" $bundle --storybook "$2" >/dev/null
    local file=$out/$1.png
    settle "$file"
    local width=$(sips -g pixelWidth "$file" | awk '/pixelWidth/ { print $2 }')
    sips --resampleWidth $((width * 2 / 3)) "$file" >/dev/null
}

for file name in $stories; do
    shoot $file-light "$name"
    shoot $file-dark "$name, dark"
done
