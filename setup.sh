#!/usr/bin/env bash

set -e

# ─────────── Theme and functions ───────────
# I like pretty colors :3
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
BLUE="\e[34m"
MAGENTA="\e[35m"
CYAN="\e[36m"
WHITE="\e[37m"
BOLD="\e[1m"
RESET="\e[0m"

okay()  { echo -e "${BOLD}${GREEN}[ OK ]${RESET} $1"; }
info()  { echo -e "${BOLD}${BLUE}[ .. ]${RESET} $1"; }
ask()   { echo -e "${BOLD}${MAGENTA}[ ? ]${RESET} $1"; }
warn()  { echo -e "${BOLD}${YELLOW}[ ! ]${RESET} $1"; }
fail()  { echo -e "${BOLD}${RED}[ FAIL ]${RESET} $1"; }
debug() { echo -e "${BOLD}${CYAN}[DEBUG]${RESET} $1"; }
note()  { echo -e "${BOLD}${WHITE}[ NOTE ]${RESET} $1"; }

# Get the directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ─────────── Arch Linux check ───────────
if [ -f /etc/arch-release ]; then
    debug "This is an Arch-based distribution."
elif grep -qi "arch" /etc/os-release; then
    debug "This is an Arch-based distribution."
else
    fail "This is not an Arch-based distribution."
    exit 1
fi

# ─────────── SystemD check ───────────
if [ -d /run/systemd/system ]; then 
    debug "System is running systemd"
else 
    fail "System is not running systemd"
    exit 1
fi

clear
echo -e "${GREEN}${BOLD}"
cat << "EOF"
██╗  ██╗██╗   ██╗██████╗ ██████╗ ██╗      █████╗ ███╗   ██╗██████╗     ███████╗███████╗████████╗██╗   ██╗██████╗ 
██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗██║     ██╔══██╗████╗  ██║██╔══██╗    ██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗
███████║ ╚████╔╝ ██████╔╝██████╔╝██║     ███████║██╔██╗ ██║██║  ██║    ███████╗█████╗     ██║   ██║   ██║██████╔╝
██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══██╗██║     ██╔══██║██║╚██╗██║██║  ██║    ╚════██║██╔══╝     ██║   ██║   ██║██╔═══╝ 
██║  ██║   ██║   ██║     ██║  ██║███████╗██║  ██║██║ ╚████║██████╔╝    ███████║███████╗   ██║   ╚██████╔╝██║     
╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝     ╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝                                                                                                                                                                                                                                   
EOF

echo -e "${RESET}"
note "This script will set up your Hyprland environment with dotfiles and packages."
echo

# ─────────── Paru Installation ───────────
if ! command -v paru &> /dev/null; then
    read -p "$(ask "Paru (AUR helper) is needed. Install it? [Y/n] ")" install_paru
    install_paru="${install_paru:-y}"

    if [[ "$install_paru" =~ ^[Yy]$ ]]; then
        git clone https://aur.archlinux.org/paru.git
        cd paru && makepkg -si && cd ..
        rm -rf paru
        if command -v paru &> /dev/null; then
            okay "Paru installed successfully"
        else
            fail "Something went wrong with installing paru."
            exit 1
        fi
    else
        fail "Paru is required. Exiting..."
        exit 1
    fi
else
    okay "Paru is already installed."
fi

# ─────────── Package Installation ───────────
sleep 2
clear
echo -e "${GREEN}${BOLD}"
cat << "EOF"
██████╗  █████╗  ██████╗██╗  ██╗ █████╗  ██████╗ ███████╗    ██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗     
██╔══██╗██╔══██╗██╔════╝██║ ██╔╝██╔══██╗██╔════╝ ██╔════╝    ██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║     
██████╔╝███████║██║     █████╔╝ ███████║██║  ███╗█████╗      ██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║     
██╔═══╝ ██╔══██║██║     ██╔═██╗ ██╔══██║██║   ██║██╔══╝      ██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║     
██║     ██║  ██║╚██████╗██║  ██╗██║  ██║╚██████╔╝███████╗    ██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗
╚═╝     ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝    ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝                                                                                                                                                                                                                                                                                                                          
EOF

echo -e "${RESET}"

# Packages needed for dotfiles (and some that I use :3)
required_packages=(
    hyprland hyprlock hyprpicker xorg-xwayland qt5-wayland qt6-wayland gvfs gvfs-mtp mtpfs xdg-user-dirs networkmanager network-manager-applet bluez bluez-utils 
    blueman pavucontrol vlc ffmpeg amberol gimp eog obs-studio vesktop-bin zen-browser-bin vscodium-bin keepassxc flatpak nautilus-open-any-terminal noto-fonts-cjk 
    noto-fonts-emoji noto-fonts-extra ttf-jetbrains-mono-nerd sddm sddm-theme-catppuccin waybar swww slurp grim wl-clipboard rofi swaync nwg-look papirus-icon-theme 
    starship zsh zoxide fzf fd bat mission-center ranger neovim cava kitty fastfetch
)

# Filter out packages that are already installed
missing_packages=()
for pkg in "${required_packages[@]}"; do
    if ! pacman -Qq "$pkg" &>/dev/null; then
        missing_packages+=("$pkg")
    fi
done

