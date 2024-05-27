system_type=$(uname -s)
system_arch=$(uname -m)

if [ "$system_type" = "Darwin" ]; then
    if [ "$system_arch" = "arm64" ]; then
        # Set PATH, MANPATH, etc., for Homebrew.
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    # === PATH START ===
    # Added by Toolbox App
    export PATH="$PATH:$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
    # protobuf
    case ":${PATH}:" in
        *:"/usr/local/opt/protobuf@3/bin":*) ;;
        *) export PATH="$(brew --prefix)/opt/protobuf@3/bin:$PATH" ;;
    esac
    # === PATH END ===
    export XDG_CONFIG_HOME="$HOME/.config"
fi
