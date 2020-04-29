#!/bin/bash

###############################################################
# INSTALL ADDITIONAL CLI AND GUI SOFTWARE ON UBUNTU OR DEBIAN #
###############################################################

# | THIS SCRIPT IS TESTED CORRECTLY ON  |
# |-------------------------------------|
# | OS             | Test | Last test   |
# |----------------|------|-------------|
# | Debian 10.3    | OK   | 10 Mar 2020 |

print_help {
         echo "Please make sure of your selections -- they are unreversible"
         echo "This will update, install and tweak your debian install"
         }

########Modifying Repo ###################################

repo_mod () {
     #sed '/deb/s/$/ non-free/' /etc/apt/sources.list

echo deb http://deb.debian.org/debian/ buster main contrib non-free >/etc/apt/sources.list
echo deb-src http://deb.debian.org/debian/ buster main > /etc/apt/sources.list

echo deb http://security.debian.org/debian-security buster/updates main contrib non-free > /etc/apt/sources.list
echo deb-src http://security.debian.org/debian-security buster/updates main > /etc/apt/sources.list

echo deb http://deb.debian.org/debian/ buster-updates main contrib non-free > /etc/apt/sources.list
echo deb-src http://deb.debian.org/debian/ buster-updates main > /etc/apt/sources.list

echo deb http://deb.debian.org/debian buster-backports main > /etc/apt/sources.list
}

################################################################
echo "updating, upgrading, Please waite..."

function_name () {
<commands>
}

sudo apt -y clean                                # REMOVE UPDATE DB
sudo apt -y autoclean                            # REMOVE NOT UNUSED PACKAGES
sudo apt -y autoremove                           # REMOVE DEB INSTALL FILES
sudo apt -y update                               # UPDATE LATEST PKG
sudo apt -y upgrade                              # UPGRADE PKG
sudo apt -y dist-upgrade                         # UPGRADE DISTRIBUTION
sudo logrotate -vf /etc/logrotate.conf           # Force Rotate logs

################################################################

# 1.5 INSTALL FIRMWARE AND MICROCODE

sudo apt -y install firmware-misc-nonfree
sudo apt -y install intel-microcode
sudo apt -y install iucode-tool
sudo apt -y install ttf-mscorefonts-installer rar unrar libavcodec-extra gstreamer1.0-libav gstreamer1.0-plugins-ugly gstreamer1.0-vaapi

################################################################

# 2. CLI SOFTWARE

echo "we will install software, Interactive (I) or you Trust us (T) or
get List (L) ?"

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


###############################################################

# 3. GUI SOFTWARE

sudo apt -y install gparted                                                 # PARTITION TOOL
sudo apt -y install gvfs-backends ntfs-3g                                   # USERSPACE VIRTUAL FILESYSTEM
sudo apt -y install xarchiver                                               # FILE ARCHIVER FRONTEND
sudo apt -y install galculator                                              # SCIENTIFIC CALCULATOR
sudo apt -y install vlc                                                     # VIDEO AND AUDIO PLAYER
sudo apt -y install blender imagemagick inkscape                            # GRAPHICS EDITORS
sudo apt -y install gimp gimp-data gimp-plugin-registry gimp-data-extras -y # GIMP WTH EXTRAS
sudo apt -y install audacity                                                # AUDIO EDITOR
sudo apt -y install openshot                                                # VIDEO EDITOR
sudo apt -y install filezilla                                               # FTP/FTPS/SFTP CLIENT
sudo apt -y install libreoffice                                             # OFFICE (optional, not last version)
sudo apt -y install google-chrome-stable
sudo apt -y install kazam                                                   # SCREENCAST (optional)

wget https://go.microsoft.com/fwlink/?LinkID=760868 -p /opt/visualtmp/      ## vscode studio
dpkg -i /opt/visualtmp/*.deb
apt -y get install -f

###############################################################

# 3.5 INSTALL VIDEO DRIVERS

#Determine if we have nvidia or amd

lshw -numeric -C display | grep vendor
#get nvidia deb
#get amd deb

###############################################################

# 4. SERVICES

sudo apt -y install ufw                                                      # firewall
sudo systemctl start ufw
sudo systemctl enable ufw


#ask if a laptop

echo 'Is this a laptop ?'
sudo apt -y install tlp                                                      # battery saver
sudo systemctl start tlp
sudo systemctl enable tlp


##############################################################

# 5. TWEAKS

sudo sysctl vm.swappiness=10                                                 # SET SWAPINESS
sudo hdparm -W 1 /dev/sda                                                    # SET DISK CACHE ON

#set grub

nano /etc/default/grub

GRUB_TIMEOUT to 0

update-grub

#################################################################

if [ "$1" == "usage1" ]; then
     run_usage1
elif [ "$1" == "usage2" ]; then
     run_usage2
else
     echo "Usage: $0 usage1|usage2"
     echo " usage1: does something"
     echo " usage2: does something too"
fi

exit 0