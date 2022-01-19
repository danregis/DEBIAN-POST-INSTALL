#!/bin/bash

###############################################################
# INSTALL ADDITIONAL CLI AND GUI SOFTWARE ON UBUNTU OR DEBIAN #
###############################################################

# | THIS SCRIPT IS TESTED CORRECTLY ON  |
# |-------------------------------------|
# | OS             | Test | Last test   |
# |----------------|------|-------------|
# | Debian 10.3    |  OK  | 19 Jan 2022 | modified since
# |                |      |             |
# |                |      |             |
# |                |      |             |
# |----------------|------|-------------|

########Declare Function########################################

#1-ADD REPOS

#need to determine which distro is used (for now debian is by default)

add_repo () {
#sed '/deb/s/$/ non-free/' /etc/apt/sources.list

echo deb http://deb.debian.org/debian/ buster main contrib non-free >/etc/apt/sources.list
echo deb-src http://deb.debian.org/debian/ buster main >> /etc/apt/sources.list

echo deb http://security.debian.org/debian-security buster/updates main contrib non-free >> /etc/apt/sources.list
echo deb-src http://security.debian.org/debian-security buster/updates main >> /etc/apt/sources.list

echo deb http://deb.debian.org/debian/ buster-updates main contrib non-free >> /etc/apt/sources.list
echo deb-src http://deb.debian.org/debian/ buster-updates main >> /etc/apt/sources.list

echo deb http://deb.debian.org/debian buster-backports main >> /etc/apt/sources.list
}

################################################################


#2- CREATE AN UPDATE SCRIPT

updates () {

touch /bin/update
echo "apt -y clean" > /bin/update                        # REMOVE UPDATE DB
echo "apt -y autoclean" >> cat /bin/update               # REMOVE NOT UNUSED PACKAGES
echo "apt -y autoremove" >>  /bin/update                 # REMOVE DEB INSTALL FILES
echo "apt update" >> /bin/update                         # UPDATE LATEST PKG
echo "apt -y upgrade" >> /bin/update                     # UPGRADE PKG
echo "apt -y dist-upgrade" >> /bin/update                # UPGRADE DISTRIBUTION
echo "logrotate -vf /etc/logrotate.conf" >> /bin/update  # Force Rotate logs
chmod +x /bin/update
sh /bin/./update
}

################################################################

#3- INSTALL FIRMWARE AND MICROCODE

firmware () {

apt -y install firmware-misc-nonfree
apt -y install intel-microcode
apt -y install iucode-tool
apt -y install ttf-mscorefonts-installer rar unrar libavcodec-extra gstreamer1.0-libav gstreamer1.0-plugins-ugly gstreamer1.0-vaapi
}

################################################################

#4- CLI SOFTWARE

cli_install () {

apt -y install build-essential cmake                                   # DEVELOPMENT TOOLS
apt -y install p7zip p7zip-full unrar-free unzip                       # FILE ARCHIVERS
apt -y install htop lshw wget locate curl htop net-tools rsync cssh    # UTILITIES
apt -y install tmux                                                    # TERMINAL MULTIPLEXER
apt -y install nano                                                    # TEXT EDITORS
apt -y install git                                                     # VCS
apt -y install okular                                                  # PDF MANIPULATION
apt -y install ffmpeg                                                  # VIDEO MANIPULATION
apt -y install default-jdk                                             # JAVA DEVELOPMENT KIT (JDK)
apt -y install wavemon                                                 # NET ONLY FOR Wireless
apt -y install speetest-CLI                                            # Speed test tool
}

###############################################################

#5- GUI SOFTWARE

gui_install () {

apt -y install gparted                                                 # PARTITION TOOL
apt -y install gvfs-backends ntfs-3g                                   # USERSPACE VIRTUAL FILESYSTEM
apt -y install xarchiver                                               # FILE ARCHIVER FRONTEND
apt -y install galculator                                              # SCIENTIFIC CALCULATOR
apt -y install vlc                                                     # VIDEO AND AUDIO PLAYER
apt -y install mpv                                                     # VIDEO AND AUDIO PLAYER
apt -y install blender imagemagick inkscape                            # GRAPHICS EDITORS
apt -y install gimp gimp-data gimp-plugin-registry gimp-data-extras -y # GIMP WTH EXTRAS
apt -y install audacity                                                # AUDIO EDITOR
apt -y install openshot                                                # VIDEO EDITOR
apt -y install filezilla                                               # FTP/FTPS/SFTP CLIENT
apt -y install libreoffice                                             # OFFICE (optional, not last version)
apt -y install firefox
apt -y install kazam                                                   # SCREENCAST (optional)
apt -y lshw                                                            # Information about hardware configuration 
}

