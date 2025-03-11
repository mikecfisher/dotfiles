sketchybar --add item spacePaddingRight left --set spacePaddingRight padding_left=-18

sketchybar --add item space_separator q \
  --set space_separator icon="💩" \
  icon.padding_left=20 \
  icon.padding_right=0 \
  icon.margin_right=0 \
  label.drawing=off \
  label.padding_left=0 \
  label.margin_left=0 \
  background.drawing=off \
  script="$PLUGIN_DIR/space_windows.sh" \
  --subscribe space_separator aerospace_workspace_change space_windows_change front_app_switched
