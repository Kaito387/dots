export EDITOR=vim
export PATH="$HOME/dev/tools:$PATH"

setopt autocd
setopt correct

alias ll='ls -alh'
alias gs='git status'
alias gl='git log --oneline --graph'

# fzf
[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && \
  source /usr/share/doc/fzf/examples/key-bindings.zsh
