# ~~~~~~~~~~~~~~~~~~~PATH~~~~~~~~~~~~~~~~~~~~~~

path=(
  $HOME/bin
  $HOME/.local/bin
  $HOME/.scripts
  /opt/cuda/bin
  $path
)


typeset -U path
export PATH


# ~~~~~~~~~~~~~~~~~~~Colors~~~~~~~~~~~~~~~~~~~~~~

autoload -U colors
colors

export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad
export FZF_DEFAULT_OPTS="
--color=fg:#c8c8c8,bg:#000000
--color=hl:#ffffff
--color=pointer:#ffffff
--color=marker:#ffffff
"
export EZA_COLORS="di=38;5;250:fi=38;5;245"


# ~~~~~~~~~~~~~~~~~~~Environment Variables~~~~~~~~~~~~~~~~~~~~~~

set -o vi

export EDITOR="nvim"
export VISUAL="nvim"
export TERM="tmux-256color"

# Directories
export DOTFILES="$HOME/Documents/dotfiles"

# Electron flags
export ELECTRON_FLAGS="$(cat ~/.config/electron/electron-flags.conf | tr '\n' ' ')"

# bat theme
export BAT_THEME="TwoDark"

# grep coloring (amber theme)
export GREP_COLORS='ms=01;38;5;255:mc=01;38;5;255:sl=38;5;240:cx=:fn=38;5;250:ln=38;5;240:bn=38;5;240:se=38;5;250'

# Minor tweaks
setopt autocd beep extendedglob nomatch notify

eval "$(zoxide init zsh)"


# ~~~~~~~~~~~~~~~~~~~History~~~~~~~~~~~~~~~~~~~~~~

HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000

setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY



alias v=nvim
alias cd=z

alias dot='cd $DOTFILES'

# eza improvements
alias ls='eza --icons=always --color=always --group-directories-first'
alias ll='eza -lah --icons --group-directories-first'
alias la='eza -a --icons'
alias lst='eza --icons --tree --level=3'

alias catp='bat --paging=always'
alias less='bat'

alias grep='grep --color=auto'

alias df='df -h'
alias du='du -h'
alias duh='du -h --max-depth=1'
alias free='free -h'

alias g='git'
alias gst='git status'
alias gd='git diff'
alias glog='git log --oneline --graph --decorate --all'

alias ta='tmux attach -t'
alias tn='tmux new -s'
alias tls='tmux ls'
alias tk='tmux kill-session -t'

alias reload='source ~/.zshrc'
alias mkdirp='mkdir -pv'

alias discord="discord $ELECTRON_FLAGS"
alias cursor="cursor $ELECTRON_FLAGS"

# zoxide interactive jump
alias zi='zoxide query -i | xargs cd'


# ~~~~~~~~~~~~~~~~~~~Sourcing~~~~~~~~~~~~~~~~~~~~~~

source ~/.privaterc
source <(fzf --zsh)


# ~~~~~~~~~~~~~~~~~~~Functions~~~~~~~~~~~~~~~~~~~~~~

# Terminal title for kitty tabs
precmd() {
  print -Pn "\e]0;%n@%m: %~\a"
}


# ~~~~~~~~~~~~~~~~~~~Completion~~~~~~~~~~~~~~~~~~~~~~

zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate

zstyle ':completion:*' matcher-list \
'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' \
'r:|[._-.]=** r:|=**' \
'' \
'l:|=* r:|=*'

# Completion UI styling
zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{245}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{196}No matches found%f'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

zstyle :compinstall filename '/home/adarsh/.zshrc'

autoload -Uz compinit
compinit


# ~~~~~~~~~~~~~~~~~~~Better History Search~~~~~~~~~~~~~~~~~~~~~~

source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down


# ~~~~~~~~~~~~~~~~~~~Colored man pages~~~~~~~~~~~~~~~~~~~~~~

export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;38;5;255m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[38;5;255;48;5;236m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[04;38;5;250m'


# ~~~~~~~~~~~~~~~~~~~Startup Banner~~~~~~~~~~~~~~~~~~~~~~

print -P "%F{250}󰣇  welcome back, Adarsh%f"
print -P "%F{240}$(date '+%A %d %B %H:%M')%f"
echo


# ~~~~~~~~~~~~~~~~~~~ Development ~~~~~~~~~~~~~~~~~~~~~~
eval "$(fnm env --use-on-cd)"

export LD_LIBRARY_PATH=/opt/cuda/lib64:$LD_LIBRARY_PATH
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

# ~~~~~~~~~~~~~~~~~~~Prompt~~~~~~~~~~~~~~~~~~~~~~

fpath+=($HOME/.zsh/pure)

autoload -U promptinit
promptinit

# Pure prompt styling
export PURE_PROMPT_SYMBOL="❯"
export PURE_GIT_UNTRACKED_DIRTY=1

zstyle :prompt:pure:path color 250
zstyle :prompt:pure:git:branch color 245
zstyle :prompt:pure:git:dirty color 160
zstyle :prompt:pure:git:clean color 250
zstyle :prompt:pure:prompt:error color 160

prompt pure


# ~~~~~~~~~~~~~~~~~~~Alias~~~~~~~~~~~~~~~~~~~~~~
