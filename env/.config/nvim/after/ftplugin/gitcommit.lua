-- Mark the first column beyond a 72-character commit message body.
vim.opt_local.colorcolumn = '73'
vim.b.undo_ftplugin = (vim.b.undo_ftplugin or '') .. '\nsetlocal colorcolumn<'
