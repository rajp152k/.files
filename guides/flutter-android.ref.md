# Flutter Android development with Neovim

## Is the setup complete?

**Yes for a minimal Flutter-on-Android development loop:** edit Dart in Neovim, inspect errors and definitions with `dartls`, build and run on an Android emulator, and hot reload changes. A disposable Flutter app was built and launched on the emulator; a changed label appeared on-screen after hot reload.

**No if “complete” means a full Android IDE:** this configuration intentionally has no completion popup, snippets, autoformat-on-save, Flutter-specific run/debug plugin, or integrated breakpoint debugger. Run, tests, formatting, and DevTools are CLI/browser workflows. Android app signing and store release credentials are project-specific and are not configured. This guide covers **Flutter/Dart apps targeting Android**, not a full native Kotlin/Java Android Studio replacement.

## What is installed

- Flutter SDK, with its Dart SDK and `dart language-server` (`dartls`). Neovim enables `dartls` for Dart files in a project with `pubspec.yaml`.
- Dart Treesitter highlighting, LSP diagnostics/navigation, Telescope search, and Neovim's built-in terminal.
- Android SDK, platform/build tools, `adb`, Android Emulator, and one AVD: `flutter_pixel_4a_api35` (Pixel 4a, Android 15/API 35, ARM64, 2 GB RAM, AOSP image). The AVD is installed even when its window is closed.
- This AOSP image has **no Google Play services**. If an app requires Google Maps, Play services, or a plugin that depends on them, create a separate Google APIs/Play image rather than assuming this image covers it.

## First run or a new session

From a terminal, start the AVD only if it is not already running:

```sh
flutter emulators --launch flutter_pixel_4a_api35
flutter devices
```

Wait until `flutter devices` lists an Android emulator as online. With this single emulator it is usually `emulator-5554`; use the actual device ID printed on your machine if it differs. The first boot is slower; later boots use Quick Boot snapshots.

In your Flutter project root (the directory containing `pubspec.yaml`):

```sh
nvim lib/main.dart
```

Keep a separate tmux pane for the app:

```sh
flutter run -d emulator-5554
```

Or run it inside Neovim with `:botright 12split | terminal flutter run -d emulator-5554`. In Neovim terminal mode, `<Esc><Esc>` returns to normal mode; press `i` to send keys to the terminal again. **Saving a Dart file does not itself reload the app:** after saving, press `r` in the `flutter run` terminal for hot reload, or `R` for hot restart (which resets app state). Press `q` there to stop the app. Leave the run session open during an edit/reload cycle; the first Gradle build takes longer than a hot reload.

For a new app, run `flutter create my_app`, then open Neovim from `my_app/`. To shut down the emulator when finished, close its window or run `adb -s emulator-5554 emu kill` (substitute its actual ID).

## Editing and checking

| Action | In Neovim |
| --- | --- |
| Open a file / search project text | `<Space>sf` / `<Space>sg` |
| Definition / references | `grd` / `grr` |
| Document symbols / workspace symbols | `gO` / `gW` |
| Hover information / rename / code action | `K` / `grn` / `gra` |
| Next / previous diagnostic | `]d` / `[d` |
| Search diagnostics | `<Space>sd` |

LSP bindings appear on a Dart buffer when `dartls` attaches. For the broader navigation reference, see [Neovim navigation and keybindings](neovim-navigation.ref.md). Run `:checkhealth vim.lsp` in a Dart buffer if navigation is missing; check `flutter doctor` and `flutter devices` if a build or target is unavailable.

Run these explicitly from the project root as needed:

```sh
flutter analyze
flutter test
dart format .
```

`dart format .` **changes files**; inspect its diff before committing. The running Flutter CLI prints a DevTools URL for browser-based inspection/debugging; no Neovim debugger integration was set up or verified.
