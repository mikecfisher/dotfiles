return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    filesystem = {
      filtered_items = {
        visible = true, -- show hidden files
        hide_dotfiles = false, -- do not hide dotfiles
        hide_gitignored = false, -- do not hide files ignored by .gitignore
        hide_hidden = false, -- always show anything marked hidden
      },
    },
  },
}
