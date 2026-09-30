local ts = require('nvim-treesitter')

ts.install({
    'bash',
    'c',
    'cpp',
    'git_config',
    'git_rebase',
    'gitcommit',
    'gitignore',
    'html',
    'json',
    'javascript',
    'latex',
    'lua',
    'make',
    'markdown',
    'markdown_inline',
    'python',
    'query',
    'regex',
    'rust',
    'tsx',
    'typescript',
    'vim',
    'vimdoc',
    'xml',
})

local ignore_filetypes = {
  'checkhealth',
  'qf'
}

local group = vim.api.nvim_create_augroup('TreesitterSetup', { clear = true })

-- Auto-install parsers and enable highlighting on FileType
vim.api.nvim_create_autocmd('FileType', {
  group = group,
  desc = 'Enable treesitter (highlighting, indentation, etc.)',
  callback = function(event)
    if vim.tbl_contains(ignore_filetypes, event.match) then
      return
    end

    local lang = vim.treesitter.language.get_lang(event.match) or event.match
    local buf = event.buf

    pcall(vim.treesitter.start, buf, lang)
    vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

  end,
})
