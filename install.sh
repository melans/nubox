#!/usr/bin/env bash
set -euo pipefail

echo "Installing nubox..."

# Check requirements
for cmd in debootstrap systemd-nspawn; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Missing: $cmd"
        echo "Install with: sudo apt install debootstrap systemd-container"
        exit 1
    fi
done

# Install
INSTALL_DIR="${NUBOX_DIR:-$HOME/nubox}"
if [[ -d "$INSTALL_DIR/.git" ]]; then
    echo "Updating existing installation..."
    cd "$INSTALL_DIR" && git pull --quiet
else
    echo "Cloning nubox..."
    git clone --quiet https://github.com/melans/nubox.git "$INSTALL_DIR"
fi

chmod +x "$INSTALL_DIR/nubox"

# Symlink to PATH
if [[ -w /usr/local/bin ]]; then
    ln -sf "$INSTALL_DIR/nubox" /usr/local/bin/nubox
elif sudo -n true 2>/dev/null; then
    sudo ln -sf "$INSTALL_DIR/nubox" /usr/local/bin/nubox
else
    echo "Add to PATH manually: export PATH=\"$INSTALL_DIR:\$PATH\""
fi

echo ""
echo "nubox installed to $INSTALL_DIR"
echo ""
echo "Get started:"
echo "  nubox --setup    # interactive first-time setup"
echo "  nubox --new test # create your first box"
echo ""
