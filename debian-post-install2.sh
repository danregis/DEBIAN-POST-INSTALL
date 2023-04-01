#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

add_repo() {
    apt update # added to ensure updates to package list are performed
    if ! command -v lsb_release &> /dev/null; then
        echo "lsb-release not found. Installing it now..."
        apt install -y lsb-release
    fi

    release_codename=$(lsb_release -sc)

    cat <<- EOF > /etc/apt/sources.list
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
    cat <<- EOF > /bin/update
#!/bin/bash
apt -y clean
apt -y autoclean
apt -y autoremove
apt update
apt -y upgrade
apt -y dist-upgrade
logrotate -vf /etc/logrotate.conf
rm $0 # add this line to remove script after execution
EOF
    chmod +x /bin/update
    /bin/update
}

firmware() {
    apt -y install firmware-misc-nonfree intel-microcode iucode-tool \
    "ttf-mscorefonts-installer" rar unrar libavcodec-extra gstreamer1.0-libav \
    gstreamer1.0-plugins-ugly gstreamer1.0-vaapi
}

cli_install() {
    apt -y install build-essential cmake p7zip p7zip-full unrar-free unzip \
    htop lshw wget locate curl htop net-tools rsync cssh tmux nano git okular \
    ffmpeg default-jdk wavemon speedtest-cli
}

gui_install() {
    apt -y install gparted gvfs-backends ntfs-3g xarchiver galculator vlc mpv \
    blender imagemagick inkscape gimp gimp-data gimp-plugin-registry \
    gimp-data-extras audacity openshot filezilla libreoffice firefox kazam "lshw"
}

deb_install() {
    apt install -y software-properties-common apt-transport-https curl
    curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
    add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
    apt update
    apt install -y "code"
}

gpu_drivers() {
    video=$(lshw -numeric -C display | grep vendor)

    if [[ "$video" == *"nvidia"* ]]; then
        add-apt-repository ppa:graphics-drivers/ppa -y
        apt update
        apt install -y nvidia-driver
    elif [[ "$video" == *"amd"* ]]; then
        add-apt-repository ppa:oibaf/graphics-drivers -y
        apt update
        apt install -y amdgpu-pro
    fi
}

firewall() {
    if [[ $(systemctl is-active ufw) != "active" ]]; then
        apt -y install ufw
        systemctl start ufw
    fi
    if [[ $(systemctl is-enabled ufw) != "enabled" ]]; then
        systemctl enable ufw
    fi
}

laptop() {
    if [[ $(systemctl is-active tlp) != "active" ]]; then
        apt -y install tlp
        systemctl start tlp
    fi
    if [[ $(systemctl is-enabled tlp) != "enabled" ]]; then
        systemctl enable tlp
    fi
}

tweaks() {
    echo "vm.swappiness=10" >> /etc/sysctl.conf
    # last option was cut off, so can't say anything about it
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
            tweaks
            ;;
        "Quit")
            break
            ;;
        *) echo "Invalid option $REPLY";;
    esac
done

echo "All done."
