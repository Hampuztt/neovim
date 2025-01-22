#!/bin/bash

# Ensure the script is run with sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script with sudo:"
    echo "sudo $0"
    exit 1
fi

echo "Updating package lists..."
apt update

echo "Installing required dependencies..."

# Install fd (or fdfind and symlink to fd)
if ! command -v fd &>/dev/null && ! command -v fdfind &>/dev/null; then
    echo "Installing fd-find..."
    apt install -y fd-find
    mkdir -p ~/.local/bin
    ln -sf "$(which fdfind)" ~/.local/bin/fd
else
    echo "fd or fdfind already installed."
fi

# Install ripgrep
if ! command -v rg &>/dev/null; then
    echo "Installing ripgrep..."
    apt install -y ripgrep
else
    echo "ripgrep is already installed."
fi

# Install lazygit
if ! command -v lazygit &>/dev/null; then
    echo "Installing lazygit..."
    add-apt-repository -y ppa:lazygit-team/release
    apt update
    apt install -y lazygit
else
    echo "lazygit is already installed."
fi

# Install LuaRocks
if ! command -v luarocks &>/dev/null; then
    echo "Installing LuaRocks..."
    apt install -y luarocks
else
    echo "LuaRocks is already installed."
fi

# Install build tools for plugins
echo "Installing build essentials and developer tools..."
apt install -y build-essential gcc make cmake unzip curl git

# Install Node.js (for LSP servers)
if ! command -v node &>/dev/null; then
    echo "Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    apt install -y nodejs
else
    echo "Node.js is already installed."
fi

# Check if the `neovim` npm package is installed
if ! npm list -g neovim &>/dev/null; then
    echo "Installing the Neovim npm package..."
    npm install -g neovim
else
    echo "The Neovim npm package is already installed."
fi

if ! npm list -g tree-sitter-cli &>/dev/null; then
    echo "Installing the tree-sitter-cli package..."
    npm install -g tree-sitter-cli
else
    echo "The treesitter npm package is already installed."
fi

# Install Python 3 and pip
if ! command -v python3 &>/dev/null; then
    echo "Installing Python 3..."
    apt install -y python3 python3-pip
else
    echo "Python 3 is already installed."
fi

# Install pynvim (Python support for Neovim)
if ! pip3 list | grep pynvim &>/dev/null; then
    echo "Installing pynvim via pip3..."
    pip3 install pynvim
else
    echo "pynvim is already installed."
fi

# Install Ruby and Neovim gem (optional for some plugins)
#if ! command -v ruby &>/dev/null; then
#    echo "Installing Ruby..."
#    apt install -y ruby-full
#else
#    echo "Ruby is already installed."
#fi

#if ! gem list | grep neovim &>/dev/null; then
#    echo "Installing neovim gem..."
#    gem install neovim
#else
#    echo "Neovim gem is already installed."
#fi

echo "All dependencies have been installed!"

