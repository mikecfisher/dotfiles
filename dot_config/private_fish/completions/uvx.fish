# Generated dynamically so completions match the installed uvx version.
if command -q uvx
    uvx --generate-shell-completion fish | source
end
