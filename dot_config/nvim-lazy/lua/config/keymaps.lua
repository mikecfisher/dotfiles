---@diagnostic disable: undefined-global
-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- New plugin spec helper
map("n", "<leader>np", function()
  vim.ui.input({ prompt = "New plugin spec name (no .lua): " }, function(name)
    if not name or name == "" then
      return
    end

    local path = vim.fn.stdpath("config") .. "/lua/plugins/" .. name .. ".lua"
    vim.cmd("edit " .. path)

    -- If it's a new file, drop in a minimal spec template
    if vim.fn.line("$") == 1 and vim.fn.getline(1) == "" then
      vim.api.nvim_buf_set_lines(0, 0, -1, false, {
        "return {",
        "  {",
        '    "author/repo",',
        "    opts = {},",
        "  },",
        "}",
      })
      vim.cmd("normal! gg")
    end
  end)
end, { desc = "New Plugin Spec" })

-- Neotest keymaps
-- All of these are guarded with pcall so a broken neotest config
-- does not crash your entire keymaps file.

local function get_neotest()
  local ok, neotest = pcall(require, "neotest")
  if not ok then
    vim.notify("Neotest not available: " .. tostring(neotest), vim.log.levels.ERROR)
    return nil
  end
  return neotest
end

map("n", "<leader>tn", function()
  local neotest = get_neotest()
  if not neotest then
    return
  end
  neotest.run.run()
end, { desc = "Run nearest test" })

map("n", "<leader>tf", function()
  local neotest = get_neotest()
  if not neotest then
    return
  end
  neotest.run.run(vim.fn.expand("%"))
end, { desc = "Run file tests" })

map("n", "<leader>to", function()
  local neotest = get_neotest()
  if not neotest then
    return
  end
  neotest.output.open({ enter = true })
end, { desc = "Test output" })

map("n", "<leader>ts", function()
  local neotest = get_neotest()
  if not neotest then
    return
  end
  neotest.summary.toggle()
end, { desc = "Toggle test summary" })

map("n", "<leader>tp", function()
  local neotest = get_neotest()
  if not neotest then
    return
  end
  neotest.output_panel.toggle()
end, { desc = "Toggle output panel" })

-- Window navigation now handled by smart-splits.nvim plugin
-- See: lua/plugins/smart-splits.lua
-- This provides seamless navigation between NeoVim splits and WezTerm panes
