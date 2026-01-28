# ~~~~~~~~~~~~~~~~~~~PATH~~~~~~~~~~~~~~~~~~~~~~

path=(
  $HOME/bin
  $HOME/.local/bin
  $HOME/.scripts
  $path                 # Keep existing PATH entries
)

# Remove duplicate entries
typeset -U path
export PATH

# ~~~~~~~~~~~~~~~~~~~Environemnt Variables~~~~~~~~~~~~~~~~~~~~~~

# Set to vim mode
set -o vi

export EDITOR="nvim"
export VISUAL="nvim"
export TERM="tmux-256color"

# dont need this right now
# export BROWSER="firefox"

# Directories

export DOTFILES="$HOME/Documents/dotfiles"
export SCRIPTS="$HOME/projects/scripts"

# Minor tweeks
setopt autocd beep extendedglob nomatch notify
eval "$(zoxide init zsh)"

# ~~~~~~~~~~~~~~~~~~~History~~~~~~~~~~~~~~~~~~~~~~

HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000

# History behaviour
setopt HIST_IGNORE_SPACE  # Don't save when prefixed with space
setopt HIST_IGNORE_DUPS   # Don't save duplicate line
setopt SHARE_HISTORY      # Share History across sessions

# ~~~~~~~~~~~~~~~~~~~Prompt~~~~~~~~~~~~~~~~~~~~~~

fpath+=($HOME/.zsh/pure)
autoload -U promptinit; promptinit
prompt pure

# ~~~~~~~~~~~~~~~~~~~Alias~~~~~~~~~~~~~~~~~~~~~~

alias v=nvim
alias cd=z

alias scripts='cd $SCRIPTS'
alias dot='cd $DOTFILES'

alias ls='eza --icons'
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

# ~~~~~~~~~~~~~~~~~~~Sourcing~~~~~~~~~~~~~~~~~~~~~~

source ~/.privaterc
source <(fzf --zsh)

# ~~~~~~~~~~~~~~~~~~~Function~~~~~~~~~~~~~~~~~~~~~~

# The following lines were added by compinstall

zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|[._-.]=** r:|=**' '' 'l:|=* r:|=*'
zstyle :compinstall filename '/home/adarsh/.zshrc'

autoload -Uz compinit
compinit

