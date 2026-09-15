# My Dev Tools

Personal shell, editor, and tmux configuration with setup scripts. Ubuntu is the
primary target; macOS support is best-effort.

## Installation

The checkout must be at `$HOME/dev`. On Ubuntu, setup assumes Bash, Git, `sudo`,
`apt`, and `add-apt-repository` are available.

```bash
git clone https://github.com/ianebeckett/dev "$HOME/dev"
cd "$HOME/dev"
./setup
```

`setup` updates the checkout with `git pull`, links `~/.gitconfig`, and invokes
`runner`. The runner loads `env/.config/zsh/.zshenv`, runs the platform installer,
then runs the remaining configuration scripts in filename order.

Neovim is installed by the platform installer. `runs/neovim` links its configuration.
Some shell/editor integrations still require additional tools; see `backlog.md`.

## Selective runs

```bash
./runner --dry-run               # Preview the full execution order
./runner --dry-run '/tmux$'       # Preview only the tmux configuration step
./runner '/tmux$'                 # Apply only the tmux configuration
./runner '/installs$'             # Install the platform's full package list
```

The filter is a grep regex matched against relative script paths. `/tmux$` selects
only tmux; bare `tmux` also selects `tmux-sessionizer`. The installer runs first
only when it matches the selection. For example, `/neovim$` configures Neovim but
doesn't install packages.

Dry-run loads `.zshenv` and lists selected scripts, without executing their bodies.
It does not validate package commands or destination conflicts.

## Configuration and reruns

- Edit configuration sources under `env/`.
- XDG paths are defined in `env/.config/zsh/.zshenv`. Use `runner` so these variables
  are initialized before configuration scripts run. `runs/zsh` also links
  `~/.zshenv` for future shell sessions.
- `lib/links.sh` creates parent directories, skips correct links, and replaces
  stale symlinks. Missing sources and existing non-symlink destinations are errors.
- Runtime caches live under `~/.cache`; Zsh history lives under `~/.local/state`.

The runner stops on the first failed script and returns its exit status. Fix the
reported issue, then rerun `./runner` to apply the full sequence, or use a filter
to retry a specific script. For a destination conflict, merge or move aside the
existing configuration before retrying.

## Checks

```bash
bash tests/smoke.sh
```

This uses a temporary home, fixture configuration sources, and stub package
installers to check dry-run selection, install-first execution, repeatable linking,
and failure propagation. It requires Bash and standard Unix tools.

For small shell edits, use focused syntax checks such as `bash -n runner` or
`zsh -n env/.config/zsh/.zshrc`.
