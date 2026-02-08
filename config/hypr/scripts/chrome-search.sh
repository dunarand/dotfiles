#!/bin/bash

# Get current workspace ID
current_ws=$(hyprctl activeworkspace -j | jq -r '.id')

# Find a Chrome/Chromium window on the current workspace
chrome_address=$(hyprctl clients -j | jq -r --arg ws "$current_ws" '
  .[] |
  select(.workspace.id == ($ws | tonumber)) |
  select(.class == "Google-chrome" or .class == "chromium" or .class == "google-chrome") |
  .address
' | head -n1)

if [ -n "$chrome_address" ]; then
    # Focus Chrome on this workspace
    hyprctl dispatch focuswindow "address:$chrome_address"

    # Open new tab and focus address bar (Wayland-native)
    hyprctl dispatch sendshortcut CTRL,T,address:$chrome_address
    hyprctl dispatch sendshortcut CTRL,L,address:$chrome_address
else
    # No Chrome on this workspace — launch it
    google-chrome-stable --new-window &
fi
