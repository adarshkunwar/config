#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$ROOT_DIR/config"
CONFIG_DIR="$HOME/.config"
SCRIPTS_DIR="$HOME/.scripts"

log() {
  printf "\033[1;32m[dotfiles]\033[0m %s\n" "$1"
}

backup_if_exist() {
  local target="$1"

  if [[ -e "$target" || -L "$target" ]]; then
    log "A config found at $target"
    read -rp "Do you want to create a backup? [y/N] " should_backup
    should_backup=${should_backup,,}

    if [[ $should_backup == "y" ]]; then
      local backup="${target}.bak.$(date +%Y%m%d_%H%M%S)"
      mv "$target" "$backup"
      log "Backed up $target -> $backup"
    else
      log "You need to remove the config at $target first"
      return 1
    fi
  fi
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CONFIG
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

link_config() {
  local name="$1"
  local folder="$2"

  if [[ "$2" == "config" ]]; then
    local source="$DOTFILES_DIR/$name"
    local target="$CONFIG_DIR/$name"
  else
    local source="$ROOT_DIR/$name"
    local target="$HOME/.$name"
  fi

  if [[ ! -e "$source" ]]; then
    log "Skipping $name (not found in dotfiles)"
    return
  fi

  if [[ -L "$target" && "$(readlink "$target")" == "$source" ]]; then
    log "$name already linked, skipping"
    return
  fi

  backup_if_exist "$target"
  ln -s "$source" "$target"
  log "Linked $name"
}

starter() {
  local -n arr="$1"
  local folder="$2"

  for file in "${arr[@]}"; do
    link_config "$file" "$folder"
  done
}

# Core configs
config_folder=(
  i3
  nvim
  kitty
  polybar
  rofi
)

# Shell config
root_file=(
  zshrc
  tmux.conf
)

mkdir -p "$CONFIG_DIR"

starter config_folder "config"
starter root_file "root"

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# SCRIPTS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

mkdir -p "$SCRIPTS_DIR"

for script in "$ROOT_DIR/scripts/"*; do
  name=$(basename "$script")
  target="$SCRIPTS_DIR/$name"

  if [[ -e "$target" ]]; then
    log "Script $name already exists in $SCRIPTS_DIR, skipping"
    continue
  fi

  ln -s "$script" "$target"
  log "Linked script $name -> $target"
done

log "Dotfiles installation complete"
