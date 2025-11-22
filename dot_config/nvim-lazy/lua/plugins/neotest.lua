-- ~/.config/nvim-lazy/lua/plugins/neotest.lua

return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      -- hard requirement for neotest
      "nvim-neotest/nvim-nio",
      -- these are usually already in LazyVim, but listing them is harmless
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      -- bun adapter
      -- REQUIRED by neotest-bun: Lua inspect
      "kikito/inspect.lua",
      "arthur944/neotest-bun",
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-bun"),
        },
      })
    end,
  },
}
