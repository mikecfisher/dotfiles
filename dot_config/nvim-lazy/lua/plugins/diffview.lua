return {
  "sindrets/diffview.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles", "DiffviewFileHistory" },
  opts = {
    enhanced_diff_hl = true, -- Better syntax highlighting in diffs
    view = {
      default = {
        layout = "diff2_horizontal", -- Side-by-side diff (like VS Code)
      },
      merge_tool = {
        layout = "diff3_horizontal",
      },
      file_history = {
        layout = "diff2_horizontal",
      },
    },
  },
  keys = {
    -- Open diff view for all changes (like VS Code's Source Control view)
    {
      "<leader>gv",
      "<cmd>DiffviewOpen<cr>",
      desc = "Diffview Open (all changes)",
    },
    -- Open diff view comparing to a specific branch/commit
    {
      "<leader>gV",
      function()
        vim.ui.input({ prompt = "Compare to branch/commit: " }, function(branch)
          if branch and branch ~= "" then
            vim.cmd("DiffviewOpen " .. branch)
          end
        end)
      end,
      desc = "Diffview Compare Branch",
    },
    -- Show file history (like VS Code's file history)
    {
      "<leader>gF",
      "<cmd>DiffviewFileHistory %<cr>",
      desc = "Diffview File History",
    },
    -- Show full project history
    {
      "<leader>gH",
      "<cmd>DiffviewFileHistory<cr>",
      desc = "Diffview Project History",
    },
    -- Close diffview
    {
      "<leader>gx",
      "<cmd>DiffviewClose<cr>",
      desc = "Diffview Close",
    },
    -- Toggle file panel in diffview
    {
      "<leader>gt",
      "<cmd>DiffviewToggleFiles<cr>",
      desc = "Diffview Toggle Files",
    },
  },
}
