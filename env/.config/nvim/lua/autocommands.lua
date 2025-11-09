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
  pattern = 'bigfile',
  callback = function(args)
    vim.schedule(function()
      vim.bo[args.buf].syntax = vim.filetype.match { buf = args.buf } or ''
    end)
  end,
})

--fuzzy-find help documents with Telescope
vim.cmd [[
augroup vimrc_help
  autocmd!
  autocmd BufEnter *.txt if &buftype == 'help' | wincmd L | endif
augroup end
]]

vim.api.nvim_create_autocmd("FileType", {
  desc = 'Fuzzy-find manpages with Telescope',
  pattern = "man",
  callback = function()
    if vim.bo.buftype == "nofile" and vim.bo.filetype == "man" then
      vim.cmd("wincmd L")
      --vim.cmd("vertical resize 115")
    end
  end,
})

vim.api.nvim_create_autocmd('BufReadPost', {
  desc = 'Go to the last location when opening a buffer',
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      vim.cmd 'normal! g`"zz'
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  desc = 'Disable cursorline in netrw',
  pattern = "netrw",
  command = "setlocal nocursorline",
})

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  callback = function()
    vim.hl.on_yank({ timeout = 50 })
  end,
})

vim.api.nvim_create_autocmd('PackChanged', {
  desc = '',
  callback = function(ev)
    if ev.data.kind == 'update' and ev.data.spec.name == 'nvim-treesitter' then
      local ok = pcall(vim.cmd('TSUpdate'))
      if not ok then
        vim.notify('TSUpdate failed!', vim.log.levels.WARN)
      end
    end
  end,
})

vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'Set LSP keymaps upon attaching to a buffer',
  group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
  callback = function(ev)
    local map = function(keys, func, desc, mode)
      mode = mode or 'n'
      vim.keymap.set(mode, keys, func, { buffer = ev.buf, desc = 'LSP: ' .. desc })
    end

    -- use Telescope for any supported list that benefits from fuzzy finding
    local telescope_builtin = require('telescope.builtin')
    map('<leader>f', function() vim.lsp.buf.format({ async = true }) end, '[F]ormat')
    map('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
    map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    map('gt', vim.lsp.buf.type_definition, '[G]oto [T]ype Definition')
    map('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
    map('<leader>vws', telescope_builtin.lsp_workspace_symbols, '[V]iew [W]orkspace [S]ymbols')
    map("]d", function() vim.diagnostic.jump({ float = true, count = -1 }) end, 'previous diagnostic')
    map("[d", function() vim.diagnostic.jump({ float = true, count = 1 }) end, 'next diagnostic')
    map('vd', vim.diagnostic.open_float, '[V]iew [D]iagnostic')
    map('vrr', telescope_builtin.lsp_references, '[V]iew [RR]eferences')
    map('vrn', vim.lsp.buf.rename, '[V]iew [R]e[N]ame')
    map('vca', vim.lsp.buf.code_action, '[V]iew [R]e[N]ame')
    map('vic', vim.lsp.buf.incoming_calls, '[V]iew [I]ncoming [C]alls') -- has Telescope builtin
    map('voc', vim.lsp.buf.outgoing_calls, '[V]iew [O]utgoing [C]alls') -- has Telescope builtin
    map('<C-h>', vim.lsp.buf.signature_help, 'Signature [H]elp', 'i')

    --also potentially useful:
    --vim.lsp.buf.typehierarchy('supertypes', 'subtypes')
    --vim.lsp.codelens
    --vim.lsp.util.apply_workspace_edit

    --make a playground for all these LSP features

  end
})
