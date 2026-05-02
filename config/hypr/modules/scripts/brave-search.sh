#!/bin/bash
current_ws=$(hyprctl activeworkspace -j | jq -r '.id')
brave_address=$(hyprctl clients -j | jq -r --arg ws "$current_ws" '
  .[] |
  select(.workspace.id == ($ws | tonumber)) |
  select(.class == "brave-browser" or .class == "Brave-browser" or .class == "brave") |
  .address
' | head -n1)

if [ -n "$brave_address" ]; then
    hyprctl dispatch "hl.dsp.focus({window=\"address:$brave_address\"})"
    hyprctl dispatch "hl.dsp.send_shortcut({mods=\"CTRL\", key=\"T\", address=\"$brave_address\"})"
    hyprctl dispatch "hl.dsp.send_shortcut({mods=\"CTRL\", key=\"L\", address=\"$brave_address\"})"
else
    brave --new-window &
fi
