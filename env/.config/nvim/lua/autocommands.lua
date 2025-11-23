local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

autocmd('FileType', {
  desc = 'Specify format options for all filetypes',
  pattern = '*',
  callback = function()
    --only insert comment leader on newline by <Enter>, not via <o>
    vim.opt_local.formatoptions = 'rqj'
  end,
})

-- Here is an example comment.
-- When I press enter at end of line in insert mode, I get a new commented line.
-- When I press o in normal mode, I don't get a new commented line.

autocmd({'BufEnter', 'BufWinEnter'}, {
    desc = 'Disable completion in specific buffers',
    pattern = {'*.txt', '*.md', '*.git/COMMIT_EDITMSG'},
    callback = function()
        vim.b.completion = false
    end
})

autocmd('FileType', {
  desc = 'Disable features in big files',
  pattern = 'bigfile',
  callback = function(args)
    vim.schedule(function()
      vim.bo[args.buf].syntax = vim.filetype.match { buf = args.buf } or ''
    end)
  end,
})

autocmd('FileType', {
  desc = 'Disable cursorline in netrw',
  pattern = 'netrw',
  command = 'setlocal nocursorline',
})

autocmd('FileType', {
  desc = 'Fuzzy-find manpages with Telescope',
  pattern = 'man',
  callback = function()
    if vim.bo.buftype == 'nofile' and vim.bo.filetype == 'man' then
      vim.cmd('wincmd L')
      --vim.cmd('vertical resize 115')
    end
  end,
})

autocmd('BufNew', {
  desc = 'Open help docs in right split',
  pattern = '*.txt',
  callback = function()
    vim.cmd('wincmd L')
  end
})

autocmd('BufReadPost', {
  desc = 'Go to the last location when opening a buffer',
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      vim.cmd 'normal! g`"zz'
    end
  end,
})

autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  callback = function()
    vim.hl.on_yank({ timeout = 50 })
  end,
})

autocmd('PackChanged', {
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

autocmd('CmdlineEnter', {
  desc = 'Highlight all matches while searching',
  callback = function()
    vim.o.hlsearch = true
  end,
})

autocmd('CmdlineLeave', {
  desc = 'Remove highlights when done searching',
  callback = function()
    vim.o.hlsearch = false
  end,
})
