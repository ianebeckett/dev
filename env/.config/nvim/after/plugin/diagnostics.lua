-- Global diagnostics configuration
vim.diagnostic.config({
  virtual_text = {
    enabled = true,
    virt_text_pos = 'eol',
  },
  signs = true,
  update_in_insert = false,
})

-- Keymaps for diagnostics
vim.keymap.set('n', '<Leader>d', vim.diagnostic.open_float, { desc = "Show diagnostic" })
vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ float = true, count = 1 }) end)
vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ float = true, count = -1 }) end)
