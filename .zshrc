# === PATH SETTINGS ===
case ":${PATH}:" in
    *:"$HOME/.local/bin":*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
esac
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$("$HOME/miniconda3/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
        . "$HOME/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="$HOME/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
# rust
. "$HOME/.cargo/env"
# golang
case ":${PATH}:" in
    *:"$HOME/go/bin":*) ;;
    *) export PATH="$HOME/go/bin:$PATH" ;;
esac
# node version manager
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
    *":$PNPM_HOME:"*) ;;
    *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# node_modules
case ":${PATH}:" in
    *:"./node_modules/.bin":*) ;;
    *) export PATH="./node_modules/.bin:$PATH" ;;
esac

# === other enviroment variable ===
export EDITOR='vim'
export GPG_TTY=$(tty)
if command -v bat >/dev/null 2>&1; then
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

# === OH MY ZSH ===
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="pi"

unsetopt autocd

HISTSIZE=50000

plugins=(
    git
    docker
    docker-compose
    autojump
    zsh-syntax-highlighting
    zsh-autosuggestions
)
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src

source $ZSH/oh-my-zsh.sh

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPTS="
--height=60%
--reverse
--cycle
--color=dark
--color=fg:-1,bg:-1,hl:#5fff87,fg+:-1,bg+:-1,hl+:#ffaf5f
--color=info:#af87ff,prompt:#5fff87,pointer:#ff87d7,marker:#ff87d7,spinner:#ff87d7
--bind 'ctrl-/:change-preview-window(down|hidden|),ctrl-y:preview-half-page-up,ctrl-e:preview-half-page-down,ctrl-f:page-down,ctrl-b:page-up'
"
export FZF_COMPLETION_TRIGGER='**'
_fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" . "$1"
}

_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'exa -aT -I .git --icons -L 2 {} | head -200'   "$@" ;;
    export|unset) fzf --preview "eval 'echo \$'{}"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview 'bat {}'                   "$@" ;;
  esac
}

# github copilot cli
type github-copilot-cli > /dev/null 2>&1 && eval "$(github-copilot-cli alias -- "$0")"

# === alias ===
alias lg="lazygit"
alias icat="kitten icat"
alias lz="eza --classify --long --tree --color --icons --almost-all --level=1"

# === zsh completion ===
if type brew &>/dev/null
then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

  autoload -Uz compinit
  compinit
fi

