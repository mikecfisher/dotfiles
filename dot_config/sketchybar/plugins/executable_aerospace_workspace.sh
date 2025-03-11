#!/usr/bin/env bash
WORKSPACE_ID=${NAME#space.}

if [ "$WORKSPACE_ID" = "$FOCUSED_WORKSPACE" ]; then
    sketchybar --set $NAME background.drawing=on
else
    sketchybar --set $NAME background.drawing=off
fi
