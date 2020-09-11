#!/bin/bash

###############################################################
# INSTALL ADDITIONAL CLI AND GUI SOFTWARE ON UBUNTU OR DEBIAN #
###############################################################

# | THIS SCRIPT IS TESTED CORRECTLY ON  |
# |-------------------------------------|
# | OS             | Test | Last test   |
# |----------------|------|-------------|
# | Debian 10.3    |  OK  | 10 Mar 2020 | modified since
# |                |      |             |
# |                |      |             |
# |                |      |             |
# |----------------|------|-------------|

########Modifying Repo ########################################

#need to determine which distro is used (for now debian is by default)

repo_mod () {
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

echo "updating, upgrading, Please be patient..."

#create a /bin file for auto updates
touch /bin/update
cat /bin/update  > sudo apt -y clean                        # REMOVE UPDATE DB
cat /bin/update  >> sudo apt -y autoclean                   # REMOVE NOT UNUSED PACKAGES
cat /bin/update  >> sudo apt -y autoremove                  # REMOVE DEB INSTALL FILES
cat /bin/update  >> sudo apt update                         # UPDATE LATEST PKG
cat /bin/update  >> sudo apt -y upgrade                     # UPGRADE PKG
cat /bin/update  >> sudo apt -y dist-upgrade                # UPGRADE DISTRIBUTION
cat /bin/update  >> sudo logrotate -vf /etc/logrotate.conf  # Force Rotate logs
sudo chmod +x /bin/update
sh ./update

################################################################

# 1.5 INSTALL FIRMWARE AND MICROCODE


firmware_update () {

sudo apt -y install firmware-misc-nonfree
sudo apt -y install intel-microcode
sudo apt -y install iucode-tool
sudo apt -y install ttf-mscorefonts-installer rar unrar libavcodec-extra gstreamer1.0-libav gstreamer1.0-plugins-ugly gstreamer1.0-vaapi
}

################################################################

# 2. CLI SOFTWARE

cli_install () {

sudo apt -y install build-essential cmake                              # DEVELOPMENT TOOLS
sudo apt -y install p7zip p7zip-full unrar-free unzip                  # FILE ARCHIVERS
sudo apt -y install htop lshw wget locate curl htop net-tools rsync    # UTILITIES
sudo apt -y install tmux                                               # TERMINAL MULTIPLEXER
sudo apt -y install nano                                               # TEXT EDITORS
sudo apt -y install git                                                # VCS
sudo apt -y install okular                                             # PDF MANIPULATION
sudo apt -y install ffmpeg                                             # VIDEO MANIPULATION
sudo apt -y install default-jdk                                        # JAVA DEVELOPMENT KIT (JDK)
sudo apt -y install wavemon                                            # NET ONLY FOR Wireless
sudo apt -y install speetest-CLI                                       # Speed test tool
}

###############################################################

# 3. GUI SOFTWARE

soft_install () {

sudo apt -y install gparted                                                 # PARTITION TOOL
sudo apt -y install gvfs-backends ntfs-3g                                   # USERSPACE VIRTUAL FILESYSTEM
sudo apt -y install xarchiver                                               # FILE ARCHIVER FRONTEND
sudo apt -y install galculator                                              # SCIENTIFIC CALCULATOR
sudo apt -y install vlc                                                     # VIDEO AND AUDIO PLAYER
sudo apt -y install mpv                                                     # VIDEO AND AUDIO PLAYER
sudo apt -y install blender imagemagick inkscape                            # GRAPHICS EDITORS
sudo apt -y install gimp gimp-data gimp-plugin-registry gimp-data-extras -y # GIMP WTH EXTRAS
sudo apt -y install audacity                                                # AUDIO EDITOR
sudo apt -y install openshot                                                # VIDEO EDITOR
sudo apt -y install filezilla                                               # FTP/FTPS/SFTP CLIENT
sudo apt -y install libreoffice                                             # OFFICE (optional, not last version)
sudo apt -y install firefox
sudo apt -y install kazam                                                   # SCREENCAST (optional)
sudo apt -y lshw                                                            # Information about hardware configuration 
}

###############################################################

# 3.2 Install some .deb packages

deb_install () {

wget https://github.com/VSCodium/vscodium/releases/download/1.48.2/codium_1.48.2-1598439200_amd64.deb -O /opt/  #visual studio code foos version
cd /opt/
dpkg -i codium*.deb
apt-get install -f 
}

###############################################################

# 3.5 INSTALL VIDEO DRIVERS

#Determine if we have nvidia or amd

video = $(lshw -numeric -C display | grep vendor)

if [ "$video" == "nvidia" ];
     sudo add-apt-repository ppa:graphics-drivers/ppa -y
     sudo apt update
     sudo apt install nvidia-driver
elif [ "$1" == "amd" ]; then
     sudo add-apt-repository ppa:oibaf/graphics-drivers -y
     sudo apt update
     sudo apt install amdgpu-pro
fi

###############################################################

# 4. SERVICES

read -p "would you like to activate firewall (y/n)?" choice
case "$choice" in 
  y|Y ) echo "activating firewall...";sudo apt -y install ufw; systemctl start ufw; systemctl enable ufw;; # Firewall
  n|N ) echo "Ok, continuing...";;
  * ) echo "invalid";;
esac

###############################################################

#ask if a laptop

read -p "Is this a laptop (y/n)?" choice
case "$choice" in 
  y|Y ) echo "installing Batt. saver...";sudo apt -y install tlp; systemctl start tlp; systemctl enable tlp;; # batt saver
  n|N ) echo "Ok, continuing....";;
  * ) echo "invalid";;
esac

##############################################################

# 5. TWEAKS

sudo echo /etc/sysctl.conf >> vm.swappiness=10                               # Set swappiness

sudo hdparm -W 1 /dev/sda                                                    # SET DISK CACHE ON

#remove time stamp on fstab

# /etc/fstab add noatime after ro

#set grub

#nano /etc/default/grub

#GRUB_TIMEOUT to 0

#update-grub

#################################################################

if [ "$1" == "Add_Repo" ]; then
     run_usage1
elif [ "$1" == "Updates" ]; then
     run_usage2
elif [ "$1" == "Firmware" ]; then
     run_usage3
elif [ "$1" == "CLI_Soft" ]; then
     run_usage3
elif [ "$1" == "GUI_Soft" ]; then
     run_usage3
elif [ "$1" == "DEB_pkg" ]; then
     run_usage3
elif [ "$1" == "GPU_Drivers" ]; then
     run_usage3
elif [ "$1" == "Firewall" ]; then
     run_usage3
elif [ "$1" == "Laptop" ]; then
     run_usage3
elif [ "$1" == "Tweaks" ]; then
     run_usage3
else
     echo "Usage: $0 Add_Repo|Updates|Firmware|CLI_Soft|GUI_Soft|DEB_pkg|GPU_Drivers|Firewall|Laptop|Tweaks"
     echo " Add Repo: adds repos from debian contrib non-free"
     echo " Updates: will create an update script you can call from any terminal"
     echo " Firmware: install firmware needed"
     echo " CLI_Soft: install terminal essential apps" 
     echo " GUI_Soft: install graphical essential apps" 
     echo " DEB_pkg: install debian pkg needed" 
     echo " GPU_Drivers: install GPU drivers nvidia/amd"
     echo " Firewall: install firewall and activates it" 
     echo " Laptop: install battery saver"
     echo " Tweaks: install a couple of tweaks to speed up your computer" 
fi

exit 0
