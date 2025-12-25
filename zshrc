
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

export GITHUB_TOKEN=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

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
alias cd="z"

