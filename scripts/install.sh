#!/bin/bash
set -e

### CamXOS Installer ###
### Assumes: Arch Linus base system ###

echo "==> Installing CamXOS base system"

# Ensure script is not run as root user directly
if [ "$EUID" -eq 0 ]; then
	echo "Please run this script as a normal user"
	exit 1
fi

# Ask for sudo once
sudo -v

# Keep sudo alive
while true; do sudo -n true; sleep 60; done 2>/dev/null &

echo "==> Updating system"
sudo pacman -Syu --noconfirm

echo "==>Installing core packages"
sudo pacman -S --needed --noconfirm \
	base-devel \
	git \
	wayfire \
	wf-shell \
	wayfire-plugins-extra \
	foot \
	wofi \
	thunar \
	firefox \
	seatd \
	dbus \
	wlr-randr \
	kanshi

echo "==> Enabling required services"
sudo systemctl enable --now seatd
sudo usermod -aG seat $USER

echo "==> Creating config directories"
mkdir -p ~/.config

echo "==> Applying CamXOS configuration"
cp -r configs/wayfire ~/.config/
cp -r configs/waybar ~/.config/ || true
cp -r configs/wofi ~/.config/ || true
cp configs/bash/bash_profile ~/.bash_profile

echo "==> Setting permissions"
chmod +x ~/.bash_profile

echo "==> Installing Wayland environment variables"
if ! grep -q "XDG_SESSION_TYPE=wayland" ~/.profile 2>/dev/null; then
cat >> ~/.profile <<EOF
export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=CamXOS
export QT_QPA_PLATFORM=wayland
EOF
fi

echo "==> Installation complete"
echo
echo "IMPORTANT:"
echo " Log out and log back in for group changes to apply"
echo " Wayfire will start automatically on tty1"
echo
echo " Welcome to CamXOS"
