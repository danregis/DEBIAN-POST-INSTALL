#!/usr/bin/env bash

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

add_repo() {
    sudo apt update
    if ! command -v lsb_release &> /dev/null; then
        echo "lsb-release not found. Installing it now..."
        sudo apt install -y lsb-release
    fi

    release_codename=$(lsb_release -sc)

    sudo tee /etc/apt/sources.list > /dev/null << EOF
deb http://deb.debian.org/debian/ $release_codename main contrib non-free
deb-src http://deb.debian.org/debian/ $release_codename main
deb http://security.debian.org/debian-security $release_codename/updates main contrib non-free
deb-src http://security.debian.org/debian-security $release_codename/updates main
deb http://deb.debian.org/debian/ $release_codename-updates main contrib non-free
deb-src http://deb.debian.org/debian/ $release_codename-updates main
deb http://deb.debian.org/debian $release_codename-backports main
EOF
}

updates() {
    sudo apt -y clean
    sudo apt -y autoclean
    sudo apt -y autoremove
    sudo apt update
    sudo apt -y upgrade
    sudo apt -y dist-upgrade
    sudo logrotate -vf /etc/logrotate.conf
    sudo rm -f /bin/update
}

firmware() {
    sudo apt -y install firmware-misc-nonfree intel-microcode iucode-tool \
    "ttf-mscorefonts-installer" rar unrar libavcodec-extra gstreamer1.0-libav \
    gstreamer1.0-plugins-ugly gstreamer1.0-vaapi
}

cli_install() {
    sudo apt -y install build-essential cmake p7zip p7zip-full unrar-free unzip \
    htop lshw wget locate curl net-tools rsync tmux nano git ffmpeg \
    default-jdk wavemon speedtest-cli
}

gui_install() {
    sudo apt -y install gparted galculator vlc mpv blender imagemagick inkscape gimp \
    gimp-data gimp-plugin-registry gimp-data-extras audacity openshot filezilla \
    libreoffice firefox
}

deb_install() {
    sudo apt install -y software-properties-common apt-transport-https curl
    curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
    sudo apt update
    sudo apt install -y "code"
}

gpu_drivers() {
    video=$(lshw -numeric -C display | grep vendor)

    if [[ "$video" == *\"nvidia"* ]]; then
        sudo add-apt-repository ppa:graphics-drivers/ppa -y
        sudo apt update
        sudo apt install -y nvidia-driver
    elif [[ "$video" == *"amd"* ]]; then
        sudo add-apt-repository ppa:oibaf/graphics-drivers -y
        sudo apt update
        sudo apt install -y amdgpu-pro
    fi
}

firewall() {
    if [[ $(systemctl is-active ufw) != "active" ]]; then
        sudo apt -y install ufw
        sudo systemctl start ufw
    fi
    if [[ $(systemctl is-enabled ufw) != "enabled" ]]; then
        sudo systemctl enable ufw
    fi
}

tweaks() {
    echo "Tweaks applied: none"
}

laptop() {
    if ! command -v tlp &> /dev/null; then
        echo "tlp not found. Skipping laptop tweaks."
        return
    fi
    
    if [[ $(systemctl is-active tlp) != "active" ]]; then
        sudo apt -y install tlp
        sudo systemctl start tlp
    fi
    if [[ $(systemctl is-enabled tlp) != "enabled" ]]; then
        sudo systemctl enable tlp
    fi
    tweaks
}

PS3='Make your selection: '
options=("Add_Repo" "Updates" "Firmware" "CLI_Soft" "GUI_Soft" "DEB_pkg" "GPU_Drivers" "Firewall" "Laptop_Tweaks" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Add_Repo")
            add_repo
            ;;
        "Updates")
            updates
            ;;
        "Firmware")
            firmware
            ;;
        "CLI_Soft")
            cli_install
            ;;
        "GUI_Soft")
            gui_install
            ;;
        "DEB_pkg")
            deb_install
            ;;
        "GPU_Drivers")
            gpu_drivers
            ;;
        "Firewall")
            firewall
            ;;
        "Laptop_Tweaks")
            laptop
            ;;
        "Quit")
            break
            ;;
        *) echo "Invalid option $REPLY";;
    esac
done

echo "All done."
