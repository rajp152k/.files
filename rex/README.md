# Rex

Personal Rex configuration, installed with GNU Stow.

## Install and reload

```sh
cd ~/.files
stow --target="$HOME" rex
rex config check
rex config reload
rex client ls
rex -C <app-client> keymap
```

`~/.config/rex` points to this package's `.config/rex`. `init.lua` loads `actions.lua` and `keys.lua`. Check the current app's action list after a Rex upgrade. Keep Lua configuration in these files; app-level shortcut overrides take priority.

## Keys

Press Ctrl-Space, release it, then press the key below.

| Key | Action |
|---|---|
| Ctrl-Space | Send one Ctrl-Space to the terminal |
| h / j / k / l | Focus left / down / up / right |
| Ctrl-h / Ctrl-j / Ctrl-k / Ctrl-l | Same focus directions |
| H / J / K / L | Resize by 5% in that direction |
| \| or % | Split right |
| - or " | Split down |
| z / = / f | Zoom / balance / float the focused pane |
| x | Close the pane and its program |
| c / n / p | New / next / previous tab |
| 1…9 | Select tab by its 1-based position |
| , | Rename tab |
| < / > | Move tab backward / forward |
| s / : | Session picker / command palette |
| r | Reload configuration |
| R | Enter resize mode |
| i | Open or focus btop |
| W | Open or focus journal: `just day` in `~/source/jour` |
| S | Open or focus scratchpad: `nvim scratchpad.md` in `~/source` |
| Enter | Open or focus the HUD shell in `~/source` |

In resize mode, use h/j/k/l repeatedly or hold a key. Hold Shift for 15% steps. Use `=` to balance. Press Escape or Enter to leave the mode. A normal prefix sequence is one action, not tmux's repeat-time window.

## Floating tools

The four tool actions create centered 80% floating terminals. Repeating an action finds its existing labeled block anywhere in the same session, raises it, and focuses it. New config loads do not lose the lookup state, because the lookup uses the server's session view.

Use the program's normal quit command to close its terminal. HUD, scratch, and journal have no nested tmux session. Their processes live in Rex blocks. This first setup does not implement tmux popup detach/hide semantics. Closing a pane ends its program. Journal and scratch launchers are defined but are not opened by the smoke test.

You can also run the actions from the palette or CLI:

```sh
rex do btop
rex do hud
rex do journal
rex do scratch
rex do dev_layout cwd="$HOME/source/your-project"
```

`dev_layout` creates a fresh tab with Neovim on the left (70%) and a shell on the right (30%). It does not reuse an existing dev tab. `cwd` defaults to `~/source`.

## Appearance

Use the existing Bit-Mage theme as the color source:

```sh
rex client ls
rex -C <app-client> do client.theme.import \
  path="$HOME/.files/ghostty/.config/ghostty/themes/bit-mage"
```

For CLI control of app actions, turn on **Remote Control** in Rex Settings → Rex Server. Import the theme from the app directly if you prefer to leave Remote Control off. The app stores appearance preferences separately from `init.lua`. Set Fira Mono, size 12, and Option-as-Alt in the app where supported; these Ghostty preferences are not Lua configuration settings in this package.

## Checks

First load the configuration. Then run the integration test in a disposable session:

```sh
(
  set -eu
  session=$(rex new "rex-config-check-$$" --cwd="$HOME" --json | jq -er '.session_id')
  trap 'rex kill "$session" >/dev/null' EXIT
  rex do -s "$session" "$HOME/.files/rex/tests/smoke.lua" --json
)
```

The test checks floating geometry, tool reuse across tabs, live btop/Neovim processes, the 70/30 layout, and automatic overlay closure after btop quits. The cleanup ends only the newly created test session. This test needs `btop`, `nvim`, and `jq` on PATH. It does not test physical keys, clipboard selection, journal writes, or reboot recovery.

Full migration notes and the next setup steps: `~/tmux2rex/SETUP.md`.
