-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Nuclear option: Kill all denols instances on startup
vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("nuke_denols_on_start", { clear = true }),
  callback = function()
    vim.defer_fn(function()
      local clients = vim.lsp.get_clients({ name = "denols" })
      for _, client in ipairs(clients) do
        vim.lsp.stop_client(client.id, true)
      end
    end, 100) -- Wait 100ms after Vim starts, then kill all denols
  end,
})

-- Kill Deno LSP immediately if it tries to attach (we don't use Deno)
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("kill_denols", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == "denols" then
      vim.schedule(function()
        vim.lsp.stop_client(client.id, true)
      end)
    end
  end,
})

-- Prevent any buffer from having denols as a client
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("prevent_denols_filetype", { clear = true }),
  pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
  callback = function(args)
    vim.defer_fn(function()
      -- Stop any denols clients attached to this buffer
      local clients = vim.lsp.get_clients({ bufnr = args.buf, name = "denols" })
      for _, client in ipairs(clients) do
        vim.lsp.stop_client(client.id, true)
      end
    end, 50) -- Small delay to catch denols after it attaches
  end,
})

-- Kill denols every time diffview opens
vim.api.nvim_create_autocmd("User", {
  group = vim.api.nvim_create_augroup("kill_denols_diffview", { clear = true }),
  pattern = "DiffviewViewOpened",
  callback = function()
    local clients = vim.lsp.get_clients({ name = "denols" })
    for _, client in ipairs(clients) do
      vim.lsp.stop_client(client.id, true)
    end
  end,
})
