export EDITOR='vim'
export GPG_TTY=$(tty)

alias lg="lazygit"
alias icat="kitten icat"
alias lz="eza --classify --long --tree --color --icons --almost-all --level=1"

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

case ":${PATH}:" in
    *:"$HOME/.local/bin":*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
esac
case ":${PATH}:" in
    *:"./node_modules/.bin":*) ;;
    *) export PATH="./node_modules/.bin:$PATH" ;;
esac
