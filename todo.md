fix terminal double-input when not in tmux
configure status far
configure rofi
get zen onto rofi menu
configure brightness adjustment
display birghtness and volume levels

dev-env software checklist:
    apt packages
    git (move to .config/git/config w/ symlink)
x    zsh
x    tmux
x    scripts
    nvim
    sway
    neovim plugins, servers
    lua
    nvm
    npm
    lua_ls
    eslint
    prettier

dev-env
    set up set-up script per:
    https://frontendmasters.com/courses/developer-productivity-v2/convert-ansible-script-to-bash/
    https://frontendmasters.com/courses/developer-productivity-v2/dotfiles/
    set up dev-env and dev-commit scripts:
    https://github.com/ThePrimeagen/dev/blob/master/env/.local/scripts/dev-commit
window manager
    sway use super+... for WM keys
        rofi or dmenu
        enter: terminal
    waybar
zsh and terminal:
    shortcut for vim .
    configure zsh-autosuggestion: accept suggestion (currently set to right arrow)
    ctrl click to go to url
    click to place cursor in terminal
    click and drag to copy text
    double clicking to highlight and then copying modified files for git-add (like that guy from paycom)
tmux:
neovim:
    set up prettier with format on save (via blink?)
    set up eslint for jump to def, jump to impl, etc
Freedom:
    update timezone

Problem with copying instead of linking configs:
when I edit a config locally, it's not added to the repo.
When I edit a config in the repo, it's nto added locally.

switch to real programmer's qwerty?
consolidate configs from several repos:
scripts
dotfiles
etc
------------------------ CONFIG PLANNING ------------------------
principles:
1. Try not to stray from defaults.
2. Minimize searching with eyeballs.
3. Don't switch to something just because it's newer.
4. Create tools to improve your experience; not to shave off one keystroke.
5. Minimize mental indirection e.g. symlinks, deeply nested directories, and
    black-box tools.

guidelines:
keep it specific to my own machine: don't try to be cross-platform unlenss it's
the last thing to do.

I'd like to C-f in to a project and start coding, so I should probably clone
projects directly into ~/, ~/personal/, and ~/school/, instead of doing nested
directories. This flatter directory tree keeps the leaf projects easily
navigable with tmux-sessionizer.

keymap mental models: mnemonic when possible, with certain exceptions e.g hjkl,
tmux ctrl+b, etc 2, 3-letter keymap mnemonics should try to adhere to a
"generic, then specific" model e.g. gs := git status prefer one or two more
keystrokes over stacking operations in mental overhead e.g. "delete line, then
insert" is easier than "insert delete line" avoid using same finger twice in a
row, but prefer it over finger-twisters avoid situations wherein one keymap is
a prefix of another don't rely on insert key; my laptop doesn't have one!

ansible:
overkill with high overhead; only use for small things like ssh key vault
