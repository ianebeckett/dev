# Repository notes

## Bootstrap and runner

- `env/` contains configuration sources symlinked into the live home environment.
  `setup`, the installers, and Zsh configuration assume the checkout is `$HOME/dev`.
- `./setup` bootstraps the host, runs `git pull`, links `~/.gitconfig`, and invokes
  `runner`. It changes the host environment; use the checks below for verification.
- `./runner --dry-run` lists selected scripts without executing their bodies.
  `./runner --dry-run '/tmux$'` selects only `runs/tmux`; remove `--dry-run` to apply.
  The filter is a grep regex over relative paths: bare `tmux` also matches
  `tmux-sessionizer`. Dry-run does not validate commands inside the scripts.
- `runner` discovers only executable files directly under `runs/`, without sorting
  or dependency ordering. New run scripts need executable permissions. It does not
  stop on script failures, so its exit status does not prove every script succeeded.
- `runs/installs`, `runs/installs-linux`, and `runs/installs-macos` are checked in
  without executable permissions and are skipped by `runner`. The dispatcher also
  executes its platform script directly, so `bash runs/installs` alone is insufficient.
- Portability is incomplete: `runner` uses `find -executable`, and `runs/neovim`
  unconditionally uses Ubuntu's unstable Neovim PPA and apt despite `setup`'s macOS branch.

## Configuration wiring

- `runs/tmux-sessionizer` requires exported `XDG_CONFIG_HOME` and `XDG_CACHE_HOME`
  with no fallback. These are defined in `env/.config/zsh/.zshenv`, but `runs/zsh`
  only links the Zsh directory and `~/.zshrc`; it does not link `~/.zshenv`.
- Neovim uses native `vim.pack` and `vim.lsp` APIs. Plugin declarations live in
  `env/.config/nvim/lua/pack.lua`, with revisions in `nvim-pack-lock.json` beside
  `init.lua`. Preserve the initialization order in `init.lua`.
- Neovim server definitions live in `env/.config/nvim/lsp/`; activation is separate
  in `env/.config/nvim/after/plugin/lsp/lsp.lua`. Language-server executables must
  already be available on PATH.
- The runnable tmux helpers are in `env/.local/scripts/`, linked by `runs/scripts`
  and added to PATH by `.zshrc`. Edit those sources rather than the similarly named
  file under `env/.cache/`. `tmux-sessionizer` reads
  `env/.config/tmux-sessionizer/tmux-sessionizer.conf` through its installed link;
  its actual session-command flag is `-s N` and window index is `69 + N`
  (the config's `-w`/`99` comments are stale).

## Focused verification

- There is no repository-wide build, test, lint, or CI task. The nested OpenCode
  `package.json` only declares plugin dependencies.
- Parse each changed Bash script separately, e.g. `bash -n runner` or
  `bash -n env/.local/scripts/tmux-sessionizer`. Parse Zsh configuration with
  `zsh -n env/.config/zsh/.zshrc` (substitute the changed file).
- Use `./runner --dry-run '/name$'` to verify script discovery and filtering.
  Neovim startup loads `vim.pack.add(..., { confirm = false })` and can install
  plugins; it is not a syntax-only check.
