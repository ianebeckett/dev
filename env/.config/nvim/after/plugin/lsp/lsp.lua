--lsp logs to ~/.local/state/nvim/lsp.log
--vim.lsp.log.set_level('debug')

vim.lsp.config('*', {
  capabilities = require('blink.cmp').get_lsp_capabilities(),
  root_markers = { '.git' },
})

vim.lsp.enable({
  'lua_ls',
  'basedpyright',
  'ruff',
  'clangd',
  'gopls',
  'rust-analyzer',
  'ts_ls',
  'svelte',
  'eslint',
  'jsonls',
  'html',
  'cssls',
  'ruby_lsp',
})

-- Global diagnostics configuration
vim.diagnostic.config({
    underline = true,
    virtual_text = {
        virt_text_pos = 'eol',
    },
    signs = true,
    float = {
        focusable = true,
        focus_id = 'diagnostic',
        border = 'rounded',
        header = '',
        source = 'if_many',
        format = function(diagnostic)
            local details = {}
            if diagnostic.source then
                details[#details + 1] = diagnostic.source
            end
            if diagnostic.code then
                details[#details + 1] = tostring(diagnostic.code)
            end
            if #details == 0 then
                return diagnostic.message
            end
            return diagnostic.message .. '\n' .. table.concat(details, ': ')
        end,
        prefix = '',
        suffix = '',
    },
    update_in_insert = true,
    severity_sort = true,
})

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup
local lspAttachGroup = augroup('lsp-attach', { clear = true })
local formatters = {
  c = 'clangd',
  cpp = 'clangd',
  go = 'gopls',
  gomod = 'gopls',
  gowork = 'gopls',
  gotmpl = 'gopls',
  rust = 'rust-analyzer',
  ruby = 'rubocop',
  python = 'ruff',
  javascript = 'ts_ls',
  javascriptreact = 'ts_ls',
  ['javascript.jsx'] = 'ts_ls',
  typescript = 'ts_ls',
  typescriptreact = 'ts_ls',
  ['typescript.tsx'] = 'ts_ls',
  lua = 'lua_ls',
  json = 'jsonls',
  jsonc = 'jsonls',
  html = 'html',
  css = 'cssls',
  scss = 'cssls',
  less = 'cssls',
}
-- local formatOnWriteGroup = augroup('format-on-write', { clear = false })

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
    map('<leader>ff', function()
      vim.lsp.buf.format({
        bufnr = ev.buf,
        async = true,
        name = formatters[vim.bo[ev.buf].filetype],
      })
    end, '[F]ormat [F]ile')

    map('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
    map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    map('gt', vim.lsp.buf.type_definition, '[G]oto [T]ype Definition')
    -- gi is "return to position where I last exited insert mode and return to insert mode"
    map('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')

    -- Diagnostics
    map(']d', function() vim.diagnostic.jump({ float = true, count = 1 }) end, 'next diagnostic')
    map('[d', function() vim.diagnostic.jump({ float = true, count = -1 }) end, 'previous diagnostic')
    map('vd', vim.diagnostic.open_float, '[V]iew [D]iagnostic')
    map('yd', function()
      local _, float_win = vim.diagnostic.open_float({ focus = false })
      if not float_win then
        vim.notify('No diagnostics on this line', vim.log.levels.INFO)
        return
      end
      vim.api.nvim_win_call(float_win, function()
        vim.cmd('normal! gg"+yG')
      end)
      -- Let the 50 ms TextYankPost highlight display before closing the float.
      vim.defer_fn(function()
        if vim.api.nvim_win_is_valid(float_win) then
          vim.api.nvim_win_close(float_win, true)
        end
      end, 80)
    end, '[Y]ank [D]iagnostic')

    -- use Telescope for any supported list that benefits from fuzzy finding
    local telescope_builtin = require('telescope.builtin')
    map('<leader>vws', telescope_builtin.lsp_workspace_symbols, '[V]iew [W]orkspace [S]ymbols')
    map('vrr', telescope_builtin.lsp_references, '[V]iew [RR]eferences')

    map('vrn', vim.lsp.buf.rename, '[V]im [R]e[N]ame')
    map('vca', vim.lsp.buf.code_action, '[V]im [C]ode [A]ction', { 'n', 'x' })
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
