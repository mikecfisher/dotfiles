status is-interactive && fnm env --use-on-cd | source
#fnm env --use-on-cd --shell fish | source
#fnm env | source

# fnm
set FNM_PATH "/Users/mike/Library/Application Support/fnm"
if [ -d "$FNM_PATH" ]
  set PATH "$FNM_PATH" $PATH
  fnm env | source
end
