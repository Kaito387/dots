#!/usr/bin/env sh
# clipboard-copy.sh — copy tmux buffer to system clipboard
# Works on Wayland (wl-copy) and X11 (xclip).
buf="$(tmux show-buffer)"
if command -v wl-copy >/dev/null 2>&1; then
    printf '%s' "$buf" | wl-copy
elif command -v xclip >/dev/null 2>&1; then
    printf '%s' "$buf" | xclip -in -selection clipboard
else
    echo "clipboard-copy: no clipboard tool found (install wl-copy or xclip)" >&2
    exit 1
fi
