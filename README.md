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

`setup` updates the checkout with `git pull`, links `~/.gitconfig`, and invokes
`runner`. The runner loads `env/.config/zsh/.zshenv`, runs the platform installer,
then runs the remaining configuration scripts in filename order.

Neovim is installed by the platform installer. `runs/neovim` links its configuration.
Some shell/editor integrations still require additional tools; see `backlog.md`.
