# Repository notes

## Bootstrap and runner

- `env/` contains configuration sources symlinked into the live home environment.
  `setup`, the installers, and Zsh configuration assume the checkout is `$HOME/dev`.
- `./setup` bootstraps the host, runs `git pull`, links `~/.gitconfig`, and invokes
  `runner`. It changes the host environment; use the checks below for verification.
- `./runner --dry-run` lists selected scripts without executing their bodies.
  `./runner --dry-run '/tmux$'` selects only `runs/tmux`; remove `--dry-run` to apply.
  The filter is a grep regex over relative paths: bare `tmux` also matches
  `tmux-sessionizer`. Dry-run still loads `.zshenv`; it does not validate commands
  inside the scripts or check link destinations.
- `runner` discovers executable regular files directly under `runs/`, including
  hidden files but excluding symlinks. It runs the selected `runs/installs` first,
  then other selected scripts in C-locale filename order. New run scripts need
  executable permissions. A failed script stops the run and its exit status is returned.
- `runs/installs` dispatches to executable helpers in `runs/installers/`. Keep
  platform helpers there so runner discovery does not execute both platforms.
  Filters apply to the dispatcher too; a configuration-only run skips installation.
- Ubuntu is the primary target. Its installer uses apt and the unstable Neovim PPA.
  macOS is best-effort; shell aliases and FZF setup still have Linux-specific assumptions.
  `runs/neovim` only links configuration; package installation belongs in the platform installer.

## Configuration wiring

- `runner` sources `env/.config/zsh/.zshenv` before executing scripts. Keep that
  file compatible with both Bash and Zsh. `runs/zsh` links `~/.zshenv` and `~/.zshrc`
  as well as the Zsh configuration directory.
- XDG variables are initialized explicitly in `.zshenv`. Do not add fallback values
  to linking scripts: missing variables indicate an initialization-order problem.
  Invoke configuration steps through `runner` so they inherit the environment.
- `lib/links.sh` provides `link_config`: validate the source, create parents, skip
  correct links, and replace stale symlinks. Existing real files/directories are
  conflicts. Keep this helper focused on linking, without environment initialization.
- `runs/tmux-sessionizer` creates its runtime cache directory and detaches the old
  checkout-linked cache if present. Cache/state files are not configuration sources.
- Neovim uses native `vim.pack` and `vim.lsp` APIs. Plugin declarations live in
  `env/.config/nvim/lua/pack.lua`, with revisions in `nvim-pack-lock.json` beside
  `init.lua`. Preserve the initialization order in `init.lua`.
- Neovim server definitions live in `env/.config/nvim/lsp/`; activation is separate
  in `env/.config/nvim/after/plugin/lsp/lsp.lua`. Language-server executables must
  already be available on PATH.
- The runnable tmux helpers are in `env/.local/scripts/`, linked by `runs/scripts`
  and added to PATH by `.zshrc`. `tmux-sessionizer` reads
  `env/.config/tmux-sessionizer/tmux-sessionizer.conf` through its installed link;
  its actual session-command flag is `-s N` and window index is `69 + N`
  (the config's `-w`/`99` comments are stale).

## Focused verification

- `bash tests/smoke.sh` runs three focused checks using a temporary home, fixture
  configuration sources, and stub platform installers: dry-run selection,
  install-first execution with repeatable linking, and failure propagation.
- Keep verification proportional. Use syntax checks for small shell edits and the
  smoke check for runner/linking changes. There is no repository-wide build, lint,
  or CI task; the smoke check does not verify real package installation.
- Parse each changed Bash script separately, e.g. `bash -n runner` or
  `bash -n env/.local/scripts/tmux-sessionizer`. Parse Zsh configuration with
  `zsh -n env/.config/zsh/.zshrc` (substitute the changed file).
- Use `./runner --dry-run '/name$'` to verify script discovery and filtering.
  Neovim startup loads `vim.pack.add(..., { confirm = false })` and can install
  plugins; it is not a syntax-only check.
