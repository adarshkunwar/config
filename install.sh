#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/config"
CONFIG_DIR="$HOME/.config"

log() {
  printf "\033[1;32m[dotfiles]\033[0m %s\n" "$1"
}

backup_if_exist() {
  local target="$1"

  if [[ -e "$target" || -L "$target" ]]; then
    local backup="${target}.bak.$(date +%Y%m%d_%H%M%S)"
    mv "$target" "$backup"
    log "Backed up $target -> $backup"
  fi
}

link_config() {
  local name="$1"
  local source="$DOTFILES_DIR/$name"
  local target="$CONFIG_DIR/$name"

  if [[ ! -e "$source" ]]; then
    log "Skipping $name (not found in dot files)"
    return
  fi

  backup_if_exist "$target"
  ln -s "$source" "$target"
  log "Linked $name"
}

log "Starting dotfiles installation"

mkdir -p "$CONFIG_DIR"

# Core configs
link_config i3
link_config nvim
link_config kitty
link_config polybar

log "Dotfiles installation complete"
