# Dotfiles

## MacOS

install [xcode](https://developer.apple.com/xcode/resources)

```bash
# install HomeBrew
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# install yadm
brew install yadm
# yadm apply
yadm clone https://github.com/eyebrowkang/dotfiles.git --no-bootstrap
yadm config local.class personal # work
yadm bootstrap
```

## Linux

### Debian or Ubuntu

**change password first when using aws, azure, etc.**
```bash
sudo passwd user
```

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y yadm curl git
echo "=== yadm init start ==="
yadm clone https://github.com/eyebrowkang/dotfiles.git --no-bootstrap
yadm config local.class server
yadm bootstrap
echo "=== yadm init ok ==="
chsh -s "$(which zsh)"
yadm alt
rm .zshrc.pre-oh-my-zsh
```

#### development server
```bash
yadm config local.class development
```
