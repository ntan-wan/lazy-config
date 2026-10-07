# lazy-config

My [LazyVim](https://www.lazyvim.org) and [lazygit](https://github.com/jesseduffield/lazygit) setup. Clone it, run one script, and you get the same editor and git UI I use.

Works on Linux, WSL and macOS.

## Quick start

```sh
git clone <this-repo-url> ~/lazy-config
cd ~/lazy-config
./install.sh
```

The script:

1. Checks the tools below and tells you how to install any that are missing.
2. Moves your current `~/.config/nvim` and lazygit config aside as `*.bak.<timestamp>` backups.
3. Symlinks the configs from this repo into place.
4. Installs Neovim plugins at the exact versions in `nvim/lazy-lock.json`.

Then open `nvim` and run `:checkhealth`.

Options:

- `--clean` also backs up `~/.local/share/nvim`, `~/.local/state/nvim` and `~/.cache/nvim`. Use it if you had another Neovim setup before and see plugin errors.
- `--no-plugins` skips step 4. Plugins install the first time you open `nvim` instead.

## Requirements

| Tool | Needed for |
| --- | --- |
| `git`, `nvim` 0.11+, `lazygit` | required |
| `rg` (ripgrep), `fd` | file and text search |
| `delta` | diffs in lazygit |
| a C compiler, `tree-sitter` CLI | treesitter parsers |
| `node` / `npm` | Mason installs prettier with it |
| a [Nerd Font](https://www.nerdfonts.com) in your terminal | icons |

## What's included

### Neovim (`nvim/`)

Stock LazyVim plus:

- **Options** (`lua/config/options.lua`): 4-space indent, absolute line numbers, `scrolloff=5`, faster `timeoutlen`, blinking cursor, format-on-save **off** (format manually with `<leader>cf`).
- **Keymaps** (`lua/config/keymaps.lua`): `jk` / `kj` in insert mode to exit to normal mode.
- **Formatting** (`lua/plugins/formatting.lua`): prettier for JS/TS/JSON/HTML/CSS/Markdown/YAML, stylua for Lua. Mason installs both.
- **Git**
  - [gitsigns](https://github.com/lewis6991/gitsigns.nvim): inline blame on the current line.
  - [diffview](https://github.com/sindrets/diffview.nvim): `<leader>gv` open changes, `<leader>gV` close, `<leader>gH` history of the current file. `q` closes it.
- **[live-server.nvim](https://github.com/barrettruth/live-server.nvim)**: `:LiveServerStart` / `:LiveServerStop` for HTML/CSS/JS live reload.
- **LazyVim extras**: Markdown.
- Open lazygit inside Neovim with `<leader>gg`.

### lazygit (`lazygit/config.yml`)

- Diffs go through `delta`.
- `b` on a file (Files panel or a commit's file list) runs `git blame` on it.

## Customizing

The configs are symlinked, so editing `~/.config/nvim/...` edits this repo. Add plugins as new files in `nvim/lua/plugins/`. See the [LazyVim docs](https://www.lazyvim.org/configuration/plugins) for how to override things.

## Updating

```sh
cd ~/lazy-config
git pull
nvim --headless "+Lazy! restore" +qa
```

`:Lazy restore` moves your plugins to the versions in `lazy-lock.json`. Running `:Lazy update` changes that file; commit it if you want others to get the new versions.

## Uninstall

```sh
./uninstall.sh
```

Removes the symlinks (only if they point into this repo) and restores your newest backups.
