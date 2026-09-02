vim.lsp.start({
  name = "rubocop",
  cmd = { "rubocop", "--lsp" },
  root_dir = vim.fs.dirname(vim.fs.find({ ".rubocop.yml", "Gemfile", ".git" }, { upward = true })[1]),
})
