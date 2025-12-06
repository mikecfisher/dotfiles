return {
  "NickvanDyke/opencode.nvim",
  dependencies = {
    -- Recommended for `ask()` and `select()`.
    -- Required for `snacks` provider.
    ---@module 'snacks' <- Loads `snacks.nvim` types for configuration intellisense.
    { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
  },
  config = function()
    ---@type opencode.Opts
    vim.g.opencode_opts = {
      -- Your configuration, if any — see `lua/opencode/config.lua`, or "goto definition".
    }

    -- Required for `opts.auto_reload`.
    vim.o.autoread = true

    -- Recommended/example keymaps.
    vim.keymap.set({ "n", "x" }, "<C-a>", function() require("opencode").ask("@this: ", { submit = true }) end, { desc = "Ask opencode (AI assistant)" })
    vim.keymap.set({ "n", "x" }, "<C-x>", function() require("opencode").select() end,                          { desc = "Execute opencode action… (AI commands)" })
    vim.keymap.set({ "n", "x" },    "ga", function() require("opencode").prompt("@this") end,                   { desc = "Add to opencode (append context)" })
    vim.keymap.set({ "n", "t" }, "<C-.>", function() require("opencode").toggle() end,                          { desc = "Toggle opencode (show/hide panel)" })
    
    -- Buffer-specific Ctrl+D/U for OpenCode scrolling (only in OpenCode buffers)
    -- Elsewhere, Ctrl+D/U work as normal Vim page scrolling
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "opencode",
      callback = function(ev)
        vim.keymap.set("n", "<C-u>", function() require("opencode").command("session.half.page.up") end, 
          { buffer = ev.buf, desc = "opencode half page up (scroll AI response up)" })
        vim.keymap.set("n", "<C-d>", function() require("opencode").command("session.half.page.down") end, 
          { buffer = ev.buf, desc = "opencode half page down (scroll AI response down)" })
      end,
    })
    -- Quick prompts for common tasks
    vim.keymap.set("n", "<leader>or", function() require("opencode").ask("review @this") end, { desc = "Review code" })
    vim.keymap.set("n", "<leader>of", function() require("opencode").ask("fix @diagnostics") end, { desc = "Fix diagnostics" })
    -- You may want these if you stick with the opinionated "<C-a>" and "<C-x>" above — otherwise consider "<leader>o".
    vim.keymap.set('n', '+', '<C-a>', { desc = 'Increment', noremap = true })
    vim.keymap.set('n', '-', '<C-x>', { desc = 'Decrement', noremap = true })
  end,
}