###############################################################

#6- INSTALL .DEB PACKAGES

deb_install () {

wget https://github.com/VSCodium/vscodium/releases/download/1.48.2/codium_1.48.2-1598439200_amd64.deb -O /opt/  #visual studio code foos version
cd /opt/
dpkg -i codium*.deb
apt-get install -f 
}

###############################################################

#7- INSTALL VIDEO DRIVERS

#Determine if we have nvidia or amd

##video = $(lshw -numeric -C display | grep vendor)

##if [ "$video" == "nvidia" ];
##     sudo add-apt-repository ppa:graphics-drivers/ppa -y
##     sudo apt update
##     sudo apt install nvidia-driver
##elif [ "$1" == "amd" ]; then
##     sudo add-apt-repository ppa:oibaf/graphics-drivers -y
##     sudo apt update
##     sudo apt install amdgpu-pro
##fi
#need to catch exception

###############################################################

#8- SERVICES

#read -p "would you like to activate firewall (y/n)?" choice
#case "$choice" in 
#  y|Y ) echo "activating firewall...";apt -y install ufw; systemctl start ufw; systemctl enable ufw;; # Firewall
#  n|N ) echo "Ok, continuing...";;
#  * ) echo "invalid";;
#esac

###############################################################

#9- ask if a laptop

#read -p "Is this a laptop (y/n)?" choice
#case "$choice" in 
#  y|Y ) echo "installing Batt. saver..."; apt -y install tlp; systemctl start tlp; systemctl enable tlp;; # batt saver
#  n|N ) echo "Ok, continuing....";;
#  * ) echo "invalid";;
#esac

###############################################################

#10- TWEAKS

#echo /etc/sysctl.conf >> vm.swappiness=10                               # Set swappiness

#hdparm -W 1 /dev/sda                                                    # SET DISK CACHE ON

#remove time stamp on fstab

# /etc/fstab add noatime after ro

#set grub

#nano /etc/default/grub

#GRUB_TIMEOUT to 0

#update-grub


###############################################################


PS3='Make your selection: '
foods=("Add_Repo" "Updates" "Firmware" "CLI_Soft" "GUI_Soft" "DEB_pkg" "GPU_Drivers" "Firewall" "Laptop" "Tweaks" "Quit")
select fav in "${foods[@]}"; do
    case $fav in
        "Add_Repo")
            echo "$fav: adds repos from debian contrib non-free"
            # optionally call a function or run some code here
            add_repo 
            ;;
        "Updates")
            echo "$fav: will create an update script called update you can call from any terminal"
            # optionally call a function or run some code here
            updates
            ;;
        "Firmware")
            echo "$fav: install firmware needed"
            # optionally call a function or run some code here
            firmware
            ;;
        "CLI_Soft")
            echo "$fav: install terminal essential apps"
            # optionally call a function or run some code here
            cli_install
            ;;
        "GUI_Soft")
            echo "$fav: install graphical essential apps"
            # optionally call a function or run some code here
            gui_install
            ;;
        "DEB_pkg")
            echo "$fav: install debian pkg needed"
            # optionally call a function or run some code here
            deb_install
            ;;
        "GPU_Drivers")
            echo "$fav: install GPU drivers nvidia/amd"
            # optionally call a function or run some code here
            ;;
        "Firewall")
            echo "$fav: install firewall and activates it"
            # optionally call a function or run some code here
            ;;
        "Laptop")
            echo "$fav: install battery saver"
            # optionally call a function or run some code here
            ;;
         "Tweaks")
            echo "$fav: install a couple of tweaks to speed up your computer"
            # optionally call a function or run some code here
            ;;
        "Quit")
            echo "User requested exit"
            exit
            ;;
        *) echo "invalid option $REPLY";;


esac
done