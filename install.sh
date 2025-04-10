#!/bin/bash

# Installer for Password Strength Checker
SCRIPT_NAME="password_checker.sh"
INSTALL_PATH="/usr/local/bin/password-checker"
REQUIRED_CMDS=("dialog" "curl" "xclip" "awk" "sha1sum" "iconv")

echo "🔐 Installing Password Strength Checker..."

# Function to install a package if missing
install_if_missing() {
    for cmd in "${REQUIRED_CMDS[@]}"; do
        if ! command -v "$cmd" &>/dev/null; then
            echo "❗ Required tool '$cmd' is missing."

            read -rp "➡️  Do you want to install '$cmd'? (y/n): " answer
            if [[ "$answer" == [Yy]* ]]; then
                if command -v apt &>/dev/null; then
                    sudo apt update && sudo apt install -y "$cmd"
                elif command -v pacman &>/dev/null; then
                    sudo pacman -Sy "$cmd"
                elif command -v dnf &>/dev/null; then
                    sudo dnf install -y "$cmd"
                elif command -v brew &>/dev/null; then
                    brew install "$cmd"
                else
                    echo "⚠️ Could not detect your package manager. Please install '$cmd' manually."
                fi
            else
                echo "⚠️ Skipping installation of '$cmd'. The script might not work properly."
            fi
        fi
    done
}

# Check and install dependencies
install_if_missing

# Install script
if [[ ! -f "$SCRIPT_NAME" ]]; then
    echo "❌ Error: '$SCRIPT_NAME' not found in the current directory."
    exit 1
fi

sudo cp "$SCRIPT_NAME" "$INSTALL_PATH"
sudo chmod +x "$INSTALL_PATH"
echo "✅ Script installed to: $INSTALL_PATH"

# Optional: Create desktop entry
read -rp "🖥️  Do you want to create a desktop launcher? (y/n): " desktop_choice
if [[ "$desktop_choice" == [Yy]* ]]; then
    DESKTOP_ENTRY="$HOME/.local/share/applications/password-checker.desktop"
    mkdir -p "$(dirname "$DESKTOP_ENTRY")"
    cat <<EOF > "$DESKTOP_ENTRY"
[Desktop Entry]
Name=Password Checker
Exec=$INSTALL_PATH
Icon=dialog-password
Type=Application
Terminal=true
Categories=Utility;Security;
EOF
    chmod +x "$DESKTOP_ENTRY"
    echo "📂 Desktop launcher created at: $DESKTOP_ENTRY"
fi

echo "🚀 Installation complete. Run the tool using: password-checker"
