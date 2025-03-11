#!/usr/bin/env bash

# make sure it's executable with:
# chmod +x ~/.config/sketchybar/plugins/aerospace.sh

# Get workspace ID from argument
SID="$1"

# Handle highlighting based on focus
if [ "$SID" = "$FOCUSED_WORKSPACE" ]; then
    sketchybar --set $NAME background.color=0x88FF00FF label.shadow.drawing=on icon.shadow.drawing=on background.border_width=2
else
    sketchybar --set $NAME background.color=0x44FFFFFF label.shadow.drawing=off icon.shadow.drawing=off background.border_width=0
fi

# Update icons if this is the workspace that changed or the previous one
# This handles both window movement and workspace switching
if [[ "$SENDER" = "aerospace_workspace_change" ]]; then
    # Update current and previous workspace
    update_workspaces=("$FOCUSED_WORKSPACE" "$PREV_WORKSPACE")

    # Update each relevant workspace
    for workspace in "${update_workspaces[@]}"; do
        # Only process non-empty strings
        if [[ -n "$workspace" ]]; then
            # Get apps in the workspace
            apps=$(aerospace list-windows --workspace "$workspace" | awk -F'|' '{gsub(/^ *| *$/, "", $2); print $2}')

            # Build icon strip
            icon_strip=" "
            if [ -n "${apps}" ]; then
                while read -r app; do
                    icon_strip+=" $($CONFIG_DIR/plugins/icon_map_fn.sh "$app")"
                done <<<"${apps}"
            else
                icon_strip=""
            fi

            # Update the workspace's label
            sketchybar --set space.$workspace label="$icon_strip"
        fi
    done
fi
