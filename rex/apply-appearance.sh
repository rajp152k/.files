#!/bin/sh
# Native pane-edge settings in Rex Beta 0.1.0 (1642).
# Apply to this Mac. These preferences are separate from server-side init.lua.
set -eu

domain=com.superlogical.rex
defaults write "$domain" Workspace.showsActivePaneBorder -bool true
defaults write "$domain" Workspace.activePaneBorderColor -string green
defaults write "$domain" Workspace.activePaneBorderOpacity -float 1.0
defaults write "$domain" Workspace.activePaneBorderTransition -string off

printf '%s\n' 'Saved green pane edges, full opacity, no border animation.'
printf '%s\n' 'If Rex does not update live, reopen the app. Leave its server running.'
