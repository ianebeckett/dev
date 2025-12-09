---@brief
---
--- https://quick-lint-js.com/
---
--- quick-lint-js finds bugs in JavaScript programs.
---
--- See installation [instructions](https://quick-lint-js.com/install/)

---@type vim.lsp.Config
return {
    cmd = { 'quick-lint-js', '--lsp-server' },
    filetypes = {
        'javascript',
        'javascriptreact',
        'javascript.jsx',
        'typescript',
        'typescriptreact',
        'typescript.tsx',
        'vue',
        'svelte',
        'astro',
        'htmlangular',
    },
    root_markers = { 'package.json', 'jsconfig.json', '.git' },
    on_attach = function(client, bufnr)
        if client.name == "quick-lint-js" then
            vim.diagnostic.config({
                update_in_insert = true,
            }, client.id)
        end
    end,
}
