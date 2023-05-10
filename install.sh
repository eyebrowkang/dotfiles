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
    echo -e "\033[31m$1 already exists, please backup or delete it!\033[0m"
    return 1
  else
    mkdir -p "$1"
    return 0
  fi
}

file_exists() {
  if [ -f "$1" ]; then
    return 0
  else
    echo -e "\033[31m$1 not exists, please backup or delete it!\033[0m"
    return 1
  fi
}

file_not_exists() {
  if [ -f "$1" ]; then
    echo -e "\033[31m$1 already exists, please backup or delete it!\033[0m"
    return 1
  else
    return 0
  fi
}

link_folder() {
  if dir_exists "$1" && dir_not_exists "$2"; then
    # 逐个遍历源目录中的文件，并为每个文件创建硬链接
    for src_file in "$1"/*; do
      if [ -f "$src_file" ]; then
        ln "$src_file" "$2"
      fi
    done

    echo "$1 all files linked to $2"
  fi
}

link_file() {
  if file_exists "$1" && file_not_exists "$2"; then
    ln "$1" "$2"
    echo "$1 linked to $2"
  fi
}

linux_install() {
  echo -e "\033[34mInstalling Linux config...\033[0m"
  # alacritty
  if command_exists alacritty; then
    link_folder "./alacritty/linux" "$HOME/.config/alacritty"
  fi
}

macosx_install() {
  echo -e "\033[34mInstalling macOS config...\033[0m"
  # alacritty
  if command_exists alacritty; then
    link_folder "./alacritty/macos" "$HOME/.config/alacritty"
  fi
  # zsh
  if command_exists zsh; then
    link_file "./zsh/macos/.zshrc" "$HOME/.zshrc"
  fi
}

common_install() {
  echo -e "\033[34mInstalling common config...\033[0m"
  # tmux
  if command_exists tmux; then
    link_folder "./tmux" "$HOME/.config/tmux"
  fi
  # lazygit
  if command_exists lazygit; then
    link_folder "./lazygit" "$(lazygit --print-config-dir)"
  fi
  # bat
  if command_exists bat; then
    link_folder "./bat" "$HOME/.config/bat"
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

