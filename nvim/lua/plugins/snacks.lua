return {
  "folke/snacks.nvim",
  opts = {
    -- animated scrolling desyncs scrollbind panes in diff views
    scroll = { enabled = false },
    picker = {
      sources = {
        -- list dotfiles (.env) and gitignored files, minus the noisy generated folders
        files = { hidden = true, ignored = true, exclude = { "node_modules", "dist", ".git" } },
        grep = { hidden = true, ignored = true, exclude = { "node_modules", "dist", ".git" } },
      },
    },
  },
}
