#!/bin/bash

command_exists() {
  # 检查命令是否存在
  if command -v "$1" >/dev/null 2>&1; then
    return 0  # 如果命令存在，返回0（在 Bash 中，0表示真）
  else
    echo -e "\033[31m$1 not installed!\033[0m"  # 如果命令不存在，打印错误信息
    return 1  # 返回1（在 Bash 中，1表示假）
  fi
}

dir_exists() {
  if [ -d "$1" ]; then
    return 0
  else
    echo -e "\033[41m$1 not exists, something was wrong!\033[0m"
    return 1
  fi
}

dir_not_exists() {
  if [ -d "$1" ]; then
    echo -e "\033[33m$1 already exists, please backup or delete it!\033[0m"
    return 1
  else
    return 0
  fi
}

file_exists() {
  if [ -f "$1" ]; then
    return 0
  else
    echo -e "\033[41m$1 not exists, something was wrong!\033[0m"
    return 1
  fi
}

file_not_exists() {
  if [ -f "$1" ]; then
    echo -e "\033[33m$1 already exists, please backup or delete it!\033[0m"
    return 1
  else
    return 0
  fi
}

link_folder() {
  if dir_exists "$1" && dir_not_exists "$2"; then
    ln -s "$1" "$(dirname "$2")"
    echo "$1 linked to "$(dirname $2)""
  fi
}

link_file() {
  if file_exists "$1" && file_not_exists "$2"; then
    ln -s "$1" "$2"
    echo "$1 linked to $2"
  fi
}

linux_install() {
  echo -e "\033[34mInstalling Linux config...\033[0m"
  # alacritty
  if command_exists alacritty; then
    link_folder ""$(pwd)"/linux/alacritty" "$HOME/.config/alacritty"
  fi
}

macosx_install() {
  echo -e "\033[34mInstalling macOS config...\033[0m"
  # alacritty
  if command_exists alacritty; then
    link_folder ""$(pwd)"/macos/alacritty" "$HOME/.config/alacritty"
  fi
  # zsh
  if command_exists zsh; then
    link_file ""$(pwd)"/macos/zshrc" "$HOME/.zshrc"
  fi
}

common_install() {
  echo -e "\033[34mInstalling common config...\033[0m"
  # tmux
  if command_exists tmux; then
    link_folder ""$(pwd)"/tmux" "$HOME/.config/tmux"
  fi
  # lazygit
  if command_exists lazygit; then
    link_folder ""$(pwd)"/lazygit" "$(lazygit --print-config-dir)"
  fi
  # bat
  if command_exists bat; then
    link_folder ""$(pwd)"/bat" "$HOME/.config/bat"
  fi
  # kitty
  if command_exists kitty; then
    link_folder ""$(pwd)"/kitty" "$HOME/.config/kitty"
  fi
}

os="${OSTYPE%%[^a-z]*}"

case "$os" in
  linux)
    linux_install
    common_install
    ;;
  darwin)
    macosx_install
    common_install
    ;;
  *)
    echo -e "\033[31m$os not supported!\033[0m"
    ;;
esac

echo -e "\033[34mConfig OK!\033[0m"
