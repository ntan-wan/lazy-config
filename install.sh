#!/bin/sh
# Symlink this repo's LazyVim and lazygit configs into place.
# Usage: ./install.sh [--clean] [--no-plugins]
#   --clean       also back up Neovim's data/state/cache dirs for a fresh plugin install
#   --no-plugins  skip installing Neovim plugins (they install on first launch instead)
set -eu

REPO_DIR=$(cd "$(dirname "$0")" && pwd -P)
CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
STAMP=$(date +%Y%m%d-%H%M%S)
CLEAN=0
PLUGINS=1

for arg in "$@"; do
  case $arg in
    --clean) CLEAN=1 ;;
    --no-plugins) PLUGINS=0 ;;
    -h | --help)
      sed -n '2,5p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      exit 1
      ;;
  esac
done

if [ -t 1 ]; then
  RED=$(printf '\033[31m') YELLOW=$(printf '\033[33m') GREEN=$(printf '\033[32m') RESET=$(printf '\033[0m')
else
  RED='' YELLOW='' GREEN='' RESET=''
fi

info() { printf '%s\n' "$*"; }
ok() { printf '%s✓%s %s\n' "$GREEN" "$RESET" "$*"; }
warn() { printf '%s!%s %s\n' "$YELLOW" "$RESET" "$*"; }
fail() { printf '%s✗%s %s\n' "$RED" "$RESET" "$*"; }

has() { command -v "$1" >/dev/null 2>&1; }

install_hint() {
  # $1 = brew package, $2 = apt package
  if [ "$(uname -s)" = Darwin ]; then
    echo "brew install $1"
  else
    echo "sudo apt install $2  (or see the tool's install docs)"
  fi
}

MISSING_REQUIRED=0

require() {
  # $1 = command, $2 = brew package, $3 = apt package
  if has "$1"; then
    ok "$1"
  else
    fail "$1 is required: $(install_hint "$2" "$3")"
    MISSING_REQUIRED=1
  fi
}

recommend() {
  # $1 = command, $2 = brew package, $3 = apt package, $4 = why
  if has "$1"; then
    ok "$1"
  else
    warn "$1 not found ($4): $(install_hint "$2" "$3")"
  fi
}

check_nvim_version() {
  has nvim || return 0
  version=$(nvim --version | head -n 1 | sed 's/^NVIM v//')
  major=$(echo "$version" | cut -d. -f1)
  minor=$(echo "$version" | cut -d. -f2)
  if [ "$major" -eq 0 ] && [ "$minor" -lt 11 ]; then
    fail "nvim $version is too old, LazyVim needs 0.11 or newer"
    MISSING_REQUIRED=1
  fi
}

info "Checking dependencies..."
require git git git
require nvim neovim neovim
check_nvim_version
require lazygit lazygit lazygit
recommend rg ripgrep ripgrep "used for live grep"
if has fdfind; then
  ok "fd (as fdfind)"
else
  recommend fd fd fd-find "used for file search"
fi
recommend delta git-delta git-delta "lazygit diff pager"
recommend cc gcc build-essential "compiles treesitter parsers"
recommend npm node npm "Mason installs prettier with it"
recommend tree-sitter tree-sitter-cli tree-sitter-cli "builds treesitter parsers; Mason installs it if missing"
info "Also make sure your terminal uses a Nerd Font: https://www.nerdfonts.com"

if [ "$MISSING_REQUIRED" -ne 0 ]; then
  echo
  fail "Install the required tools above, then run this script again."
  exit 1
fi

backup() {
  # Move $1 aside if it exists (file, dir or symlink).
  if [ -e "$1" ] || [ -L "$1" ]; then
    mv "$1" "$1.bak.$STAMP"
    warn "Backed up $1 -> $1.bak.$STAMP"
  fi
}

link() {
  # $1 = source in repo, $2 = target path
  if [ -L "$2" ] && [ "$(readlink "$2")" = "$1" ]; then
    ok "$2 already linked"
    return
  fi
  backup "$2"
  mkdir -p "$(dirname "$2")"
  ln -s "$1" "$2"
  ok "Linked $2 -> $1"
}

lazygit_config_dir() {
  dir=$(lazygit --print-config-dir 2>/dev/null || true)
  if [ -n "$dir" ]; then
    echo "$dir"
  else
    echo "$CONFIG_HOME/lazygit"
  fi
}

echo
info "Linking configs..."
link "$REPO_DIR/nvim" "$CONFIG_HOME/nvim"
link "$REPO_DIR/lazygit" "$(lazygit_config_dir)"

if [ "$CLEAN" -eq 1 ]; then
  echo
  info "Backing up Neovim data, state and cache..."
  backup "${XDG_DATA_HOME:-$HOME/.local/share}/nvim"
  backup "${XDG_STATE_HOME:-$HOME/.local/state}/nvim"
  backup "${XDG_CACHE_HOME:-$HOME/.cache}/nvim"
fi

install_plugins() {
  # The first launch installs some plugins at their latest commit and rewrites
  # lazy-lock.json, so put the lockfile back and restore to the pinned commits.
  lockfile="$REPO_DIR/nvim/lazy-lock.json"
  saved_lock=$(mktemp)
  cp "$lockfile" "$saved_lock"
  nvim --headless "+qa" >/dev/null 2>&1 || true
  cp "$saved_lock" "$lockfile"
  rm -f "$saved_lock"
  if nvim --headless "+Lazy! restore" "+qa" >/dev/null 2>&1; then
    ok "Plugins installed at the versions in lazy-lock.json"
  else
    warn "Plugin install reported errors, open nvim and run :Lazy to check"
  fi
}

if [ "$PLUGINS" -eq 1 ]; then
  echo
  info "Installing Neovim plugins (takes a minute)..."
  install_plugins
fi

echo
ok "Done. Next steps:"
info "  1. Run 'nvim'. Mason finishes installing language tools in the background."
info "  2. Run ':checkhealth' inside Neovim to spot anything missing."
info "  3. Run 'lazygit' inside any git repo."
