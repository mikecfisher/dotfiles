# Generated dynamically so completions match the installed uv version.
if command -q uv
    uv generate-shell-completion fish | source
end
