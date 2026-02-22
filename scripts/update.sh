#!/bin/bash
set -e

### CamXOS updater ###
### Safe sytem + config update ###

echo "==> CamXOS Update Started"

# Must NOT be run as root
if [ "$EUID" -eq 0 ]; then
	echo "Run as normal user"
	exit 1
fi

# Ask for sudo once
sudo -v
while true; do sudo -n true; sleep 60; done 2>/dev/null &

CAMXOS_DIR="$HOME/camxos"

echo "==> Updating Arch system"
sudo pacman -Syu --noconfirm

#Ensure repo exists
if [ ! -d "$CAMXOS_DIR/.git" ]; then
	echo "ERROR: CamXOS repo not found at $CAMXOS_DIR"
	exit 1
fi

echo "==> Pulling latest CamXOS updates"
cd "$CAMXOS_DIR"
git pull --rebase

echo "==> Updating configuration files"

mkdir -p ~/.config

rsync -av --ignore-existing configs/wayfire/ ~/.config/wayfire/
rsync -av --ignore-existing configs/waybar/ ~/.config/waybar/ || true
rsync -av --ignore-existing configs/wofi/ ~/.config/wofi/ || true

# Update bash profile safely
if ! grep -q "CamXOS" ~/.bash_profile 2>/dev/null; then
	cp configs/bash/bash_profile ~/.bash_profile
fi

echo "==> Reloading Wayfire"
if pgrep -x wayfire >/dev/null; then
	pkill -USR2 wayfire || true
fi

echo
echo "==> CamXOS update complete"
echo "If kernel or drivers updated, reboot is recommended"
