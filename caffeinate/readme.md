# Caffeinate

Keeps the Mac awake while it is plugged in and the lid is open.

The active setup is a per-user LaunchAgent:

```sh
~/Library/LaunchAgents/com.raj.keepawake-ac.plist
```

It runs:

```sh
/usr/bin/caffeinate -s
```

`-s` prevents system sleep only while on AC power. The display can still sleep normally, and closing the lid may still put the Mac to sleep.

## Check status

```sh
launchctl print gui/$(id -u)/com.raj.keepawake-ac
pmset -g assertions
```

Expected assertion:

```text
PreventSystemSleep named: "caffeinate command-line tool"
```

## Disable

```sh
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/com.raj.keepawake-ac.plist
rm ~/Library/LaunchAgents/com.raj.keepawake-ac.plist
```

## Re-enable

```sh
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.raj.keepawake-ac.plist
launchctl enable gui/$(id -u)/com.raj.keepawake-ac
launchctl kickstart -k gui/$(id -u)/com.raj.keepawake-ac
```
