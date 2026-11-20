# My Dev Tools

Personal shell, editor, and tmux configuration with setup scripts. Ubuntu is the
primary target; macOS support is best-effort.

## Installation

First, set up a new SSH key for your device

The checkout must be at `$HOME/dev`. On Ubuntu, setup assumes Bash, Git, `sudo`,
`apt`, and `add-apt-repository` are available.

```bash
git clone git@github.com:ianebeckett/dev.git "$HOME/dev"
cd "$HOME/dev"
./setup
```

`./runner --dry-run` prints the scripts it would run without executing them.

The language server installer uses these package sources:

| Tool | Ubuntu | macOS |
| --- | --- | --- |
| Node and npm | apt (`nodejs`, `npm`) | Homebrew (`node`) |
| Ruby, RubyGems, and Bundler | apt (`ruby`, `ruby-dev`, `ruby-bundler`, native build dependencies) | Homebrew (`ruby`) |
| uv | Official standalone installer | Homebrew (`uv`) |
| clangd | apt (`clangd`) | Homebrew (`llvm`) |
| LuaLS | Official 3.19.1 release, SHA-256 checked, x86-64/ARM64 | Homebrew (`lua-language-server`) |
| JSON language server | npm (`vscode-langservers-extracted@4.10.0`) | Same |
| quick-lint-js | npm (`quick-lint-js@3.2.0`) | Same |
| Ruby LSP | RubyGems (`ruby-lsp`) | Same |
| basedpyright | `uv tool install basedpyright` | Same |
