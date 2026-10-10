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

`setup` updates the checkout with `git pull` and invokes `runner`. The runner
loads `env/.config/zsh/.zshenv`, installs system packages and language servers,
then runs the selected scripts in `runs/configure` in its explicit order.

Neovim is installed by the platform installer. `runs/configure/neovim` links its
configuration. To install missing tools again without pulling the repository:

```bash
./runner
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

Package managers handle repeat runs: apt uses `--no-upgrade`, Homebrew uses
`HOMEBREW_NO_INSTALL_UPGRADE=1`, RubyGems uses `--conservative`, and uv manages
its existing tool installation. npm package versions are pinned in the installer.
Only bootstrapping Homebrew/uv and downloading Linux LuaLS need existence checks.
These options avoid explicitly upgrading existing packages; package managers
may still adjust dependencies when installing missing packages.
npm and RubyGems install without sudo, with commands in
`~/.local/bin`; uv exposes basedpyright there too. Linux LuaLS lives in
`~/.local/lua-language-server`. The shell configuration adds these to PATH and
exposes Homebrew's Ruby and LLVM on macOS.

Ruby LSP is installed for the Ruby selected when setup runs. If you switch Ruby
versions with rbenv, rerun `./runs/install_language_servers` under that Ruby to
install its gem if needed. Node/npm and Ruby/RubyGems from the system package
manager provide the fresh-machine defaults; existing runtime managers remain
usable. macOS requires the command line developer tools needed by Homebrew.

Installation references: [uv](https://docs.astral.sh/uv/getting-started/installation/),
[LuaLS](https://github.com/LuaLS/lua-language-server/releases/tag/3.19.1),
[clangd](https://clangd.llvm.org/installation),
[JSON](https://github.com/hrsh7th/vscode-langservers-extracted),
[quick-lint-js](https://quick-lint-js.com/install/neovim/npm-posix/),
[Ruby LSP](https://shopify.github.io/ruby-lsp/#with-other-editors), and
[basedpyright](https://docs.basedpyright.com/latest/installation/command-line-and-language-server/).
