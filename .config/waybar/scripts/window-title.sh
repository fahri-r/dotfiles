#!/usr/bin/env bash

# Get active workspace ID
WORKSPACE_ID=$(hyprctl activeworkspace -j | jq -r '.id')

# Count windows in workspace
WINDOW_COUNT=$(hyprctl clients -j | jq --argjson ws "$WORKSPACE_ID" '[.[] | select(.workspace.id == $ws)] | length')

if [ "$WINDOW_COUNT" -eq 0 ]; then
   echo ""
else
   hyprctl activewindow -j | jq -r '.title | .[0:50]'
fi
