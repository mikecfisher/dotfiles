# Sketchybar Aerospace plugin

<img width="273" alt="image" src="https://github.com/user-attachments/assets/9d59affa-4ce3-4148-8ff2-38210628ecab" />


Fast plugin to render aerospace workspaces with app icons in sketchybar. Supports multiple monitors with correct ordering. Spaces will only appear on the monitor on which the space is.

Currently all style is hardcoded. Fork and adjust as needed.

Required sketchybar config:

```
sketchybar --add event aerospace_workspace_change
sketchybar --add event aerospace_focus_change
sketchybar --add item aerospace left \
        --subscribe aerospace aerospace_workspace_change \
        --subscribe aerospace aerospace_focus_change \
        --set aerospace \
        label="󱂬" \
        click_script="aerospace reload-config" \
        script="$CONFIG_DIR/plugins/aerospace_plugin"
```

Required aerospace config:

```
exec-on-workspace-change = ['/bin/dash', '-c',
  'sketchybar --trigger aerospace_workspace_change FOCUSED=$AEROSPACE_FOCUSED_WORKSPACE PREV_FOCUSED=$AEROSPACE_PREV_WORKSPACE'
]

on-focus-changed = [
  'exec-and-forget sketchybar --trigger aerospace_focus_change'
]
```

# Attribution

`mach.h` from [FelixKrat/SbarLua](https://github.com/FelixKratz/SbarLua)
