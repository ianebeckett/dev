#!/bin/sh

# The npm launcher is named node, but its foreground child is named codex.
# Ignore background jobs and match the executable name, not its arguments.
ps -t "${1#/dev/}" -o stat= -o comm= 2>/dev/null |
    awk '
        $1 ~ /\+/ && $2 ~ /(^|\/)codex$/ { found = 1 }
        END { print found ? "codex" : "node" }
    '
