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
  desc = 'Disable relative number in qflist',
  pattern = 'qf',
  command = 'setlocal nornu',
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

autocmd('FileType', {
    desc = 'Disable completion in specific buffers',
    pattern = {'text', 'markdown', 'gitcommit'},
    callback = function()
        vim.b.completion = false
    end
})

autocmd('BufWinEnter', {
  desc = 'Open help docs in right split',
  pattern = '*.txt',
  callback = function()
    vim.cmd('wincmd L')
  end
})

autocmd('TermOpen', {
  desc = 'Open man pages in right split',
  callback = function()
    vim.cmd('wincmd L')
  end
})

autocmd('BufNewFile', {
  desc = 'Create missing parent directories automatically',
  callback = function(args)
    autocmd('BufWritePre', {
      buffer = args.buf,
      once = true,
      callback = function()
        local dir = vim.fn.expand('%:h')
        if vim.fn.isdirectory(dir) == 0 then
          vim.fn.mkdir(dir, 'p')
        end
      end
    })
  end
})

autocmd('BufReadPost', {
  desc = 'Go to the last location when opening a buffer',
  callback = function(args)
    -- local excludes = {
    --     '.*%.git/COMMIT_EDITMSG',
    --     '.*%.git/rebase%-merge/git%-rebase%-todo',
    -- }
    -- local buf_name = vim.api.nvim_buf_get_name(args.buf)
    -- for _, pattern in ipairs(excludes) do
    --     if string.match(buf_name, pattern) then
    --       return
    --     end
    -- end
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      vim.cmd 'normal! g`"zz'
    end
  end,
})

autocmd('BufWritePre', {
    desc = 'remove trailing whitespace before saving. Preserve search and cursor position.',
    pattern = '*',
    callback = function()
        local search = vim.fn.getreg('/')
        local current_position = vim.api.nvim_win_get_cursor(0)
        vim.cmd [[%s/\s\+$//e]]
        vim.fn.setreg('/', search)
        vim.api.nvim_win_set_cursor(0, current_position)
    end
})

autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  callback = function()
    vim.hl.on_yank({ timeout = 50 })
  end,
})

-- yank ring
autocmd('TextYankPost', {
  callback = function()
    if vim.v.event.operator == 'y' then
      for i = 9, 1, -1 do -- Shift all numbered registers.
        vim.fn.setreg(tostring(i), vim.fn.getreg(tostring(i - 1)))
      end
    end
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

autocmd('InsertEnter', {
    desc = 'Use absolute line numbers in insert mode',
    callback = function()
        vim.opt.relativenumber = false
    end,
})

autocmd('InsertLeave', {
    desc = 'Return to relative line numbers in normal mode',
    callback = function()
        vim.opt.relativenumber = true
    end,
})
