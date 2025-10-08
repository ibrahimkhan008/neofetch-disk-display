#!/bin/bash
CONFIG_FILE="$HOME/.config/neofetch/config.conf"

echo "[*] Checking Neofetch..."
if ! command -v neofetch >/dev/null 2>&1; then
    echo "[+] Neofetch not found, installing..."
    if [ "$EUID" -ne 0 ]; then
        # Not running as root
        if command -v sudo >/dev/null 2>&1; then
            sudo apt update && sudo apt install -y neofetch
        else
            echo "[!] Please run this script as root or install sudo."
            exit 1
        fi
    else
        apt update && apt install -y neofetch
    fi
else
    echo "[✓] Neofetch is already installed."
fi

# Ensure config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "[+] Generating default Neofetch config..."
    mkdir -p "$HOME/.config/neofetch"
    neofetch --config none --generate "$CONFIG_FILE"
fi

# Check if the line exists
if grep -q '^[#]*\s*info "Disk" disk' "$CONFIG_FILE"; then
    if grep -q '^#.*info "Disk" disk' "$CONFIG_FILE"; then
        echo "[*] Found commented 'info \"Disk\" disk'. Uncommenting..."
        sed -i 's/^#\s*info "Disk" disk/info "Disk" disk/' "$CONFIG_FILE"
        echo "[✓] Uncommented line successfully."
    else
        echo "[✓] 'info \"Disk\" disk' line already active."
    fi
else
    echo "[*] Adding 'info \"Disk\" disk' after 'info \"Memory\" memory'..."
    sed -i '/info "Memory" memory/a info "Disk" disk' "$CONFIG_FILE"
    echo "[✓] Line added successfully."
fi

echo "[✓] All done! Run 'neofetch' to see the changes."
