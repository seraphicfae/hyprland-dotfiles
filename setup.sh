#!/bin/bash

set -e

# Colors
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

echo -e "${GREEN}Hyprland Dotfiles Setup Script${RESET}"

# Check if paru is installed
if ! command -v paru &> /dev/null; then
    echo -e "${YELLOW}paru is not installed.${RESET}"
    read -p "Would you like to install paru? [Y/n] " install_paru
    install_paru=${install_paru:-Y}
    if [[ $install_paru =~ ^[Yy]$ ]]; then
        git clone https://aur.archlinux.org/paru.git
        cd paru
        makepkg -si
        cd ..
        rm -rf paru
    else
        echo -e "${RED}paru is required. Exiting.${RESET}"
        exit 1
    fi
fi

# Check if ~/.config exists
if [ ! -d "$HOME/.config" ]; then
    echo -e "${GREEN}~/.config does not exist. Creating it...${RESET}"
    mkdir -p "$HOME/.config"
    echo -e "${GREEN}~/.config created.${RESET}"
fi

# Prompt user to back up existing ~/.config
read -p "Would you like to back up your existing .config folder? [Y/n] " backup_config
backup_config=${backup_config:-Y}

if [[ $backup_config =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}Creating backup...${RESET}"
    cp -r "$HOME/.config" "$HOME/.config.bak"
    echo -e "${GREEN}Backup created at ~/.config.bak${RESET}"
fi

# Install packages via paru
echo -e "${GREEN}Installing required packages...${RESET}"
paru -S --needed \
    hyprland hyprlock hyprpicker xorg-xwayland qt5-wayland qt6-wayland gvfs gvfs-mtp mtpfs \
    xdg-user-dirs networkmanager network-manager-applet bluez bluez-utils blueman \
    pavucontrol vlc ffmpeg amberol gimp eog obs-studio vesktop-bin \
    zen-browser-bin vscodium-bin keepassxc flatpak nautilus fastfetch \
    noto-fonts-cjk noto-fonts-emoji noto-fonts-extra sddm sddm-theme-catppuccin \
    waybar swww slurp grim wl-clipboard rofi swaync nwg-look \
    ttf-jetbrains-mono-nerd papirus-icon-theme starship nushell \
    mission-center ranger vim cava kitty

# Copy config files
echo -e "${GREEN}Copying dotfiles to ~/.config...${RESET}"
cp -r .config/* ~/.config/

# Create and copy special folders
for folder in .icons .themes .vscode-oss .zen; do
    echo -e "${GREEN}Processing ${folder}...${RESET}"
    mkdir -p ~/${folder}
    cp -r ${folder}/* ~/${folder}/
done

echo -e "${GREEN}Starting essential services...${RESET}"

# Start NetworkManager
if systemctl is-enabled NetworkManager &> /dev/null; then
    sudo systemctl enable --now NetworkManager
else
    echo -e "${YELLOW}NetworkManager is not enabled. Starting it temporarily...${RESET}"
    sudo systemctl enable --now NetworkManager
fi

# Start Bluetooth
if systemctl is-enabled bluetooth &> /dev/null; then
    sudo systemctl enable --now bluetooth
else
    echo -e "${YELLOW}Bluetooth is not enabled. Starting it temporarily...${RESET}"
    sudo systemctl enable bluetooth
fi

# Start SDDM
if command -v sddm &> /dev/null; then
    echo -e "${GREEN}Starting SDDM (not starting)...${RESET}"
    sudo systemctl enable sddm
else
    echo -e "${RED}SDDM not found!${RESET}"
fi

# Change shell to Nushell if it's installed
if [[ -x /usr/bin/nu ]]; then
    echo -e "${GREEN}Setting Nushell as the default shell...${RESET}"
    chsh -s /usr/bin/nu
else
    echo -e "${YELLOW}Nushell not found at /usr/bin/nu. Skipping shell change.${RESET}"
fi

# Confirm success
echo -e "${GREEN}Dotfiles installed successfully.${RESET}"

# Prompt for reboot
read -p "Would you like to reboot now? [y/N] " reboot_choice
if [[ $reboot_choice =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Rebooting...${RESET}"
    reboot
else
    echo -e "${GREEN}Installation complete. Please reboot manually when ready.${RESET}"
fi