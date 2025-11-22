return {
  "mrjones2014/smart-splits.nvim",
  lazy = false, -- CRITICAL: Must not be lazy-loaded for WezTerm integration!
  opts = {
    -- Integrate with WezTerm
    multiplexer_integration = "wezterm",
    -- Don't wrap at edges - stop instead
    at_edge = "stop",
    -- Disable multiplexer navigation when pane is zoomed
    disable_multiplexer_nav_when_zoomed = true,
    -- Default resize amount
    default_amount = 3,
    -- Move cursor to same row when switching left/right
    move_cursor_same_row = false,
    -- Ignored filetypes when resizing (e.g., NvimTree)
    ignored_filetypes = { "NvimTree", "neo-tree" },
    -- Log level
    log_level = "info",
  },
  keys = {
    -- Navigation between splits/panes with Ctrl+HJKL
    {
      "<C-h>",
      function()
        require("smart-splits").move_cursor_left()
      end,
      desc = "Move to left split/pane",
    },
    {
      "<C-j>",
      function()
        require("smart-splits").move_cursor_down()
      end,
      desc = "Move to bottom split/pane",
    },
    {
      "<C-k>",
      function()
        require("smart-splits").move_cursor_up()
      end,
      desc = "Move to top split/pane",
    },
    {
      "<C-l>",
      function()
        require("smart-splits").move_cursor_right()
      end,
      desc = "Move to right split/pane",
    },
    {
      "<C-\\>",
      function()
        require("smart-splits").move_cursor_previous()
      end,
      desc = "Move to previous split/pane",
    },

    -- Resizing splits with Alt+HJKL
    {
      "<A-h>",
      function()
        require("smart-splits").resize_left()
      end,
      desc = "Resize split left",
    },
    {
      "<A-j>",
      function()
        require("smart-splits").resize_down()
      end,
      desc = "Resize split down",
    },
    {
      "<A-k>",
      function()
        require("smart-splits").resize_up()
      end,
      desc = "Resize split up",
    },
    {
      "<A-l>",
      function()
        require("smart-splits").resize_right()
      end,
      desc = "Resize split right",
    },

    -- Swapping buffers between splits with <leader><leader> + direction
    {
      "<leader><leader>h",
      function()
        require("smart-splits").swap_buf_left()
      end,
      desc = "Swap buffer left",
    },
    {
      "<leader><leader>j",
      function()
        require("smart-splits").swap_buf_down()
      end,
      desc = "Swap buffer down",
    },
    {
      "<leader><leader>k",
      function()
        require("smart-splits").swap_buf_up()
      end,
      desc = "Swap buffer up",
    },
    {
      "<leader><leader>l",
      function()
        require("smart-splits").swap_buf_right()
      end,
      desc = "Swap buffer right",
    },
  },
}
