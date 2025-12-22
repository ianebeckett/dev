--lsp logs to ~/.local/state/nvim/lsp.log
--vim.lsp.log.set_level('debug')

vim.lsp.config('*', {
  capabilities = require('blink.cmp').get_lsp_capabilities(),
  root_markers = { '.git/', },
})

vim.lsp.enable({
  'lua_ls',
  'clangd',
  'quick_lint_js',
  'ts_ls',
  'jsonls',
  'gopls',
  'rust-analyzer',
});

-- Global diagnostics configuration
vim.diagnostic.config({
    underline = true,
    virtual_text = {
        enabled = true,
        virt_text_pos = 'eol',
    },
    signs = true,
    float = {
        focusable = true,
        border = 'rounded',
        header = '',
        source = false,
        format = function(diagnostic)
            return string.format('%s\n%s: %s',
            diagnostic.message, diagnostic.source, diagnostic.code)
        end,
        prefix = '',
    },
    update_in_insert = true,
    severity_sort = true,
})

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup
local lspAttachGroup = augroup('lsp-attach', { clear = true })
local formatOnWriteGroup = augroup('format-on-write', { clear = false })

autocmd('LspAttach', {
  desc = 'Set LSP keymaps upon attaching to a buffer',
  group = lspAttachGroup,
  callback = function(ev)
    local map = function(keys, func, desc, mode)
      mode = mode or 'n'
      vim.keymap.set(mode, keys, func, { buffer = ev.buf, desc = 'LSP: ' .. desc })
    end

    -- use Telescope for any supported list that benefits from fuzzy finding
    local telescope_builtin = require('telescope.builtin')
    map('<leader>ff', function() vim.lsp.buf.format({ async = true }) end, '[F]ormat [F]ile')
    map('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
    map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    map('gt', vim.lsp.buf.type_definition, '[G]oto [T]ype Definition')
    -- gi is "return to position where I last exited insert mode and return to insert mode"
    map('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
    map('<leader>vws', telescope_builtin.lsp_workspace_symbols, '[V]iew [W]orkspace [S]ymbols')
    map('<leader>dv', vim.diagnostic.open_float, 'show diagnostic')
    map(']d', function() vim.diagnostic.jump({ float = true, count = 1 }) end, 'next diagnostic')
    map('[d', function() vim.diagnostic.jump({ float = true, count = -1 }) end, 'previous diagnostic')
    map('vrr', telescope_builtin.lsp_references, '[V]iew [RR]eferences')
    map('vrn', vim.lsp.buf.rename, '[V]iew [R]e[N]ame')
    map('vca', vim.lsp.buf.code_action, '[V]iew [R]e[N]ame')
    map('vic', vim.lsp.buf.incoming_calls, '[V]iew [I]ncoming [C]alls') -- has Telescope builtin
    map('voc', vim.lsp.buf.outgoing_calls, '[V]iew [O]utgoing [C]alls') -- has Telescope builtin

    -- -- format on write.
    -- -- Usually not needed if server supports "textDocument/willSaveWaitUntil".
    -- local client = vim.lsp.get_client_by_id(ev.data.client_id)
    -- if not client then
    --   return
    -- end
    -- if not client:supports_method('textDocument/willSaveWaitUntil')
    --     and client:supports_method('textDocument/formatting') then
    --   autocmd('BufWritePre', {
    --     group = formatOnWriteGroup,
    --     buffer = ev.buf,
    --     callback = function()
    --       vim.lsp.buf.format({
    --         bufnr = ev.buf,
    --         id = client.id,
    --         timeout_ms = 200,
    --         filter = function()
    --           --enable/disable here
    --           return client.name == 'lua_ls' or
    --               client.name == 'prettier'
    --         end,
    --       })
    --     end
    --   })
    -- end
    --
    --also potentially useful:
    --vim.lsp.buf.typehierarchy('supertypes', 'subtypes')
    --vim.lsp.codelens
    --vim.lsp.util.apply_workspace_edit
  end
})
