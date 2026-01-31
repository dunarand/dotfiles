#!/bin/bash

# Ensure UTF-8 so Nerd Font icons render correctly
export LC_ALL=C.UTF-8

pactl --format=json list sink-inputs | jq -c '
  if . == null or . == [] then
    []
  else
    [
      .[] | 
      # --- Volume handling: average all channels safely ---
      (
        .volume | to_entries | map(.value.value_percent | sub("%"; "") | tonumber) 
        | add / length
      ) as $avg_vol

      | {
          id: .index,

          # --- App name resolution (robust fallback chain) ---
          name: (
            .properties["application.name"]
            // .properties["media.name"]
            // .properties["application.process.binary"]
            // "Unknown App"
          ),

          volume: ($avg_vol | floor),

          mute: (.mute // false),

          # --- Icon mapping (expandable & safer) ---
          icon: (
            (
              .properties["application.process.binary"]
              // .properties["application.name"]
              // ""
            | ascii_downcase
            ) as $app
            | if $app | test("firefox|brave|chromium|chrome|zen") then ""
              elif $app | test("spotify") then ""
              elif $app | test("discord|vesktop|armcord") then ""
              elif $app | test("mpv|vlc") then "󰕼"
              else "󰎇"
              end
          )
        }
    ]
  end
'
