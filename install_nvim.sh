#!/bin/bash

# Define the local installation directory
INSTALL_DIR="$HOME/.local/bin"
NVIM_RUNTIME_DIR="$HOME/.local/share/nvim"
NVIM_BINARY_URL="https://github.com/neovim/neovim/releases/download/v0.11.2/nvim-linux-x86_64.tar.gz"

# Ensure the installation directories exist
mkdir -p "$INSTALL_DIR"
mkdir -p "$NVIM_RUNTIME_DIR"

# Download the latest precompiled Neovim binary
echo "Downloading the latest Neovim precompiled binary..."
curl -LO "$NVIM_BINARY_URL" || { echo "Failed to download Neovim binary."; exit 1; }

# Extract the tar.gz file
echo "Extracting Neovim binary..."
tar xzvf nvim-linux64.tar.gz || { echo "Failed to extract Neovim binary."; exit 1; }

# Move the Neovim binary to the local bin directory
echo "Installing Neovim to $INSTALL_DIR..."
mv nvim-linux64/bin/nvim "$INSTALL_DIR/nvim" || { echo "Failed to install Neovim binary."; exit 1; }

# Move the runtime files to the proper location
echo "Installing Neovim runtime files to $NVIM_RUNTIME_DIR..."
cp -r nvim-linux64/share/nvim/* "$NVIM_RUNTIME_DIR/" || { echo "Failed to install runtime files."; exit 1; }

# Clean up the extracted files
rm -rf nvim-linux64 nvim-linux64.tar.gz

# Add the local bin directory to PATH if not already present
if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
    echo "Added $INSTALL_DIR to PATH. Restart your shell or run 'source ~/.bashrc' to update the PATH."
fi

# Verify the installation
echo "Verifying Neovim installation..."
if "$INSTALL_DIR/nvim" --version &>/dev/null; then
    echo "Neovim successfully installed! Version:"
    "$INSTALL_DIR/nvim" --version | head -n 1
else
    echo "Failed to verify Neovim installation."
    exit 1
fi

