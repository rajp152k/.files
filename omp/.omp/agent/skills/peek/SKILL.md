---
name: peek
description: "Use when the user asks 'what am I looking at?', 'what's on my screen?', or otherwise asks you to inspect their current macOS desktop. Capture and inspect the display with screencapture; no /peek command is required."
---

# Inspect the current macOS screen

Use when the user asks what they are looking at or requests a screen inspection, including in ordinary chat without `/peek`. This captures the user's real desktop, not a browser automation tab. Treat images as private: don't upload them or include them in the response unless requested.

1. Create a unique temporary directory using `mktemp -d /tmp/omp-screencapture.XXXXXX`; retain the returned absolute path.
2. Capture the main display with `screencapture -x -m -t png <directory>/screen.png` via `bash`. `-x` suppresses the shutter sound; `-m` avoids ambiguous multi-display output. Do not use `-h`: macOS `screencapture` reports it as an illegal option.
3. Open the resulting PNG with `read` (`<directory>/screen.png`). Visually inspect the image and report only what is relevant to the user's question. If the user wants another display, use `-D<display>` instead of `-m` (e.g. `-D2`); for a specified rectangle use `-R<x,y,w,h>`; for a known window ID use `-l<windowid>`. For an interactive window/selection, `-i` requires the user's interaction and is not the default.
4. Once analysis is complete, remove only the temporary directory created in step 1 (and its screenshot). Do not reuse or overwrite an existing screenshot path.

If capture fails or produces a blank/black image, report that observation rather than inferring the screen contents. macOS may require Screen & System Audio Recording permission for the terminal/agent host in System Settings → Privacy & Security; after granting it, the host may need restarting. Do not modify privacy settings yourself.
