#!/bin/bash
# Get current workspace ID
current_ws=$(hyprctl activeworkspace -j | jq -r '.id')
# Find a Brave window on the current workspace
brave_address=$(hyprctl clients -j | jq -r --arg ws "$current_ws" '
  .[] |
  select(.workspace.id == ($ws | tonumber)) |
  select(.class == "brave-browser" or .class == "Brave-browser" or .class == "brave") |
  .address
' | head -n1)
if [ -n "$brave_address" ]; then
    # Focus Brave on this workspace
    hyprctl dispatch focuswindow "address:$brave_address"
    # Open new tab and focus address bar (Wayland-native)
    hyprctl dispatch sendshortcut CTRL,T,address:$brave_address
    hyprctl dispatch sendshortcut CTRL,L,address:$brave_address
else
    # No Brave on this workspace — launch it
    brave --new-window &
fi
