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

## TeX lecture notes on Ubuntu GNOME

The automatic viewer workflow targets Ubuntu GNOME (tested on Ubuntu 26.04 /
GNOME 50). The Ubuntu package installer adds:

- TeX Live's recommended/additional LaTeX packages, recommended fonts, and
  mathematics/science packages, plus `latexmk` for compilation.
- Zathura and its Poppler PDF backend.
- The system Python's PyGObject/Gio bindings for desktop integration.
- Ubuntu's desktop extensions, including Desktop Icons NG (DING), which exposes
  per-monitor dimensions and dock/panel margins. Ubuntu 26.04 uses
  `gnome-shell-ubuntu-extensions`; older releases use separate DING/Dock packages.

After linking the Neovim configuration, the runner executes `runs/configure/tex`
as the logged-in user. It enables DING and installs/enables
[Window Calls](https://extensions.gnome.org/extension/4724/window-calls/) through
GNOME's extension service. Accept GNOME's installation dialog on the first run.
Existing active extensions are reused; disabled required extensions are enabled,
and unrelated extensions and dock preferences are preserved. Globally disabled
user extensions and incompatible installed versions produce actionable errors.
No unsafe-mode setting is needed.

Run the desktop step from a terminal in your GNOME session, without sudo. Setup
outside GNOME defers this step. If a newly installed system extension is not yet
recognized, log out and back in before retrying:

```bash
./runs/configure/tex
./runs/configure/tex --check
```

`--check` verifies required commands and both live extension interfaces without
installing anything or changing desktop settings. The desktop configuration runs
last, so its failure does not prevent the other tools from being linked.

VimTeX and LuaSnip are already declared in the linked Neovim configuration and
are installed by `vim.pack` on first startup. This requires a Neovim build with
`vim.pack` support. Open a saved, compilable `.tex` file to start `latexmk` and
its PDF viewer; saves rebuild the PDF. The terminal sits beside the dock on the
left and the PDF occupies the right half of the terminal's monitor. Focus returns
to Neovim. Closing the last project buffer with `:bd` closes the managed viewer;
when no other managed viewer uses that terminal, it re-maximizes. Independent PDF
viewers are reused without taking ownership of their lifetime. After changing
monitor configurations, reopen the TeX buffer to recalculate the layout.

The automatic desktop workflow is Linux/GNOME-specific; macOS setup skips this
step. `wmctrl`, `xdotool`, and a forced XWayland backend are not needed by the
current implementation. A fresh non-GNOME machine needs a separate viewer setup.

Validation (no package installations or desktop changes):

```bash
python3 -B -m unittest discover -s tests -v
python3 -B -m unittest discover -s env/.config/nvim/tests -v
```

Primary references: [TeX Live](https://tug.org/texlive/),
[Zathura](https://pwmt.org/projects/zathura/),
[Window Calls](https://extensions.gnome.org/extension/4724/window-calls/), and
[Desktop Icons NG](https://gitlab.com/rastersoft/desktop-icons-ng).
