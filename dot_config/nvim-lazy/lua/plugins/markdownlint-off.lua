return {
  "mfussenegger/nvim-lint",
  opts = function(_, opts)
    -- Stop linting markdown with markdownlint
    opts.linters_by_ft = opts.linters_by_ft or {}

    opts.linters_by_ft.markdown = nil
    opts.linters_by_ft["markdown.mdx"] = nil
    opts.linters_by_ft["markdown_inline"] = nil
  end,
}
