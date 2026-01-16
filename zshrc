# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi


# The following lines were added by compinstall

zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|[._-.]=** r:|=**' '' 'l:|=* r:|=*'
zstyle :compinstall filename '/home/adarsh/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt autocd beep extendedglob nomatch notify

bindkey -v
export KEYTIMEOUT=1
# End of lines configured by zsh-newuser-install
#

function tat {
  name=$(basename `pwd` | sed -e 's/\.//g')

  if tmux ls 2>&1 | grep "$name"; then
    tmux attach -t "$name"
  elif [ -f .envrc ]; then
    direnv exec / tmux new-session -s "$name"
  else 
    tmux new-session -s "$name"
  fi
}

source ~/.privaterc

export EDITOR="nvim"
export VISUAL="nvim"
alias v="nvim"

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


alias cd="z"
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'


alias ls='eza --icons --git --group-directories-first --color=always --long --header --time-style=long-iso'
alias lsf='eza --icons --git --long --header --group --group-directories-first --time-style=relative --color=always'
alias lst='eza --icons --git --tree --level=2 --group-directories-first'
alias ll='eza --icons --long'
alias la='eza --icons --git --all --long --header'
alias lt='eza --icons --tree --level=3'
alias l='eza --icons'


alias c='clear'
alias catp='bat --paging=always'
alias less='bat'
alias grep='grep --color=auto'


alias df='df -h'
alias du='du -h'
alias duh='du -h --max-depth=1'
alias free='free -h'


alias g='git'
alias gst='git status'
alias ga='git add'
alias gaa='git add .'
alias gc='git commit'
alias gcm='git commit -m'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias glog='git log --oneline --graph --decorate --all'


alias ta='tmux attach -t'
alias tn='tmux new -s'
alias tls='tmux ls'
alias tk='tmux kill-session -t'


alias reload='source ~/.zshrc'
alias path='echo -e ${PATH//:/\\n}'
alias mkdirp='mkdir -pv'

alias factorio='wine ~/Downloads/Factorio-SteamRIP.com/Factorio/bin/x64/factorio.exe'
