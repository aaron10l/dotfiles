# dotfiles

Personal terminal and editor setup for macOS.

[github.com/aaron10l/dotfiles](https://github.com/aaron10l/dotfiles)

## What's included

- **WezTerm** — `wezterm/.config/wezterm/wezterm.lua`
- **Neovim** — `nvim/.config/nvim/` (Kickstart-based, Lazy.nvim)
- **Rectangle** — installed via Homebrew (default app settings)

## Prerequisites

Install these before running the install script:

```bash
brew install wezterm neovim
brew install --cask font-hack-nerd-font rectangle
```

Optional (recommended for cleaner installs):

```bash
brew install stow
```

## Install on a new machine

```bash
git clone https://github.com/aaron10l/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

The install script symlinks configs into `~/.config/`. If you already have real directories at those paths, they are moved to `*.bak.<timestamp>` first.

On first launch, Neovim will bootstrap Lazy.nvim and install plugins automatically.

## WezTerm keybindings

Leader is `Ctrl+Space`.

| Keys | Action |
| --- | --- |
| `Leader h` | Split vertical |
| `Leader v` | Split horizontal |
| `Leader z` | Toggle pane zoom |
| `Leader Shift h/j/k/l` | Resize pane (repeatable) |
| `Ctrl h/j/k/l` | Navigate panes (works with nvim splits) |
| `Leader 1-5` | Switch tab |
| `Leader m` | Toggle maximize (fills screen, not native fullscreen) |
| `Cmd f` | Toggle maximize (fills screen, not native fullscreen) |
| `Ctrl Cmd f` | Native macOS fullscreen |
| `Leader s` | Fuzzy workspace switcher |
| `Leader n` | New workspace |
| `Cmd Shift R` | Reload WezTerm config |

## Neovim

Config lives in `init.lua` with custom plugins under `lua/custom/plugins/`.

`lazy-lock.json` is tracked so plugin versions stay in sync across machines.

## Rectangle

The install script installs Rectangle if it is missing. Default shortcuts and settings are used — no config is tracked in this repo.

After install, open Rectangle once and grant **Accessibility** permission when macOS prompts you.

## Updating

Edit files in `~/dotfiles`, then commit and push. Changes are live immediately because configs are symlinked.

```bash
cd ~/dotfiles
git add -A
git commit -m "Update configs"
git push
```

On another machine:

```bash
cd ~/dotfiles
git pull
```
