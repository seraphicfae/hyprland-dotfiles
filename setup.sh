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
    while true; do
        read -n 1 -r -p "$(ask "Paru (AUR helper) is needed. Install it? [Y/n] ")" install_paru
        echo
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
            break
        elif [[ "$install_paru" =~ ^[Nn]$ ]]; then
            fail "Paru is required. Exiting..."
            exit 1
        else
            warn "Please enter Y or N."
        fi
    done
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
    
    while true; do
        read -n 1 -r -p "$(ask "Install missing packages? [Y/n] ")" install_missing
        echo
        install_missing="${install_missing:-y}"

        if [[ "$install_missing" =~ ^[Yy]$ ]]; then
            paru -S --noconfirm "${missing_packages[@]}"
            okay "Missing packages installed."
            break
        elif [[ "$install_missing" =~ ^[Nn]$ ]]; then
            warn "Skipped installing missing packages."
            break
        else
            warn "Please enter Y or N."
        fi
    done
else
    okay "All required packages are already installed."
    
    while true; do
        read -n 1 -r -p "$(ask "Update all packages? [Y/n] ")" update_all
        echo
        update_all="${update_all:-y}"

        if [[ "$update_all" =~ ^[Yy]$ ]]; then
            paru -Syu --noconfirm
            okay "Packages updated."
            break
        elif [[ "$update_all" =~ ^[Nn]$ ]]; then
            info "Skipping package update."
            break
        else
            warn "Please enter Y or N."
        fi
    done
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
while true; do
    read -n 1 -r -p "$(ask "Back up existing dotfiles? [Y/n] ")" backup_dotfiles
    echo
    backup_dotfiles="${backup_dotfiles:-y}"

    if [[ "$backup_dotfiles" =~ ^[Yy]$ ]]; then
        for folder in "${dotfile_paths[@]}"; do
            if [ -e "$HOME/$folder" ]; then
                info "Backing up $HOME/$folder"
                mv "$HOME/$folder" "$HOME/${folder}.bak"
                okay "Backed up $folder"
            fi
        done
        break
    elif [[ "$backup_dotfiles" =~ ^[Nn]$ ]]; then
        warn "Skipping backup of dotfiles."
        break
    else
        warn "Please enter Y or N."
    fi
done

# Copy dotfiles
while true; do
    read -n 1 -r -p "$(ask "Copy dotfiles to your home directory? [Y/n] ")" copy_dotfiles
    echo
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
        break
    elif [[ "$copy_dotfiles" =~ ^[Nn]$ ]]; then
        warn "Skipped dotfile installation"
        break
    else
        warn "Please enter Y or N."
    fi
done

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

while true; do
    read -n 1 -r -p "$(ask "Set up system services? [Y/n] ")" enable_services
    echo
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
        break
    elif [[ "$enable_services" =~ ^[Nn]$ ]]; then
        warn "Skipped service setup"
        break
    else
        warn "Please enter Y or N."
    fi
done

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

while true; do
    read -n 1 -r -p "$(ask "Reboot now to start using your new setup? [Y/n] ")" reboot_choice
    echo
    reboot_choice="${reboot_choice:-y}"

    if [[ "$reboot_choice" =~ ^[Yy]$ ]]; then
        info "Rebooting system..."
        sudo reboot
        break
    elif [[ "$reboot_choice" =~ ^[Nn]$ ]]; then
        note "Setup complete! Reboot when you're ready to use your new Hyprland setup."
        break
    else
        warn "Please enter Y or N."
    fi
done