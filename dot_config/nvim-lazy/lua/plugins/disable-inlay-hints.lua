-- Disable inlay hints (those inline type annotations like ": string", ": Promise<void>")

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = {
        enabled = false,
      },
    },
  },
}
