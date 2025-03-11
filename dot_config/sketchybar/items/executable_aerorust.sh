# Add this to your sketchybarrc
sketchybar --add event aerospace_workspace_change
sketchybar --add event aerospace_focus_change
sketchybar --add item aerospace left \
  --subscribe aerospace aerospace_workspace_change \
  --subscribe aerospace aerospace_focus_change \
  --set aerospace \
  label="󱂬" \
  click_script="aerospace reload-config" \
  script="$CONFIG_DIR/plugins/aerospace_plugin"
