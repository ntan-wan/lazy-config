#!/bin/sh
# Remove the symlinks created by install.sh and restore the newest backups.
set -eu

REPO_DIR=$(cd "$(dirname "$0")" && pwd -P)
CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}

restore_latest_backup() {
  # Backups are named <target>.bak.<YYYYmmdd-HHMMSS>, so the last in sort order is the newest.
  latest=$(ls -d "$1".bak.* 2>/dev/null | sort | tail -n 1 || true)
  if [ -n "$latest" ]; then
    mv "$latest" "$1"
    echo "Restored $latest -> $1"
  fi
}

unlink_target() {
  # $1 = source in repo, $2 = target path
  if [ -L "$2" ] && [ "$(readlink "$2")" = "$1" ]; then
    rm "$2"
    echo "Removed link $2"
    restore_latest_backup "$2"
  else
    echo "Skipped $2 (not linked to this repo)"
  fi
}

lazygit_config_dir() {
  dir=$(lazygit --print-config-dir 2>/dev/null || true)
  if [ -n "$dir" ]; then
    echo "$dir"
  else
    echo "$CONFIG_HOME/lazygit"
  fi
}

unlink_target "$REPO_DIR/nvim" "$CONFIG_HOME/nvim"
unlink_target "$REPO_DIR/lazygit" "$(lazygit_config_dir)"
