#!/bin/bash

$AWESOME_AUR='https://aur.archlinux.org/awesome-git.git'
$I3COLOR_AUR='https://aur.archlinux.org/i3lock-color.git'
$SLACK_AUR='https://aur.archlinux.org/slack-desktop.git'
$SPOTIFY_AUR='https://aur.archlinux.org/spotify.git'
$TIMESHIFT_AUR='https://aur.archlinux.org/timeshift.git'
$VMWARE_KEYMAPS_AUR='https://aur.archlinux.org/vmware-keymaps.git'
$VMWARE_WORKSTATION_AUR='https://aur.archlinux.org/vmware-workstation.git'

function aur_install (){
	mkdir $HOME/.aur/ 2>/dev/null
	git clone $1 $HOME/.aur/$2
	makepkg -s $HOME/.aur/$2/PKGBUILD
	package_name=$(ls $HOME/.aur/$2/ | grep ".zst")
	sudo pacman -U $package_name
}
# Update and upgrade system
sudo pacman -Syu

# LTS kernel
if ! check 'linux-lts'; then
	sudo pacman -S linux-lts
	sudo pacman -R linux
	sudo grub-mkconfig -o /boot/grub/grub.cfg
	echo 'System reboot is needed to continue'
	sleep 5
	sudo reboot
fi

# Networking tools
network_packages=('networkmanager' 'network-manager-applet' 'network-manager-openvpn' 'nm-connection-editor' 'openvpn')
sudo pacman -S ${network_packages[*]}
sudo systemctl enable NetworkManager.service

# Misc
misc_packages=('git' 'cronie' 'curl' 'firefox' 'pcmanfm' 'tmux' 'terminator' 'wget')
sudo pacman -S ${misc_packages[*]}

# X server
x_packages=('xorg-server' 'nvidia-lts' 'nvidia-utils' 'sddm' 'arandr')
sudo pacman -S ${x_packages[*]}
sudo systemctl enable sddm.service

# Bluetooth and audio
audio_packages=('bluez' 'bluez-utils' 'blueman' 'pulseaudio' 'pulseaudio-bluetooth' 'pavucontrol')
sudo pacman -S ${audio_packages[*]}
sudo systemctl enable bluetooth.service

# Awesome DE
awesome_packages=('picom' 'rofi' 'gnome-screenshot')
sudo pacman -S ${awesome_packages[*]}
aur_install $AWESOME_AUR 'awesome-git'
aur_install $I3COLOR_AUR 'i3lock-color'

# Theme and fonts
themes_packages=('lxappearance' 'adwaita-icon-theme' 'arc-gtk-theme' 'arc-icon-theme' 'breeze-gtk' 'breeze-icons') 
sudo pacman -S ${themes_packages[*]}

# Backup retrieval
backup_packages=('restic' 'seahorse')
sudo pacman -S ${backup_packages[*]}
sudo restic -r sftp:remote_backup:/arch_backup restore latest --target /

# Nvim with plugins
nvim_packages=('neovim' 'python' 'python-pip' 'clangd')
sudo pacman -S ${nvim_packages[*]}
pip install python-lsp-server

sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

vim -c PlugInstall

# Misc AUR packages

aur_install $SLACK_AUR 'slack-desktop'
aur_install $SPOTIFY_AUR 'spotify'
aur_install $TIMESHIFT_AUR 'timeshift'
aur_install $VMWARE_KEYMAPS_AUR 'vmware-keymaps'
aur_install $VMWARE_WORKSTATION_AUR 'vmware-workstation'

