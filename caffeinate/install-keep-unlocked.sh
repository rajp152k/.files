#!/bin/sh
# Install a per-user AC/open-lid automatic-lock inhibitor.
set -eu
source_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
support="$HOME/Library/Application Support/KeepAwakeAC"
label=com.raj.keepunlocked-ac-open
domain="gui/$(id -u)"
agent="$HOME/Library/LaunchAgents/$label.plist"
mkdir -p "$support" "$HOME/Library/LaunchAgents"
build=$(mktemp -d "$support/build.XXXXXX")
trap 'rm -rf "$build"' EXIT HUP INT TERM

xcrun clang -std=c11 -Wall -Wextra -Werror -O2 \
    -framework CoreFoundation -framework IOKit \
    "$source_dir/keep-unlocked.c" -o "$build/keep-unlocked"
"$build/keep-unlocked" --exercise
"$build/keep-unlocked" --status

plist="$build/$label.plist"
plutil -create xml1 "$plist"
plutil -insert Label -string "$label" "$plist"
plutil -insert ProgramArguments -json '[]' "$plist"
plutil -insert ProgramArguments.0 -string "$support/keep-unlocked" "$plist"
plutil -insert RunAtLoad -bool YES "$plist"
plutil -insert KeepAlive -bool YES "$plist"
plutil -insert ThrottleInterval -integer 10 "$plist"
plutil -insert StandardOutPath -string "$support/output.log" "$plist"
plutil -insert StandardErrorPath -string "$support/error.log" "$plist"
plutil -lint "$plist"

if launchctl print "$domain/$label" >/dev/null 2>&1; then
    launchctl bootout "$domain/$label"
fi
mv "$build/keep-unlocked" "$support/keep-unlocked"
cp "$plist" "$agent"
launchctl enable "$domain/$label"
launchctl bootstrap "$domain" "$agent"
echo "Installed $label"
