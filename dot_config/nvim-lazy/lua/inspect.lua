-- ~/.config/nvim-lazy/lua/inspect.lua
-- Minimal shim so `require("inspect")` works for neotest-bun.
-- Uses vim.inspect under the hood.

local function inspect(value, options)
  return vim.inspect(value, options)
end

return inspect