if (( ${#missing_packages[@]} > 0 )); then
    info "Found ${#missing_packages[@]} missing packages"
    read -p "$(ask "Install missing packages? [Y/n] ")" install_missing
    install_missing="${install_missing:-y}"

    if [[ "$install_missing" =~ ^[Yy]$ ]]; then
        paru -S --noconfirm "${missing_packages[@]}"
        okay "Missing packages installed."
    else
        warn "Skipped installing missing packages."
    fi
else
    okay "All required packages are already installed."
    read -p "$(ask "Update all packages? [Y/n] ")" update_all
    update_all="${update_all:-y}"

    if [[ "$update_all" =~ ^[Yy]$ ]]; then
        paru -Syu --noconfirm
        okay "Packages updated."
    fi
fi

# ─────────── Dotfile(s) Installation ───────────
sleep 2
clear
echo -e "${GREEN}${BOLD}"
cat << "EOF"
██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗    ██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗     
██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝    ██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║     
██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗      ██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║     
██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝      ██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║     
██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗    ██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗
╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝    ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝                                                                                                                                                                                                                                                                                                                                                                                                                                    
EOF

echo -e "${RESET}"

declare -a dotfile_paths=(".config" ".zen" ".icons" ".themes" ".vscode-oss")

# Backup existing dotfiles
read -p "$(ask "Back up existing dotfiles? [Y/n] ")" backup_dotfiles
backup_dotfiles="${backup_dotfiles:-y}"

if [[ "$backup_dotfiles" =~ ^[Yy]$ ]]; then
    for folder in "${dotfile_paths[@]}"; do
        if [ -e "$HOME/$folder" ]; then
            info "Backing up $HOME/$folder"
            mv "$HOME/$folder" "$HOME/${folder}.bak"
            okay "Backed up $folder"
        fi
    done
fi

# Copy dotfiles
read -p "$(ask "Copy dotfiles to your home directory? [Y/n] ")" copy_dotfiles
copy_dotfiles="${copy_dotfiles:-y}"

if [[ "$copy_dotfiles" =~ ^[Yy]$ ]]; then
    for folder in "${dotfile_paths[@]}"; do
        if [ -d "$DOTFILES_DIR/$folder" ]; then
            mkdir -p "$HOME/$folder"
            info "Copying $folder"
            cp -rf "$DOTFILES_DIR/$folder/"* "$HOME/$folder/"
            okay "Copied $folder"
        else
            warn "$DOTFILES_DIR/$folder not found, skipping"
        fi
    done
else
    warn "Skipped dotfile installation"
fi

# ─────────── Services and Setup ───────────
sleep 2
clear
echo -e "${GREEN}${BOLD}"
cat << "EOF"
███████╗███████╗██████╗ ██╗   ██╗██╗ ██████╗███████╗███████╗
██╔════╝██╔════╝██╔══██╗██║   ██║██║██╔════╝██╔════╝██╔════╝
███████╗█████╗  ██████╔╝██║   ██║██║██║     █████╗  ███████╗
╚════██║██╔══╝  ██╔══██╗╚██╗ ██╔╝██║██║     ██╔══╝  ╚════██║
███████║███████╗██║  ██║ ╚████╔╝ ██║╚██████╗███████╗███████║
╚══════╝╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚═╝ ╚═════╝╚══════╝╚══════╝                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
EOF

echo -e "${RESET}"

read -p "$(ask "Set up system services? [Y/n] ")" enable_services
enable_services=${enable_services:-y}

if [[ "$enable_services" =~ ^[Yy]$ ]]; then
    # NetworkManager
    info "Setting up NetworkManager..."
    sudo systemctl enable --now NetworkManager
    okay "NetworkManager configured"

    # Bluetooth
    info "Setting up Bluetooth..."
    sudo systemctl enable --now bluetooth
    okay "Bluetooth configured"

    # SDDM
    info "Setting up SDDM display manager..."
    sudo systemctl enable sddm
    echo -e "[Theme]\nCurrent=catppuccin-mocha" | sudo tee /etc/sddm.conf > /dev/null
    okay "SDDM configured with Catppuccin theme"

    # Zsh setup
    if command -v zsh &>/dev/null; then
        if [[ "$SHELL" != "/usr/bin/zsh" ]]; then
            info "Setting Zsh as default shell..."
            chsh -s /usr/bin/zsh "$(whoami)"
            okay "Default shell changed to Zsh"
        fi

        # Zsh configuration
        echo 'export ZDOTDIR="$HOME/.config/zsh"' > "$HOME/.zshenv"
        mkdir -p "$HOME/.config/zsh"
        
        if [[ ! -d "$HOME/.config/zsh/antidote" ]]; then
            info "Installing Zsh plugin manager..."
            git clone --depth=1 https://github.com/mattmc3/antidote.git "$HOME/.config/zsh/antidote"
            okay "Antidote plugin manager installed"
        fi
    fi
else
    warn "Skipped service setup"
fi

# ─────────── Done! ───────────
sleep 2
clear
echo -e "${GREEN}${BOLD}"
cat << "EOF"
██████╗  ██████╗ ███╗   ██╗███████╗██╗
██╔══██╗██╔═══██╗████╗  ██║██╔════╝██║
██║  ██║██║   ██║██╔██╗ ██║█████╗  ██║
██║  ██║██║   ██║██║╚██╗██║██╔══╝  ╚═╝
██████╔╝╚██████╔╝██║ ╚████║███████╗██╗
╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚══════╝╚═╝                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
EOF

echo -e "${RESET}"
okay "Setup complete!"

read -p "$(ask "Reboot now to start using your new setup? [Y/n] ")" reboot_choice
reboot_choice="${reboot_choice:-y}"

if [[ "$reboot_choice" =~ ^[Yy]$ ]]; then
    info "Rebooting system..."
    sudo reboot
else
    note "Setup complete! Reboot when you're ready to use your new Hyprland setup."
fi