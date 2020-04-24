#!/bin/bash

###############################################################
# INSTALL ADDITIONAL CLI AND GUI SOFTWARE ON UBUNTU OR DEBIAN #
###############################################################

# | THIS SCRIPT IS TESTED CORRECTLY ON  |
# |-------------------------------------|
# | OS             | Test | Last test   |
# |----------------|------|-------------|
# | Debian 10.3    | OK   | 10 Mar 2020 |
# |                | OK   | 10 Mar 2020 |
# |                | OK   | 10 Mar 2020 |
# |                | OK   | 10 Mar 2020 |
# |                | OK   | 10 Mar 2020 |
# |                | OK   | 10 Mar 2020 |


print_help {
         echo "Please make sure of your selections -- they are unreversible"
         echo "This will update, install and tweak your debian install"
         }



# 1. KEEP UBUNTU OR DEBIAN UP TO DATE

########SELECT FASTEST REPO ###################################
echo "Setting fastest mirror, Please wait..."

sudo apt-get -y install apt-get install netselect-ap

mv /etc/apt/sources.list /etc/apt/sources.list.bak

sudo netselect-apt

sed '/deb/s/$/ non-free/' /etc/apt/sources.list

#echo deb http://deb.debian.org/debian/ buster main contrib non-free >
/etc/apt/sources.list
#echo deb-src http://deb.debian.org/debian/ buster main >
/etc/apt/sources.list

#echo deb http://security.debian.org/debian-security buster/updates main
contrib non-free > /etc/apt/sources.list
#echo deb-src http://security.debian.org/debian-security buster/updates
main > /etc/apt/sources.list

#echo deb http://deb.debian.org/debian/ buster-updates main contrib
non-free > /etc/apt/sources.list
#echo deb-src http://deb.debian.org/debian/ buster-updates main >
/etc/apt/sources.list

################################################################
echo "updating, upgrading, Please waite..."

sudo apt-get -y clean                                # REMOVE UPDATE DB
sudo apt-get -y autoclean                            # REMOVE NOT UNUSED PACKAGES
sudo apt-get -y autoremove                           # REMOVE DEB INSTALL FILES
sudo apt-get -y update                               # UPDATE LATEST PKG
sudo apt-get -y upgrade                              # UPGRADE PKG
sudo apt-get -y dist-upgrade                         # UPGRADE DISTRIBUTION

################################################################

# 1.5 INSTALL FIRMWARE AND MICROCODE

sudo apt-get -y install firmware-misc-nonfree
sudo apt-get -y install intel-microcode
sudo apt-get -y install iucode-tool
sudo apt-get -y install ttf-mscorefonts-installer rar unrar libavcodec-extra gstreamer1.0-libav gstreamer1.0-plugins-ugly gstreamer1.0-vaapi

################################################################

# 2. CLI SOFTWARE

echo "we will install software, Interactive (I) or you Trust us (T) or
get List (L) ?"

sudo apt-get install -y build-essential cmake                              # DEVELOPMENT TOOLS
sudo apt-get install -y p7zip p7zip-full unrar-free unzip                  # FILE ARCHIVERS
sudo apt-get install -y htop lshw wget locate curl htop net-tools rsync    # UTILITIES
sudo apt-get install -y tmux                                               # TERMINAL MULTIPLEXER
sudo apt-get install -y nano                                               # TEXT EDITORS
sudo apt-get install -y git                                                # VCS
sudo apt-get install -y okular                                             # PDF MANIPULATION
sudo apt-get install -y ffmpeg                                             # VIDEO MANIPULATION
sudo apt-get install -y default-jdk                                        # JAVA DEVELOPMENT KIT (JDK)
sudo apt-get install -y wavemon                                            # NET ONLY FOR Wireless


###############################################################

# 3. GUI SOFTWARE

sudo apt-get install -y gparted                                                 # PARTITION TOOL
sudo apt-get install -y gvfs-backends ntfs-3g                                   # USERSPACE VIRTUAL FILESYSTEM
sudo apt-get install -y xarchiver                                               # FILE ARCHIVER FRONTEND
sudo apt-get install -y galculator                                              # SCIENTIFIC CALCULATOR
sudo apt-get install -y vlc                                                     # VIDEO AND AUDIO PLAYER
#sudo apt-get install -y vscode studio                                          # TEXT EDITOR
#wget https://go.microsoft.com/fwlink/?LinkID=760868                            # vscode studio
sudo apt-get install -y blender imagemagick inkscape                            # GRAPHICS EDITORS
sudo apt-get install -y gimp gimp-data gimp-plugin-registry gimp-data-extras -y # GIMP WTH EXTRAS
sudo apt-get install -y audacity                                                # AUDIO EDITOR
sudo apt-get install -y openshot                                                # VIDEO EDITOR
sudo apt-get install -y filezilla                                               # FTP/FTPS/SFTP CLIENT
sudo apt-get install -y libreoffice                                             # OFFICE (optional, not last version)
sudo apt-get install -y google-chrome-stable
sudo apt-get install -y kazam                                                   # SCREENCAST (optional)

###############################################################

# 3.5 INSTALL VIDEO DRIVERS

#Determine if we have nvidia or amd
#
#get nvidia deb
#get amd deb

###############################################################

# 4. SERVICES

sudo apt-get install -y ufw                                                      # firewall
sudo systemctl start ufw
sudo systemctl enable ufw

sudo apt-get install tlp                                                         # battery saver
sudo systemctl start tlp
sudo systemctl enable tlp


##############################################################

# 5. TWEAKS

sudo sysctl vm.swappiness=10                                                    # SET SWAPINESS
sudo hdparm -W 1 /dev/sda                                                       # SET DISK CACHE ON



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