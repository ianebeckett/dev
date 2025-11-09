vim.api.nvim_create_autocmd("FileType", {
  desc = 'Specify format options for all filetypes',
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions = "rqj"
  end,
})

-- Here is an example comment.
-- When I press enter at end of line in insert mode, I get a new commented line.
-- When I press o in normal mode, I don't get a new commented line.

vim.api.nvim_create_autocmd('FileType', {
  desc = 'Disable features in big files',
  group = vim.api.nvim_create_augroup('mariasolos/big_file', { clear = true }),
  pattern = 'bigfile',
  callback = function(args)
    vim.schedule(function()
      vim.bo[args.buf].syntax = vim.filetype.match { buf = args.buf } or ''
    end)
  end,
})

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc, mode) --TODO: why use this?
      mode = mode or 'n'
      vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end
    local builtin = require('telescope.builtin')
    map("<leader>f", function() vim.lsp.buf.format() end, '[F]ormat')
    map('gd', builtin.lsp_definitions, '[G]oto [d]efinition')
    map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    map('gW', builtin.lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')
    map('gt', builtin.lsp_type_definitions, '[G]oto [t]ype Definition')
  end
})

vim.api.nvim_create_autocmd('BufReadPost', {
  desc = 'Go to the last location when opening a buffer',
  group = vim.api.nvim_create_augroup('mariasolos/last_location', { clear = true }),
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      vim.cmd 'normal! g`"zz'
    end
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "netrw",
  command = "setlocal nocursorline",
})

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank({ timeout = 50 })
  end,
})

vim.cmd [[
augroup vimrc_help
  autocmd!
  autocmd BufEnter *.txt if &buftype == 'help' | wincmd L | endif
augroup end
]]

vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(event)
    if event.data.kind == 'update' and event.data.spec.name == 'nvim-treesitter' then
      local ok = pcall(vim.cmd, 'TSUpdate')
      if not ok then
        vim.notify('TsUpdate failed!', vim.log.levels.WARN)
      end
    end
  end,
})
