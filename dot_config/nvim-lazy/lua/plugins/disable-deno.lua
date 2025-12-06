-- Disable Deno LSP completely (we don't use Deno, only TypeScript/Node)
-- This overrides LazyVim's typescript extra which tries to enable denols

return {
  -- Override nvim-lspconfig before it loads
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- Ensure servers table exists
      opts.servers = opts.servers or {}

      -- Completely disable denols with multiple fail-safes
      opts.servers.denols = {
        -- Make the command invalid so it can't start
        cmd = { "false" }, -- 'false' command always fails immediately
        -- Override root_dir to always return nil
        root_dir = function()
          return nil
        end,
        autostart = false,
        single_file_support = false,
        enabled = false, -- Explicitly disable
      }

      -- Ensure setup table exists
      opts.setup = opts.setup or {}

      -- Prevent denols from ever starting
      opts.setup.denols = function()
        return true -- Return true to skip setup
      end

      return opts
    end,
    -- Run this BEFORE lspconfig initializes
    priority = 1000,
  },
  -- Override mason-lspconfig
  {
    "mason-org/mason-lspconfig.nvim",
    opts = function(_, opts)
      -- Ensure denols is not in the auto-install list
      opts.ensure_installed = opts.ensure_installed or {}
      opts.ensure_installed = vim.tbl_filter(function(server)
        return server ~= "denols"
      end, opts.ensure_installed)

      -- Add denols to handlers to prevent auto-setup
      opts.handlers = opts.handlers or {}
      opts.handlers.denols = function()
        -- Do nothing - block denols from being set up by mason-lspconfig
      end

      return opts
    end,
  },
  -- Override mason itself
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      -- Prevent Mason UI from showing denols
      opts.ui = opts.ui or {}
      opts.ui.check_outdated_packages_on_open = false

      return opts
    end,
  },
}
