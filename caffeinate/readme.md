# Mac sleep and automatic locking

| Power | Lid | Behavior |
| --- | --- | --- |
| AC | Open | Keep the Mac and display awake; prevent automatic screen locking. |
| AC | Closed | Keep the Mac awake with its display off. |
| Battery | Open | Use the normal battery sleep and lock settings. |
| Battery | Closed | Sleep after closing the lid. |

The AC power settings are `sleep 0` and `displaysleep 0`. Battery settings are
`sleep 1` and `displaysleep 2`, in minutes.

Use Control-Command-Q to lock manually. Password requirements are unchanged.

## Services

The existing per-user service `com.raj.keepawake-ac` runs
`/usr/bin/caffeinate -s`. This assertion applies only on AC power. The Mac's
sleep log confirmed battery sleep after lid closure during a physical test.

The per-user service `com.raj.keepunlocked-ac-open` runs `keep-unlocked.c`.
It checks the power source and lid state through IOKit. When AC is connected
and the lid is open, it holds a `UserIsActive` assertion to prevent idle locking.
It releases that assertion when power or lid notifications report a change.
It also checks the state every five seconds. It renews the assertion every
30 seconds, with a 60-second expiry if the helper stops responding.

The helper is installed at:

```text
~/Library/Application Support/KeepAwakeAC/keep-unlocked
```

## Build and install the lock-prevention helper

From the repository root, run:

```sh
sh caffeinate/install-keep-unlocked.sh
```

Install the Xcode Command Line Tools first. The script builds the helper,
exercises its assertion create/release paths with simulated power/lid inputs,
and installs the per-user LaunchAgent. Physical unplug and lid tests are
separate from those checks.

## Check status

```sh
launchctl print gui/$(id -u)/com.raj.keepawake-ac
launchctl print gui/$(id -u)/com.raj.keepunlocked-ac-open
"$HOME/Library/Application Support/KeepAwakeAC/keep-unlocked" --status
pmset -g assertions
pmset -g custom
```

With AC connected and the lid open, find the `UserIsActive` assertion named
`Keep unlocked: AC and lid open`. Read helper errors in
`~/Library/Application Support/KeepAwakeAC/error.log`.

## Disable automatic-lock prevention

```sh
launchctl bootout gui/$(id -u)/com.raj.keepunlocked-ac-open
rm ~/Library/LaunchAgents/com.raj.keepunlocked-ac-open.plist
```

To disable the separate AC keep-awake service, run:

```sh
launchctl bootout gui/$(id -u)/com.raj.keepawake-ac
rm ~/Library/LaunchAgents/com.raj.keepawake-ac.plist
```
