-- lua/plugins/lsp-file-operations.lua
return {
  "antosha417/nvim-lsp-file-operations",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-neo-tree/neo-tree.nvim", -- LazyVim already uses this
  },
  config = function()
    require("lsp-file-operations").setup()
  end,
}
