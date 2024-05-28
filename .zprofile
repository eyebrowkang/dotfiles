# This file only execute for login shell
system_type=$(uname -s)
system_arch=$(uname -m)

have_command() {
    if command -v "$1" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

if [ "$system_type" = "Darwin" ]; then
    # +==+ HomeBrew Start +==+
    brew_path=$(which brew 2>/dev/null)

    if [ -n "$brew_path" ]; then
        # Set PATH, MANPATH, etc., for Homebrew.
        eval "$($brew_path shellenv)"
        export PATH="$HOMEBREW_PREFIX/opt/protobuf@3/bin:$PATH"
    fi
    # +==+ HomeBrew End +==+

    if have_command bat; then
        export MANPAGER="sh -c 'col -bx | bat -l man -p'"
    fi

    export XDG_CONFIG_HOME="$HOME/.config"
fi

cargo_env="$HOME/.cargo/env"
if [[ -e "$cargo_env" ]]; then
    source $cargo_env
fi

go_bin="$HOME/go/bin"
if [[ -d "$go_bin" ]]; then
    export PATH="$go_bin:$PATH"
fi

if [[ -d "$HOME/miniconda3" ]]; then
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
fi

export NVM_DIR="$HOME/.nvm"
[ -d "$NVM_DIR" ] && [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

if have_command pnpm; then
    export PNPM_HOME="$HOME/.local/share/pnpm"
    mkdir -p $PNPM_HOME;
    export PATH="$PNPM_HOME:$PATH"
fi
