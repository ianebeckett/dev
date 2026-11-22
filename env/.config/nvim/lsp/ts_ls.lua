---@brief
---
--- https://github.com/typescript-language-server/typescript-language-server
---
--- `ts_ls`, aka `typescript-language-server`, is a Language Server Protocol implementation for TypeScript wrapping `tsserver`. Note that `ts_ls` is not `tsserver`.
---
--- `typescript-language-server` depends on `typescript`. Both packages can be installed via `npm`:
--- ```sh
--- npm install -g typescript typescript-language-server
--- ```
---
--- To configure typescript language server, add a
--- [`tsconfig.json`](https://www.typescriptlang.org/docs/handbook/tsconfig-json.html) or
--- [`jsconfig.json`](https://code.visualstudio.com/docs/languages/jsconfig) to the root of your
--- project.
---
--- Here's an example that disables type checking in JavaScript files.
---
--- ```json
--- {
---   "compilerOptions": {
---     "module": "commonjs",
---     "target": "es6",
---     "checkJs": false
---   },
---   "exclude": [
---     "node_modules"
---   ]
--- }
--- ```
---
--- Use the `:LspTypescriptSourceAction` command to see "whole file" ("source") code-actions such as:
--- - organize imports
--- - remove unused code
---
--- ### Monorepo support
---
--- `ts_ls` supports monorepos by default. It will automatically find the `tsconfig.json` or `jsconfig.json` corresponding to the package you are working on.
--- This works without the need of spawning multiple instances of `ts_ls`, saving memory.
---
--- It is recommended to use the same version of TypeScript in all packages, and therefore have it available in your workspace root. The location of the TypeScript binary will be determined automatically, but only once.
---

local missing_typescript_notified = {}

local function read_package(path)
  local ok, package = pcall(function()
    return vim.json.decode(table.concat(vim.fn.readfile(path), '\n'))
  end)
  return ok and type(package) == 'table' and package or {}
end

local function has_workspace_typescript(root)
  -- Match typescript-language-server's workspace lookup, including package-manager SDKs.
  local module_folders = {
    'node_modules/typescript/lib',
    '.vscode/pnpify/typescript/lib',
    '.yarn/sdks/typescript/lib',
    '.pnpm/sdks/typescript/lib',
  }
  local dir = root
  while dir do
    for _, folder in ipairs(module_folders) do
      local lib = vim.fs.joinpath(dir, folder)
      if vim.uv.fs_stat(lib) then
        local package = read_package(vim.fs.joinpath(vim.fs.dirname(lib), 'package.json'))
        -- The server uses the first matching directory; an incomplete install cannot start it.
        return vim.fn.filereadable(vim.fs.joinpath(lib, 'tsserver.js')) == 1
          and type(package.version) == 'string'
          and package.version ~= ''
      end
    end
    local parent = vim.fs.dirname(dir)
    if parent == dir then
      break
    end
    dir = parent
  end
  return false
end

---@type vim.lsp.Config
return {
  init_options = { hostInfo = 'neovim' },
  cmd = { 'typescript-language-server', '--stdio' },
  filetypes = {
    'javascript',
    'javascriptreact',
    'javascript.jsx',
    'typescript',
    'typescriptreact',
    'typescript.tsx',
  },
  root_dir = function(bufnr, on_dir)
    -- The project root is where the LSP can be started from
    -- As stated in the documentation above, this LSP supports monorepos and simple projects.
    -- We select then from the project root, which is identified by the presence of a package
    -- manager lock file.
    local root_markers = { 'package-lock.json', 'yarn.lock', 'pnpm-lock.yaml', 'bun.lockb', 'bun.lock' }
    -- Give the root markers equal priority by wrapping them in a table
    root_markers = vim.fn.has('nvim-0.11.3') == 1 and { root_markers, { '.git' } }
        or vim.list_extend(root_markers, { '.git' })
    -- We fallback to the current working directory if no project root is found
    local project_root = vim.fs.root(bufnr, root_markers) or vim.fn.getcwd()

    if has_workspace_typescript(project_root) then
      on_dir(project_root)
      return
    end

    if missing_typescript_notified[project_root] then
      return
    end
    local manifests = vim.fs.find('package.json', {
      path = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)),
      upward = true,
      stop = vim.fs.dirname(project_root),
      type = 'file',
      limit = math.huge,
    })
    for _, path in ipairs(manifests) do
      local package = read_package(path)
      for _, field in ipairs({ 'dependencies', 'devDependencies', 'peerDependencies', 'optionalDependencies' }) do
        if type(package[field]) == 'table' and package[field].typescript ~= nil then
          missing_typescript_notified[project_root] = true
          vim.schedule(function()
            vim.notify(
              'TypeScript dependency missing; install project dependencies to enable TypeScript LSP.\n' .. project_root,
              vim.log.levels.WARN,
              { title = 'ts_ls' }
            )
          end)
          return
        end
      end
    end
  end,
  handlers = {
    -- handle rename request for certain code actions like extracting functions / types
    ['_typescript.rename'] = function(_, result, ctx)
      local client = assert(vim.lsp.get_client_by_id(ctx.client_id))
      vim.lsp.util.show_document({
        uri = result.textDocument.uri,
        range = {
          start = result.position,
          ['end'] = result.position,
        },
      }, client.offset_encoding)
      vim.lsp.buf.rename()
      return vim.NIL
    end,
  },
  commands = {
    ['editor.action.showReferences'] = function(command, ctx)
      local client = assert(vim.lsp.get_client_by_id(ctx.client_id))
      local file_uri, position, references = unpack(command.arguments)

      local quickfix_items = vim.lsp.util.locations_to_items(references, client.offset_encoding)
      vim.fn.setqflist({}, ' ', {
        title = command.title,
        items = quickfix_items,
        context = {
          command = command,
          bufnr = ctx.bufnr,
        },
      })

      vim.lsp.util.show_document({
        uri = file_uri,
        range = {
          start = position,
          ['end'] = position,
        },
      }, client.offset_encoding)

      vim.cmd('botright copen')
    end,
  },
  on_attach = function(client, bufnr)
    -- ts_ls provides `source.*` code actions that apply to the whole file. These only appear in
    -- `vim.lsp.buf.code_action()` if specified in `context.only`.
    vim.api.nvim_buf_create_user_command(bufnr, 'LspTypescriptSourceAction', function()
      local source_actions = vim.tbl_filter(function(action)
        return vim.startswith(action, 'source.')
      end, client.server_capabilities.codeActionProvider.codeActionKinds)

      vim.lsp.buf.code_action({
        context = {
          only = source_actions,
        },
      })
    end, {})
  end,
}
